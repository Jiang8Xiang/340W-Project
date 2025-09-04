/*---------- SCF+ ------------*/
use "$scf/raw/HSCF_2019.dta", clear
mi unset, asis
	
/* Drop overinfluential outliers */
drop if id == "19530750" & yearmerge == 1953

** Merge with state-level data 
merge 1:m year id impnum using "$scf/raw/SCF_states.dta"
drop _merge

/* Keep only 1950*/
keep if yearmerge==1950

/*Generate statefip as in Census*/
gen statefip =.
replace statefip = 1 if state=="Alabama"
replace statefip = 4 if state=="Arizona"
replace statefip = 5 if state=="Arkansas"
replace statefip = 6 if state=="California"
replace statefip = 8 if state=="Colorado"
replace statefip = 9 if state=="Connecticut"
replace statefip = 10 if state=="Delaware"
replace statefip = 11 if state=="District of Columbia"
replace statefip = 12 if state=="Florida"
replace statefip = 13 if state=="Georgia"
replace statefip = 16 if state=="Idaho"
replace statefip = 17 if state=="Illinois"
replace statefip = 18 if state=="Indiana"
replace statefip = 19 if state=="Iowa"
replace statefip = 20 if state=="Kansas"
replace statefip = 21 if state=="Kentucky"
replace statefip = 22 if state=="Louisiana"
replace statefip = 23 if state=="Maine"
replace statefip = 24 if state=="Maryland"
replace statefip = 25 if state=="Massachusetts"
replace statefip = 26 if state=="Michigan"
replace statefip = 27 if state=="Minnesota"
replace statefip = 28 if state=="Mississippi"
replace statefip = 29 if state=="Missouri"
replace statefip = 30 if state=="Montana"
replace statefip = 31 if state=="Nebraska"
replace statefip = 32 if state=="Nevada"
replace statefip = 33 if state=="New Hampshire"
replace statefip = 34 if state=="New Jersey"
replace statefip = 35 if state=="New Mexico"
replace statefip = 36 if state=="New York"
replace statefip = 37 if state=="North Carolina"
replace statefip = 38 if state=="North Dakota"
replace statefip = 39 if state=="Ohio"
replace statefip = 40 if state=="Oklahoma"
replace statefip = 41 if state=="Oregon"
replace statefip = 42 if state=="Pennsylvania"
replace statefip = 44 if state=="Rhode Island "
replace statefip = 45 if state=="South Carolina"
replace statefip = 46 if state=="South Dakota"
replace statefip = 47 if state=="Tennessee"
replace statefip = 48 if state=="Texas"
replace statefip = 49 if state=="Utah"
replace statefip = 50 if state=="Vermont"
replace statefip = 51 if state=="Virginia"
replace statefip = 53 if state=="Washington"
replace statefip = 54 if state=="West Virginia"
replace statefip = 55 if state=="Wisconsin"
replace statefip = 56 if state=="Wyoming"

gen homeownership = (house>0)
rename ageh age
gen age2 = age^2
gen poswealth = (ffanw>0)
gen sex = (sexh==1)

** Generate farmer variable
gen farmer = (occuh==3)

** Generate professionals variable
gen professional = (occuh==5)

** Generate retirement variable
*gen retired = (occ1950==984)

** Generate laborer variable
gen laborer = (occuh==4)

** Generate unemployment variable
gen unemployed = (occuh==2)

** Regression for Black
preserve
logit poswealth hhsize i.sex i.farmer i.professional i.laborer i.unemployed eduh age age2 i.statefip if blackh==1 & homeownership==0

** Predict positive wealth holdings for 1940 BLACK

use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear

keep if year>=1900

keep if race==2
gen age2 = age^2
gen homeownership = (ownershp==1)
gen marstat = (marst==1|marst==2)
replace sex = (sex==1)
rename occscore incws
rename famsize hhsize

** Generate farmer variable
gen farmer = 0 
replace farmer = 1 if occ1950==100 | occ1950==123 | (occ1950>=810 & occ1950<=840) | occ1950==910

** Generate professionals variable
gen professional = 0 
replace professional = 1 if occ1950<100 | (occ1950>=200 & occ1950<300)

** Generate retirement variable
*gen retired = (occ1950==984)

** Generate laborer variable
gen laborer = 0 
replace laborer = 1 if occ1950<=970
replace laborer = 0 if farmer==1
replace laborer = 0 if professional==1

** Generate unemployment variable
gen unemployed = (empstat==2) 
replace unemployed = 0 if unemployed==1 & labforce==0

** Generate education variable
gen eduh =0
replace eduh = 1 if educ<=5
replace eduh = 2 if educ>5 & educ<=9
replace eduh = 3 if educ>9

** Replace literacy variable
replace lit = 0 if educd<=15 & year==1940
replace lit = 1 if educd>15 & year==1940

forval year=1900(10)1940{
predict poswealthhat`year' if relate==1 & homeownership==0 & year==`year'
bysort serial: egen poswealthhat`year'_hh = mean(poswealthhat`year') if year==`year' 
}

collapse (mean) homeownership *_hh [aw=perwt], by(year)
gen nohome = 1-homeownership
gen sharewealth_nohome =.

forval year=1900(10)1940{
sum poswealthhat`year'_hh 
replace sharewealth_nohome = nohome * r(mean) if year==`year'
}

gen poswealth = sharewealth_nohome+homeownership

forval year=1900(10)1940{

sum poswealth if year==`year'
global poswealth_b_`year'_scf = r(mean)

}

restore

** Regression for White
preserve
logit poswealth hhsize i.sex i.farmer i.professional i.laborer i.unemployed eduh age age2 i.statefip if blackh==0 & homeownership==0

** Predict positive wealth holdings for 1940 White

use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear

keep if year>=1900
keep if race!=2
gen age2 = age^2
gen homeownership = (ownershp==1)
gen marstat = (marst==1|marst==2)
replace sex = (sex==1)
rename occscore incws
rename famsize hhsize

** Generate farmer variable
gen farmer = 0 
replace farmer = 1 if occ1950==100 | occ1950==123 | (occ1950>=810 & occ1950<=840) | occ1950==910

** Generate professionals variable
gen professional = 0 
replace professional = 1 if occ1950<100 | (occ1950>=200 & occ1950<300)

** Generate retirement variable
*gen retired = (occ1950==984)

** Generate laborer variable
gen laborer = 0 
replace laborer = 1 if occ1950<=970
replace laborer = 0 if farmer==1
replace laborer = 0 if professional==1

** Generate unemployment variable
gen unemployed = (empstat==2) 
replace unemployed = 0 if unemployed==1 & labforce==0

** Generate education variable
gen eduh =0
replace eduh = 1 if educ<=5
replace eduh = 2 if educ>5 & educ<=9
replace eduh = 3 if educ>9

** Replace literacy variable
replace lit = 0 if educd<=15 & year==1940
replace lit = 1 if educd>15 & year==1940

forval year=1900(10)1940{
predict poswealthhat`year' if relate==1 & homeownership==0 & year==`year'
bysort serial: egen poswealthhat`year'_hh = mean(poswealthhat`year') if year==`year' 
}

collapse (mean) homeownership *_hh [aw=perwt], by(year)
gen nohome = 1-homeownership
gen sharewealth_nohome =.

forval year=1900(10)1940{
sum poswealthhat`year'_hh 
replace sharewealth_nohome = nohome * r(mean) if year==`year'
}

gen poswealth = sharewealth_nohome+homeownership

forval year=1900(10)1940{

sum poswealth if year==`year'
global poswealth_w_`year'_scf = r(mean)

}

restore
