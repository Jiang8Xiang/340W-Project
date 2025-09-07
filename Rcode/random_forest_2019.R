rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
library(ranger)
library(doParallel)
library(parallel)
library(caret)
numcores <- detectCores() - 3L

##################################################
######       Bagging & Random Forest        ######
##################################################
gc()
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
rm(data)
gc()
set.seed(12345)
for(i in c(2,8)) {
  gc()
  fit=ranger(relMW_groups~age+race+sex+hispanic+dmarried+
                     ruralstatus+educcat+veteran
                   , data=data.train, mtry=i, num.trees = 2000, num.threads = numcores,
             respect.unordered.factors = TRUE, 
             write.forest = T, probability = T)
  assign(paste("rf.income",i,sep=''),get("fit"))
  rm(fit)
  gc()
  print(i)
  flush.console()  
}
relMW_groups_test<-data3$relMW_groups

for(i in c(2,8)) {
  gc()
  assign("bag.income", get(paste("rf.income",i,sep='')))  
  #bag.preds2 = predict(bag.income,type="prob",newdata=data3)[,2]
  temp = predict(bag.income, data3, num.threads = numcores)
  bag.preds2 = temp$predictions[,2]
  bag.prediction = prediction(bag.preds2, relMW_groups_test)
  bag.perf = performance(bag.prediction,"tpr","fpr")
  bag.perf2 = performance(bag.prediction,"prec","rec")
  asd<-performance(bag.prediction,"auc")@y.values[[1]]
  assign(paste("rf.perf",i,sep=''),get("bag.perf"))
  assign(paste("rf.perf2",i,sep=''),get("bag.perf2"))
  assign(paste("rf.preds",i,sep=''),get("bag.preds2"))
  assign(paste("rf.auc",i,sep=''),get("asd"))
  rm(bag.preds2)
  rm(bag.prediction)
  rm(bag.predict)
  rm(bag.perf)
  rm(bag.perf2)
  rm(asd)
  gc()
  print(i)
  flush.console()  
}

rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
rf_auc_pr <- trapz(as.vector(rf.perf22@x.values)[[1]][-1], as.vector(rf.perf22@y.values)[[1]][-1])
save.image(file=paste0(data_directory, "random_forest_2019.RData"))

