rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
library(glmnet)
library(doParallel)
library(parallel)
library(caret)
numcores <- detectCores() - 1L
cl <- makePSOCKcluster(numcores)
registerDoParallel(cl)




############################################################
############    Elastic-Net/Logistic           #############
############################################################

rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
rm(data)
gc()

ctrl <- trainControl(method = "cv", 
                     number=5,
                     summaryFunction=twoClassSummary,	# Use ROC
                     classProbs=TRUE,
                     allowParallel = TRUE)

data.train$age2<-(data.train$age)^2
data.train$age3<-(data.train$age)^3
data.train$age4<-(data.train$age)^4

data.train$relMW_groups<-plyr::revalue(data.train$relMW_groups, c("TRUE"="Yes", "FALSE"="No"))
set.seed(12345)
elnet_mod = train(
  relMW_groups ~ age3+ age4 + (race+sex+hispanic+age+dmarried+educcat+ruralstatus+veteran)^4 +
    (race+sex+hispanic+age2+dmarried+educcat+ruralstatus+veteran)^2, data = data.train,
  method = "glmnet",
  trControl = ctrl,
  tuneLength = 10,
  family = "binomial"
)

get_best_result = function(caret_fit) {
  best = which(rownames(caret_fit$results) == rownames(caret_fit$bestTune))
  best_result = caret_fit$results[best, ]
  rownames(best_result) = NULL
  best_result
}
get_best_result(elnet_mod)
coef(elnet_mod$finalModel , s=elnet_mod$bestTune$lambda, alpha=elnet_mod$bestTune$alpha )
outcomeName <- 'default'

predictorsNames <- c("age", "age2", "age3", "age4", "educcat", "race" , "sex", "hispanic", "dmarried","ruralstatus","veteran")
data3$age2<-(data3$age)^2
data3$age3<-(data3$age)^3
data3$age4<-(data3$age)^4

elastic_net.preds2 <- predict(object=elnet_mod, data3[,predictorsNames], type='prob')
elastic_net.prediction = prediction(elastic_net.preds2$Yes, data3$relMW_groups)
elastic_net.perf2 = performance(elastic_net.prediction,"prec","rec")
elastic_net.perf = performance(elastic_net.prediction,"tpr","fpr")
#stopCluster(cl)

rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
gc()
en_auc_pr<-trapz(as.vector(elastic_net.perf2@x.values)[[1]][-1], as.vector(elastic_net.perf2@y.values)[[1]][-1])
save.image(file=paste0(data_directory, "elastic_net_predictions_1979_2019.RData"))


