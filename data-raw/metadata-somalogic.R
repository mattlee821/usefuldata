list_example_adats <- function() {
  api_url <- "https://api.github.com/repos/SomaLogic/SomaLogic-Data/contents?ref=main"
  listing_path <- tempfile(fileext = ".json")
  on.exit(unlink(listing_path))

  status <- utils::download.file(api_url, listing_path, mode = "wb", quiet = FALSE)
  if (status != 0L || !file.exists(listing_path) || file.info(listing_path)$size == 0) {
    stop("Failed to retrieve the SomaLogic-Data repository listing.", call. = FALSE)
  }

  listing <- jsonlite::fromJSON(listing_path)
  required_fields <- c("name", "type", "download_url")
  if (!is.data.frame(listing) || !all(required_fields %in% names(listing))) {
    stop("Unexpected response from the SomaLogic-Data repository listing.", call. = FALSE)
  }

  is_example_adat <- !is.na(listing$type) &
    listing$type == "file" &
    !is.na(listing$name) &
    grepl("^example_data.*[.]adat$", listing$name)
  example_adats <- listing[is_example_adat, required_fields]
  if (nrow(example_adats) == 0L) {
    stop("No public example ADAT files were found in SomaLogic-Data.", call. = FALSE)
  }
  if (anyNA(example_adats$download_url) || any(example_adats$download_url == "")) {
    stop("A public example ADAT is missing its download URL.", call. = FALSE)
  }
  if (anyDuplicated(example_adats$name)) {
    stop("The repository listing contains duplicate example ADAT filenames.", call. = FALSE)
  }

  example_adats[order(example_adats$name), , drop = FALSE]
}

read_example_metadata <- function(source) {
  url <- source$download_url
  adat_path <- tempfile(fileext = ".adat")
  on.exit(unlink(adat_path))

  status <- utils::download.file(url, adat_path, mode = "wb", quiet = FALSE)
  if (status != 0L || !file.exists(adat_path) || file.info(adat_path)$size == 0) {
    stop("Failed to download SomaLogic example ADAT: ", url, call. = FALSE)
  }

  adat_md5 <- unname(tools::md5sum(adat_path))
  annotation <- SomaDataIO::getAnalyteInfo(SomaDataIO::read_adat(adat_path))
  required_columns <- c(
    "SeqId", "SomaId", "Target", "TargetFullName", "UniProt",
    "EntrezGeneID", "EntrezGeneSymbol", "Organism", "Type"
  )
  missing_columns <- setdiff(required_columns, names(annotation))
  if (length(missing_columns) > 0) {
    stop(
      "ADAT is missing expected annotation columns: ",
      paste(missing_columns, collapse = ", "),
      " (", source$name, ")",
      call. = FALSE
    )
  }

  annotation |>
    dplyr::filter(
      Organism == "Human",
      Type == "Protein",
      !grepl("internal use only", TargetFullName, ignore.case = TRUE)
    ) |>
    dplyr::select(
      SeqId, SomaId, Target, TargetFullName,
      UniProt, EntrezGeneID, EntrezGeneSymbol
    ) |>
    tidyr::separate_rows(UniProt, sep = "[|,[:space:]]+") |>
    dplyr::transmute(
      ExampleADAT = source$name,
      ADAT_MD5 = adat_md5,
      SeqId = trimws(as.character(SeqId)),
      SomaId = trimws(as.character(SomaId)),
      UNIPROT = trimws(as.character(UniProt)),
      Target,
      TargetFullName,
      EntrezGeneID,
      EntrezGeneSymbol
    ) |>
    dplyr::filter(
      !is.na(SeqId), SeqId != "",
      !is.na(SomaId), SomaId != "",
      !is.na(UNIPROT), UNIPROT != ""
    ) |>
    dplyr::distinct() |>
    as.data.frame()
}

example_adats <- list_example_adats()
message(
  "Using SomaLogic example ADATs: ",
  paste(example_adats$name, collapse = ", ")
)
metadata_GRCh38_p14_somalogic <- dplyr::bind_rows(
  lapply(seq_len(nrow(example_adats)), function(i) {
    read_example_metadata(example_adats[i, , drop = FALSE])
  })
) |>
  dplyr::arrange(ExampleADAT, SeqId, UNIPROT) |>
  as.data.frame()

if (nrow(metadata_GRCh38_p14_somalogic) == 0L) {
  stop("No SomaLogic assay metadata was extracted.", call. = FALSE)
}
if (anyDuplicated(metadata_GRCh38_p14_somalogic[c("ExampleADAT", "SeqId", "UNIPROT")])) {
  stop("SomaLogic example ADATs contain duplicate assay-to-UniProt links.", call. = FALSE)
}

metadata_path <- "data/metadata_GRCh38_p14_somalogic.rda"
if (file.exists(metadata_path)) {
  previous_env <- new.env(parent = emptyenv())
  load(metadata_path, envir = previous_env)
  previous_metadata <- previous_env$metadata_GRCh38_p14_somalogic

  if (all(c("ExampleADAT", "ADAT_MD5") %in% names(previous_metadata))) {
    previous_sources <- unique(previous_metadata[c("ExampleADAT", "ADAT_MD5")])
    current_sources <- unique(metadata_GRCh38_p14_somalogic[c("ExampleADAT", "ADAT_MD5")])
    source_changes <- dplyr::left_join(
      current_sources,
      previous_sources,
      by = "ExampleADAT",
      suffix = c("_current", "_previous")
    ) |>
      dplyr::filter(is.na(ADAT_MD5_previous) | ADAT_MD5_current != ADAT_MD5_previous)

    if (nrow(source_changes) == 0L) {
      message("No example ADAT checksum changes detected.")
    } else {
      message(
        "Changed or newly available example ADAT(s): ",
        paste(source_changes$ExampleADAT, collapse = ", ")
      )
    }

    removed_sources <- setdiff(previous_sources$ExampleADAT, current_sources$ExampleADAT)
    if (length(removed_sources) > 0L) {
      message("No longer published example ADAT(s): ", paste(removed_sources, collapse = ", "))
    }
  } else {
    message("Saved metadata has no ADAT checksums; recording source checksums for the first time.")
  }

  previous_soma_ids <- unique(stats::na.omit(as.character(previous_metadata$SomaId)))
  current_soma_ids <- unique(as.character(metadata_GRCh38_p14_somalogic$SomaId))
  added_soma_ids <- sort(setdiff(current_soma_ids, previous_soma_ids))
  removed_soma_ids <- sort(setdiff(previous_soma_ids, current_soma_ids))

  association_key <- function(x) {
    unique(paste(x$SeqId, x$UNIPROT, sep = "\t"))
  }
  added_associations <- sort(setdiff(
    association_key(metadata_GRCh38_p14_somalogic),
    association_key(previous_metadata)
  ))
  removed_associations <- sort(setdiff(
    association_key(previous_metadata),
    association_key(metadata_GRCh38_p14_somalogic)
  ))

  message(
    "SomaLogic example ADAT comparison: ",
    length(added_soma_ids), " added SomaId(s) vs saved metadata, ",
    length(removed_soma_ids), " removed SomaId(s), ",
    length(added_associations), " new SeqId-UniProt link(s), ",
    length(removed_associations), " removed link(s)."
  )
  if (length(added_soma_ids) > 0L) {
    message("New SomaId(s): ", paste(added_soma_ids, collapse = ", "))
  }
  if (length(removed_soma_ids) > 0L) {
    message("Removed SomaId(s): ", paste(removed_soma_ids, collapse = ", "))
  }
} else {
  message("No saved SomaLogic metadata found; creating the initial example ADAT inventory.")
}

save(
  metadata_GRCh38_p14_somalogic,
  file = metadata_path,
  compress = "gzip"
)

message(
  "Saved ", nrow(metadata_GRCh38_p14_somalogic),
  " assay-to-UniProt links from ",
  nrow(example_adats), " SomaLogic example ADATs."
)
