rm(list=ls()[!stringr::str_detect(ls(), "directory")])
gc()
closeAllConnections()
library(ROCR)
library(gbm)
library(ggplot2)
library(caTools)
library(ggthemes)

gc()



load(file=paste0(data_directory, "full_sample_1979_2019.RData"))
load(file=paste0(data_directory, "prediction_model_1979_2019.RData"))
load(file=paste0(data_directory, "elastic_net_predictions_1979_2019.RData"))
load(file=paste0(data_directory, "ml_sl_linearmodel_2019.RData"))
load(file=paste0(data_directory, "basic_logistic_2019.RData"))
load(file=paste0(data_directory, "random_forest_2019.RData"))
load(file=paste0(data_directory, "tree_2019.RData"))


a<-as.numeric(summary(data3$relMW_groups)[2])
recallteen<-as.numeric(summary(data3$relMW_groups[data3$agecat==0])[2]/a)
precisteen<-as.numeric(summary(data3$relMW_groups[data3$agecat==0])[2]/length(which(data3$agecat == 0)))

a<-as.numeric(summary(data3$relMW_groups)[2])
recallhsd30<-as.numeric(summary(data3$relMW_groups[(data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1 )])[2]/a)
precishsd30<-as.numeric(summary(data3$relMW_groups[(data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1 )])[2]/length(which((data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1 ))))

a<-as.numeric(summary(data3$relMW_groups)[2])
recallhsl30<-as.numeric(summary(data3$relMW_groups[(data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1 | data3$educcat==2 )])[2]/a)
precishsl30<-as.numeric(summary(data3$relMW_groups[(data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1  | data3$educcat==2)])[2]/length(which((data3$agecat==0 | data3$agecat==20 | data3$agecat==25 ) & (data3$educcat==1 | data3$educcat==2))))

recallhsd40<-as.numeric(summary(data3$relMW_groups[(data3$age<40 ) & (data3$educcat==1 )])[2]/a)
precishsd40<-as.numeric(summary(data3$relMW_groups[(data3$age<40 ) & (data3$educcat==1 )])[2]/length(which((data3$age<40 ) & (data3$educcat==1 ))))

a<-as.numeric(summary(data3$relMW_groups)[2])
recallhsd<-as.numeric(summary(data3$relMW_groups[ (data3$educcat==1)])[2]/a)
precishsd<-as.numeric(summary(data3$relMW_groups[ (data3$educcat==1)])[2]/length(which( (data3$educcat==1))))



boost_pr_data <- data.frame(recall = unlist(boost.perf2@x.values), 
                            precision = unlist(boost.perf2@y.values)
)
rf_pr_data <- data.frame(recall = approx(unlist(rf.perf22@x.values), unlist(rf.perf22@y.values), xout = boost_pr_data$recall)$x , 
                         precision = approx(unlist(rf.perf22@x.values), unlist(rf.perf22@y.values), xout = boost_pr_data$recall)$y)


lm_pr_data <- data.frame(recall = approx(unlist(lm.perf2@x.values), unlist(lm.perf2@y.values), xout = boost_pr_data$recall)$x , 
                         precision = approx(unlist(lm.perf2@x.values), unlist(lm.perf2@y.values), xout = boost_pr_data$recall)$y)

glm_pr_data <- data.frame(recall = approx(unlist(glm.perf2@x.values), unlist(glm.perf2@y.values), xout = boost_pr_data$recall)$x , 
                          precision = approx(unlist(glm.perf2@x.values), unlist(glm.perf2@y.values), xout = boost_pr_data$recall)$y)

elastic_net_pr_data <- data.frame(recall = approx(unlist(elastic_net.perf2@x.values), unlist(elastic_net.perf2@y.values), xout = boost_pr_data$recall)$x , 
                                  precision = approx(unlist(elastic_net.perf2@x.values), unlist(elastic_net.perf2@y.values), xout = boost_pr_data$recall)$y)

tree_pr_data <- data.frame(recall = approx(unlist(tree.perf2@x.values), unlist(tree.perf2@y.values), xout = boost_pr_data$recall)$x , 
                           precision = approx(unlist(tree.perf2@x.values), unlist(tree.perf2@y.values), xout = boost_pr_data$recall)$y)


all_pr_data <- boost_pr_data

all_pr_data$rf_precision <- rf_pr_data$precision
all_pr_data$lm_precision <- lm_pr_data$precision
all_pr_data$glm_precision <- glm_pr_data$precision
all_pr_data$elastic_net_precision <- elastic_net_pr_data$precision
all_pr_data$tree_precision <- tree_pr_data$precision


all_pr_data$rf_precision_difference <- rf_pr_data$precision  - all_pr_data$precision 
all_pr_data$lm_precision_difference <-  lm_pr_data$precision-  all_pr_data$precision
all_pr_data$glm_precision_difference <- glm_pr_data$precision - all_pr_data$precision
all_pr_data$elastic_net_precision_difference <- elastic_net_pr_data$precision- all_pr_data$precision
all_pr_data$tree_precision_difference <- tree_pr_data$precision- all_pr_data$precision

scales::show_col(colorblind_pal()(8)[c(2:4, 6:8)])

rel_plot <- ggplot(data = all_pr_data, aes(x = recall))  + 
  geom_line(aes(y = rf_precision_difference, color = "Random Forest"), size = 1.5) + 
  geom_line(aes(y = lm_precision_difference, color = "Linear (Card & Krueger"), size = 1.5) + 
  geom_line(aes(y = glm_precision_difference, color = "Basic Logistic"), size = 1.5)  +
  geom_line(aes(y = elastic_net_precision_difference, color = "Elastic Net"), size = 1.5)  +
  geom_line(aes(y = tree_precision_difference, color = "Tree"), size = 2)  +
  geom_hline(aes(yintercept = 0), linetype="dashed")  +
  #        scale_color_manual(values = c("var1" = "green", 
  #                                      "var2" = "red", 
  #                                      "var3" = "blue",
  #                                      "var4" = "emerald" ,
  #                                      "var5" = "orange"
  #                                      )) + 
  theme_bw() + 
  theme(text = element_text(family = "serif")) + 
  xlab("Recall") + ylab("Precision Relative to the Gradient Boosting") + 
  labs(color = "Learning Method") +
  theme(legend.position = c(0.8, 0.2),
        legend.text=element_text(size=15),
        legend.title=element_text(size=15))  +
  scale_color_manual(values = colorblind_pal()(8)[c(2:4, 6:8)])

rel_plot

colors <- ggplot_build(rel_plot)$data

pdf(paste0(figure_directory, "figure_2a.pdf"), family="Times", width=9)

op <- par(family = "serif")

plot(all_pr_data$recall, all_pr_data$rf_precision, type = "l", pch = 19, 
     col = unique(colors[[1]]$colour), xlab = "Recall", ylab = "Precision", 
     lwd = 3,
     ylim=c(0, 1), xlim = c(0,1), lty = 6,cex.lab=1.5, cex.axis=1)
lines(all_pr_data$recall, all_pr_data$lm_precision, type = "l", 
      col = unique(colors[[2]]$colour), lwd = 4, lty = 2, pch = 19)
lines(all_pr_data$recall, all_pr_data$glm_precision, type = "l",
      col = unique(colors[[3]]$colour), lwd = 4, lty = 3, pch = 19)
lines(all_pr_data$recall, all_pr_data$elastic_net_precision, type = "l",
      col = unique(colors[[4]]$colour), lwd = 4, lty = 4, pch = 19)
lines(all_pr_data$recall, all_pr_data$tree_precision, type = "l",
      col = unique(colors[[5]]$colour), lwd = 3, lty =5, pch = 19)
lines(all_pr_data$recall, all_pr_data$precision, type = "l",
      col = "black", lwd = 3, lty =1, pch = 19)
legend(x = 0.53, y= 1,col=c("white", "black", c(unique(colors[[1]]$colour), 
                                                unique(colors[[5]]$colour),
                                                unique(colors[[2]]$colour),
                                                unique(colors[[3]]$colour),
                                                unique(colors[[4]]$colour))),lwd=c(3, 3,3,4,4,4), lty=c(0, 1,6,5,2, 3,4),
       legend=c("Learning Method:", "Boosted Trees", "Random Forest", "Tree", "Linear (Card & Krueger)" ,
                "Basic logistic", "Elastic net"),
       bty='n', cex=1.25, ncol=1, seg.len=5) 
random_choice <- as.numeric(summary(data3$relMW_groups)[2]/length(data3$relMW_groups))
abline(random_choice,0,lty=2)

dev.off()



pdf(paste0(figure_directory, "figure_2b.pdf"), family="Times", width=9)

op <- par(family = "serif")

plot(all_pr_data$recall, all_pr_data$rf_precision_difference, type = "l", pch = 19, 
     col = unique(colors[[1]]$colour), xlab = "Recall", ylab = "Precision Relative to the Boosting", 
     lwd = 4,
     ylim=c(-0.3, 0), xlim = c(0,1), lty = 6,cex.lab=1.5, cex.axis=1)
lines(all_pr_data$recall, all_pr_data$lm_precision_difference, type = "l", 
      col = unique(colors[[2]]$colour), lwd = 4, lty = 2, pch = 19)
lines(all_pr_data$recall, all_pr_data$glm_precision_difference, type = "l",
      col = unique(colors[[3]]$colour), lwd = 4, lty = 3, pch = 19)
lines(all_pr_data$recall, all_pr_data$elastic_net_precision_difference, type = "l",
      col = unique(colors[[4]]$colour), lwd = 4, lty = 4, pch = 19)
lines(all_pr_data$recall, all_pr_data$tree_precision_difference, type = "l",
      col = unique(colors[[5]]$colour), lwd = 3, lty =5, pch = 19)
legend(x = 0.53, y= -0.17,col=c("white", c(unique(colors[[1]]$colour), 
                                           unique(colors[[5]]$colour),
                                           unique(colors[[2]]$colour),
                                           unique(colors[[3]]$colour),
                                           unique(colors[[4]]$colour))),lwd=c(3, 3,3,4,4,4), lty=c(0, 6,5,2,3,4),
       legend=c("Learning Method:", "Random Forest", "Tree", "Linear (Card & Krueger)" ,
                "Basic logistic", "Elastic net"),
       bty='n', cex=1.25,  ncol=1, seg.len=5) 
abline(0,0,lty=2)


dev.off()

pdf(paste0(figure_directory, "figure_3.pdf"), family="Times", width=9)
plot(all_pr_data$recall, all_pr_data$precision, type = "l", pch = 19,
     col = "black", xlab = "Recall", ylab = "Precision",
     lwd = 3,
     ylim=c(0, 1), xlim = c(0,1), lty = 1,cex.lab=1.5, cex.axis=1)
points(recallteen, precisteen, pch=17, col=1, cex=1.5)
points(recallhsd, precishsd, pch=19, col=1, cex=1.5)
points(recallhsd30, precishsd30, pch=19, col="gray", cex=1.5)
points(recallhsl30, precishsl30, pch=17, col="gray", cex=1.5)
#points(recallboost, precisboost, pch=17, col="gray", cex=1.5)
legend(0.63,1,col=c("white", c(1)),lwd=2, lty=c(0,1),
       legend=c("Learning Method:", "Boosted Trees"),bty='n', cex=1.25,  ncol=1)
legend(0.30,1,col=c("white", 1, 1, "gray", "gray"), pch=c(19, 17,19,19,17),lwd=-1,
       legend=c("Groups:", "Teen", "LTHS", "LTHS, Age<30", "HSL, Age<30"),
       bty='n', cex=1.25,  ncol=1, bg="white")
random_choice = as.numeric(summary(data3$relMW_groups)[2]/length(data3$relMW_groups))
abline(random_choice,0,lty=2)
dev.off()