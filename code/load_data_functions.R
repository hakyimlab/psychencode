# -----------------------------------------------------------------------------
# LOAD GENCODE DATA

load_gencode_df <- function() {
  gencode_df <- read.table(glue::glue("{DATA}/gencode_v26_ld_region_annotated.txt.gz"), header = TRUE)
  gencode_df <- (gencode_df %>% select(c(gene_id, gene_name, chromosome, region_id)))
  gencode_df$gene_id <- gsub("\\..*", "", gencode_df$gene_id)
  return(gencode_df)
}

# -----------------------------------------------------------------------------
# LOAD AND JOIN WITH GENCODE DATA

load_truebetas <- function(fp, gencode_df) {

  # Load true betas
  df <- read.table(fp, header=TRUE)

  df$gene_id <- gsub("\\..*", "", df$gene_id)

  df <- left_join(df, gencode_df, by='gene_id')
}

load_fastenloc_coloc_result<- function(fp) {
  # Read colocalization file
  df <- read.table(fp, header=TRUE)

  # Remove trailing colon and decimals from Ensembl gene IDs
  df$Signal <- gsub("\\:.*", "", df$Signal)
  return(df)
}

load_predicted_expression <- function(fp, gencode_df) {
  df <- read.table(file=fp, sep="\t", quote="", comment.char="", skip = 1, header = TRUE)
  # Retain the column names
  cols <- read.table(file=fp, sep="\t", quote="", comment.char="", nrows = 1)
  # Fill the column names
  colnames(df) <- unname(unlist(cols[1,]))
  ## Melt the data so each row is FID, IID, gene_id, predicted_expression
  df <- df %>%
    pivot_longer(
      cols = starts_with("ENSG"),
      names_to = "gene_id",
      values_to = "predicted_expression",
      values_drop_na = TRUE
    )

  #Remove trailing decimal from Ensembl gene IDs
  df$gene_id <- gsub("\\..*", "", df$gene_id)

  # Join dataframes
  df <- left_join(df, gencode_df, by='gene_id')
  return(df)
}

load_prediction_summary <- function(fp, gencode_df){
  # Load prediction summary
  df <- read.table(fp, header=TRUE)
  df$gene <- gsub("\\..*", "", df$gene)

  # gencode_df already has gene names, so we will delete the column loaded from the prediction summary
  df <- (df %>% select(-c(gene_name)))

  # Join dataframes
  df <- left_join(df, gencode_df, by=c('gene'='gene_id'))
}

load_predixcan_association <- function(fp, gencode_df){
  # Load PrediXcan association df
  df <- read.table(fp, header=TRUE)
  df$gene <- gsub("\\..*", "", df$gene)

  # Join dataframes
  df <- left_join(df, gencode_df, by=c('gene'='gene_id'))

  return(df)
}

load_spredixcan_association <- function(fp, gencode_df){
  # Load PrediXcan association df
  df <- read.csv(fp, header=TRUE)
  df$gene <- gsub("\\..*", "", df$gene)

  # gencode_df already has gene names, so we will delete the column loaded from the SPrediXcan results
  df <- (df %>% select(-c(gene_name)))

  # Join dataframes
  df <- left_join(df, gencode_df, by=c('gene'='gene_id'))

  return(df)
}

load_twmr_results <- function(dir, gencode_df){
  twmr_df <- data.frame(gene=character(),
                        alpha=numeric(),
                        P=numeric(),
                        Nsnps=numeric(),
                        Ngene=numeric())
  gene_lst <- list.files(dir)
  gene_lst <- gene_lst[str_detect(gene_lst, "\\.alpha")]
  for (file in gene_lst) {
    df_i <- read.table(file.path(dir, file), header=TRUE)
    twmr_df <- rbind(twmr_df, df_i)
  }

  twmr_df <- left_join(twmr_df, gencode_df, by=c('gene'='gene_id'))
  return(twmr_df)
}
