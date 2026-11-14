# SomaLogic Assay Metadata

SomaLogic assay identifiers and their associated UniProt accessions. A
SeqId can map to multiple UniProt accessions; retain the SeqId-UniProt
relationship when joining assay measurements to the UniProt mapping. The
same relationship may occur in multiple example ADATs.

## Usage

``` r
metadata_GRCh38_p14_somalogic
```

## Format

A data frame with the following columns:

- ExampleADAT:

  SomaLogic public example ADAT filename

- ADAT_MD5:

  MD5 checksum of the downloaded source ADAT

- SeqId:

  SomaLogic sequence ID

- SomaId:

  SomaLogic assay ID

- UNIPROT:

  Associated UniProt accession

- Target:

  SomaLogic target name

- TargetFullName:

  Full target name

- EntrezGeneID:

  Source Entrez gene ID

- EntrezGeneSymbol:

  Source Entrez gene symbol

## Source

SomaLogic public example ADATs in the [SomaLogic-Data
repository](https://github.com/SomaLogic/SomaLogic-Data).
