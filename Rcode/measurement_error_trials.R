rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(doParallel)
registerDoParallel(4)
library(glmnet)
library(DMwR)
library(foreign)
library(randomForest)
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
#Optimal cut points

data<-read.csv(paste0(data_directory, "forME_CPS1977_subMW_MW125.csv")
               , header=TRUE, sep = ",")

#data$relMW_groups<-(data$relMW_groups==1)
data$relMW_groups_w<-(data$relMW_groups_w!=3)
data$relMW_groups_w <- factor(data$relMW_groups_w)
data$relMW_groups_er<-(data$relMW_groups_er!=3)
data$relMW_groups_er <- factor(data$relMW_groups_er)
data$educcat <- factor(data$educcat)
data$ruralstatus <- factor(data$ruralstatus)
data$sex <- factor(data$gender)
data$hispanic <- factor(data$hispanic)
data$dmarried <- factor(data$dmarried)
data$race <- factor(data$race)
data$veteran<-factor(data$veteran)


set.seed(12345) # Set Seed so that same sample can be reproduced in future also
# Now Selecting 80% of data as sample from total 'n' rows of the data  
sample <- sample.int(n = nrow(data), size = floor(.8*nrow(data)), replace = F)
train <- data[sample, ]
test  <- data[-sample, ]

data2_w<-subset(train, select=c(race,sex, hispanic, age,
                              dmarried, educcat, relMW_groups_w,
                              ruralstatus, 
                              veteran
)) 

data2_er<-subset(train, select=c(race,sex, hispanic, age,
                              dmarried, educcat, relMW_groups_er,
                              ruralstatus, 
                              veteran
)) 

data3_w<-subset(test    , select=c(race,sex, hispanic, age,
                                 dmarried, educcat, relMW_groups_w,
                                 ruralstatus, 
                                 veteran
)) 

data3_er<-subset(test    , select=c(race,sex, hispanic, age,
                                 dmarried, educcat, relMW_groups_er,
                                 ruralstatus, 
                                 veteran
)) 

gc()
rm(test,train)
save.image(file=paste0(data_directory, "ml_sl_CPS1977.RData"))

rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()


####################################################################################
#######            Model based on worker-reported information         ##############
####################################################################################


load(paste0(data_directory, "ml_sl_CPS1977.RData"))

data2_w$relMW_groups_w<-as.factor(
  ifelse(data2_w$relMW_groups_w==TRUE, "Y", "N"))


grid <- expand.grid(interaction.depth=c( 4), # Depth of variable interactions
                    n.trees=c(3000) ,	        # Num trees to fit
                    shrinkage=seq(0.0005,0.002,0.0005),		
                    n.minobsinnode = c(5,10) 
)
#											

# Set up to do parallel processing   
trainX<-subset(data2_w,  select=c(race,sex, hispanic, age,
                                     dmarried, educcat,
                                     ruralstatus, veteran ))

ctrl <- trainControl(method = "cv", 
                     number=5,
                     summaryFunction=twoClassSummary,	# Use ROC
                     classProbs=TRUE,
                     allowParallel = TRUE)
gc()
set.seed(12345)
gbm.tune2 <- train(x=trainX,y=data2_w$relMW_groups_w,
                   method = "gbm",
                   metric = "ROC",
                   trControl = ctrl,
                   tuneGrid=grid,
                   verbose=FALSE)

gc()

# Look at the tuning results
# Note that ROC was the performance criterion used to select the optimal model.   

gbm.tune2$bestTune
#plot(gbm.tune)
plot(gbm.tune2)
rm(list = ls(pattern = "data")[!stringr::str_detect(ls(pattern = "data"), "directory")])
gc()


# gbm.tune2$bestTune
#n.trees interaction.depth shrinkage n.minobsinnode
#3    3000                 4     0.002              10

gc()



rm(list=ls()[!stringr::str_detect(ls(), "directory")])

gc()
load(file=paste0(data_directory, "ml_sl_CPS1977.RData"))

set.seed(12345)
data2_w$relMW_groups2<-
  ifelse(data2_w$relMW_groups_w==TRUE, 1, 0)

gc()
boost.income_w = gbm(relMW_groups2~age+race+sex+hispanic+dmarried+
                     ruralstatus+educcat+veteran, 
                   data = data2_w, 
                   n.trees = 3000, shrinkage = 0.002, interaction.depth = 4, n.minobsinnode = 10)
gc()

relMW_groups_test<-
  ifelse(data3_er$relMW_groups_er==TRUE, 1, 0)

gc()
boost.preds2_w = predict(boost.income_w,type="response",newdata=data3_er, n.trees = 3000)
boost.prediction_w = prediction(boost.preds2_w, relMW_groups_test)
boost.predict_w=predict(boost.income_w, newdata=data3_er, n.trees=3000)
boost.perf_w = performance(boost.prediction_w,"tpr","fpr")
boost.perf2_w = performance(boost.prediction_w,"prec","rec")
boost.auc_w<-performance(boost.prediction_w,"auc")@y.values[[1]]
gc()


rm(list = ls(pattern = "data")[!stringr::str_detect(ls(pattern = "data"), "directory")])
save.image(file=paste0(data_directory, "ml_sl_CPS1977_boost_w.RData"))



####################################################################################
#######            Model based on employed-reported information         ############
####################################################################################



load(paste0(data_directory, "ml_sl_CPS1977.RData"))

data2_er$relMW_groups_er<-as.factor(
  ifelse(data2_er$relMW_groups_er==TRUE, "Y", "N"))


grid <- expand.grid(interaction.depth=c( 2, 4, 6), # Depth of variable interactions
                    n.trees=c(2000, 3000) ,	        # Num trees to fit
                    shrinkage=seq(0.001,0.01,0.001),		
                    n.minobsinnode = c(5,10) 
)
#											

# Set up to do parallel processing   
trainX<-subset(data2_er,  select=c(race,sex, hispanic, age,
                                  dmarried, educcat,
                                  ruralstatus, veteran ))

ctrl <- trainControl(method = "cv", 
                     number=5,
                     summaryFunction=twoClassSummary,	# Use ROC
                     classProbs=TRUE,
                     allowParallel = TRUE)
gc()
set.seed(12345)
gbm.tune2 <- train(x=trainX,y=data2_er$relMW_groups_er,
                   method = "gbm",
                   metric = "ROC",
                   trControl = ctrl,
                   tuneGrid=grid,
                   verbose=FALSE)

gc()

# Look at the tuning results
# Note that ROC was the performance criterion used to select the optimal model.   

gbm.tune2$bestTune
#plot(gbm.tune)
plot(gbm.tune2)
rm(list = ls(pattern = "data")[!stringr::str_detect(ls(pattern = "data"), "directory")])
gc()


# gbm.tune2$bestTune
#n.trees interaction.depth shrinkage n.minobsinnode
#3    3000                 4     0.002             10

gc()



rm(list=ls()[!stringr::str_detect(ls(), "directory")])

gc()
rm(list=ls()[!stringr::str_detect(ls(), "directory")])
load(file=paste0(data_directory, "ml_sl_CPS1977.RData"))

set.seed(12345)
data2_er$relMW_groups2<-
  ifelse(data2_er$relMW_groups_er==TRUE, 1, 0)

gc()
boost.income_er = gbm(relMW_groups2~age+race+sex+hispanic+dmarried+
                       ruralstatus+educcat+veteran, 
                     data = data2_er, 
                     n.trees = 3000, shrinkage = 0.002, interaction.depth = 4, n.minobsinnode = 5)
gc()

relMW_groups_test<-
  ifelse(data3_er$relMW_groups_er==TRUE, 1, 0)

gc()
boost.preds2_er = predict(boost.income_er,type="response",newdata=data3_er, n.trees = 3000)
boost.prediction_er = prediction(boost.preds2_er, relMW_groups_test)
boost.predict_er=predict(boost.income_er, newdata=data3_er, n.trees=3000)
boost.perf_er = performance(boost.prediction_er,"tpr","fpr")
boost.perf2_er = performance(boost.prediction_er,"prec","rec")
boost.auc_er<-performance(boost.prediction_er,"auc")@y.values[[1]]
gc()

plot(boost.perf2_er)

rm(list = ls(pattern = "data")[!stringr::str_detect(ls(pattern = "data"), "directory")])
save.image(file=paste0(data_directory, "ml_sl_CPS1977_boost_er.RData"))





#####################################################################################
##############            Plot findings                                  ############
#####################################################################################
rm(list=ls()[!stringr::str_detect(ls(), "directory")])
load(file=paste0(data_directory, "ml_sl_CPS1977.RData"))
load(file=paste0(data_directory, "ml_sl_CPS1977_boost_er.RData"))
load(file=paste0(data_directory, "ml_sl_CPS1977_boost_w.RData"))


statadata<-data.frame(boost.preds2_w, boost.preds2_er)
names(statadata)[names(statadata) == "boost.preds2_w"] <- "pred_prob_worker_reported"
names(statadata)[names(statadata) == "boost.preds2_er"] <- "pred_prob_employer_reported"

write.dta(statadata, paste0(data_directory, "CPS_1977_pred_probs.dta"))

