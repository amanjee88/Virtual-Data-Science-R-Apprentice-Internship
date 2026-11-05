# Week 3: Reproducible preprocessing and feature scaling
# Full-data z-scores are exported only as a teaching/demo transformation.
# The model script below fits scaling parameters on training data only.
d <- read.csv("data/processed/wine_clean.csv", stringsAsFactors=FALSE)
d$cultivar <- factor(d$cultivar, levels=paste("Cultivar",1:3))
features <- setdiff(names(d),c("record_id","cultivar"))
scaled <- d[c("record_id","cultivar")]
for (nm in features) scaled[[paste0("z_",nm)]] <- as.numeric(scale(d[[nm]]))
write.csv(scaled,"data/processed/wine_scaled_demo_R.csv",row.names=FALSE)
# Create a deterministic stratified split only if the supplied split file is absent.
if (!file.exists("data/processed/split_assignment.csv")) {
  set.seed(2026)
  assignment <- rep(NA_character_,nrow(d))
  for (lev in levels(d$cultivar)) {
    ix <- which(d$cultivar==lev)
    n_test <- round(length(ix)*0.30)
    test_ix <- sample(ix,n_test)
    assignment[test_ix] <- "test"
  }
  assignment[is.na(assignment)] <- "train"
  write.csv(data.frame(record_id=d$record_id,split=assignment),
            "data/processed/split_assignment.csv",row.names=FALSE)
}
cat("Preprocessing demo created. Model scaling will be fitted using training records only.\n")
