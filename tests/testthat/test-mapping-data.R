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
