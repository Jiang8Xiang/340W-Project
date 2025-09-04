/**------ Run regression with 1870 data, for Black-------*/ 

use "$micro_census_jep/CensusData1870_reg.dta", clear

gen poswealth = (persprop_eq>0)
gen age2 = age^2
replace sex = (sex==1)
replace labforce = (labforce==2)
replace urban = (urban==2)

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
gen unemployed = (occ1950>970)

** Generate literacy variable
gen literacy = (lit==4)


** Regression for Black
logit poswealth c.famsize i.urban i.sex i.labforce i.farmer i.professional i.laborer i.literacy c.age c.age2 i.statefip if race==2 & relate==1 & realprop==0

** Predict positive wealth holdings for 1880-1940

use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear

keep if race==2
gen age2 = age^2
gen homeownership = (ownershp==1)
replace sex = (sex==1)
replace labforce = (labforce==2)
replace urban = (urban==2)

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
gen unemployed = (occ1950>970)

** Generate literacy variable
gen literacy = (lit==4)
replace literacy = 1 if educd>15 & year==1940

forval year=1880(10)1940{
predict poswealthhat`year' if relate==1 & homeownership==0 & year==`year'
bysort serial: egen poswealthhat`year'_hh = mean(poswealthhat`year') if year==`year'
}

collapse (mean) homeownership *_hh [aw=perwt], by(year)
drop if year<1900
gen nohome = 1-homeownership
gen sharewealth_nohome =.

forval year=1900(10)1940{

sum poswealthhat`year'_hh 
replace sharewealth_nohome = nohome * r(mean) if year==`year'

}

gen poswealth = sharewealth_nohome+homeownership

forval year=1900(10)1940{

sum poswealth if year==`year'
global poswealth_b_`year' = r(mean)

}

/**------ Run regression with 1860 data, for White-------*/ 

use "$micro_census_jep/CensusData1860_reg.dta", clear


gen poswealth = (persprop_eq>0)
gen age2 = age^2
replace sex = (sex==1)
replace labforce = (labforce==2)
replace urban = (urban==2)

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
gen unemployed = (occ1950>970)

** Generate literacy variable
gen literacy = (lit==4)


** Regression for White
logit poswealth famsize i.urban i.sex i.labforce i.farmer i.professional i.laborer i.literacy age age2 i.statefip if race!=2 & relate==1 & realprop==0

** Predict positive wealth holdings for 1880-1940

use "$micro_census_jep/raw/CensusData1850_1950Covariates.dta", clear

drop if year<1880
keep if race!=2
gen age2 = age^2
gen homeownership = (ownershp==1)
replace sex = (sex==1)
replace labforce = (labforce==2)

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
gen unemployed = (occ1950>970)

** Generate literacy variable
gen literacy = (lit==4)
replace literacy = 1 if educd>15 & year==1940

forval year=1880(10)1940{
predict poswealthhat`year' if relate==1 & homeownership==0 & year==`year'
bysort serial: egen poswealthhat`year'_hh = mean(poswealthhat`year') if year==`year'
}

** Collapse by homeownership and predicted positive wealth (of none homeowners)
collapse (mean) homeownership *_hh [aw=perwt], by(year)
drop if year<1900
gen nohome = 1-homeownership
gen sharewealth_nohome =.

forval year=1900(10)1940{
sum poswealthhat`year'_hh 
replace sharewealth_nohome = nohome * r(mean) if year==`year'
}

gen poswealth = sharewealth_nohome+homeownership

forval year=1900(10)1940{

sum poswealth if year==`year'
global poswealth_w_`year' = r(mean)

}

