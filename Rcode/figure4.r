rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(glmnet)
#library(DMwR)
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




load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
load(file=paste0(data_directory, "prediction_model_1979_2019.RData"))
a<-summary(boost.income)[,2]



a<-summary(boost.income)[,2]
pdf(paste0(figure_directory,"figure_4.pdf"), family="Times",
    width = 8, height = 5)
par(las=2) # make label text perpendicular to axis
par(mar=c(3,10,1,1)) # increase y-axis margin.
barplot(a, horiz=TRUE, names.arg=c("Age", "Education", 
                                   "Gender", "Marital Status", "Rural", 
                                    "Hispanic", "Race", "Veteran"), cex.names=1.5, 
        xlim = c(0,100))
dev.off()
