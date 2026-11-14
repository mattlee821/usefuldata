# Resolve the UniProt accessions of the SomaLogic metadata to current UniProt accessions, and build the SeqId-level
# table that names assays. Run after metadata-somalogic.R; needs network access to rest.uniprot.org.
#
# UniProt retires accessions: an entry can be merged into another, demerged into several, or deleted, and an
# accession can become secondary to another. The SomaLogic example ADATs keep the accession they were annotated
# with, so this step asks UniProt for the current accession(s) of each one and records the UniProt release and the
# date it asked.
#
# Writes:
#   data/somalogic_uniprot_status.rda          1 row per UNIPROT and current accession (a demerged entry has several)
#   data/somalogic_seqid_uniprot_current.rda   1 row per SeqId, from the most recent example ADAT that has it

library(dplyr)
library(tidyr)
library(httr2)

metadata_path <- "data/metadata_GRCh38_p14_somalogic.rda"
if (!file.exists(metadata_path)) {
  stop("Run data-raw/metadata-somalogic.R first.", call. = FALSE)
}
metadata_env <- new.env(parent = emptyenv())
load(metadata_path, envir = metadata_env)
metadata <- metadata_env$metadata_GRCh38_p14_somalogic

uniprot_request <- function(url, ...) {
  httr2::request(url) |>
    httr2::req_user_agent("usefuldata (R package data build)") |>
    httr2::req_url_query(...) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_retry(max_tries = 6, backoff = function(i) 2 * i)
}

ids <- sort(unique(metadata$UNIPROT[!is.na(metadata$UNIPROT) & metadata$UNIPROT != ""]))
message("Checking ", length(ids), " distinct UniProt accessions against UniProt")

# 1. active entries: the batch endpoint returns only these, and reports the release ====
active <- character()
release <- NA_character_
release_date <- NA_character_
for (chunk in split(ids, ceiling(seq_along(ids) / 400))) {
  response <- httr2::req_perform(uniprot_request(
    "https://rest.uniprot.org/uniprotkb/accessions",
    accessions = paste(chunk, collapse = ","), fields = "accession", size = 500
  ))
  if (httr2::resp_status(response) != 200L) {
    next # an invalid accession in the chunk rejects the whole chunk; its accessions are looked up one by one below
  }
  release <- httr2::resp_header(response, "x-uniprot-release", default = release)
  release_date <- httr2::resp_header(response, "x-uniprot-release-date", default = release_date)
  found <- vapply(httr2::resp_body_json(response)$results, function(entry) entry$primaryAccession, character(1))
  active <- c(active, found)
}

# 2. everything else, one at a time: inactive (merged, demerged, deleted), secondary, or unknown ====
lookup_one <- function(id) {
  response <- httr2::req_perform(uniprot_request(paste0("https://rest.uniprot.org/uniprotkb/", id, ".json")))
  if (httr2::resp_status(response) != 200L) {
    return(data.frame(UNIPROT = id, STATUS = "unresolved", UNIPROT_CURRENT = NA_character_))
  }
  entry <- httr2::resp_body_json(response)
  if (identical(entry$entryType, "Inactive")) {
    reason <- tolower(entry$inactiveReason$inactiveReasonType)
    successors <- unlist(entry$inactiveReason$mergeDemergeTo)
    return(data.frame(
      UNIPROT = id, STATUS = reason,
      UNIPROT_CURRENT = if (length(successors)) successors else NA_character_
    ))
  }
  if (!identical(entry$primaryAccession, id)) {
    return(data.frame(UNIPROT = id, STATUS = "secondary", UNIPROT_CURRENT = entry$primaryAccession))
  }
  data.frame(UNIPROT = id, STATUS = "current", UNIPROT_CURRENT = id)
}
remaining <- setdiff(ids, active)
message(length(active), " active; looking up ", length(remaining), " others individually")
individual <- lapply(remaining, lookup_one)
somalogic_uniprot_status <- dplyr::bind_rows(
  data.frame(UNIPROT = active, STATUS = "current", UNIPROT_CURRENT = active),
  dplyr::bind_rows(individual)
) |>
  dplyr::mutate(
    UNIPROT_RELEASE = release,
    UNIPROT_RELEASE_DATE = release_date,
    UNIPROT_CHECKED = as.character(Sys.Date())
  ) |>
  dplyr::arrange(UNIPROT, UNIPROT_CURRENT) |>
  as.data.frame()
if (anyNA(somalogic_uniprot_status$UNIPROT_RELEASE)) {
  stop("UniProt did not report its release.", call. = FALSE)
}
message("Status: ", paste(names(table(somalogic_uniprot_status$STATUS)), table(somalogic_uniprot_status$STATUS), collapse = ", "))

# 3. one row per SeqId, from the most recent example ADAT that contains it ====
# The version is read from the file name; the unversioned example_data.adat is the oldest (V4.0).
adat_version <- function(name) {
  versioned <- grepl("_v[0-9]+[.][0-9]+_", name)
  out <- rep(0, length(name))
  out[versioned] <- as.numeric(sub("^.*_v([0-9]+[.][0-9]+)_.*$", "\\1", name[versioned]))
  out
}
collapse_ids <- function(x) {
  x <- sort(unique(stats::na.omit(x)))
  if (length(x) == 0L) NA_character_ else paste(x, collapse = "-")
}

latest <- metadata |>
  dplyr::mutate(ADAT_VERSION = adat_version(ExampleADAT)) |>
  dplyr::group_by(SeqId) |>
  dplyr::filter(ADAT_VERSION == max(ADAT_VERSION)) |>
  dplyr::ungroup()

changes <- somalogic_uniprot_status |>
  dplyr::filter(STATUS != "current") |>
  dplyr::group_by(UNIPROT, STATUS) |>
  dplyr::summarise(
    CHANGE = paste0(
      UNIPROT[1], " ", STATUS[1], if (all(is.na(UNIPROT_CURRENT))) "" else paste0(" -> ", paste(sort(UNIPROT_CURRENT), collapse = ",")),
      collapse = ""
    ),
    .groups = "drop"
  )

somalogic_seqid_uniprot_current <- latest |>
  dplyr::left_join(
    somalogic_uniprot_status[c("UNIPROT", "UNIPROT_CURRENT")],
    by = "UNIPROT", relationship = "many-to-many"
  ) |>
  dplyr::left_join(changes[c("UNIPROT", "CHANGE")], by = "UNIPROT") |>
  dplyr::group_by(SeqId) |>
  dplyr::summarise(
    ExampleADAT = ExampleADAT[1],
    SomaId = SomaId[1],
    Target = Target[1],
    TargetFullName = TargetFullName[1],
    UNIPROT_SOURCE = collapse_ids(UNIPROT),
    UNIPROT_CURRENT = collapse_ids(UNIPROT_CURRENT),
    UNIPROT_STATUS = if (all(is.na(CHANGE))) "current" else "updated",
    UNIPROT_CHANGES = if (all(is.na(CHANGE))) NA_character_ else paste(sort(unique(stats::na.omit(CHANGE))), collapse = "; "),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    UNIPROT_RELEASE = release,
    UNIPROT_CHECKED = as.character(Sys.Date())
  ) |>
  dplyr::arrange(SeqId) |>
  as.data.frame()

if (nrow(somalogic_seqid_uniprot_current) != dplyr::n_distinct(metadata$SeqId)) {
  stop("The SeqId table does not have one row per SeqId.", call. = FALSE)
}
# A SeqId whose only accession UniProt has deleted keeps its row, with no current accession and its own status.
somalogic_seqid_uniprot_current$UNIPROT_STATUS[is.na(somalogic_seqid_uniprot_current$UNIPROT_CURRENT)] <- "no_current_accession"
if (any(somalogic_seqid_uniprot_current$UNIPROT_STATUS == "no_current_accession")) {
  message(
    "No current UniProt accession (deleted by UniProt): ",
    paste(somalogic_seqid_uniprot_current$SeqId[somalogic_seqid_uniprot_current$UNIPROT_STATUS == "no_current_accession"], collapse = ", ")
  )
}

save(somalogic_uniprot_status, file = "data/somalogic_uniprot_status.rda", compress = "gzip")
save(somalogic_seqid_uniprot_current, file = "data/somalogic_seqid_uniprot_current.rda", compress = "gzip")
message(
  "Saved ", nrow(somalogic_seqid_uniprot_current), " SeqIds (UniProt release ", release, ", ", Sys.Date(), "); ",
  sum(somalogic_seqid_uniprot_current$UNIPROT_STATUS == "updated"), " have an updated UniProt accession, ",
  sum(somalogic_seqid_uniprot_current$UNIPROT_STATUS == "no_current_accession"), " have none."
)
