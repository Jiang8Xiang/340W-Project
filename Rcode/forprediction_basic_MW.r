rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
#library(doParallel)
#registerDoParallel(4)
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

#dataall <- read.dta("D:/Research Related/dropboxdocuments/Dropbox/commute/data/forprediction_cpsbasic_alldata.dta")
# DC file path# dataall <- read.dta("D:/Research Related/dropboxdocuments/Dropbox/commute/data/forprediction_cpsbasic_alldata_withind_occ_hours_w2017.dta")

#data_directory <- "/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/REPL_pkg/data/"
#Rdata_directory <- "C:/Users/uctpdtz/Dropbox/MinimumWageParticipation/Rdata/"
#temporary_directory <- "C:/Users/uctpdtz/Dropbox/MinimumWageParticipation/Rdata/"


dataall <- read_dta(paste0(data_directory, "forprediction_fewvars_IPUMS_basic_eventstudy_1979_2019_ML_MW.dta"))
dataall <- zap_formats(dataall)  
dataall <- zap_label(dataall) 
dataall <- zap_labels(dataall)
dataall$educcat <- factor(dataall$educcat)

gc()
dataall$race[dataall$race==2L]<-0L
dataall$agecat <- factor(dataall$agecat)
dataall$ruralstatus <- factor(dataall$ruralstatus)
dataall$sex <- factor(dataall$sex)
dataall$hispanic <- factor(dataall$hispanic)
dataall$dmarried <- factor(dataall$dmarried)
dataall$race <- factor(dataall$race)
dataall$veteran<-factor(dataall$veteran)
gc()
load(file=paste0(data_directory,"full_sample_1979_2019.RData"))




load(file=paste0(data_directory,"prediction_model_1979_2019.RData"))

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
boost.preds2 = predict(boost.income,type="response",newdata=datatemp, n.trees = length(boost.income$trees))
gc()
datatemp$boost.preds<-boost.preds2
i <- a
saveRDS(datatemp, paste0(data_directory, "CPSbasic_MLpredprobs_",i,".rds"))
print(i)
rm(datatemp)
for (i in (a+1):b)  {
  gc()
  datatemp2<-subset(dataall, year==i)
  
  levels(datatemp2$educcat) <- levels(data.train$educcat)
  levels(datatemp2$ruralstatus) <- levels(data.train$ruralstatus)
  levels(datatemp2$sex) <- levels(data.train$sex)
  levels(datatemp2$hispanic) <- levels(data.train$hispanic)
  levels(datatemp2$dmarried) <- levels(data.train$dmarried)
  levels(datatemp2$race) <- levels(data.train$race)
  
  boost.preds2 = predict(boost.income,type="response",newdata=datatemp2, n.trees = length(boost.income$trees))
  datatemp2$boost.preds<-boost.preds2
  #datatemp <- rbind(datatemp, datatemp2)
  saveRDS(datatemp2, paste0(data_directory, "CPSbasic_MLpredprobs_",i,".rds"))
  rm(datatemp2)
  print(i)
  gc()
}

rm(dataall)
rm(data)
rm(data2)
rm(data3)
#Combine rds's
data_final <- data.frame()
for (i in c(a:b)){
  temp <- readRDS(paste0(data_directory, "CPSbasic_MLpredprobs_",i,".rds"))
  temp <- subset(temp, select = c(rowid, boost.preds))
  data_final <- dplyr::bind_rows(data_final, temp)
}


write.dta(data_final, paste0(data_directory, "CPSbasic_MLpredprobsonly_1979_2019.dta"))

gc()
