#' UniProt Mapping Data
#'
#' A mapping of UniProt accessions to gene identifiers and genomic positions
#' for hg19 and hg38. Rows represent distinct annotation records; an accession
#' can have more than one record when its source mappings disagree.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{UNIPROT}{UniProt accession}
#'   \item{uniprot_gn_id}{UniProt gene ID}
#'   \item{uniprot_gn_symbol}{UniProt gene symbol}
#'   \item{entrezgene_id}{Entrez gene ID}
#'   \item{entrezgene_accession}{Entrez accession}
#'   \item{hgnc_id}{HGNC ID}
#'   \item{hgnc_symbol}{HGNC symbol}
#'   \item{ensembl_gene_id}{Ensembl gene ID}
#'   \item{external_gene_name}{External gene name}
#'   \item{gene_biotype}{Gene biotype}
#'   \item{CHR}{Chromosome name}
#'   \item{START_hg19}{Start position in hg19}
#'   \item{END_hg19}{End position in hg19}
#'   \item{strand_hg19}{Strand in hg19}
#'   \item{START_hg38}{Start position in hg38}
#'   \item{END_hg38}{End position in hg38}
#'   \item{strand_hg38}{Strand in hg38}
#' }
#' @source Generated from Olink and SomaLogic mappings using BioMart.
"mapping_GRCh38_p14_uniprot"

#' SomaLogic Assay Metadata
#'
#' SomaLogic assay identifiers and their associated UniProt accessions.
#' A SeqId can map to multiple UniProt accessions; retain the SeqId-UniProt
#' relationship when joining assay measurements to the UniProt mapping.
#' The same relationship may occur in multiple example ADATs.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{ExampleADAT}{SomaLogic public example ADAT filename}
#'   \item{ADAT_MD5}{MD5 checksum of the downloaded source ADAT}
#'   \item{SeqId}{SomaLogic sequence ID}
#'   \item{SomaId}{SomaLogic assay ID}
#'   \item{UNIPROT}{Associated UniProt accession}
#'   \item{Target}{SomaLogic target name}
#'   \item{TargetFullName}{Full target name}
#'   \item{EntrezGeneID}{Source Entrez gene ID}
#'   \item{EntrezGeneSymbol}{Source Entrez gene symbol}
#' }
#' @source SomaLogic public example ADATs in the
#'   \href{https://github.com/SomaLogic/SomaLogic-Data}{SomaLogic-Data repository}.
"metadata_GRCh38_p14_somalogic"
