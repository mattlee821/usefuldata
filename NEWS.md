# usefuldata (development)

* Add `somalogic_seqid_uniprot_current`, 1 row per SomaLogic SeqId with the UniProt accession(s) from the most recent
  example ADAT, replaced by their current accession(s) where UniProt has merged, demerged or deleted them.
* Add `somalogic_uniprot_status` with the UniProt status of every accession in the SomaLogic metadata, the UniProt
  release and the date checked. Both are built by `data-raw/status-uniprot.R`, run after `metadata-somalogic.R`.

# usefuldata 1.0.0

## Data model

* Add `mapping_GRCh38_p14_uniprot` as the shared UniProt mapping for Olink and
  SomaLogic proteins.
* Add `metadata_GRCh38_p14_somalogic` with assay metadata and source ADAT
  checksums. The refresh script discovers public example ADATs dynamically.
* Replace `mapping_GRCh38_p14_olink` and `mapping_GRCh38_p14_somalogic` with
  the shared mapping and separate SomaLogic metadata datasets.
* Use pkgdown's default Bootstrap theme for the website.
