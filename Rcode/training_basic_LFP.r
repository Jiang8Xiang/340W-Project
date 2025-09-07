rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(gbm)
library(ROCR)
library(haven)


data <- read_dta(file=paste0(data_directory, "fortraining_fewvars_IPUMS_basic_eventstudy_1986_2019_ML_LFP.dta"))
data <- zap_formats(data)  
data <- zap_label(data) 
data <- zap_labels(data)
data$educcat <- factor(data$educcat)

data$race[data$race==2L]<-0L
data$agecat <- factor(data$agecat)
data$ruralstatus <- factor(data$ruralstatus)
data$sex <- factor(data$sex)
data$hispanic <- factor(data$hispanic)
data$dmarried <- factor(data$dmarried)
data$race <- factor(data$race)
data$veteran<-factor(data$veteran)



data <- data[!is.na(data$switch_lfp),]


#Recreate the training/test data to include "black" indicator
data2 <-subset(data, (training== 1 & (quarterdate<136 | quarterdate>142)) , select=c(race,sex, hispanic, age,
                                                                                     dmarried, educcat, switch_lfp,
                                                                                     ruralstatus,veteran, black, nchlt5
)) 


data2$switch_lfp <- factor(data2$switch_lfp)

set.seed(12345)
smp_size <- 150000
train_ind <- sample((nrow(data2)), size = smp_size)
data.train <- data2[train_ind, ]
data3<-subset(data2[-train_ind, ],  select=c(age, race,sex, hispanic,
                                             dmarried, educcat, switch_lfp,
                                             ruralstatus, veteran, black, nchlt5
)) 
data3$switch_lfp <- factor(data3$switch_lfp)
gc()


table(data.train$race)
table(data.train$hispanic)

data.train$switch_lfp<-
  ifelse(data.train$switch_lfp=="1", 1, 0)

save.image(file=paste0(data_directory,"full_sample_1986_2019_lfp_child_less_5.RData"))



set.seed(12345)
gc()
boost.income = gbm(switch_lfp~age+race+sex+hispanic+dmarried+
                     ruralstatus+educcat+veteran+nchlt5, 
                   data = data.train, 
                   n.trees = 2500, shrinkage = 0.009, interaction.depth = 6)
gc()


relMW_groups_test<-
  ifelse(data3$switch_lfp=="1", 1, 0)

gc()
boost.preds2 = predict(boost.income,type="response",newdata=data3, n.trees = 2500)
boost.prediction = prediction(boost.preds2, relMW_groups_test)
boost.predict=predict(boost.income, newdata=data3, n.trees=2500)
boost.perf = performance(boost.prediction,"tpr","fpr")
boost.perf2 = performance(boost.prediction,"prec","rec")
boost.auc<-performance(boost.prediction,"auc")@y.values[[1]]
gc()

boost_auc_pr<-trapz(as.vector(boost.perf2@x.values)[[1]][-1], as.vector(boost.perf2@y.values)[[1]][-1])

boost.perf2017<-boost.perf2
plot(boost.perf2)
rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
save.image(file=paste0(data_directory, "prediction_model_1986_2019_switch_lfp_number_child_less_5.RData"))
