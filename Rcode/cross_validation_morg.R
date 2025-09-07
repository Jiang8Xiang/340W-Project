rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(pracma)
library(gbm)
library(ROCR)
library(caret)
library(doParallel)
library(parallel)
numcores <- detectCores() - 1L
cl <- makePSOCKcluster(numcores)
registerDoParallel(cl)

#data_directory <- "/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/REPL_pkg/data/"
#Rdata_directory <- "C:/Users/uctpdtz/Dropbox/MinimumWageParticipation/Rdata/"
load(file=paste0(data_directory, "full_sample_1979_2019.RData"))



data.train$relMW_groups<-as.factor(
  ifelse(data.train$relMW_groups==TRUE, "Y", "N"))


grid <- expand.grid(interaction.depth=c(2,4,6), # Depth of variable interactions
                    n.trees=c(2500, 4000, 6000) ,	        # Num trees to fit
                    #n.trees=c(100, 200) ,	        # Num trees to fit
                    shrinkage=seq(0.001,0.01,0.002),		
                    n.minobsinnode = 10 
)
#											

# Set up to do parallel processing   
trainX<-subset(data.train,  select=c(race,sex, hispanic, age,
                                     dmarried, educcat,
                                     ruralstatus, veteran ))


ctrl <- trainControl(method = "cv", 
                     number=10,
                     summaryFunction=twoClassSummary,	# Use ROC
                     classProbs=TRUE,
                     allowParallel = TRUE)
gc()
set.seed(12345)
gbm.tune2 <- train(x=trainX,y=data.train$relMW_groups,
                   method = "gbm",
                   metric = "ROC",
                   trControl = ctrl,
                   tuneGrid=grid,
                   verbose=FALSE)

gc()

# Look at the tuning results
# Note that ROC was the performance criterion used to select the optimal model.   

plot(gbm.tune2)  		# Plot the performance of the training models


gbm.tune2$bestTune
rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
gc()
