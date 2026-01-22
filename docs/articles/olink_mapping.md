# Olink Mapping

## Olink Mapping Dataset

This dataset provides a mapping of Olink Explore and Target proteins to
their corresponding genomic coordinates and gene identifiers. The data
is derived from Olink assay data and mapped using BioMart.

### Data Generation Summary

The mapping was generated using the following steps:

1.  **Input Data**: Raw data was sourced from Olink Explore and Target
    assay files (CSV and Excel formats).
2.  **Formatting**: UniProt IDs and Target Gene symbols were extracted
    and separated where multiple entries existed.
3.  **Mapping**: UniProt IDs and HGNC symbols were mapped to Ensembl
    Gene IDs using `biomaRt` (Ensembl dataset `hsapiens_gene_ensembl`).
4.  **Filtering**:
    - Only **protein_coding** genes were retained.
    - Only standard chromosomes (1-22, X, Y) were retained.
    - Mappings were filtered to ensure consistency between UniProt gene
      symbols and Entrez/HGNC/External gene names.
5.  **Genomic Positions**: Start and End positions were retrieved for
    both **hg19** and **hg38** builds using
    `TxDb.Hsapiens.UCSC.hg19.knownGene` and
    `TxDb.Hsapiens.UCSC.hg38.knownGene`.

### Column Descriptions

| Column                 | Description                                 |
|:-----------------------|:--------------------------------------------|
| `UNIPROT`              | UniProt ID provided by Olink                |
| `Target`               | Target gene symbol (HGNC) provided by Olink |
| `TargetFullName`       | Full protein name provided by Olink         |
| `uniprot_gn_id`        | Mapped UniProt gene ID                      |
| `uniprot_gn_symbol`    | Mapped UniProt gene symbol                  |
| `entrezgene_id`        | Mapped Entrez gene ID                       |
| `entrezgene_accession` | Mapped Entrez accession                     |
| `hgnc_id`              | Mapped HGNC ID                              |
| `hgnc_symbol`          | Mapped HGNC symbol                          |
| `ensembl_gene_id`      | Mapped Ensembl Gene ID                      |
| `external_gene_name`   | External gene name                          |
| `gene_biotype`         | Gene biotype (e.g. protein_coding)          |
| `CHR`                  | Chromosome name                             |
| `START_hg19`           | Start position (hg19)                       |
| `END_hg19`             | End position (hg19)                         |
| `strand_hg19`          | Strand (hg19)                               |
| `START_hg38`           | Start position (hg38)                       |
| `END_hg38`             | End position (hg38)                         |
| `strand_hg38`          | Strand (hg38)                               |

### Interactive Table
