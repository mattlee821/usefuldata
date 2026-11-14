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

#' Current UniProt accessions of the SomaLogic assays
#'
#' One row per SomaLogic SeqId, with the UniProt accession(s) from the most recent public example ADAT that contains
#' the SeqId, checked against UniProt so that retired accessions are replaced by their current ones. Built by
#' `data-raw/status-uniprot.R` from [metadata_GRCh38_p14_somalogic] and [somalogic_uniprot_status].
#'
#' The most recent example ADAT is the highest version in the file name; the unversioned `example_data.adat` is the
#' oldest (V4.0). A SeqId present only in an older ADAT keeps that ADAT's accession.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{SeqId}{SomaLogic sequence ID, as in the example ADATs (`10000-28`)}
#'   \item{ExampleADAT}{The most recent example ADAT that contains the SeqId}
#'   \item{SomaId}{SomaLogic assay ID in that ADAT}
#'   \item{Target}{SomaLogic target name in that ADAT}
#'   \item{TargetFullName}{Full target name in that ADAT}
#'   \item{UNIPROT_SOURCE}{UniProt accession(s) in that ADAT, sorted and joined with `-`}
#'   \item{UNIPROT_CURRENT}{Current UniProt accession(s), sorted and joined with `-`: a merged accession is replaced
#'     by the one it was merged into, and a demerged accession by all the entries it was split into. `NA` when UniProt
#'     has deleted the accession}
#'   \item{UNIPROT_STATUS}{`current` (no change), `updated` (`UNIPROT_CURRENT` differs from `UNIPROT_SOURCE`) or
#'     `no_current_accession` (UniProt deleted it)}
#'   \item{UNIPROT_CHANGES}{What changed, for example `P01562 demerged -> A0A087WWS6,P0DY56`; `NA` when nothing did}
#'   \item{UNIPROT_RELEASE}{UniProt release the accessions were checked against}
#'   \item{UNIPROT_CHECKED}{Date of the check}
#' }
#' @source UniProt REST API (<https://rest.uniprot.org>), applied to [metadata_GRCh38_p14_somalogic].
"somalogic_seqid_uniprot_current"

#' UniProt status of the SomaLogic accessions
#'
#' One row per UniProt accession in [metadata_GRCh38_p14_somalogic] and current accession. A demerged accession has
#' one row for each entry it was split into.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{UNIPROT}{UniProt accession as in the example ADATs}
#'   \item{STATUS}{`current`; `secondary` (merged into another entry, now a secondary accession of it); `demerged`
#'     (split into several entries); `deleted`; or `unresolved` (UniProt did not answer)}
#'   \item{UNIPROT_CURRENT}{The current accession; `NA` for a deleted accession}
#'   \item{UNIPROT_RELEASE}{UniProt release the accession was checked against}
#'   \item{UNIPROT_RELEASE_DATE}{Date of that release}
#'   \item{UNIPROT_CHECKED}{Date of the check}
#' }
#' @source UniProt REST API (<https://rest.uniprot.org>).
"somalogic_uniprot_status"
