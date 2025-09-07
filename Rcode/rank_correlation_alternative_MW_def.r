rm(list=ls()[!stringr::str_detect(ls(), "directory")])
library(haven)
library(tidyverse)



for (i in c(103, seq(110, 175,5) , 200)){
  assign(paste0("alt_preds_", i), 
         read_dta(paste0(data_directory, "CPSmorg_MLpredprobs_1979_2019_new_c", i,".dta")) %>% 
           select(boost_preds))
  print(i)
}
alt_preds_wage <- read_dta(paste0(data_directory, "CPSmorg_MLpredprobs_1979_2019_new_wage.dta"))

a <- c()
a[1] <- cor(alt_preds_125$boost_preds, 
    alt_preds_wage$boost_preds, method = "spearman")
a[2] <- cor(alt_preds_125$boost_preds, alt_preds_103$boost_preds, method = "spearman")
a[3] <- cor(alt_preds_125$boost_preds, alt_preds_110$boost_preds, method = "spearman")
a[4] <- cor(alt_preds_125$boost_preds, alt_preds_115$boost_preds, method = "spearman")
a[5] <- cor(alt_preds_125$boost_preds, alt_preds_120$boost_preds, method = "spearman")
a[6] <- 1
a[7] <- cor(alt_preds_125$boost_preds, alt_preds_130$boost_preds, method = "spearman")
a[8] <- cor(alt_preds_125$boost_preds, alt_preds_135$boost_preds, method = "spearman")
a[9] <- cor(alt_preds_125$boost_preds, alt_preds_140$boost_preds, method = "spearman")
a[10] <- cor(alt_preds_125$boost_preds, alt_preds_145$boost_preds, method = "spearman")
a[11] <- cor(alt_preds_125$boost_preds, alt_preds_150$boost_preds, method = "spearman")
a[12] <- cor(alt_preds_125$boost_preds, alt_preds_155$boost_preds, method = "spearman")
a[13] <- cor(alt_preds_125$boost_preds, alt_preds_160$boost_preds, method = "spearman")
a[14] <- cor(alt_preds_125$boost_preds, alt_preds_165$boost_preds, method = "spearman")
a[15] <- cor(alt_preds_125$boost_preds, alt_preds_170$boost_preds, method = "spearman")
a[16] <- cor(alt_preds_125$boost_preds, alt_preds_175$boost_preds, method = "spearman")
a[17] <- cor(alt_preds_125$boost_preds, alt_preds_200$boost_preds, method = "spearman")


rank_cor <- data.frame(
  x = c(250, c(103, seq(110, 175,5) , 200)),
  y = a
)
write_excel_csv(rank_cor, paste0(data_directory, "rank_correlation_coef.csv"))