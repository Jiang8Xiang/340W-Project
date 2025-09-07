rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()

library(pracma)
library(gbm)
library(ROCR)


data<-read.csv(paste0(data_directory, "fortraining_eventstudy_1979_2019_c200.csv")
               , header=TRUE, sep = ",", stringsAsFactors = T)

data$agecat <- factor(data$agecat)
data$educcat <- factor(data$educcat)
data$ruralstatus <- factor(data$ruralstatus)
data$sex <- factor(data$sex)
data$hispanic <- factor(data$hispanic)
data$dmarried <- factor(data$dmarried)
data$race <- factor(data$race)
data$veteran<-factor(data$veteran)




data2 <-subset(data, (training== 1 & (quarterdate<136 | quarterdate>142)) , select=c(race,sex, hispanic, agecat, age,
                                                                                     dmarried, educcat, wage,
                                                                                     ruralstatus,veteran
)) 



set.seed(12345)
smp_size <- 150000
train_ind <- sample((nrow(data2)), size = smp_size)
data.train <- data2[train_ind, ]
data3<-subset(data2[-train_ind, ],  select=c(age, race,sex, hispanic, agecat,
                                             dmarried, educcat, wage,
                                             ruralstatus, veteran
)) 
gc()

set.seed(12345)

gc()
boost.income = gbm(wage~age+race+sex+hispanic+dmarried+
                     ruralstatus+educcat+veteran, 
                   data = data.train, 
                   n.trees = 4000, shrinkage = 0.005, interaction.depth = 6)
gc()


rm(list = ls(pattern = "data")[!(stringr::str_detect( ls(pattern = "data")  , "directory")  )])
save.image(file=paste0(data_directory, "prediction_model_1979_2019_wage.RData"))


