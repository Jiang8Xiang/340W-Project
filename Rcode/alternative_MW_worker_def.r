
for (cutoff in c(103,seq(110,175, 5), 200)){
  rm(list=ls()[!((stringr::str_detect(ls(), "directory")) | 
                   (stringr::str_detect(ls(), "cutoff"))) ])  
  gc()
  closeAllConnections()
  
  library(pracma)
  library(gbm)
  library(ROCR)
  


  
  data<-read.csv(paste0(data_directory, "fortraining_eventstudy_1979_2019_c", cutoff, ".csv")
                 , header=TRUE, sep = ",", stringsAsFactors = T)
  
  data$relMW_groups<-(data$relMW_groups!=3)
  data$relMW_groups <- factor(data$relMW_groups)
  data$agecat <- factor(data$agecat)
  data$educcat <- factor(data$educcat)
  data$ruralstatus <- factor(data$ruralstatus)
  data$sex <- factor(data$sex)
  data$hispanic <- factor(data$hispanic)
  data$dmarried <- factor(data$dmarried)
  data$race <- factor(data$race)
  data$veteran<-factor(data$veteran)
  
  
  
  
  data2 <-subset(data, (training== 1 & (quarterdate<136 | quarterdate>142)) , select=c(race,sex, hispanic, agecat, age,
                                                                                       dmarried, educcat, relMW_groups,
                                                                                       ruralstatus,veteran
  )) 
  
  
  data2$relMW_groups <- factor(data2$relMW_groups)
  
  set.seed(12345)
  smp_size <- 150000
  train_ind <- sample((nrow(data2)), size = smp_size)
  data.train <- data2[train_ind, ]
  data3<-subset(data2[-train_ind, ],  select=c(age, race,sex, hispanic, agecat,
                                               dmarried, educcat, relMW_groups,
                                               ruralstatus, veteran
  )) 
  data3$relMW_groups <- factor(data3$relMW_groups)
  gc()
  
  set.seed(12345)
  data.train$relMW_groups2<-
    ifelse(data.train$relMW_groups==TRUE, 1, 0)
  
  gc()
  boost.income = gbm(relMW_groups2~age+race+sex+hispanic+dmarried+
                       ruralstatus+educcat+veteran, 
                     data = data.train, 
                     n.trees = 4000, shrinkage = 0.005, interaction.depth = 6)
  gc()
  
  relMW_groups_test<-
    ifelse(data3$relMW_groups==TRUE, 1, 0)
  
  gc()
  boost.preds2 = predict(boost.income,type="response",newdata=data3, n.trees = 4000)
  boost.prediction = prediction(boost.preds2, relMW_groups_test)
  boost.predict=predict(boost.income, newdata=data3, n.trees=4000)
  boost.perf = performance(boost.prediction,"tpr","fpr")
  boost.perf2 = performance(boost.prediction,"prec","rec")
  boost.auc<-performance(boost.prediction,"auc")@y.values[[1]]
  gc()
  
  rm(list = ls(pattern = "data")[!(stringr::str_detect( ls(pattern = "data")  , "directory")  )])
  save.image(file=paste0(data_directory, "prediction_model_1979_2019_c", cutoff, ".RData"))
  
  
  
  
    
}
