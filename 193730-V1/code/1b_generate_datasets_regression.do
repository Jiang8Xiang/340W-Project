*=============================================================================================================
*	1a. Compile the historical wealth gap series.

	/* 
	This do-file combines available information on white and Black wealth from 1860 to 2020 to construct a time 
	series for the entire time period on the racial wealth gap. 
	
	Authors: Moritz Kuhn and Ellora Derenoncourt
	Created: Feb 8, 2021 
	Last modified: May 11, 2022
	*/
	
	/*
	Derived wealth gap series
	1. wealthgapscale: Our baseline wealth gap measure 
	
	Robustness measures
	1. wealthgap_hhscale: Household-level wealth gap
	2. wealthgap_debtscale: Adjust for (non-farm mortgage)debt for the historical period; assign all debt to non-Black population 
	3. assetgapscale: Asset gap (also for post-1950)
	4. wealthgap_nwscale: Use national wealth to estimate non-Black wealth for whole period 1860-2020
	
	*/

*-------------------------------------------------------------------------------------------------------------
* 1. Calculate white and Black wealth in 1860 using Census.
*-------------------------------------------------------------------------------------------------------------

	/* This section constructs estimates of white and Black wealth for 1860. 

	We begin with Black and white wealth as enumerated in the 1860 Census. Only free black persons are 
	enumerated in the 1860 Census. Enslaved Black persons were recorded separately. We use a count of the 
	enslaved Black population in 1860 from Haines' (2010) "Historical, Demographic, Economic, and Social Data: 
	The United States, 1790-2002 (ICPSR 2896)" Part 9.  Note that this matches the published Census report 
	"Black Population 1790-1915" counts of the enslaved available at:

	https://www2.census.gov/library/publications/decennial/1910/black-population-1790-1915/00480330.zip.
	*/

	use "$population/raw/ICPSR_02896/DS0009/02896-0009-Data.dta", clear
	drop if county==0
	collapse (sum) fctot stot
	local count_enslaved_1860 = stot[1]
	di `count_enslaved_1860' // The enslaved count is 3953760.

	clear

	set obs `count_enslaved_1860'
	gen race = 2
	gen realprop = 0
	gen persprop = 0
	gen year = 1860

	tempfile enslaved	
	save `enslaved', replace
	
	/*
	From full 1860 Census data, we obtain the number of households among the free Black population and
	calculate average household size:
	*/
	use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear
	keep if year==1860
	count if race == 2 & relate == 1 // Count number of household heads
	local no_black_households = `r(N)' 
	di `no_black_households' //  94,457

	count if race == 2 // Count total free Black population
	local no_black_pop = `r(N)'
	di `no_black_pop' // 492,830
	
	local avg_hh_size_black = `no_black_households'/`no_black_pop'
	di %8.2f `avg_hh_size_black' //	5.22 

	/*
	We assume 5.22 would be average household size of the enslaved as well, implying
	*/
	
	local zero_wealth_black_hh = `count_enslaved_1860'/`avg_hh_size_black'
	di %8.0f `zero_wealth_black_hh'  // 739,600

	/*
	Or 739,600 additional Black households with zero wealth in 1860.
	*/

	use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear
	keep if year==1860
	
	* Assume 0 wealth for those with missing wealth and impute top-coded wealth
	*(coded as 999998 for missing and 999997 means top-coded; 
	*see https://usa.ipums.org/usa-action/variables/REALPROP#codes_section
	*and https://usa.ipums.org/usa-action/variables/PERSPROP#codes_section)
	
	* Replace missing code with zero wealth.
	replace realprop = 0 if realprop >= 999998 
	replace persprop = 0 if persprop >= 999998 

	* Add in enslaved population
	append using `enslaved'

	/* Wealth including slaves */
	gen wealth = realprop + persprop 

	/* Approximation for tax units */
	quietly : count if relate == 1  
	local totalpopulation = `r(N)'
	local top001population = `totalpopulation' * 0.01/100
	
	/* 
	Impute wealth above the censoring limit $999,997 
    Use Saez-Zucman 1913 estimate for wealth concentration and assume it also 
	applies to 1860. Estimate for Top 0.01% is 8.8%.
    Assume that uncensored observations constitute 91.2% (= 100 - 8.8) and 
	take estimate for total wealth from 
	$data\Wealth_by_state.xlsx <-- Q FOR MK: WE NEED SOURCE FOR THIS 
	
	Total wealth in the top 0.01 %
	*/
	
	* Pull in 1913 wealth share of top 0.01% from Saez-Zucman (QJE 2016)
	preserve
	import excel using $sz/raw/SaezZucman2015MainData.xlsx, sheet("DataFig1-6-7b") cellrange(I3:I3) clear
	local top01share = I[1]
	di `top01share' // `top01share'
	restore
	
	preserve
	import excel using $wdt/raw/wealth_debt_taxation_1922.xlsx, sheet("Table17") cellrange(B2:B2) clear
	local totwealth = B[1]
	di %12.0f `totwealth' // 16159616068
	restore 
	
	local topwealth = `top01share' * `totwealth' 
	local topwealth_taxunit = `topwealth'/`top001population'

	display "Total tax units : " %12.0f `totalpopulation' _newline /*
	*/ "Top 0.01 tax units : " %12.0f `top001population' _newline /*
	*/ "Top 0.01 average wealth : " %12.1f `topwealth_taxunit' _newline

	* Impute top-coded wealth.
	replace wealth = `topwealth_taxunit' if realprop == 999997 | persprop == 999997 
	 
	/* Calculate per capita and total Black wealth in 1860 */
	sum wealth if race == 2 
	global wealth_black_1860 =  `r(mean)' * `r(N)' 
	
	/* Calculate per capita and total non-Black wealth */
	sum wealth if race != 2 
	global wealth_nonblack_1860 = `r(mean)' * `r(N)' //- `slaveprop'
	
	/* Caclulate alternative per capita wealth without slave wealth*/
	
	* Import data on slave wealth
	preserve 
	import excel using $slavewealth/raw/Historical_Statistics_of_the_United_States_Bb209-214.xls, sheet("Bb209-214") cellrange(F62:F62) clear
	rename F value_slave
	global slaveprop = value_slave * 1000000
	restore
	
	qui sum wealth
	local totalwealth = `r(mean)'*`r(N)'
	
	display  "Total value of slaves : $" %12.1fc $slaveprop _newline  /*
	*/ "Slave wealth as share of total wealth (Census) : " %6.2fc $slaveprop/`totalwealth' * 100 "%" _newline 
	
	* Subtract nonblack wealth from slave wealth 
	global wealth_nonblack_1860_noslaves = ${wealth_nonblack_1860} - ${slaveprop}

	/* Calculate alternative per capita and total non-Black wealth (National wealth) */
	
	* Import data on national wealth
	preserve
	import excel using $wdt/raw/wealth_debt_taxation_1922.xlsx, sheet("Table7") cellrange(C2:C2) clear
	rename C totalwealth

	/* Adjust values are reported in 1,000 */
	replace totalwealth = totalwealth * 1000

	global nationalwealth1860 = totalwealth[1]
	restore
	
	global wealth_nonblack_1860_alt = ${nationalwealth1860} - ${wealth_black_1860} 
	
	/*Calculate per capita and total white wealth*/
	sum wealth if race == 1 
	global wealth_white_1860 =  `r(mean)' * `r(N)' 
	
	/* Statistics from 1860 Census necessary for addressing bottom-censoring in 1870:
	In 1870, enumerators were instructed to exclude clothing when recording personal property and to only
	record for those with personal property of $100 or more. We apply various assumptions to address
	this censoring. See wealthdistribution_bottom_18601870.do for a detailed analysis. Here we only include 
	the parts of the code necessary to adjust the 1870 data at the lower end of the wealth (persprop) 
	distribution according to our preferred assumption. These adjustments draw from 1860 data, which is not 
	censored from below. */
		
	gen zerowealth = (persprop == 0)
	
	/* Share of below-100 personal property with zero wealth. */
	
	sum zerowealth if race == 2 & persprop < 100
	global BLACKZEROWEALTH1860 = `r(mean)'
	sum zerowealth if race != 2 & persprop < 100
	global NONBLACKZEROWEALTH1860 = `r(mean)'
 	sum zerowealth if race == 1 & persprop < 100
	global WHITEZEROWEALTH1860 = `r(mean)'
	
	 /* Share of individuals with zero wealth */
	gen zerototwealth = (wealth <= 0) 
	sum zerototwealth if race == 2  
	global ZEROWEALTH1860_black = `r(mean)'
	sum zerototwealth if race != 2  
	global ZEROWEALTH1860_nonblack = `r(mean)'
	sum zerototwealth if race == 1 
	global ZEROWEALTH1860_white = `r(mean)'
	
	
	/*Distribute household head real property wealth to all household members*/
	bysort serial: egen totrealprop = total(realprop)
	bysort serial: egen totpersprop = total(persprop)
	bysort serial: gen N_hh=_N
	
	gen realprop_eq = totrealprop/N_hh
	gen persprop_eq = totpersprop/N_hh
	gen wealth_eq = realprop_eq + persprop_eq
	gen homeowner = (realprop_eq > 0)
	gen zerototwealth_eq = (wealth_eq<=0)
	
	/* Share of individuals with zero wealth, after wealth distribution among households */
	sum zerototwealth_eq if race == 2  
	global ZEROWEALTH1860_black_eq = `r(mean)'
	sum zerototwealth_eq if race != 2  
	global ZEROWEALTH1860_nonblack_eq = `r(mean)'
	sum zerototwealth_eq if race == 1 
	global ZEROWEALTH1860_white_eq = `r(mean)'
		
	save "$micro_census_jep/CensusData1860_reg.dta", replace

*-------------------------------------------------------------------------------------------------------------
* 2. Calculate white and Black wealth in 1870 using Census.
*-------------------------------------------------------------------------------------------------------------

	/* This section constructs estimates of white and Black wealth in 1870 using the 1870 Census. 	
	*/
	
	use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear
	keep if year==1870
	
	replace persprop = 0 if persprop >= 999998
	replace realprop = 0 if realprop >= 999998
 
	gen wealth = persprop + realprop
	
	/* See note above regarding bottom-censoring in 1870 Census andwealthdistribution_bottom_18601870.do 
	for a detailed analysis. Here we only include the parts of the code necessary to adjust the 1870 data 
	at the lower end of the wealth (persprop) distribution according to our preferred assumption. */
	gen black = (race == 2)
	label define black_lbl 0 "non-black" 1 "black"
	label values black black_lbl
	 
	tempfile black0 white0 truewhite0

	/* Distribution of positive wealth for Black persons below 100 dollars */
	preserve
	keep if black == 1 & inrange(persprop,1,99)
	sum persprop, d
	global positiveN = _N
	gen iszerowealth = 1
	gen imputedwealth = 1
	global conditionalmean = `r(mean)'
	restore

	/* Share of Black persons with zeros and imputation of conditional mean from previous step */
	preserve
	keep if black == 1 & persprop == 0
	gen imputedwealth = 1
	gen iszerowealth = _n/(_N + ${positiveN})
	replace persprop = $conditionalmean
	save `black0', replace
	restore

	/* Distribution of positive wealth for non-Black persons below 100 dollars */
	preserve
	keep if black == 0 & inrange(persprop,1,99)
	sum persprop, d
	global positiveN = _N
	gen iszerowealth = 1
	gen imputedwealth = 1
	global conditionalmean = `r(mean)'
	restore

	/* Share of non-Black persons with zeros and imputation of conditional mean from previous step */
	preserve
	keep if black == 0 & persprop == 0
	gen imputedwealth = 1
	gen iszerowealth = _n/(_N + ${positiveN})
	replace persprop = $conditionalmean
	save `white0', replace
	restore

	/* Distribution of positive wealth for white persons below 100 dollars */
	preserve
	keep if race == 1 & inrange(persprop,1,99)
	sum persprop, d
	global positiveN = _N
	gen iszerowealth = 1
	gen imputedwealth = 1
	global whiteconditionalmean = `r(mean)'
	restore

	/* Share of white persons with zeros and imputation of conditional mean from previous step */
	preserve
	keep if race == 1 & persprop == 0
	gen imputedwealth = 1
	gen iszerowealth = _n/(_N + ${positiveN})
	replace persprop = $whiteconditionalmean
	save `truewhite0', replace
	restore
	
	/* Drop all zero observations and append sample with the imputed conditional mean */
	drop if persprop == 0

	append using `white0'
	append using `black0'
	append using `truewhite0'

	/* Match share of true zeros from 1860 data in the */
	replace persprop = 0 if black == 1 & imputedwealth == 1 & iszerowealth <= $BLACKZEROWEALTH1860 
	replace persprop = 0 if black == 0 & imputedwealth == 1 & iszerowealth <= $NONBLACKZEROWEALTH1860 
	replace persprop = 0 if race  == 1 & imputedwealth == 1 & iszerowealth <= $WHITEZEROWEALTH1860
	drop iszerowealth

	replace wealth = persprop + realprop
 
 /* 
	Impute wealth above the censoring limit $999,997 
    Use Saez-Zucman 1913 estimate for wealth concentration and assume it also 
	applies to 1870. Estimate for Top 0.01% is 8.8%.
    Assume that uncensored observations constitute 91.2% (= 100 - 8.8) and 
	take estimate for total wealth from Table 17 in "Wealth, debt, and taxation" 
	(https://babel.hathitrust.org/cgi/pt?id=coo1.ark:/13960/t4jm2v48t&view=1up&seq=1)
	which is $30,068,518,507    
	*/
	
	* Pull in 1913 wealth share of top 0.01% from Saez-Zucman (QJE 2016)
	preserve
	import excel using ${sz}/raw/SaezZucman2015MainData.xlsx, sheet("DataFig1-6-7b") cellrange(I3:I3) clear
	local top01share = I[1]
	di `top01share' // `top01share'
	restore
	
	//quietly : sum wealth if realprop < 999997 & persprop < 999997
	//local totalwealth_cens =  `r(mean)' * `r(N)'
	preserve
	import excel using ${wdt}/raw/wealth_debt_taxation_1922.xlsx, sheet("Table17") cellrange(C2:C2) clear
	local totwealth = C[1]
	di %12.0f `totwealth' // 30068518507
	restore
	
	/* Approximation of number of tax units */
	quietly : count if relate == 1  
	local totalpopulation = `r(N)'
	local top001population = `totalpopulation' * 0.01/100

	/* Total wealth in the top 0.01 % 
	data on total wealth from $data\Wealth_by_state.xlsx */
	local topwealth = `top01share' * `totwealth'  
	local topwealth_taxunit = `topwealth'/`top001population'

	display "Total tax units : " %12.0f `totalpopulation' _newline /*
	*/ "Top 0.01 tax units : " %12.0f `top001population' _newline /*
	*/ "Top 0.01 average wealth : " %12.1f `topwealth_taxunit' _newline

	replace wealth = `topwealth_taxunit' if realprop == 999997 | persprop == 999997 

	sum wealth 
	local totalwealth = `r(mean)' * `r(N)' 
	local missingwealth = `totwealth' - `totalwealth'
	display "=========================================================" _newline /*
	*/ "Total wealth (Census) : $" %12.1gc `totalwealth' _newline /*
	*/ "Total wealth (Wealth, debt, and taxation) : $"%12.1gc `totwealth'  _newline /*
	*/ "Missing total wealth : $" %12.1gc `missingwealth' _newline /*
	*/ "=========================================================" _newline
 
	/* Calculate per capita and total Black wealth in 1870 */
	sum wealth if race == 2 
	global wealth_black_1870 =  `r(mean)' * `r(N)'

	/* For non-Black wealth, we use national wealth minus census Black wealth as our baseline because 
	national wealth estimates are higher, suggesting underreporting in Census */
	/* BASELINE: Calculate wealth-report-based per capita and total non-Black wealth */
	
	* Import data on national wealth
	preserve
	import excel using $wdt/raw/wealth_debt_taxation_1922.xlsx, sheet("Table7") cellrange(C3:C3) clear
	rename C totalwealth

	/* Adjust values are reported in 1,000 */
	replace totalwealth = totalwealth * 1000
		
	global nationalwealth1870 = totalwealth[1]
	restore
		
	global wealth_nonblack_1870 = ${nationalwealth1870} - ${wealth_black_1870} 

	/* Calculate census-based per capita and total non-Black wealth in 1870 */
	sum wealth if race != 2 
	global wealth_nonblack_1870_cens = `r(mean)' * `r(N)' 

	/* Calculate per capita and total white wealth in 1870 */
	sum wealth if race == 1 
	global wealth_white_1870 =  `r(mean)' * `r(N)'
	
	/* Share of individuals with zero wealth */
	gen zerototwealth = (wealth <= 0) 
	sum zerototwealth if race == 2  
	global ZEROWEALTH1870_black = `r(mean)'
	sum zerototwealth if race != 2  
	global ZEROWEALTH1870_nonblack = `r(mean)'	
	sum zerototwealth if race == 1  
	global ZEROWEALTH1870_white = `r(mean)'	
		
	
	/*Distribute household head real property wealth to all household members*/
	bysort serial: egen totrealprop = total(realprop)
	bysort serial: egen totpersprop = total(persprop)
	bysort serial: gen N_hh=_N
	
	gen realprop_eq = totrealprop/N_hh
	gen persprop_eq = totpersprop/N_hh
	gen wealth_eq = realprop_eq + persprop_eq
	gen homeowner = (realprop_eq > 0)
	gen zerototwealth_eq = (wealth_eq<=0)
	
	/* Share of individuals with zero wealth, after wealth distribution among households */
	sum zerototwealth_eq if race == 2  
	global ZEROWEALTH1870_black_eq = `r(mean)'
	sum zerototwealth_eq if race != 2  
	global ZEROWEALTH1870_nonblack_eq = `r(mean)'
	sum zerototwealth_eq if race == 1 
	global ZEROWEALTH1870_white_eq = `r(mean)'
	
	save "$micro_census_jep/CensusData1870_reg.dta", replace
