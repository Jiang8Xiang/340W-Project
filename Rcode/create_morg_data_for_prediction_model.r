rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()

library(pracma)
library(gbm)
library(ROCR)


#data_directory <- "/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/REPL_pkg/data/"
#Rdata_directory <- "C:/Users/uctpdtz/Dropbox/MinimumWageParticipation/Rdata/"

data<-read.csv(paste0(data_directory, "fortraining_eventstudy_1979_2019.csv")
               , header=TRUE, sep = ",", stringsAsFactors = T)
#setwd("C:/Users/uctpdtz/Dropbox/commute/data/")

#Use SMOTE!!!

#data$relMW_groups<-(data$relMW_groups==1)
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
save.image(file=paste0(data_directory, "full_sample_1979_2019.RData"))
