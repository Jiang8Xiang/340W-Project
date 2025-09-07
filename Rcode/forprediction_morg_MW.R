rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
gc()
library(doParallel)
registerDoParallel(4)
library(glmnet)
library(DMwR)
library(randomForest)
library(foreign)
library(gbm)
library(ROCR)
library(e1071)
library(Matrix)
library(SparseM)
library(PRROC)
library(tree)
library(rpart)
library(partykit)
library(caret)
library(MLmetrics)
library(caTools)
library(haven)
#######################################################################################
##################             Prediction                          ####################
#######################################################################################
gc()

dataall<-read_dta(paste0(data_directory, "forpredictionmorg_fewvars_eventstudy_2019.dta"))
dataall <- zap_formats(dataall)  
dataall <- zap_label(dataall) 
dataall <- zap_labels(dataall)

dataall$relMW_groups<-(dataall$relMW_groups!=3)
dataall$relMW_groups <- factor(dataall$relMW_groups)
dataall$agecat <- factor(dataall$agecat)
dataall$educcat <- factor(dataall$educcat)
dataall$ruralstatus <- factor(dataall$ruralstatus)
dataall$sex <- factor(dataall$sex)
dataall$hispanic <- factor(dataall$hispanic)
dataall$dmarried <- factor(dataall$dmarried)
dataall$race <- factor(dataall$race)
dataall$veteran<-factor(dataall$veteran)

load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
load(file=paste0(data_directory, "prediction_model_1979_2019.RData"))

gc()


a<-as.numeric(min(dataall$year))
b<-as.numeric(max(dataall$year))
datatemp<-subset(dataall, year==a)

levels(datatemp$educcat) <- levels(data.train$educcat)
levels(datatemp$ruralstatus) <- levels(data.train$ruralstatus)
levels(datatemp$sex) <- levels(data.train$sex)
levels(datatemp$hispanic) <- levels(data.train$hispanic)
levels(datatemp$dmarried) <- levels(data.train$dmarried)
levels(datatemp$race) <- levels(data.train$race)



gc()
boost.preds2 = predict(boost.income,type="response",newdata=datatemp, n.trees = 4000)
gc()
datatemp$boost.preds<-boost.preds2


for (i in (a+1):b)  {
  gc()
  datatemp2<-subset(dataall, year==i)
  
  levels(datatemp2$educcat) <- levels(data.train$educcat)
  levels(datatemp2$ruralstatus) <- levels(data.train$ruralstatus)
  levels(datatemp2$sex) <- levels(data.train$sex)
  levels(datatemp2$hispanic) <- levels(data.train$hispanic)
  levels(datatemp2$dmarried) <- levels(data.train$dmarried)
  levels(datatemp2$race) <- levels(data.train$race)
  
  boost.preds2 = predict(boost.income,type="response",newdata=datatemp2, n.trees = 4000)
  datatemp2$boost.preds<-boost.preds2
  datatemp <- rbind(datatemp, datatemp2)
  rm(datatemp2)
  print(i)
  flush.console()
  gc()
}
write.dta(datatemp, paste0(data_directory, "CPSmorg_MLpredprobsonly_1979_2019.dta"))
gc()



