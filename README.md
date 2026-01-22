# usefuldata

The `usefuldata` package provides useful datasets for analysis. It currently includes pre-processed mapping datasets for Olink and SomaLogic proteomics platforms, but will include other datasets in the future.

## Installation

You can install the package from GitHub using the `remotes` package:

```r
# install.packages("remotes")
remotes::install_github("mattlee821/usefuldata")
```

## Datasets

The package contains the following datasets:

### 1. `mapping_GRCh38_p14_olink`

This dataset maps Olink proteins (UniProt IDs) to gene identifiers and genomic positions.

**Columns include:**
- `UNIPROT`: UniProt ID (Olink identifier)
- `Target`: Gene Symbol
- `ensembl_gene_id`: Ensembl Gene ID
- `hgnc_id` / `hgnc_symbol`: HGNC info
- `START_hg19` / `END_hg19`: Genomic coordinates (hg19)
- `START_hg38` / `END_hg38`: Genomic coordinates (hg38)

### 2. `mapping_GRCh38_p14_somalogic`

This dataset maps SomaLogic aptamers (SeqId/SomaId) to gene identifiers and genomic positions.

**Columns include:**
- `SeqId`: Sequence ID
- `SomaId`: SomaLogic ID
- `UNIPROT`: UniProt ID
- `Target`: Gene Symbol
- `ensembl_gene_id`: Ensembl Gene ID
- `START_hg19` / `END_hg19`: Genomic coordinates (hg19)
- `START_hg38` / `END_hg38`: Genomic coordinates (hg38)

## Usage

You can load the datasets directly into your R session:

```r
library(usefuldata)

# Load Olink mapping
head(mapping_GRCh38_p14_olink)

# Load SomaLogic mapping
head(mapping_GRCh38_p14_somalogic)
```
