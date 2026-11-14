# UniProt Mapping Data

A mapping of UniProt accessions to gene identifiers and genomic
positions for hg19 and hg38. Rows represent distinct annotation records;
an accession can have more than one record when its source mappings
disagree.

## Usage

``` r
mapping_GRCh38_p14_uniprot
```

## Format

A data frame with the following columns:

- UNIPROT:

  UniProt accession

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

  Gene biotype

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

Generated from Olink and SomaLogic mappings using BioMart.
