# Week 4: Three-class predictive analysis using R
# Dependencies: recommended R packages MASS and nnet.
if (!requireNamespace("MASS",quietly=TRUE)) stop("Install MASS: install.packages('MASS')")
if (!requireNamespace("nnet",quietly=TRUE)) stop("Install nnet: install.packages('nnet')")
d <- read.csv("data/processed/wine_clean.csv", stringsAsFactors=FALSE)
d$cultivar <- factor(d$cultivar, levels=paste("Cultivar",1:3))
assignment <- read.csv("data/processed/split_assignment.csv",stringsAsFactors=FALSE)
stopifnot(nrow(assignment)==nrow(d),all(assignment$record_id==d$record_id))
train <- d[assignment$split=="train",,drop=FALSE]
test <- d[assignment$split=="test",,drop=FALSE]
features <- setdiff(names(d),c("record_id","cultivar"))
# Fit center and scale on training data only; apply unchanged parameters to test data.
centers <- sapply(train[features],mean)
scales <- sapply(train[features],sd)
scales[scales==0] <- 1
scale_frame <- function(x) as.data.frame(sweep(sweep(x[,features,drop=FALSE],2,centers,"-"),2,scales,"/"))
train_x <- scale_frame(train); test_x <- scale_frame(test)
train_y <- train$cultivar; test_y <- test$cultivar
set.seed(2026)
lda_fit <- MASS::lda(x=train_x, grouping=train_y)
lda_pred <- predict(lda_fit,newdata=test_x)
lda_class <- lda_pred$class; lda_prob <- lda_pred$posterior
train_model <- data.frame(cultivar=train_y,train_x,check.names=FALSE)
multinom_fit <- nnet::multinom(cultivar ~ ., data=train_model,
                               trace=FALSE, maxit=1000, MaxNWts=10000)
multinom_class <- predict(multinom_fit,newdata=test_x,type="class")
multinom_prob <- predict(multinom_fit,newdata=test_x,type="probs")
if (is.null(dim(multinom_prob))) multinom_prob <- matrix(multinom_prob,nrow=1)
class_levels <- levels(d$cultivar)
metric_row <- function(model_name, actual, predicted, probs) {
  cm <- table(factor(actual,levels=class_levels),factor(predicted,levels=class_levels))
  precision <- diag(cm)/pmax(colSums(cm),1)
  recall <- diag(cm)/pmax(rowSums(cm),1)
  f1 <- ifelse(precision+recall>0,2*precision*recall/(precision+recall),0)
  # Macro one-vs-rest AUC, computed from class probabilities using trapezoidal integration.
  auc_one <- function(y,p) {
    yy <- as.integer(y)
    thresholds <- sort(unique(c(Inf,p,-Inf)),decreasing=TRUE)
    tpr <- sapply(thresholds,function(t) sum(p>=t & yy==1)/sum(yy==1))
    fpr <- sapply(thresholds,function(t) sum(p>=t & yy==0)/sum(yy==0))
    ord <- order(fpr,tpr)
    sum(diff(fpr[ord])*(head(tpr[ord],-1)+tail(tpr[ord],-1))/2)
  }
  aucs <- sapply(seq_along(class_levels),function(k) auc_one(as.integer(actual==class_levels[k]),probs[,k]))
  data.frame(model=model_name,accuracy=sum(diag(cm))/sum(cm),
             macro_precision=mean(precision),macro_recall=mean(recall),
             macro_f1=mean(f1),macro_ovr_auc=mean(aucs))
}
metrics <- rbind(
  metric_row("Linear Discriminant Analysis",test_y,lda_class,as.matrix(lda_prob)),
  metric_row("Multinomial Logistic Regression",test_y,multinom_class,as.matrix(multinom_prob))
)
dir.create("outputs",showWarnings=FALSE)
write.csv(metrics,"outputs/model_metrics_R.csv",row.names=FALSE)
write.csv(as.data.frame.matrix(table(Actual=test_y,Predicted=lda_class)),
          "outputs/confusion_lda_R.csv")
write.csv(as.data.frame.matrix(table(Actual=test_y,Predicted=multinom_class)),
          "outputs/confusion_multinomial_R.csv")
predictions <- data.frame(record_id=test$record_id,actual=test_y,
                          lda_prediction=lda_class,multinomial_prediction=multinom_class)
for (k in seq_along(class_levels)) {
  predictions[[paste0("lda_prob_",k)]] <- lda_prob[,k]
  predictions[[paste0("multinom_prob_",k)]] <- multinom_prob[,k]
}
write.csv(predictions,"outputs/model_predictions_R.csv",row.names=FALSE)
# One-vs-rest ROC figures for both models.
roc_plot <- function(actual,probs,file,title) {
  png(file,width=1200,height=900,res=150)
  plot(c(0,1),c(0,1),type="n",xlab="False positive rate",ylab="True positive rate",main=title)
  abline(0,1,lty=2)
  for (k in seq_along(class_levels)) {
    y <- as.integer(actual==class_levels[k]); p <- probs[,k]
    thresholds <- sort(unique(c(Inf,p,-Inf)),decreasing=TRUE)
    tpr <- sapply(thresholds,function(t) sum(p>=t & y==1)/sum(y==1))
    fpr <- sapply(thresholds,function(t) sum(p>=t & y==0)/sum(y==0))
    ord <- order(fpr,tpr); lines(fpr[ord],tpr[ord],lwd=2)
  }
  legend("bottomright",legend=class_levels,lwd=2,bty="n")
  dev.off()
}
roc_plot(test_y,as.matrix(lda_prob),"reports/figures/06_roc_lda_R.png","One-vs-rest ROC: LDA")
roc_plot(test_y,as.matrix(multinom_prob),"reports/figures/06_roc_multinomial_R.png","One-vs-rest ROC: Multinomial logistic regression")
cat("Model evaluation complete. Train:",nrow(train)," Test:",nrow(test),"\n")
print(metrics)
