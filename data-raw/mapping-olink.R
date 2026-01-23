# source utils ====
source("data-raw/utils.R")

# data ====
# input directory
input_dir <- "data-raw/raw_data"

standard_files <- c(
  "Olink Explore Cardiometabolic - 2026-01-22.csv",
  "Olink Explore Cardiometabolic II - 2026-01-22.csv",
  "Olink Explore Inflammation - 2026-01-22.csv",
  "Olink Explore Inflammation II - 2026-01-22.csv",
  "Olink Explore Neurology - 2026-01-22.csv",
  "Olink Explore Neurology II - 2026-01-22.csv",
  "Olink Explore Oncology - 2026-01-22.csv",
  "Olink Explore Oncology II - 2026-01-22.csv",
  "Olink Target 48 Immune Surveillance - 2026-01-22.csv",
  "Olink Target 48 Cytokine - 2026-01-22.csv",
  "Olink Target 48 Neurodegeneration - 2026-01-22.csv",
  "Olink Flex - 2026-01-22.csv",
  "Olink Reveal - 2026-01-22.csv",
  "Olink Target 96 Cardiometabolic - 2026-01-22.csv",
  "Olink Target 96 Cardiovascular II - 2026-01-22.csv",
  "Olink Target 96 Cardiovascular III - 2026-01-22.csv"
)
files <- file.path(input_dir, standard_files)

# Read files if they exist
df_list <- list()
for (f in files) {
  if (file.exists(f)) {
    name <- tools::file_path_sans_ext(basename(f))
    df_list[[name]] <- data.table::fread(file = f, sep = ";")
  } else {
    warning(paste("File not found:", f))
  }
}

if (length(df_list) > 0) {
  df <- data.table::rbindlist(
    df_list,
    use.names = TRUE,
    fill = TRUE
  )
} else {
  df <- data.table::data.table()
}

# read ht file
ht_path <- file.path(input_dir, "olink-explore-ht-assay-list.xlsx")
if (file.exists(ht_path)) {
  df_ht <- readxl::read_excel(
    path = ht_path,
    skip = 6
  ) |>
    dplyr::rename(Gene = "Gene name") |>
    dplyr::select(-"Olink ID*")
} else {
  df_ht <- data.frame()
  warning("HT assay list file missing")
}

# combine
data <- df |>
  dplyr::bind_rows(df_ht) |>
  unique()

## format data
data <- data %>%
  dplyr::rename(
    UNIPROT = `UniProt ID`,
    TargetFullName = `Protein name`,
    Target = `Gene`
  ) %>%
  tidyr::separate_rows(UNIPROT, sep = "_") %>%
  tidyr::separate_rows(Target, sep = "_")

id_uniprot_id <- unique(data$UNIPROT)
id_hgnc_id <- unique(data$Target)

# mart ====
mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
VAR_build <- listDatasets(mart)[grep("hsapiens", listDatasets(mart)$dataset), "description"] # check build
VAR_build <- sub(".*\\((.*)\\).*", "\\1", VAR_build)

# map each ID ====
## map UNIPROT ====
map_uniprot_raw <- biomaRt_getBM_batch(
  mart = mart,
  attributes = c(
    "uniprot_gn_id", "uniprot_gn_symbol",
    "entrezgene_id", "entrezgene_accession",
    "hgnc_id", "hgnc_symbol",
    "external_gene_name",
    "gene_biotype",
    "chromosome_name"
  ),
  filters = "uniprot_gn_id",
  values = id_uniprot_id,
  chunk_size = 2
)

map_uniprot <- map_uniprot_raw %>%
  dplyr::filter(gene_biotype == "protein_coding") %>%
  dplyr::filter(chromosome_name %in% c(as.character(1:22), "X", "Y", "")) %>%
  dplyr::filter(uniprot_gn_symbol == entrezgene_accession |
    uniprot_gn_symbol == hgnc_symbol |
    uniprot_gn_symbol == external_gene_name) %>%
  dplyr::rename(CHR = chromosome_name) %>%
  dplyr::distinct()

## map HGNC ====
# Note: Reuse logic but adapting for HGNC
map_hgnc_raw <- biomaRt_getBM_batch(
  mart = mart,
  attributes = c(
    "uniprot_gn_id", "uniprot_gn_symbol",
    "entrezgene_id", "entrezgene_accession",
    "hgnc_id", "hgnc_symbol",
    "external_gene_name",
    "gene_biotype",
    "chromosome_name"
  ),
  filters = "hgnc_symbol",
  values = id_hgnc_id,
  chunk_size = 2
)

map_hgnc <- map_hgnc_raw %>%
  dplyr::filter(gene_biotype == "protein_coding") %>%
  dplyr::filter(chromosome_name %in% c(as.character(1:22), "X", "Y", "")) %>%
  dplyr::filter(uniprot_gn_symbol == entrezgene_accession |
    uniprot_gn_symbol == hgnc_symbol |
    uniprot_gn_symbol == external_gene_name) %>%
  dplyr::rename(CHR = chromosome_name) %>%
  dplyr::distinct()

# ensemble primary id ====
ensembl_uniprot <- getBM(
  attributes = c("uniprot_gn_id", "ensembl_gene_id", "chromosome_name"),
  filters = "uniprot_gn_id",
  values = id_uniprot_id,
  mart = mart
)

ensembl_hgnc <- getBM(
  attributes = c("hgnc_symbol", "ensembl_gene_id", "chromosome_name"),
  filters = "hgnc_symbol",
  values = id_hgnc_id,
  mart = mart
)

map_ensembl <- full_join(ensembl_uniprot, ensembl_hgnc, by = c("ensembl_gene_id", "chromosome_name")) %>%
  dplyr::rename(CHR = chromosome_name) %>%
  filter(CHR %in% c(as.character(1:22), "X", "Y"))

# combine maps ====
map <- rbind(
  map_uniprot,
  map_hgnc
) %>%
  dplyr::distinct()

map <- full_join(map, map_ensembl)

# positions ====
## hg19 ====
id_hg19 <- subset(
  genes(TxDb.Hsapiens.UCSC.hg19.knownGene,
    single.strand.genes.only = FALSE
  ),
  gene_id %in% unique(map$entrezgene_id)
) %>%
  as.data.frame() %>%
  dplyr::rename(
    entrezgene_id = group_name,
    CHR = seqnames,
    START_hg19 = start,
    END_hg19 = end,
    strand_hg19 = strand
  ) %>%
  dplyr::group_by(entrezgene_id) %>%
  dplyr::filter(any(CHR %in% paste0("chr", c(1:22, "X", "Y")))) %>% # Keep only groups with at least one valid chromosome entry
  dplyr::filter(CHR %in% paste0("chr", c(1:22, "X", "Y")) | n() == 1) %>% # Keep valid chromosomes or keep if only one entry exists
  dplyr::ungroup() %>%
  dplyr::mutate(CHR = sub("^chr", "", CHR)) %>%
  dplyr::mutate(entrezgene_id = as.integer(entrezgene_id)) %>%
  droplevels() %>%
  dplyr::select(-group, -width)

## hg38 ====
id_hg38 <- subset(
  genes(TxDb.Hsapiens.UCSC.hg38.knownGene,
    single.strand.genes.only = FALSE
  ),
  gene_id %in% unique(map$entrezgene_id)
) %>%
  as.data.frame() %>%
  dplyr::rename(
    entrezgene_id = group_name,
    CHR = seqnames,
    START_hg38 = start,
    END_hg38 = end,
    strand_hg38 = strand
  ) %>%
  dplyr::group_by(entrezgene_id) %>%
  dplyr::filter(any(CHR %in% paste0("chr", c(1:22, "X", "Y")))) %>% # Keep only groups with at least one valid chromosome entry
  dplyr::filter(CHR %in% paste0("chr", c(1:22, "X", "Y")) | n() == 1) %>% # Keep valid chromosomes or keep if only one entry exists
  dplyr::ungroup() %>%
  dplyr::mutate(CHR = sub("^chr", "", CHR)) %>%
  dplyr::mutate(entrezgene_id = as.integer(entrezgene_id)) %>%
  droplevels() %>%
  dplyr::select(-group, -width)

## combine builds ====
id_gene <- dplyr::full_join(id_hg19, id_hg38,
  by = c(
    "entrezgene_id" = "entrezgene_id",
    "CHR" = "CHR"
  )
)

# join map and build info ====
map <- map %>%
  dplyr::full_join(id_gene,
    by = c(
      "entrezgene_id" = "entrezgene_id",
      "CHR" = "CHR"
    )
  )

# join map and data ====
data_map_uniprot <- data %>%
  dplyr::left_join(map,
    by = c("UNIPROT" = "uniprot_gn_id")
  )

data_map_hgnc <- data %>%
  dplyr::left_join(map,
    by = c("Target" = "hgnc_symbol")
  )

data_map <- bind_rows(
  data_map_uniprot,
  data_map_hgnc
) %>%
  dplyr::group_by(UNIPROT) %>%
  dplyr::summarise(dplyr::across(dplyr::everything(), ~ dplyr::coalesce(.x[1], .x[2]))) %>%
  dplyr::ungroup() %>%
  distinct() %>%
  as.data.frame()

columns <- c(
  "UNIPROT", "Target", "TargetFullName",
  "uniprot_gn_id", "uniprot_gn_symbol",
  "entrezgene_id", "entrezgene_accession",
  "hgnc_id", "hgnc_symbol", "ensembl_gene_id", "external_gene_name", "gene_biotype",
  "CHR", "START_hg19", "END_hg19", "strand_hg19", "START_hg38", "END_hg38", "strand_hg38"
)
# Ensure columns exist
data_map_cols <- intersect(columns, colnames(data_map))
data_map <- data_map[, data_map_cols]

## write
write.table(
  x = data_map,
  file = paste0("data-raw/raw_data/mapping_", VAR_build, "_olink.txt"),
  sep = "\t", col.names = T, row.names = F, quote = FALSE
)

mapping_GRCh38_p14_olink <- data_map
usethis::use_data(mapping_GRCh38_p14_olink, overwrite = TRUE)
