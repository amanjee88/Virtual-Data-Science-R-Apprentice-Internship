# Run from the project root with: Rscript src/run_all.R
source("src/01_clean_data.R")
source("src/02_eda.R")
source("src/03_preprocess.R")
source("src/04_modeling.R")
source("src/05_final_summary.R")
cat("Project workflow finished. Check data/processed, reports/figures, and outputs.\n")
