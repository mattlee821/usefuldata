#' Olink Mapping Data
#'
#' A dataset containing mapping of UniProt IDs from Olink data to Ensembl, and HGNC identifiers,
#' along with genomic positions for hg19 and hg38 builds.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{UNIPROT}{UniProt ID}
#'   \item{Target}{Target gene symbol (HGNC)}
#'   \item{TargetFullName}{Full protein name}
#'   \item{uniprot_gn_id}{UniProt gene ID}
#'   \item{uniprot_gn_symbol}{UniProt gene symbol}
#'   \item{entrezgene_id}{Entrez gene ID}
#'   \item{entrezgene_accession}{Entrez accession}
#'   \item{hgnc_id}{HGNC ID}
#'   \item{hgnc_symbol}{HGNC symbol}
#'   \item{ensembl_gene_id}{Ensembl gene ID}
#'   \item{external_gene_name}{External gene name}
#'   \item{gene_biotype}{Gene biotype (e.g. protein_coding)}
#'   \item{CHR}{Chromosome name}
#'   \item{START_hg19}{Start position in hg19}
#'   \item{END_hg19}{End position in hg19}
#'   \item{strand_hg19}{Strand in hg19}
#'   \item{START_hg38}{Start position in hg38}
#'   \item{END_hg38}{End position in hg38}
#'   \item{strand_hg38}{Strand in hg38}
#' }
#' @source Generated using BioMart and Olink data files.
"mapping_GRCh38_p14_olink"

#' SomaLogic Mapping Data
#'
#' A dataset containing mapping of SomaLogic IDs to Ensembl, UniProt, and HGNC identifiers,
#' along with genomic positions for hg19 and hg38 builds.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{SeqId}{Sequence ID}
#'   \item{SomaId}{SomaLogic ID}
#'   \item{UNIPROT}{UniProt ID}
#'   \item{Target}{Target gene symbol (HGNC)}
#'   \item{TargetFullName}{Full protein name}
#'   \item{EntrezGeneID}{Entrez gene ID}
#'   \item{EntrezGeneSymbol}{Entrez gene symbol}
#'   \item{uniprot_gn_id}{UniProt gene ID}
#'   \item{uniprot_gn_symbol}{UniProt gene symbol}
#'   \item{entrezgene_id}{Entrez gene ID (mapped)}
#'   \item{entrezgene_accession}{Entrez accession (mapped)}
#'   \item{hgnc_id}{HGNC ID}
#'   \item{hgnc_symbol}{HGNC symbol}
#'   \item{ensembl_gene_id}{Ensembl gene ID}
#'   \item{external_gene_name}{External gene name}
#'   \item{gene_biotype}{Gene biotype (e.g. protein_coding)}
#'   \item{CHR}{Chromosome name}
#'   \item{START_hg19}{Start position in hg19}
#'   \item{END_hg19}{End position in hg19}
#'   \item{strand_hg19}{Strand in hg19}
#'   \item{START_hg38}{Start position in hg38}
#'   \item{END_hg38}{End position in hg38}
#'   \item{strand_hg38}{Strand in hg38}
#' }
#' @source Generated using BioMart and SomaLogic ADAT file.
"mapping_GRCh38_p14_somalogic"
