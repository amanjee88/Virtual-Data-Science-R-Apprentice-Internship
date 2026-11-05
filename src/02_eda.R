# Week 2: Exploratory data analysis and visualisation (base R)
# Run from the project root: source("src/02_eda.R")
d <- read.csv("data/processed/wine_clean.csv", stringsAsFactors=FALSE)
d$cultivar <- factor(d$cultivar, levels=paste("Cultivar",1:3))
features <- setdiff(names(d), c("record_id","cultivar"))
dir.create("reports/figures", recursive=TRUE, showWarnings=FALSE)
# Univariate summary statistics
stats <- do.call(rbind, lapply(features, function(nm) {
  x <- d[[nm]]
  data.frame(feature=nm, mean=mean(x), sd=sd(x), minimum=min(x),
             q1=unname(quantile(x,.25)), median=median(x),
             q3=unname(quantile(x,.75)), maximum=max(x))
}))
write.csv(stats,"data/processed/summary_statistics_R.csv",row.names=FALSE)
class_counts <- table(d$cultivar)
png("reports/figures/01_class_distribution_R.png",width=1200,height=720,res=150)
barplot(class_counts, main="Wine records by cultivar", xlab="Cultivar", ylab="Number of records")
dev.off()
png("reports/figures/02_alcohol_by_cultivar_R.png",width=1200,height=720,res=150)
boxplot(alcohol ~ cultivar, data=d, main="Alcohol distribution by cultivar", xlab="Cultivar", ylab="Alcohol measurement")
dev.off()
png("reports/figures/03_correlation_heatmap_R.png",width=1300,height=1100,res=150)
c <- cor(d[features]); image(seq_len(ncol(c)),seq_len(nrow(c)),t(c[nrow(c):1,]),
  axes=FALSE, main="Correlation matrix of chemical measurements", xlab="", ylab="")
axis(1,at=seq_len(ncol(c)),labels=colnames(c),las=2,cex.axis=.65)
axis(2,at=seq_len(nrow(c)),labels=rev(rownames(c)),las=2,cex.axis=.65)
dev.off()
png("reports/figures/04_phenols_scatter_R.png",width=1200,height=800,res=150)
cols <- as.integer(d$cultivar)
plot(d$flavanoids,d$total_phenols,col=cols,pch=19,
     xlab="Flavanoids",ylab="Total phenols",main="Flavanoids vs total phenols by cultivar")
legend("topleft",legend=levels(d$cultivar),col=1:3,pch=19,bty="n")
dev.off()
png("reports/figures/05_color_intensity_boxplot_R.png",width=1200,height=720,res=150)
boxplot(color_intensity ~ cultivar, data=d, main="Color intensity by cultivar", xlab="Cultivar", ylab="Color intensity")
dev.off()
write.csv(aggregate(d[features],list(cultivar=d$cultivar),mean),
          "data/processed/class_means_R.csv",row.names=FALSE)
cat("EDA complete. Records:",nrow(d)," Features:",length(features),"\n")
