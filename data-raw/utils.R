# libraries ====
library(org.Hs.eg.db)
library(AnnotationDbi)
library(GenomicFeatures)
library(TxDb.Hsapiens.UCSC.hg19.knownGene)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(biomaRt)
library(UniProt.ws)
library(SomaDataIO)
library(dplyr)
library(tidyr)
library(data.table)
library(readxl)

#' Batch query Biomart
#'
#' @param mart Biomart object
#' @param attributes Attributes to retrieve
#' @param filters Filters to use
#' @param values Values for the filter
#' @param chunk_size Chunk size for batching
#'
#' @return A data frame with mapped IDs
biomaRt_getBM_batch <- function(mart, attributes, filters, values, chunk_size) {
    # Remove `filters` from `attributes` if it's already present
    if (filters %in% attributes) {
        attributes <- setdiff(attributes, filters)
    }

    # Split attributes into chunks, each including the filters column
    attribute_chunks <- lapply(
        split(attributes, ceiling(seq_along(attributes) / chunk_size)),
        function(chunk) c(filters, chunk)
    )

    # Loop over each chunk and fetch data, storing results in a list
    result_list <- list()
    for (i in seq_along(attribute_chunks)) {
        result <- tryCatch(
            biomaRt::getBM(
                attributes = attribute_chunks[[i]],
                filters = filters,
                values = values,
                mart = mart
            ),
            error = function(e) NULL # If a query fails, return NULL for this chunk
        )

        # Only add result to the list if it's not NULL and contains the identifier column
        if (!is.null(result) && filters %in% colnames(result)) {
            result_list[[i]] <- result
        }
    }

    # Sequentially join each data frame in result_list

    # Start with a data frame containing only the 'values' column
    # Use list(values) to handle cases where values might be different types,
    # but here we name it dynamically
    final_result <- data.frame(setNames(list(values), filters), stringsAsFactors = FALSE)

    # Sequentially join each data frame in result_list
    for (i in seq_along(result_list)) {
        if (!is.null(result_list[[i]])) {
            final_result <- dplyr::full_join(final_result, result_list[[i]], by = filters)
            # Free up memory after each join
            gc()
        }
    }

    return(final_result)
}
