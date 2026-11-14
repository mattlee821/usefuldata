# usefuldata

The `usefuldata` package provides useful datasets for analysis. It includes a shared UniProt mapping for Olink and SomaLogic proteins, plus SomaLogic-specific assay metadata.

## Installation

You can install the package from GitHub using the `remotes` package:

```r
# install.packages("remotes")
remotes::install_github("mattlee821/usefuldata")
```

## Datasets

The package contains the following datasets:

### 1. `mapping_GRCh38_p14_uniprot`

This shared dataset maps UniProt accessions to gene identifiers and genomic positions. It is the mapping to use for Olink data, which uses UniProt accessions as identifiers, and as the protein-level reference for SomaLogic data.

**Columns include:**
- `UNIPROT`: UniProt accession
- `ensembl_gene_id`: Ensembl Gene ID
- `hgnc_id` / `hgnc_symbol`: HGNC identifiers
- `START_hg19` / `END_hg19`: Genomic coordinates (hg19)
- `START_hg38` / `END_hg38`: Genomic coordinates (hg38)

An accession can have more than one row if the source mapping contains multiple distinct annotation records. Check for duplicate `UNIPROT` values before assuming a one-to-one join.

### 2. `metadata_GRCh38_p14_somalogic`

This dataset contains metadata extracted from the public example ADATs listed in the [SomaLogic-Data repository](https://github.com/SomaLogic/SomaLogic-Data), with the source filename and checksum recorded per row. It currently includes V4, V4.1, and V5.0 examples; newly listed `example_data*.adat` files are included when the metadata is refreshed. These examples are the package's reference inventory, not a guarantee of full commercial menu coverage. Join the metadata to the shared mapping using `UNIPROT`.

**Columns include:**
- `SeqId`: Sequence ID
- `SomaId`: SomaLogic ID
- `ExampleADAT`: Source example ADAT filename
- `ADAT_MD5`: Checksum of the exact downloaded ADAT
- `UNIPROT`: UniProt ID
- `Target`: Gene Symbol
- `TargetFullName`: Full target name
- `EntrezGeneID` / `EntrezGeneSymbol`: Source Entrez identifiers

A SomaLogic assay can map to multiple UniProt accessions, and the same assay may appear in multiple example files. Keep the `ExampleADAT`-`SeqId`-`UNIPROT` relationship when joining assay measurements; joining may produce multiple rows for an assay.

### 3. `somalogic_seqid_uniprot_current` and `somalogic_uniprot_status`

UniProt retires accessions, and the SomaLogic example ADATs keep the accession each assay was annotated with. These two datasets check every accession in `metadata_GRCh38_p14_somalogic` against UniProt and record the result, the UniProt release and the date.

`somalogic_seqid_uniprot_current` has 1 row per SeqId, from the most recent example ADAT that contains it (the highest version in the file name; the unversioned `example_data.adat` is the oldest):
- `UNIPROT_SOURCE`: the accession(s) in that ADAT, sorted and joined with `-`
- `UNIPROT_CURRENT`: the current accession(s), sorted and joined with `-`. A merged accession is replaced by the entry it was merged into and a demerged accession by all the entries it was split into; `NA` when UniProt has deleted it
- `UNIPROT_STATUS`: `current`, `updated` or `no_current_accession`
- `UNIPROT_CHANGES`, `UNIPROT_RELEASE`, `UNIPROT_CHECKED`, and `ExampleADAT`, `SomaId`, `Target`, `TargetFullName` from that ADAT

`somalogic_uniprot_status` has 1 row per accession and current accession (a demerged accession has several) with `STATUS` (`current`, `secondary`, `demerged`, `deleted`, `unresolved`).

Use `UNIPROT_CURRENT` to name or join SomaLogic assays; keep `SeqId` with it, because several SeqIds can share a UniProt accession.

## Usage

You can load the datasets directly into your R session:

```r
library(usefuldata)

# Load the shared UniProt mapping
head(mapping_GRCh38_p14_uniprot)

# Load SomaLogic assay metadata and join to protein annotations
head(metadata_GRCh38_p14_somalogic)
merge(
  metadata_GRCh38_p14_somalogic,
  mapping_GRCh38_p14_uniprot,
  by = "UNIPROT"
)
```

## Regenerating the data

From the package root, download the current public example ADATs, compare their SomaLogic IDs and SeqId-UniProt links against the saved metadata, check the accessions against UniProt (needs network access), then rebuild the UniProt mapping:

```sh
Rscript data-raw/mapping-olink.R
Rscript data-raw/metadata-somalogic.R
Rscript data-raw/status-uniprot.R
Rscript data-raw/mapping-somalogic.R
Rscript data-raw/mapping-uniprot.R
```
