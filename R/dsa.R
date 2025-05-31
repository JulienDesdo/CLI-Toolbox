args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  stop("Usage: Rscript data-analyzer.R <fichier.csv> [--deep]")
}

file_path <- args[1]
deep_mode <- "--deep" %in% args

# Lire les données
df <- read.csv(file_path, stringsAsFactors = FALSE)

cat(" Aperçu du dataset:\n")
cat("• Dimensions :", nrow(df), "lignes x", ncol(df), "colonnes\n\n")

cat(" Colonnes :\n")
print(names(df))
cat("\n")

cat(" Types de données :\n")
print(sapply(df, class))
cat("\n")

cat(" Valeurs manquantes :\n")
print(colSums(is.na(df)))
cat("\n")

cat(" Statistiques générales :\n")
print(summary(df))
cat("\n")

if (deep_mode) {
  cat(" Analyse avancée (--deep):\n\n")
  
  ## Constantes
  const_cols <- names(df)[sapply(df, function(col) length(unique(col)) == 1)]
  if (length(const_cols) > 0) {
    cat("• Colonnes constantes :", paste(const_cols, collapse=", "), "\n")
  }
  
  ## Uniques
  unique_cols <- names(df)[sapply(df, function(col) length(unique(col)) == nrow(df))]
  if (length(unique_cols) > 0) {
    cat("• Colonnes uniques :", paste(unique_cols, collapse=", "), "\n")
  }
  
  ## Variables catégorielles (textes)
  cat("\n Colonnes catégorielles (top 5 valeurs) :\n")
  cat_cols <- names(df)[sapply(df, is.character)]
  for (col in cat_cols) {
    top_vals <- sort(table(df[[col]]), decreasing = TRUE)[1:5]
    cat(paste0("- ", col, " : "))
    print(top_vals)
    cat("\n")
  }
  
  ## Variables numériques : détection outliers simples
  num_cols <- names(df)[sapply(df, is.numeric)]
  cat("Valeurs aberrantes (z-score > 3) :\n")
  for (col in num_cols) {
    z <- scale(df[[col]])
    outliers <- sum(abs(z) > 3, na.rm = TRUE)
    if (outliers > 0) {
      cat(paste0("- ", col, " : ", outliers, " valeurs hors norme\n"))
    }
  }
  
  ## Corrélations (simplifiées)
  if (length(num_cols) >= 2) {
    cat("\n Corrélations entre variables numériques :\n")
    cor_matrix <- cor(df[num_cols], use="complete.obs")
    print(round(cor_matrix, 2))
  }
}
