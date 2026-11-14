test_that("the UniProt mapping contains distinct annotation records", {
  mapping <- mapping_GRCh38_p14_uniprot

  expect_gt(nrow(mapping), 0L)
  expect_true(all(!is.na(mapping$UNIPROT) & mapping$UNIPROT != ""))
  expect_equal(anyDuplicated(mapping), 0L)
  expect_true(all(c(
    "uniprot_gn_id", "hgnc_id", "ensembl_gene_id",
    "START_hg19", "END_hg19", "START_hg38", "END_hg38"
  ) %in% names(mapping)))
  expect_false(any(c("SeqId", "SomaId", "Target") %in% names(mapping)))
})

test_that("SomaLogic metadata preserves unique assay-to-UniProt links", {
  metadata <- metadata_GRCh38_p14_somalogic
  mapping <- mapping_GRCh38_p14_uniprot

  expect_gt(nrow(metadata), 0L)
  expect_true(all(c(
    "ExampleADAT", "ADAT_MD5", "SeqId", "SomaId", "UNIPROT",
    "Target", "TargetFullName", "EntrezGeneID", "EntrezGeneSymbol"
  ) %in% names(metadata)))
  expect_true(all(grepl("^example_data.*[.]adat$", metadata$ExampleADAT)))
  expect_equal(anyDuplicated(metadata[c("ExampleADAT", "SeqId", "UNIPROT")]), 0L)
  expect_true(all(grepl("^[A-Z0-9-]+$", metadata$UNIPROT)))
  expect_true(all(grepl("^[[:xdigit:]]{32}$", metadata$ADAT_MD5)))
  expect_true(all(metadata$UNIPROT %in% mapping$UNIPROT))
  expect_false("ensembl_gene_id" %in% names(metadata))

  joined <- merge(metadata, mapping, by = "UNIPROT")
  expect_gte(nrow(joined), nrow(metadata))
})

test_that("every SomaLogic SeqId has a row with current UniProt accessions", {
  current <- somalogic_seqid_uniprot_current
  status <- somalogic_uniprot_status
  metadata <- metadata_GRCh38_p14_somalogic

  expect_equal(nrow(current), length(unique(metadata$SeqId)))
  expect_equal(anyDuplicated(current$SeqId), 0L)
  expect_setequal(current$SeqId, metadata$SeqId)
  expect_true(all(current$UNIPROT_STATUS %in% c("current", "updated", "no_current_accession")))
  expect_equal(is.na(current$UNIPROT_CURRENT), current$UNIPROT_STATUS == "no_current_accession")
  expect_true(all(grepl("^[A-Z0-9]+(-[A-Z0-9]+)*$", current$UNIPROT_CURRENT[!is.na(current$UNIPROT_CURRENT)])))
  expect_false(any(status$STATUS == "unresolved"))
  expect_true(all(grepl("^[0-9]{4}_[0-9]{2}$", current$UNIPROT_RELEASE)))
})

test_that("updated accessions differ from the source and retired accessions are not current", {
  current <- somalogic_seqid_uniprot_current
  status <- somalogic_uniprot_status

  updated <- current[current$UNIPROT_STATUS == "updated", ]
  expect_true(all(updated$UNIPROT_CURRENT != updated$UNIPROT_SOURCE))
  expect_true(all(!is.na(updated$UNIPROT_CHANGES)))
  unchanged <- current[current$UNIPROT_STATUS == "current", ]
  expect_equal(unchanged$UNIPROT_CURRENT, unchanged$UNIPROT_SOURCE)
  retired <- unique(status$UNIPROT[status$STATUS %in% c("secondary", "demerged", "deleted")])
  expect_false(any(retired %in% unlist(strsplit(stats::na.omit(current$UNIPROT_CURRENT), "-"))))
})

test_that("the SeqId table takes the most recent example ADAT", {
  current <- somalogic_seqid_uniprot_current
  metadata <- metadata_GRCh38_p14_somalogic
  version <- function(x) {
    out <- rep(0, length(x))
    versioned <- grepl("_v[0-9]+[.][0-9]+_", x)
    out[versioned] <- as.numeric(sub("^.*_v([0-9]+[.][0-9]+)_.*$", "\\1", x[versioned]))
    out
  }
  newest <- vapply(split(version(metadata$ExampleADAT), metadata$SeqId), max, numeric(1))
  expect_equal(version(current$ExampleADAT), as.numeric(newest[current$SeqId]))
})
