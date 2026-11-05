# Week 3: Data cleaning and quality assessment
# Run from the project root: source("src/01_clean_data.R")
raw_path <- "data/raw/wine_recognition_raw.csv"
if (!file.exists(raw_path)) stop("Raw data file not found. Run this script from the project root.")
raw <- read.csv(raw_path, check.names = FALSE, stringsAsFactors = FALSE)
original_names <- names(raw)
clean_names <- tolower(gsub("[^A-Za-z0-9]+", "_", original_names))
clean_names <- gsub("(^_|_$)", "", clean_names)
names(raw) <- clean_names
# Keep the shortened identifier consistent with the cleaned report schema.
names(raw)[names(raw) == "od280_od315_of_diluted_wines"] <- "od280_od315"
if (!"class" %in% names(raw)) stop("Expected class field is missing.")
names(raw)[names(raw) == "class"] <- "cultivar_code"
feature_cols <- setdiff(names(raw), "cultivar_code")
for (nm in feature_cols) raw[[nm]] <- as.numeric(raw[[nm]])
raw$record_id <- seq_len(nrow(raw))
raw$cultivar <- factor(paste("Cultivar", raw$cultivar_code),
                       levels = paste("Cultivar", 1:3))
clean <- raw[c("record_id", "cultivar", feature_cols)]
missing_total <- sum(is.na(clean))
duplicate_total <- sum(duplicated(clean[, setdiff(names(clean), "record_id")]))
if (missing_total > 0) {
  # No missing values are expected in this release; stop rather than silently impute.
  stop("Missing values were detected. Review and document an explicit imputation rule before proceeding.")
}
# IQR outlier flags are diagnostic only. Potentially valid extreme values are retained.
outlier_rows <- list()
for (nm in feature_cols) {
  q <- quantile(clean[[nm]], c(.25, .75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  lo <- q[1] - 1.5 * iqr
  hi <- q[2] + 1.5 * iqr
  ix <- which(clean[[nm]] < lo | clean[[nm]] > hi)
  if (length(ix)) outlier_rows[[nm]] <- data.frame(
    record_id = clean$record_id[ix], cultivar = clean$cultivar[ix],
    feature = nm, value = clean[[nm]][ix], lower_fence = lo, upper_fence = hi
  )
}
outliers <- if (length(outlier_rows)) do.call(rbind, outlier_rows) else data.frame()
quality <- do.call(rbind, lapply(feature_cols, function(nm) {
  q <- quantile(clean[[nm]], c(.25,.75), na.rm=TRUE); iqr <- q[2]-q[1]
  data.frame(feature=nm, missing_values=sum(is.na(clean[[nm]])),
             distinct_values=length(unique(clean[[nm]])), minimum=min(clean[[nm]]),
             maximum=max(clean[[nm]]), iqr_outlier_flags=sum(clean[[nm]] < q[1]-1.5*iqr | clean[[nm]] > q[2]+1.5*iqr))
}))
write.csv(clean, "data/processed/wine_clean.csv", row.names=FALSE)
write.csv(quality, "data/processed/quality_audit_R.csv", row.names=FALSE)
write.csv(outliers, "data/processed/outlier_flags_R.csv", row.names=FALSE)
cat("Rows:", nrow(clean), " Features:", length(feature_cols),
    " Missing cells:", missing_total, " Duplicate observations:", duplicate_total, "\n")
