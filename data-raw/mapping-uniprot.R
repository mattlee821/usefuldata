# Run mapping-olink.R and mapping-somalogic.R first to refresh the source tables.

olink_path <- "data-raw/raw_data/mapping_GRCh38.p14_olink.txt"
somalogic_path <- "data-raw/raw_data/mapping_GRCh38.p14_somalogic.txt"

shared_columns <- c(
  "UNIPROT", "uniprot_gn_id", "uniprot_gn_symbol",
  "entrezgene_id", "entrezgene_accession",
  "hgnc_id", "hgnc_symbol", "ensembl_gene_id", "external_gene_name",
  "gene_biotype", "CHR",
  "START_hg19", "END_hg19", "strand_hg19",
  "START_hg38", "END_hg38", "strand_hg38"
)

read_mapping <- function(path) {
  if (!file.exists(path)) {
    stop("Mapping source file not found: ", path, call. = FALSE)
  }

  mapping <- utils::read.delim(
    path,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    na.strings = c("", "NA")
  )
  missing_columns <- setdiff(shared_columns, names(mapping))
  if (length(missing_columns) > 0) {
    stop(
      "Mapping source is missing columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  mapping[shared_columns]
}

mapping_GRCh38_p14_uniprot <- dplyr::bind_rows(
  read_mapping(olink_path),
  read_mapping(somalogic_path)
) |>
  dplyr::filter(!is.na(UNIPROT), UNIPROT != "") |>
  dplyr::distinct() |>
  dplyr::arrange(UNIPROT, CHR, START_hg38, ensembl_gene_id) |>
  as.data.frame()

save(
  mapping_GRCh38_p14_uniprot,
  file = "data/mapping_GRCh38_p14_uniprot.rda",
  compress = "gzip"
)
