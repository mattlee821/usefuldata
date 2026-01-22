# Olink Mapping Data

A dataset containing mapping of UniProt IDs from Olink data to Ensembl,
and HGNC identifiers, along with genomic positions for hg19 and hg38
builds.

## Usage

``` r
mapping_GRCh38_p14_olink
```

## Format

A data frame with the following columns:

- UNIPROT:

  UniProt ID

- Target:

  Target gene symbol (HGNC)

- TargetFullName:

  Full protein name

- uniprot_gn_id:

  UniProt gene ID

- uniprot_gn_symbol:

  UniProt gene symbol

- entrezgene_id:

  Entrez gene ID

- entrezgene_accession:

  Entrez accession

- hgnc_id:

  HGNC ID

- hgnc_symbol:

  HGNC symbol

- ensembl_gene_id:

  Ensembl gene ID

- external_gene_name:

  External gene name

- gene_biotype:

  Gene biotype (e.g. protein_coding)

- CHR:

  Chromosome name

- START_hg19:

  Start position in hg19

- END_hg19:

  End position in hg19

- strand_hg19:

  Strand in hg19

- START_hg38:

  Start position in hg38

- END_hg38:

  End position in hg38

- strand_hg38:

  Strand in hg38

## Source

Generated using BioMart and Olink data files.
