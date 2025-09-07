rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
library(tree)
library(doParallel)
library(parallel)
numcores <- detectCores() - 3L


gc()
rm(list=ls()[!stringr::str_detect(ls(), "directory")])
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
relMW_groups_test<-data3$relMW_groups
#Continuous
tree.income=tree(relMW_groups~age+race+sex+hispanic+dmarried+
                   ruralstatus+educcat+veteran
                 , data=data2)

tree.preds2 = predict(tree.income,type="vector",newdata=data3)[,2]
bag.prediction = prediction(tree.preds2, relMW_groups_test)
tree.perf = performance(bag.prediction,"tpr","fpr")
tree.perf2 = performance(bag.prediction,"prec","rec")
tree.auc2<-performance(bag.prediction,"auc")@y.values[[1]]
rm(bag.prediction)
gc()

#pdf("D:/Research Related/dropboxdocuments/Dropbox/commute/figures/rf_SMOTE_AUC.pdf")
#par(mfrow=c(1,1))
#plot(rf.perf2,col=2,lwd=2)


rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
tree_auc_pr<-trapz(as.vector(tree.perf2@x.values)[[1]][-1], as.vector(tree.perf2@y.values)[[1]][-1])
save.image(file=paste0(data_directory, "tree_2019.RData"))
