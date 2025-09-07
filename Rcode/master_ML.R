data_directory <<- "/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/Minwage_ML_Repl_Pkg_JOLE/data/"
figure_directory  <<- "/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/Minwage_ML_Repl_Pkg_JOLE/figures/"

setwd("/Users/davidzentlermunro/Dropbox/MinimumWageParticipation/Minwage_ML_Repl_Pkg_JOLE/Rcode/")

source('create_morg_data_for_prediction_model.r', echo = TRUE)
source('cross_validation_morg.r', echo = TRUE)
source('training_morg.r', echo = TRUE)
source('training_basic_LFP.R', echo = TRUE)
source('elastic_net_2019.R', echo = TRUE)
source('tree_2019.R', echo = TRUE)
source('linear_model_CK_2019.R', echo = TRUE)
source('random_forest_2019.R', echo = TRUE)
source('basic_logistic_2019.R', echo = TRUE)

source('forprediction_morg_MW.r', echo = TRUE)
source('forprediction_basic_MW.r')
source('forprediction_morg_lfp_1986_2019.r', echo = TRUE)
source('forprediction_basic_lfp_1986_2019.r', echo = TRUE)
source('measurement_error_trials.R', echo = TRUE)
source('alternative_MW_worker_def.R', echo = TRUE)
source('forprediction_morg_MW_alternative_MW_worker_def.R', echo = TRUE)
source('alternative_MW_worker_def_wage.R', echo = TRUE)
source('forprediction_morg_MW_alternative_MW_worker_def_wage.R', echo = TRUE)
source('rank_correlation_alternative_MW_def.R', echo = TRUE)

source('figure1.r', echo = TRUE)
source('figure2_and_3.r', echo = TRUE)
source('figure4.r', echo = TRUE)
source('figureA6.r', echo = TRUE)




