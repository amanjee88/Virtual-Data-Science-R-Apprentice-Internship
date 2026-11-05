# Week 5: Build a compact results summary from the R model run.
m <- read.csv("outputs/model_metrics_R.csv",stringsAsFactors=FALSE)
lines <- c("WINE CULTIVAR CLASSIFICATION - FINAL MODEL SUMMARY", "",
           paste("Generated:",format(Sys.time(),"%Y-%m-%d %H:%M")), "",
           capture.output(print(m,row.names=FALSE)))
writeLines(lines,"outputs/final_model_summary_R.txt")
cat(paste(lines,collapse="\n"),"\n")
