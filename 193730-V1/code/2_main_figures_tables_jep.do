
*------------------------------------------------------------------------------------------------------------%	
* Figure 1a-1b: Wealth distribution in 1860/1870 by race
*------------------------------------------------------------------------------------------------------------%		

	forvalues i = 1860(10)1870 {
	use "$micro_census_jep/CensusData`i'.dta", clear

	** Wealth as share of total wealth
	egen totwealth = total(wealth)
	replace totwealth = totwealth/1000
	gen wealth_norm = wealth_eq/totwealth*100


	** Generate Black/white dummy
	if `i'==1870{
	drop black
	}

	gen black = 0
	gen white = 0
	replace black = 1 if race==2
	replace white = 1 if race!=2

	/** Summary statistics
	sum wealth_black_1860_norm wealth_nonblack_1860_norm, d
	sum wealth if race==2, d
	sum wealth if race!=2, d
	*/


	** Define bins 
	gen bin =. 
	replace bin = 1 if wealth_eq< 50
	replace bin = 2 if wealth_eq>=50 	& wealth_eq<100
	replace bin = 3 if wealth_eq>=100 	& wealth_eq<200 
	replace bin = 4 if wealth_eq>=200 	& wealth_eq<300 
	replace bin = 5 if wealth_eq>=300 	& wealth_eq<400
	replace bin = 6 if wealth_eq>=400 		& wealth_eq<500
	replace bin = 7 if wealth_eq>=500 		& wealth_eq<600
	replace bin = 8 if wealth_eq>=600 		& wealth_eq<700
	replace bin = 9 if wealth_eq>=700 		& wealth_eq<800
	replace bin = 10 if wealth_eq>=800 		& wealth_eq<900
	replace bin = 11 if wealth_eq>=900		& wealth_eq<1000
	replace bin = 12 if wealth_eq>=1000

	replace bin = . if wealth_eq==.

	// Collapse by bin
	collapse (sum) black white, by(bin)
	drop if bin==.
	egen tot_b = total(black)
	egen tot_w = total(white)

	gen sharepop_w = white/tot_w*100
	gen sharepop_b = black/tot_b*100

	egen tot_pos_b = total(black) if bin>0
	egen tot_pos_w = total(white) if bin>0

	gen sharepop_pos_w = white/tot_pos_w*100
	gen sharepop_pos_b = black/tot_pos_b*100

	graph bar sharepop_w sharepop_b , over(bin, relabel(1 "0-50" 2 "50-100" 3 "100-200" 4 "200-300" 5 "300-400" 6 "400-500" 7 "500-600" /*
		*/ 8 "600-700" 9 "700-800" 10 "800-900" 11 "900-1000" 12 "1000+") label(angle(90))) /*
		*/	bar(1, fcolor(maroon) lcolor(maroon) lwidth(vvthin)) /*
		*/	bar(2, fcolor(gs10) lcolor(gs10) lwidth(vvthin)) /*
		*/ 	plotregion(color(white)) graphregion(color(white)) bgcolor(white) /*
		*/ 	legend(label(1 "White") label(2 "Black") region(color(none))) name("bar_`i'", replace) title("") /*
		*/	ytitle("% Population (by race)") b1title("US Dollars (nominal)") /*
		*/ 	yscale(r(0 100)) ylabel(0(20)100) ylabel(, angle(0)) scheme(s2color)
		graph export "${figtab}/bar_`i'_dollars.pdf", replace
		
	}

	
*------------------------------------------------------------------------------------------------------------%
* Figure 2: Historical evolution of Black wealth, 1870-2020
*------------------------------------------------------------------------------------------------------------%

	/*---------Figure 2(a): Black wealth relative to total national wealth, 1870-2020*/
	/* Population data interpolated from the following raw data */
	import delimited "$population/raw/census_race_statistics_1790_2010.csv", clear 

	gen blackpopulationshare_decade = black_population/total_population

	keep year blackpopulationshare_decade
	tempfile populationdata
	save `populationdata', replace

	import excel "$data_dkks/WealthGapFinal18602020.xlsx", sheet("Sheet1") firstrow clear

	merge 1:1 year using `populationdata', nogen
	ipolate blackpopulationshare_decade year , generate(blackpopulationshare)

	gen blackwealthsharedirect = (inversewealthgap * blackpopulationshare)/( inversewealthgap * blackpopulationshare +  (1 - blackpopulationshare))
	replace blackwealthsharedirect = blackwealthsharedirect*100

	twoway line blackwealthsharedirect year if year >= 1870, lcolor(maroon) lwidth(thick) ///
	ytitle("% of national wealth", axis(1)) ///
	graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1860(20)2020)) xlabel(1860(20)2020) name("wealthshare", replace) scheme(s2color)
	graph export "$figtab/wealthshare.pdf", replace
 
	/*---------Figure 2(b): Real growth of Black wealth, by decade: 1870-2020*/

	/*Import Black wealth series*/
	import excel "$data_dkks/WealthGapFinal18602020.xlsx", sheet("Sheet1") firstrow clear
	 drop if year<1870
	 
	 gen decade = round(year/10)*10
	 collapse (mean) black_wealth_pc nonblack_wealth_pc, by(decade)
	 
	 tsset decade
	 gen growth_black = (black_wealth_pc/black_wealth_pc[_n-1]-1)*100
	 gen growth_nonblack = (nonblack_wealth_pc/nonblack_wealth_pc[_n-1]-1)*100
	 
	
	* Merge years into different eras based on history
	keep if (decade==1870) | (decade==1900) | (decade==1930) | (decade==1960) | (decade==1980) | (decade==2020)
	
	gen growth_black_30 = ((black_wealth_pc/black_wealth_pc[_n-1])^(1/(decade-decade[_n-1]))-1)*100
	gen growth_nonblack_30 = ((nonblack_wealth_pc/nonblack_wealth_pc[_n-1])^(1/(decade-decade[_n-1]))-1)*100

	drop if decade<=1870
	label define yeardef 1900 "1870-1900" 1930 "1900-1930" 1960 "1930-1960" 1980 "1960-1980" 2020 "1980-2020"
	label value decade yeardef
	
	graph bar growth_nonblack_30 growth_black_30, over(decade,label(angle(90))) 	///
	plotregion(color(white)) graphregion(color(white)) bgcolor(white) ///
	bar(1, fcolor(maroon) lcolor(black) lwidth(vvthin)) ///
	bar(2, fcolor(gs10) lcolor(black) lwidth(vvthin)) ///
	b1title("Year") ytitle("Annual growth rate (in %)") title("") ///
	legend(lab(1 "White") lab(2 "Black") region(lcolor(none) fcolor(none)) rows(1) ) name("wealthgrowth_30y", replace) scheme(s2color)
	graph export "${figtab}/wealthgrowth_30y.pdf", replace
	
*------------------------------------------------------------------------------------------------------------%
* Figure 3: White-Black per capita wealth ratio: 1860-2020
*------------------------------------------------------------------------------------------------------------%	

	** Only baseline series
	use "$data_dkks/WealthGapFinal18602020.dta", clear
	twoway connected wealthgap year  , ///
	lcolor(maroon) lwidth(thick) msymbol(none) graphregion(color(white)) plotregion(ilcolor(white)) ///
	xsc(range(1860(20)2020)) xlabel(1860(20)2020) xtitle("Year") ytitle("W/B wealth gap") name("benchmark",replace) ///
	yline(1,lpattern(dash) lcolor(gs8)) yla(1 "1" 20 "20" 40 "40" 60 "60")	
	graph export $figtab/historical_series.pdf, replace
	*text(3 1862 "1:1", color(gs8))
	
	** Baseline series + description 
	use "$data_dkks/WealthGapFinal18602020.dta", clear
	twoway connected wealthgap year  , msymbol(none) lcolor(maroon) lwidth(thick) ///
	graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1860(20)2020)) ///
	xlabel(1860(20)2020) ytitle("W/B wealth gap") ///
	yline(1,lpattern(dash) lcolor(gs8)) yla(1 "1" 20 "20" 40 "40" 60 "60")	///
	text(56.5 1870 "1860: 56", placement(e) size(medium)) ///
	text(27 1880 "1870: 23", placement(e) size(medium)) ///
	text(15 1925 "1920: 10", placement(e) size(medium)) ///
	text(12 1955 "1950: 7", placement(e) size(medium)) ///
	text(10 1982 "1980: 5", placement(e) size(medium)) ///
	text(12 2010 "2020: 6", placement(e) size(medium)) ///
	|| pcarrowi 56.25 1870   56.25 1864 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) ///
	|| pcarrowi 27 1880   23 1872 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) ///
	|| pcarrowi 14 1925   11 1922 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) ///
	|| pcarrowi 11 1955   8 1952 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) ///
	|| pcarrowi 9 1982   7 1980 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) ///
	|| pcarrowi 11 2020   7 2019 (1) "", mlabcolor(black) lcolor(black) mcolor(black) legend(off) scheme(s2color)
	graph export $figtab/historical_series_info.pdf, replace
	
	** Baseline series + description + Include simulation exercises
	preserve
	import excel "$simulation/simulation_wealthgap.xlsx", sheet("Sheet1") clear
	rename A year
	rename B wealthgap_simul
	drop if year==2020
	tempfile wealthgap_simul 
	save `wealthgap_simul', replace
	restore
	
	preserve
	import excel "$simulation/simulation_wealthgap_ls.xlsx", sheet("Sheet1") clear
	rename A year
	rename B wealthgap_simul_ls
	drop if year==2020
	tempfile wealthgap_simul_ls 
	save `wealthgap_simul_ls', replace
	restore
	
	use "$data_dkks/WealthGapFinal18602020.dta", clear
	tsset year
	tsfill 
	merge 1:1 year using `wealthgap_simul', nogen
	merge 1:1 year using `wealthgap_simul_ls', nogen
	
	** With same qs simulation 
	twoway connected wealthgap year  , lpattern(solid) msymbol(none) lcolor(maroon) lwidth(thick) ///
	|| line wealthgap_simul year, lpattern(longdash) msymbol(none) lcolor(maroon%70) lwidth(thick) ///
	legend(order(1 2) lab(1 "Data") lab(2 "Simulation") region(lcolor(none) fcolor(none)) rows(1) ) ///
	graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1860(20)2020)) ///
	xlabel(1860(20)2020) ytitle("W/B wealth gap") ///
	yline(1,lpattern(dash) lcolor(gs8)) yla(1 "1" 20 "20" 40 "40" 60 "60")	///
	text(56.5 1870 "1860: 56", placement(e) size(medium)) ///
	text(27 1880 "1870: 23", placement(e) size(medium)) ///
	text(15 1925 "1922: 10", placement(e) size(medium)) ///
	text(12 1955 "1949: 7", placement(e) size(medium)) ///
	text(10 1982 "1983: 5", placement(e) size(medium)) ///
	text(27 1962 "2019 actual gap: 6", placement(e) size(medium)) ///
	text(24 1962 "2019 gap without frictions: 3.2", placement(e) size(medium)) ///
	|| pcarrowi 56.25 1870   56.25 1864 (1) "", mlabcolor(black) lcolor(black) mcolor(black) ///
	|| pcarrowi 27 1880   23 1872 (1) "", mlabcolor(black) lcolor(black) mcolor(black)  ///
	|| pcarrowi 14 1925   11 1922 (1) "", mlabcolor(black) lcolor(black) mcolor(black)  ///
	|| pcarrowi 11 1955   8 1952 (1) "", mlabcolor(black) lcolor(black) mcolor(black)  ///
	|| pcarrowi 9 1982   7 1980 (1) "", mlabcolor(black) lcolor(black) mcolor(black)  ///
	|| pcarrowi 22 2020   7 2020 (1) "", mlabcolor(black) lcolor(black) mcolor(black)  scheme(s2color)
	graph export $figtab/historical_series_info_sim.pdf, replace

*------------------------------------------------------------------------------------------------------------%	
* Figure 4: Black and white homeownership rates, 1860-2020
*------------------------------------------------------------------------------------------------------------%	

	use "$micro_census/AggregateHousingDataCENSCF_1860-2019.dta", clear
	
	* White and Black homeownership rates from 1860-2020
	twoway connected homeowner0 homeowner1 year if census == 1 , msymbol( plus circle) color(maroon black) ///
	|| connected homeowner0 homeowner1 year if census == 0 & year >= 1930, ///
	 msymbol(diamond triangle) color(orange*.75 forest_green*.75) ///
	 graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1860(20)2020)) ///
	xlabel(1860(20)2020) xtitle("Year") ytitle("Homeownership rate") ///
	legend(lab(1 "White (Census)") lab(2 "Black (Census)") lab(3 "White (SCF+)") lab(4 "Black (SCF+)") region(color(none))) ///
	name("homeownership_series", replace) scheme(s2color)
	graph export $figtab/homeownership_series.pdf, replace

*------------------------------------------------------------------------------------------------------------%	
* Figure 5: Black and white shares with positive wealth, 1860-2020
*------------------------------------------------------------------------------------------------------------%	

	use "$micro_census/AggregateHousingData_1860-2019.dta", clear
	tempfile housing 
	save `housing', replace

	use "$data_dkks/WealthGapFinal18602020.dta", clear
	merge 1:1 year using `housing', nogen

	gen poswealthshare_black_eq= poswealthshare_black if year>1940
	gen poswealthshare_nonblack_eq=poswealthshare_nonblack if year>1940
	
	replace poswealthshare_black_eq = 1-$ZEROWEALTH1860_black_eq if year==1860
	replace poswealthshare_black_eq = 1-$ZEROWEALTH1870_black_eq if year==1870
	
	replace poswealthshare_black_eq = $poswealth_b_1900 if year==1900
	replace poswealthshare_black_eq = $poswealth_b_1910 if year==1910
	replace poswealthshare_black_eq = $poswealth_b_1920 if year==1920
	replace poswealthshare_black_eq = $poswealth_b_1930 if year==1930
	replace poswealthshare_black_eq = $poswealth_b_1940 if year==1940
	
	replace poswealthshare_nonblack_eq = 1-$ZEROWEALTH1860_nonblack_eq if year==1860
	replace poswealthshare_nonblack_eq = 1-$ZEROWEALTH1870_nonblack_eq if year==1870

	replace poswealthshare_nonblack_eq = $poswealth_w_1900 if year==1900
	replace poswealthshare_nonblack_eq = $poswealth_w_1910 if year==1910
	replace poswealthshare_nonblack_eq = $poswealth_w_1920 if year==1920
	replace poswealthshare_nonblack_eq = $poswealth_w_1930 if year==1930
	replace poswealthshare_nonblack_eq = $poswealth_w_1940 if year==1940

	gen poswealthshare_black_scf=.
	gen poswealthshare_nonblack_scf=.

	replace poswealthshare_black_scf = $poswealth_b_1900_scf if year==1900
	replace poswealthshare_black_scf = $poswealth_b_1910_scf if year==1910
	replace poswealthshare_black_scf = $poswealth_b_1920_scf if year==1920
	replace poswealthshare_black_scf = $poswealth_b_1930_scf if year==1930
	replace poswealthshare_black_scf = $poswealth_b_1940_scf if year==1940
	replace poswealthshare_black_scf = poswealthshare_black_eq if year>=1950

	replace poswealthshare_nonblack_scf = $poswealth_w_1900_scf if year==1900
	replace poswealthshare_nonblack_scf = $poswealth_w_1910_scf if year==1910
	replace poswealthshare_nonblack_scf = $poswealth_w_1920_scf if year==1920
	replace poswealthshare_nonblack_scf = $poswealth_w_1930_scf if year==1930
	replace poswealthshare_nonblack_scf = $poswealth_w_1940_scf if year==1940
	replace poswealthshare_nonblack_scf = poswealthshare_nonblack_eq if year>=1950
	
	twoway line poswealthshare_black_eq year if year<1900, lpattern(solid) msymbol(none) lcolor(black) lwidth(thick) ///
	|| line poswealthshare_nonblack_eq year if year<1900, lpattern(solid) msymbol(solid) lcolor(maroon) lwidth(thick) ///
	|| line poswealthshare_black_eq year if year>=1870 & year<1950, lpattern(dash) msymbol(none) lcolor(black) lwidth(thick) ///
	|| line poswealthshare_nonblack_eq year if year>=1870 & year<1950, lpattern(dash) msymbol(none) lcolor(maroon) lwidth(thick)  ///
	|| connected poswealthshare_black_scf year if year==1940 , msymbol(diamond) msize(large) mcolor(gs8) lcolor(black) mlcolor(black) ///
	|| connected poswealthshare_nonblack_scf year if year==1940, msymbol(diamond) msize(large) mcolor(gold) lcolor(maroon) mlcolor(maroon) ///
	|| connected poswealthshare_black_scf year if year>1940, lpattern(dash) msymbol(circle) msize(small) mcolor(black) lcolor(black) ///
	|| connected poswealthshare_nonblack_scf year if year>1940, lpattern(dash) msymbol(triangle) msize(small) mcolor(maroon) lcolor(maroon) ///
	yline(0.5, lcolor(gs7) lpattern(--) lwidth(thick)) ///
	xsc(range(1860(20)2020)) xlabel(1860(20)2020) xtitle("") ytitle("% Population") graphregion(color(white)) plotregion(ilcolor(white)) /// 
	yscale(r(0 1)) ylabel(0(0.2)1) ylabel(, angle(0)) ///
	legend( lab(1 "1860+1870 Census, Black") lab(2 "1860+1870 Census, White") ///
	lab(3 "1870 Census prediction, Black") lab(4 "1860 Census prediction, White") ///
	lab(5 "1950 SCF+ prediction, Black") lab(6 "1950 SCF+ prediction, White") ///
	lab(7 "SCF+, Black") lab(8 "SCF+, White") ///
	c(1) position() bplacement() row(4) size(small) region(color(none)))  name("share_poswealth_predict_all", replace) scheme(s2color)
	graph export "${figtab}/share_poswealth_predict_all.pdf", replace

*------------------------------------------------------------------------------------------------------------%	
* Figure 6: The racial wealth gap at the median
*------------------------------------------------------------------------------------------------------------%	
/*---------Figure 6(a): The racial wealth and income gap along the distribution*/

	use  "${scf}/raw/HSCF_2019.dta", clear

	replace blackh=. if raceh==0
	drop if blackh==.
		
	* Drop extreme outlier 
	drop if id == "19530750" & yearmerge == 1953

	gen decade = round(yearmerge/10) * 10
	gen homeownership = (house > 0 & house < .)
	gen hequity = house-hdebt
	
	xtile quant=ffanw [pweight=wgtI95W95], n(100)

	* Calculate average household size at the median, 90th percentile, and 99th percentile
	preserve
	qui collapse (mean) hhsize_med = hhsize if quant>=45 & quant<=55, by(decade blackh)
	reshape wide hhsize_med, i(decade) j(blackh)
	
	tempfile hhsize_med
	save `hhsize_med', replace
	restore
	
	qui collapse (p50) ffanwmed = ffanw tincmed=tinc housemed = hequity (mean) ffanwmean = ffanw tincmean = tinc hhsize /*
	*/ (mean) homeownership [aw=wgtI95W95], by(decade blackh) // summarize
	drop if blackh==.
	reshape wide ffanw* house* tinc* hhsize* homeownership*, i(decade) j(blackh)
	
	merge 1:1 decade using `hhsize_med', nogen

	/* Moving average across surveys */
		sort decade
		foreach cvar in ffanwmed housemed ffanwmean tincmed tincmean hhsize hhsize_med homeownership  {
			forvalues i = 0(1)1 {
				gen `cvar'`i'_smooth = .
				replace `cvar'`i'_smooth = (`cvar'`i'[_n-1] + `cvar'`i'[_n] + `cvar'`i'[_n+1]) / 3 if _n > 1 & _n < _N
				replace `cvar'`i'_smooth = (`cvar'`i'[_n] + `cvar'`i'[_n+1]) / 2 if _n == 1 
				replace `cvar'`i'_smooth = (`cvar'`i'[_n] + `cvar'`i'[_n-1]) / 2 if _n == _N 
				}
	}

		/* Generate per capita values */
		foreach cvar in ffanwmean tincmean {
				gen `cvar'_pp0 = `cvar'0_smooth /hhsize0_smooth
				gen `cvar'_pp1 = `cvar'1_smooth /hhsize1_smooth
	}
	
		foreach cvar in ffanwmed tincmed housemed{
				gen `cvar'_pp0 = `cvar'0_smooth /hhsize_med0_smooth
				gen `cvar'_pp1 = `cvar'1_smooth /hhsize_med1_smooth
	}
	
	** Median gap
	gen wratio_med_pc = ffanwmed_pp0/ffanwmed_pp1
	gen yratio_med_pc = tincmed_pp0/tincmed_pp1
	gen hratio_med_pc = housemed_pp0/housemed_pp1
	
	gen wratio_med = ffanwmed0_smooth/ffanwmed1_smooth
	gen yratio_med = tincmed0_smooth/tincmed1_smooth
	gen hratio_med = housemed0_smooth/housemed1_smooth

	** Mean gap 
	gen wratio_mean_pc = ffanwmean_pp0/ffanwmean_pp1
	gen yratio_mean_pc = tincmean_pp0/tincmean_pp1
	
	gen wratio_mean = ffanwmean0_smooth/ffanwmean1_smooth
	gen yratio_mean = tincmean0_smooth/tincmean1_smooth
	
	twoway connected wratio_med decade, lp(solid) lc(gs0) msym(o) msize(large) mfc(gs0) mlc(gs0) lw(thick) ///
	|| line wratio_mean decade, lp(dash) lw(thick) lc(gs0) lc(maroon) lw(thick) ///
	plotregion(color(white)) graphregion(color(white)) bgcolor(white) ///
	xscale(r(1950 2020)) xlabel(1950(10)2020) yscale(r(0 25)) ylabel(0(5)25) ylabel(, angle(0)) xtitle("") ytitle("W/B median wealth gap") title("") ///
	legend(lab(1 "Median") lab(2 "Mean") row(1) region(color(none)))   name("wratio_p50_mean", replace)  scheme(s2color)
	graph export "${figtab}/wratio_p50_mean.pdf", replace
	
	
	/*---------Figure 6(b): Growth of median wealth*/

	** Generate growth rates of median wealth gap 
	forvalues i = 0(1)1 {
		gen wealthgrowth`i' = (ffanwmed_pp`i'/ffanwmed_pp`i'[_n-1] - 1) * 100
		}

		
	graph bar wealthgrowth0  wealthgrowth1 if decade > 1950 , over(decade, relabel(1 "1950-1960" 2 "1960-1970" 3 "1970-1980" 4 "1980-1990" 5 "1990-2000" 6 "2000-2010" 7 "2010-2020") label(angle(90))) /*
	*/	bar(1, fcolor(maroon) lcolor(maroon) lwidth(vvthin)) /*
	*/	bar(2, fcolor(gs10) lcolor(gs10) lwidth(vvthin)) /*
	*/ 	plotregion(color(white)) graphregion(color(white)) bgcolor(white) /*
	*/ 	legend(label(1 "White") label(2 "Black") region(color(none))) name("wealthgrowthmedian", replace) title("") /*
	*/	ytitle("Growth rate (in %)") b1title("Year") scheme(s2color)
	graph export "${figtab}/wealthgrowthmedian.pdf", replace
	
*------------------------------------------------------------------------------------------------------------%	
* Figure 7: Black population shares along the wealth distribution
*------------------------------------------------------------------------------------------------------------%	
	/*---------- SCF+ ------------*/
	use "$scf/raw/HSCF_2019.dta", clear
	mi unset, asis
		
	/* Drop overinfluential outliers */
	drop if id == "19530750" & yearmerge == 1953

	gen decade = round(yearmerge/10)*10

	// PLOT: BLACK POPULATION SHARE IN WEALTH GROUPS

	* Populations share from Census
	preserve
	insheet using $population/raw/census_race_statistics_1790_2010.csv, clear

	keep if year>=1950

		g bpopshare=black_population/total_population*100
		sort year
		rename year decade
	tempfile blackshare_census
	save `blackshare_census', replace

	restore	

	* Average population share Black 

	preserve
	collapse (sum) hhsize [aw=wgtI95W95], by(decade blackh)
	reshape wide hhsize*, i(decade) j(blackh)
	gen blackshare_mean_pop = hhsize1/(hhsize1+hhsize0)

	tempfile blackshare_mean_pop
	save `blackshare_mean_pop', replace
	restore

		
	collapse (sum) hhsize [aw = wgtI95W95], by(decade blackh ffanwgroups)
	reshape wide hhsize, i(decade black) j(ffanwgroups)
	reshape wide hhsize*, i(decade) j(black)

	gen blackh1 = hhsize11/(hhsize11+hhsize10)
	gen blackh2 = hhsize21/(hhsize21+hhsize20)
	gen blackh3 = hhsize31/(hhsize31+hhsize30)

	merge 1:1 decade using `blackshare_mean_pop', nogen
	merge 1:1 decade using `blackshare_census', nogen

	replace bpopshare = bpopshare/100

	twoway connected blackh1 decade, lp(solid) lc(gs0) msym(o) msize(large) mfc(gs0) mlc(gs0) lw(thick) ///
		|| connected blackh2 decade, lp(solid) lc(gs5) msym(t) msize(large) mfc(gs5) mlc(gs5) lw(thick)  ///
		|| connected blackh3 decade, lp(solid) lc(gs9) msym(d) msize(large) mfc(gs9) mlc(gs9) lw(thick)  ///
		|| line blackshare_mean_pop decade, lp(dash) lc(maroon) msym(d) msize(large) mfc(maroon) mlc(maroon) lw(thick) ///
		 graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1950(10)2020)) ///
		xlabel(1950(10)2020) xtitle("Year") ytitle("Black population share") ///
		legend(lab(1 "Bottom 50% ") lab(2 "50%-90%") lab(3 "Top 10%") lab(4 "Average") region(color(none))) ///
		name("blackshare_ffanw_pop", replace) scheme(s2color)
		graph export "$figtab/blackshare_ffanw_pop.pdf", replace
		
*------------------------------------------------------------------------------------------------------------%	
* Figure 8: Rank gap at the median and 90t percentile
*------------------------------------------------------------------------------------------------------------%	
	use  "${scf}/HSCF_2019_dc_micro.dta", clear

	replace blackh=. if raceh==0
	drop if blackh==.
		
	* Percentile ranks
	preserve
	tempfile coeff_rank

	keep if blackh==0
	sort decade nw
	by decade: egen N = total(wgtI95W95)
	by decade nw: egen temp = total(wgtI95W95)
	gen half = temp/2
	by decade: gen runsum = sum(wgtI95W95)
	gen runsum_n_1 = runsum[_n-1]
	by decade: replace runsum_n_1 = 0 if _n==1
	gen i=.
	bysort decade nw: replace i = half + runsum_n_1 if _n==1
	replace i = i[_n-1] if i==.
	gen pct = i/N *100

	keep pct nw decade
	duplicates drop pct nw decade, force

	save `coeff_rank', replace
	restore


	nearmrg decade using `coeff_rank', nearvar(nw)
	drop _merge

	drop if nw==.


	foreach yr in 1950 1960 1970 1980 1990 2000 2010 2020 {
		
		di "`yr'"
		qui qreg pct blackh agehgroup [pw = wgtI95W95] if decade == `yr', q(50)
		qui gen coeff_rank50_`yr' = _b[blackh]
		qui qreg pct blackh agehgroup* [pw = wgtI95W95] if decade == `yr', q(90)
		qui gen coeff_rank90_`yr' = _b[blackh]

	}

	qui collapse coeff_*, by(decade) // summarize

	gen rankgap50=.
	gen rankgap90=.

	qui levelsof decade, clean local(myears)

	foreach myear of local myears {

	replace rankgap50 = coeff_rank50_`myear' if decade==`myear'
	replace rankgap90 = coeff_rank90_`myear' if decade==`myear'
	}

	sum rankgap50 rankgap90
	egen mean_rankgap50 = mean(rankgap50)
	egen mean_rankgap90 = mean(rankgap90)

	drop coeff_*

	twoway connected rankgap50 decade, lp(solid) lc(maroon) msym(o) msize(large) mfc(maroon) mlc(maroon) lw(thick) || ///
	connected rankgap90 decade, lp(dash) lc(gs0) msym(o) msize(large) mfc(gs0) mlc(gs0) lw(thick) ///
	plotregion(color(white)) graphregion(color(white)) bgcolor(white) ///
	xscale(r(1950 2020)) xlabel(1950(10)2020) yscale(r(-35 -15)) ylabel(-35(5)-15) ylabel(, angle(0)) xtitle("Year") ytitle("Rank gap (percentiles)") title("") ///
	legend(label(1 "Median")label(2 "90th percentile")region(color(none))) name("rankgap90", replace) legend(region(lstyle(none) color(none) )) scheme(s2color)
	graph export "${figtab}/rankgap_all.pdf", replace
	
*------------------------------------------------------------------------------------------------------------%
* APPENDIX FIGURES:
* Appendix A: Alternative representation of Black and white wealth: Figure A1-A4, Table A1
* Appendix B: Imputing personal property: Figure B1-B5, Table B1-B2
*------------------------------------------------------------------------------------------------------------%	
*------------------------------------------------------------------------------------------------------------%
* Figure A1: Black share of national wealth vs. top 0.1% share of national wealth
*------------------------------------------------------------------------------------------------------------%	

	/* Pull in wealth shares of top 0.1% from Saez-Zucman (QJE 2016)*/
	preserve
	import excel year=A wealthshare_01=I wealthshare_001=J using "$psz/PSZ2022AppendixTables.xlsx", sheet("TE1") cellrange(A47:J116) clear
	tempfile wealthshare_psz
	save `wealthshare_psz', replace
	restore
	
	preserve
	import delimited "$population/raw/census_race_statistics_1790_2010.csv", clear 

	gen blackpopulationshare_decade = black_population/total_population

	keep year blackpopulationshare_decade
	tempfile populationdata
	save `populationdata', replace
	restore

	import excel "$data_dkks/WealthGapFinal18602020.xlsx", sheet("Sheet1") firstrow clear

	merge 1:1 year using `populationdata', nogen
	merge 1:1 year using `wealthshare_psz', nogen
	
	ipolate blackpopulationshare_decade year , generate(blackpopulationshare)

	gen blackwealthsharedirect = (inversewealthgap * blackpopulationshare)/( inversewealthgap * blackpopulationshare +  (1 - blackpopulationshare))
	replace blackwealthsharedirect = blackwealthsharedirect*100
	
	replace wealthshare_01 = wealthshare_01*100
	replace wealthshare_01 =. if blackwealthsharedirect==.
	
	twoway connected blackwealthsharedirect year if year>=1950, lp(dash) lc(gs0) lc(gs0) msym(none) msize(large) mfc(gs0) mlc(gs0) lw(thick) /// ///
	|| connected wealthshare_01 year if year>=1950, ///
	graphregion(color(white)) plotregion(ilcolor(white)) xsc(range(1950(10)2020)) ///
	xlabel(1950(10)2020)  msymbol(none) lcolor(maroon) lwidth(thick) ///
	legend(lab(1 "Black ") lab(2 "Top 0.1%") region(color(none))) ///
	xtitle("Year") ytitle("% of national wealth") name("historical_series_wealth_share", replace) scheme(s2color)
	graph export "$figtab/historical_series_wealth_share_with01.pdf", replace
	
*------------------------------------------------------------------------------------------------------------%	
* Figure A2: White-Black per capita wealth ratio in logs
*------------------------------------------------------------------------------------------------------------%	

	use "$data_dkks/WealthGapFinal18602020.dta", clear
	gen logwealthgap = log(wealthgap)
	twoway connected logwealthgap year  if year>=1870, ///
	lcolor(maroon) lwidth(thick) msymbol(none) graphregion(color(white)) plotregion(ilcolor(white)) ///
	xsc(range(1870(20)2020)) xlabel(1870(20)2020) xtitle("Year") ytitle("Log W/B wealth gap") name("logwealthgap",replace) scheme(s2color)
	graph export $figtab/logwealthgap.pdf, replace

*------------------------------------------------------------------------------------------------------------%	
* Table A1: White share with positive wealth: South vs. Non-South
*------------------------------------------------------------------------------------------------------------%		
	use "$micro_census_jep/CensusData1860.dta", clear	

/** South vs. Non-South
	gen south = 0
	replace south = 1 if statefip == 1 | statefip == 5 | statefip == 10 | statefip == 12 | statefip == 13 | statefip == 21 ///
	| statefip == 22 | statefip == 24 | statefip == 28 | statefip == 37 | statefip == 40 | statefip == 45 | statefip == 47 ///
	| statefip == 48 | statefip == 51 /*| statefip == 54 | statefip == 11*/
*/
* Use definition of South from Ager et al. 
	gen south = ((stateicp >=40 & stateicp <=56) | stateicp == 34 | stateicp == 11 | stateicp == 98)	
	
/** Union states
	gen union = 0
	replace union = 1 if statefip == 23 | statefip == 36 | statefip == 33 | statefip == 50 | statefip == 25 | statefip == 9 ///
	| statefip == 44 | statefip == 42 | statefip == 34 | statefip == 39 | statefip == 18 | statefip == 17 | statefip == 20 ///
	| statefip == 26 | statefip == 55 | statefip == 27 | statefip == 19 | statefip == 6 | statefip == 32 | statefip == 41 ///
	
** Confederate states
	gen confederate = 0
	replace confederate = 1 if statefip == 1 | statefip == 5 | statefip == 12 | statefip == 13 ///
	| statefip == 22 | statefip == 28 | statefip == 37 | statefip == 45 | statefip == 47 ///
	| statefip == 48 | statefip == 51 /*| statefip == 54 | statefip == 11*/
	
** Boarder states
	gen boarder = 0
	replace boarder = 1 if statefip == 10 | statefip == 21 | statefip == 24 | statefip == 29 ///
	| statefip == 54 
*/

** Summarize shares with positive wealth & save as texfiles
	gen poswealthshare_eq = (wealth_eq>0)
	
	sum poswealthshare_eq if race == 1 
	local poswealthshare_1860 = r(mean)*100
	PrintEst `poswealthshare_1860' "poswealthshare_1860"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1860: qui estpost summarize poswealthshare_eq if race == 1 
	
	
	sum poswealthshare_eq if race == 1  & south==1
	local poswealthshare_1860_south = r(mean)*100
	PrintEst `poswealthshare_1860_south' "poswealthshare_1860_south"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1860_south: qui estpost summarize poswealthshare_eq if race == 1  & south==1
	
	sum poswealthshare_eq if race == 1  & south==0
	local poswealthshare_1860_nosouth = r(mean)*100
	PrintEst `poswealthshare_1860_nosouth' "poswealthshare_1860_nosouth"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1860_nosouth: qui estpost summarize poswealthshare_eq if race == 1  & south==0
	
	use "$micro_census_jep/CensusData1870.dta", clear	
	
* Use definition of South from Ager et al. 
	gen south = ((stateicp >=40 & stateicp <=56) | stateicp == 34 | stateicp == 11 | stateicp == 98)
/** Union states
	gen union = 0
	replace union = 1 if statefip == 23 | statefip == 36 | statefip == 33 | statefip == 50 | statefip == 25 | statefip == 9 ///
	| statefip == 44 | statefip == 42 | statefip == 34 | statefip == 39 | statefip == 18 | statefip == 17 | statefip == 20 ///
	| statefip == 26 | statefip == 55 | statefip == 27 | statefip == 19 | statefip == 6 | statefip == 32 | statefip == 41 ///
	
** Confederate states
	gen confederate = 0
	replace confederate = 1 if statefip == 1 | statefip == 5 | statefip == 12 | statefip == 13 ///
	| statefip == 22 | statefip == 28 | statefip == 37 | statefip == 45 | statefip == 47 ///
	| statefip == 48 | statefip == 51 /*| statefip == 54 | statefip == 11*/
	
** Boarder states
	gen boarder = 0
	replace boarder = 1 if statefip == 10 | statefip == 21 | statefip == 24 | statefip == 29 ///
	| statefip == 54 
*/	
	gen poswealthshare_eq = 1-zerototwealth_eq
	
	sum poswealthshare_eq if race == 1 
	local poswealthshare_1870 = r(mean)*100
	PrintEst `poswealthshare_1870' "poswealthshare_1870"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1870: qui estpost summarize poswealthshare_eq if race == 1 
	
	sum poswealthshare_eq if race == 1  & south==1
	local poswealthshare_1870_south = r(mean)*100
	PrintEst `poswealthshare_1870_south' "poswealthshare_1870_south"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1870_south: qui estpost summarize poswealthshare_eq if race == 1  & south==1
	
	sum poswealthshare_eq if race == 1  & south==0
	local poswealthshare_1870_nosouth = r(mean)*100
	PrintEst `poswealthshare_1870_nosouth' "poswealthshare_1870_nosouth"	"" "%" 4.1f "$figtab/text"
	eststo poswealthshare_1870_nosouth: qui estpost summarize poswealthshare_eq if race == 1  & south==0
	
	

	esttab poswealthshare_1860 poswealthshare_1860_south poswealthshare_1860_nosouth, cells("mean") label unstack mtitle("1860 All" "1860 South" "1860 NSouth") nonumbers eqlabels(none) collabels(none)
	
	esttab poswealthshare_1870 poswealthshare_1870_south poswealthshare_1870_nosouth, cells("mean") label unstack mtitle("1860 All" "1860 South" "1860 NSouth") nonumbers eqlabels(none) collabels(none)
	
*------------------------------------------------------------------------------------------------------------%	
* Figure B1: Black and white shares with positive wealth, 1860-1870 and 1950-2020
*------------------------------------------------------------------------------------------------------------%	

	use "$micro_census/AggregateHousingData_1860-2019.dta", clear
	tempfile housing 
	save `housing', replace

	use "$data_dkks/WealthGapFinal18602020.dta", clear
	merge 1:1 year using `housing', nogen

	gen poswealthshare_black_eq=poswealthshare_black if year>1940
	gen poswealthshare_nonblack_eq=poswealthshare_nonblack if year>1940
	
	replace poswealthshare_black_eq = 1-$ZEROWEALTH1860_black_eq if year==1860
	replace poswealthshare_black_eq = 1-$ZEROWEALTH1870_black_eq if year==1870
	
	replace poswealthshare_nonblack_eq = 1-$ZEROWEALTH1860_nonblack_eq if year==1860
	replace poswealthshare_nonblack_eq = 1-$ZEROWEALTH1870_nonblack_eq if year==1870
	

	gen poswealthshare_black_scf = poswealthshare_black_eq if year>=1950
	gen poswealthshare_nonblack_scf = poswealthshare_nonblack_eq if year>=1950

	twoway connected poswealthshare_black_eq year if year<=1870, lpattern(solid) msymbol(none) lcolor(black) lwidth(thick) ///
	|| connected poswealthshare_nonblack_eq year if year<=1870, lpattern(solid) color(maroon) msymbol(none) lpattern(dots) lwidth(thick)  ///
	|| connected poswealthshare_black_scf year if year>=1950, lpattern(solid) msymbol(none) lcolor(black) lwidth(thick) ///
	|| connected poswealthshare_nonblack_scf year if year>=1950, lpattern(solid) color(maroon) msymbol(none) lpattern(dots) lwidth(thick)  ///
	|| connected homeowner1 year, lpattern(dash) msymbol(circle) msize(small) mcolor(black) lcolor(black) ///
	|| connected homeowner0 year, lpattern(dash) msymbol(triangle) msize(small) mcolor(maroon) lcolor(maroon) ///
	xsc(range(1860(20)2020)) xlabel(1860(20)2020) xtitle("") ytitle("% Population") graphregion(color(white)) plotregion(ilcolor(white)) /// 
	yscale(r(0 1)) ylabel(0(0.2)1) ylabel(, angle(0)) ///
	legend(order(1 "Black, total wealth share" 2 "White, total wealth share" 5 "Black, homeownership" 6 "White, homeownership") region(color(none))) name("share_poswealth_1860_1870_scf", replace) scheme(s2color)
	graph export "${figtab}/share_poswealth_1860_1870_scf.pdf", replace
	

*------------------------------------------------------------------------------------------------------------*
* Number for footnote 2
*------------------------------------------------------------------------------------------------------------%
		use "$scf/raw/HSCF_2019.dta", clear
		mi unset, asis
				
		/* Drop overinfluential outliers */
		drop if id == "19530750" & yearmerge == 1953

		gen decade = round(yearmerge/10)*10

		keep if decade == 2020 

		xtile quan = ffanw if ffanw!=. [aw=wgtI95W95], n(1000)

		gen wealthgroup_all = 1 + (quan >= 500)  + (quan >= 900)  + (quan >= 990)  + (quan >= 999)

		preserve
		collapse (sum) hhsize [aw = wgtI95W95], by(blackh wealthgroup_all)
		reshape wide hhsize, i(blackh) j(wealthgroup_all)

		egen tot1 = sum(hhsize1)
		egen tot2 = sum(hhsize2)
		egen tot3 = sum(hhsize3)
		egen tot4 = sum(hhsize4)
		egen tot5 = sum(hhsize5)

		gen blackh1 = hhsize1/tot1
		gen blackh2 = hhsize2/tot2
		gen blackh3 = hhsize3/tot3
		gen blackh4 = hhsize4/tot4
		gen blackh5 = hhsize5/tot5

		sum blackh5 if blackh==1
		local blackshare_top = r(mean)*100
		PrintEst `blackshare_top' "blackshare_top"	"" "%" 9.0fc "$figtab/text"
			
		restore


		preserve
		gen other = (raceh==0)
		collapse (sum) hhsize [aw = wgtI95W95], by(other wealthgroup_all)
		reshape wide hhsize, i(other) j(wealthgroup_all)

		egen tot1 = sum(hhsize1)
		egen tot2 = sum(hhsize2)
		egen tot3 = sum(hhsize3)
		egen tot4 = sum(hhsize4)
		egen tot5 = sum(hhsize5)

		gen other1 = hhsize1/tot1
		gen other2 = hhsize2/tot2
		gen other3 = hhsize3/tot3
		gen other4 = hhsize4/tot4
		gen other5 = hhsize5/tot5

		sum other5 if other==1
		local othershare_top = r(mean)*100
		PrintEst `othershare_top' "othershare_top"	"" "%" 9.0fc "$figtab/text"
		restore

