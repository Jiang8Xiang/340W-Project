rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
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

#Rdata_directory <- "C:/Users/mvp14/Desktop/temp/Seeing_beyond_the_trees_forAD/Rdata/"


gc()
rm(list = ls(pattern = "data")[!stringr::str_detect( ls(pattern = "data"), "directory")])
load(paste0(data_directory, "full_sample_1979_2019.RData"))
relMW_groups_test<-data3$relMW_groups
#Discrete
tree.income=tree(relMW_groups~agecat+race+sex+hispanic+dmarried+
                   ruralstatus+educcat+veteran
                 , data=data2)

par(mfrow=c(1,1))
summary(tree.income)
plot(tree.income)
text(tree.income, pretty=1)
op <- par(mar = rep(0, 4))
par(op)
#Changes for pretty picture
tree.income$frame$splits
tree.income$frame$splits[1,1]<-"<25"
tree.income$frame$splits[2,1]<-""
tree.income$frame$splits[4,1]<-""
tree.income$frame$splits[5,1]<-">19"
tree.income$frame$var
tree.income$frame$var<-c("Age >= 25              Age", "    SC, CG        LTHS, HSG ", "<leaf>", "<leaf>",  "Age <= 19     Age",
                         "<leaf>", "<leaf>")
pdf(paste0(figure_directory,"figure_1.pdf"), family="Times"
)
par(mar=c(1,1,1,1))
plot(tree.income)
text(tree.income, pretty=1)
dev.off()
