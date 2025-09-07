####################################################################
#################          Logit                    ################
####################################################################

rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))


glm.fit<-glm(  relMW_groups ~ age+educcat, 
               data = data.train, family="binomial"
)

relMW_groups_test<-data3$relMW_groups

glm.probs=predict(glm.fit,type="response", newdata = data3)
glm.prediction = prediction(glm.probs, relMW_groups_test)
glm.perf2 = performance(glm.prediction,"prec","rec")
glm.auc2<-performance(glm.prediction,"auc")@y.values[[1]]


rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
glm_auc_pr<-trapz(as.vector(glm.perf2@x.values)[[1]][-1], as.vector(glm.perf2@y.values)[[1]][-1])
save.image(file=paste0(data_directory, "basic_logistic_2019.RData"))
