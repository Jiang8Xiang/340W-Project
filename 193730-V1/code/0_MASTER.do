*=============================================================================================================
*	Historical Changes in the Distribution of Black and White Wealth
*	Ellora Derenoncourt, Chi Hyun Kim, Moritz Kuhn, Moritz Schularick
*
*	This is the master do-file for "Historical Changes in the Distribution of Black and White Wealth" which calls 
*	all the individual do-files required to replicate the analysis conducted in this paper.
*
*	Created: March 9, 2023
* 	Last edited: March 9, 2023
*=============================================================================================================

*-------------------------------------------------------------------------------------------------------------
* 0. Set preconditions and directory paths.
*-------------------------------------------------------------------------------------------------------------

	capture log close
	clear all
	set more off
	set matsize 11000
	set maxvar 30000

	* Action required: Install packages 
	ssc install statastates, replace
	ssc install ftools, replace
	ssc install moremata, replace
	ssc install renvarlab, replace
	ssc install keeporder, replace
	ssc install estout, replace
	net install grc1leg,from(http://www.stata.com/users/vwiggins/)
	ssc install nearmrg
	ssc install winsor2
	ssc install coefplot
	
	/* Action required: Change to path to the replication folder on your home directory. */
	global home 		"~/Dropbox/WealthGap"
	global code			"$home/jep_replication/code"
	global data_dkks	"$home/qje_replication_internal/data"
	global data			"$home/jep_replication/data"
	global simulation 	"$home/qje_replication_internal/simulation"
	
	global programs		"$code/programs"
	
	global xwalks		"$data_dkks/crosswalks"
	global price		"$data_dkks/price_indices"
	global sz			"$data_dkks/saez_zucman_qje_2016"
	global taxsouth		"$data_dkks/southern_state_tax_records"
	global population	"$data_dkks/population"
	global micro_census	"$data_dkks/census_microdata"
	global scf 			"$data_dkks/scf"
	global wdt			"$data_dkks/wealth_debt_taxation_report"
	global nhgis		"$data_dkks/nhgis"
	global slavewealth	"$data_dkks/slave_wealth"
	
	global psz	        "$data/psz" 
	global micro_census_jep "$data/micro_census" 
	
	global figtab		"$home/jep_replication/figures_tables"
	global slides		"$home/jep/slides"
	global paper		"$home/jep/paper"


/* If needed, change paths based on computer/user 
	
if "`c(username)'" == "ellorad" { // Ellora
	
	global home 	"~/Dropbox/WealthGap"	
	*adopath + "$home/stata/ado"

}	*/
	cd $code
	run "programs/PrintEst" 
*-------------------------------------------------------------------------------------------------------------

*-------------------------------------------------------------------------------------------------------------
* 1a. Compile the historical wealth gap series.
*-------------------------------------------------------------------------------------------------------------

	cd $code
	do 1a_generate_datasets_1860_1870.do
	
*-------------------------------------------------------------------------------------------------------------
* 1b. Compile datasets for regression
*-------------------------------------------------------------------------------------------------------------
	cd $code
	do 1b_generate_datasets_regression.do
	
*-------------------------------------------------------------------------------------------------------------
* 1d + 1e. Regression for imputation exercise
*-------------------------------------------------------------------------------------------------------------
	cd $code
	do 1c_regression_poswealth_forward.do
	do 1d_regression_poswealth_backward.do

*-------------------------------------------------------------------------------------------------------------
* 2. Main figures and tables
*-------------------------------------------------------------------------------------------------------------
	cd $code
	do 2_main_figures_tables_jep.do
