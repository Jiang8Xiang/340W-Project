rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(pracma)
library(gbm)
library(ROCR)


load(file=paste0(data_directory, "full_sample_1979_2019.RData"))


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

boost_auc_pr<-trapz(as.vector(boost.perf2@x.values)[[1]][-1], as.vector(boost.perf2@y.values)[[1]][-1])

boost.perf2017<-boost.perf2
plot(boost.perf2)
rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
save.image(file=paste0(data_directory, "prediction_model_1979_2019.RData"))
