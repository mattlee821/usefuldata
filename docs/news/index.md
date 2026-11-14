# Changelog

## usefuldata 1.0.0

### Data model

- Add `mapping_GRCh38_p14_uniprot` as the shared UniProt mapping for
  Olink and SomaLogic proteins.
- Add `metadata_GRCh38_p14_somalogic` with assay metadata and source
  ADAT checksums. The refresh script discovers public example ADATs
  dynamically.
- Replace `mapping_GRCh38_p14_olink` and `mapping_GRCh38_p14_somalogic`
  with the shared mapping and separate SomaLogic metadata datasets.
- Use pkgdown’s default Bootstrap theme for the website.
