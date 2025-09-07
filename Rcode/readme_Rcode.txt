This document describes the inputs and outputs of the R scripts. 
The order matters as some scripts use the outputs of others as inputs.

*** create_morg_data_for_prediction_model.r ***
This is the script that needs to be run to obtain the essential data sets for predicting individual's exposure to a minimum wage change.
Input: fortraining_eventstudy_1979_2019.csv
Output: full_sample_1979_2019.RData

*** cross_validation_morg.r ***
This is the script that needs to be run to obtain the optimum hyperparameters of the gbm model.
Input: full_sample_1979_2019.RData
Output: NA (at the end of the script gbm.tune2$bestTune reports the optimum hyperparameters.

*** training_morg.r ***
This is the script that needs to be run to train the gbm model.
Input: full_sample_1979_2019.RData
Output: prediction_model_1979_2019.RData

*** training_basic_LFP.r ***
This is the script that needs to be run to train the gbm model to find how likelihood an individual is likely to switch between E, I, U.
Inputs: fortraining_fewvars_IPUMS_basic_eventstudy_1986_2019_ML_LFP.dta
Outputs: full_sample_1986_2019_lfp_child_less_5.RData, prediction_model_1986_2019_switch_lfp_number_child_less_5.RData

*** elastic_net_2019.r ***
This is the script that needs to be run to train the elastic net model (for comparison with gbm in figure 2).
Input: full_sample_1979_2019.RData
Output: elastic_net_predictions_1979_2019.RData

*** tree_2019.r ***
This is the script that needs to be run to train the tree model (for comparison with gbm in figure 2).
Input: full_sample_1979_2019.RData
Output: tree_2019.RData

*** linear_model_CK_2019.r ***
This is the script that needs to be run to estimate the linear Card and Krueger probability model (for comparison with gbm in figure 2).
Input: full_sample_1979_2019.RData
Output: ml_sl_linearmodel_2019.RData

*** random_forest_2019.r ***
This is the script that needs to be run to train the random forest model (for comparison with gbm in figure 2).
Input: full_sample_1979_2019.RData
Output: random_forest_2019.RData

*** basic_logistic_2019.r ***
This is the script that needs to be run to estimate the basic logistic model (for comparison with gbm in figure 2).
Input: full_sample_1979_2019.RData
Output: basic_logistic_2019.RData

*** forprediction_morg_MW.r ***
This is the script that needs to be run to get the predictions of the gbm model for the entire MORG sample.
Inputs: forpredictionmorg_eventstudy_2019.dta, full_sample_1979_2019.RData, prediction_model_1979_2019.RData
Output: CPSmorg_MLpredprobs_1979_2019_new.dta
 
*** forprediction_basic_MW.r ***
This is the script that needs to be run to get the predictions of the gbm model for the entire CPS Basic sample.
Inputs: forprediction_fewvars_IPUMS_basic_eventstudy_1979_2019_ML_MW.dta, full_sample_1979_2019.RData, prediction_model_1979_2019.RData
Output: CPSbasic_IPUMS_MLpredprobs_1979_2019_ML_MW.dta
Note: Because the data is too large, there are some intermediate data sets produced and saved in a temporary directory.

*** forprediction_basic_LFP_1986_2019.r  ***
This is the script that needs to be run to predict how likelihood an individual is likely to switch between E, I, U.
Inputs: fortraining_fewvars_IPUMS_basic_eventstudy_1986_2019_ML_LFP.dta, full_sample_1986_2019_lfp_child_less_5.RData, prediction_model_1986_2019_switch_lfp_number_child_less_5.RData
Outputs: CPSbasic_IPUMS_MLpredprobs_1986_2019_ML_lfp.dta
Note: Because the data is too large, there are some intermediate data sets produced and saved in a temporary directory.

*** forprediction_morg_LFP_1986_2019.r  ***
This is the script that needs to be run to predict how likelihood an individual is likely to switch between E, I, U.
Inputs: fortraining_fewvars_morg_eventstudy_1986_2019_ML_LFP.dta, full_sample_1986_2019_lfp_child_less_5.RData, prediction_model_1986_2019_switch_lfp_number_child_less_5.RData
Outputs: CPSmorg_IPUMS_MLpredprobs_1986_2019_ML_lfp.dta
Note: Because the data is too large, there are some intermediate data sets produced and saved in a temporary directory.


*** measurement_error_trials.r  ***
This is the script that needs to be run to show robustness to using employer rather than employee reported wages: see Appendix C, figure_C2
Inputs: forME_CPS1977_subMW_MW125.csv
Outputs: ml_sl_CPS1977.RData, CPS_1977_pred_probs.dta
Note: The predicted probabilities in the .dta output file are in stata file figure_C2.do


*** alternative_MW_worker_def.r  ***
This is the script that needs to be run to check robustness to using different thresholds for classification of MW wage workers: see Appendix C, figure_C1
Inputs: fortraining_eventstudy_1979_2019_cX.csv 
Outputs: prediction_model_1979_2019_cX.RData where X=(103,seq(110,175, 5), 200)
Note: Outputs used in file below

*** forprediction_morg_MW_alternative_MW_worker_def.r  ***
This is the script that needs to be run to check robustness to using different thresholds for classification of MW wage workers, applying models estimate above: see Appendix C, figure_C1
Inputs: prediction_model_1979_2019_cX.RData where X=(103,seq(110,175, 5), 200), forpredictionmorg_fewvars_eventstudy_2019.dta
Outputs: CPSmorg_MLpredprobs_1979_2019_new_cX.dta where X=(103,seq(110,175, 5), 200)
Note: .dta outputs used in stata file rank_correlation_alternative_MW_def.r 

*** alternative_MW_worker_def_wage.r  ***
This is the script that needs to be run to compare baseline prediction model to model that simply predicts wage level: see Appendix C, figure_C1
Inputs: fortraining_eventstudy_1979_2019_c200.csv
Outputs: prediction_model_1979_2019_wage.RData
Note: Output used in file below

*** forprediction_morg_MW_alternative_MW_worker_def_wage.r  ***
This is the script that needs to be run to compare baseline prediction model to model that simply predicts wage level and applies model estimated above: see Appendix C, figure_C1
Inputs: prediction_model_1979_2019_wage.RData, forpredictionmorg_fewvars_eventstudy_2019.dta
Outputs: CPSmorg_MLpredprobs_1979_2019_new_wage.dta
Note:  .dta outputs used in stata file rank_correlation_alternative_MW_def.r 

*** rank_correlation_alternative_MW_def.r  ***
This is the script that calculates rank correlation coefficients for predict probabilities using baseline prediction model and prediction models using different thresholds of classification/or predict wage level: see Appendix C, figure_C1
Inputs: CPSmorg_MLpredprobs_1979_2019_new_cX.dta where X=(103,seq(110,175, 5), 200),  CPSmorg_MLpredprobs_1979_2019_new_wage.dta
Outputs: rank_correlation_coef.csv
Note: csv output used in figure_C1.do

*** figure1.r ***
This script produces figure 1 in the paper.
Inputs: full_sample_1979_2019.RData
Outputs: figure_1.pdf

*** figure2and3.r ***
This script produces figure 2 and 3 in the paper.
Inputs: full_sample_1979_2019.RData, prediction_model_1979_2019.RData, elastic_net_predictions_1979_2019.RData, ml_sl_linearmodel_2019.RData, basic_logistic_2019.RData, random_forest_2019.RData, tree_2019.RData
Outputs: figure_2a.pdf,figure_2b.pdf,figure_3.pdf

*** figure4.r ***
This script produces figure 4 in the paper.
Inputs: full_sample_1979_2019.RData, prediction_model_1979_2019.RData, 
Outputs: boost_relimp_2019_new.pdf

*** figure A6.r ***'
This script produces figure A6 in the paper.
Inputs: prediction_model_1979_2019_switch_lfp_number_child_less_5.RData
Outputs: figure_A6_new.pdf




