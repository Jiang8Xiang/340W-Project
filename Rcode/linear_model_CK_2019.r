##################################################################
###############         Linear model              ################
##################################################################


rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
gc()
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))

data.train$age2<-data.train$age^2
data.train$age3<-data.train$age^3

data.train$teen <- ifelse(data.train$age < 20, 
                          1, 0) 
data.train$race_2 <- ifelse(data.train$race == 1, 
                            1, 0) 
data.train$young_adult<-ifelse(data.train$age >= 20 & data.train$age<=25, 
                               1, 0) 
data.train$race_sex_teen <- interaction(data.train$race_2, data.train$teen, data.train$sex)
data.train$race_sex_ya <- interaction(data.train$race_2, data.train$young_adult, data.train$sex)

data.train$relMW_groups2<-as.numeric(data.train$relMW_groups)-1


lm_fit<-lm(relMW_groups2 ~ age3+age2+age+race_sex_teen+race_sex_ya+educcat+hispanic+race+sex+educcat:sex:age, 
           data = data.train)

data3$age2<-(data3$age)^2
data3$age2<-(data3$age)^2
data3$age3<-(data3$age)^3
data3$age4<-(data3$age)^4

data3$teen <- ifelse(data3$age < 20, 
                     1, 0) 
data3$race_2 <- ifelse(data3$race == 1, 
                       1, 0) 
data3$young_adult<-ifelse(data3$age >= 20 & data3$age<=25, 
                          1, 0) 
data3$race_sex_teen <- interaction(data3$race_2, data3$teen, data3$sex)
data3$race_sex_ya <- interaction(data3$race_2, data3$young_adult, data3$sex)


relMW_groups_test<-data3$relMW_groups
lm.probs=predict(lm_fit, newdata = data3)
lm.prediction = prediction(lm.probs, relMW_groups_test)
lm.perf2 = performance(lm.prediction,"prec","rec")
lm.auc2<-performance(lm.prediction,"auc")@y.values[[1]]

rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
lm_auc_pr<-trapz(as.vector(lm.perf2@x.values)[[1]][-1], as.vector(lm.perf2@y.values)[[1]][-1])
save.image(file=paste0(data_directory, "ml_sl_linearmodel_2019.RData"))

