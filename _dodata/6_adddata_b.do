clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile temp  

* -------------------
*** Prep add covariates 
import delimited /Users/jkun0001/Desktop/24_05_24_replicationpackage_all/_dodata/_rawdata/analytic_data2011.csv, varnames(1) rowrange(3) clear 
rename digitfipscode fcounty
destring uninsuredadultsrawvalue, force replace
save `temp', replace 
* -------------------
use /Users/jkun0001/Desktop/24_05_24_data/dontuse/20_01_08_data_alphas_hhi.dta

drop _merge
merge m:1 fcounty using `temp', keepusing(uninsuredadultsrawvalue) keep(1 3) nogen  
*** 

*-------------------------------------------------------------------------------
* Prepare
* first fill up chain id 
	egen ne = group(providerid)
	g chainid_inclnochian = chainid*10000
	replace chainid_inclnochian = ne if chainid_inclnochian==.
	egen chainid_incl_nochain = group(chainid_inclnochian)
	drop ne chainid_inclnochian
bys chainid_incl_nochain measure year : g nrhospinchain_cond = _N
bys providerid : egen numberofhospitalsinchain = max(nrhospinchain_cond)

bys chainid : g tx = _n
tab numberofhospitalsinchain 
_pctile numberofhospitalsinchain , nq(100)  
g largechain=numberofhospitalsinchain>=r(r70)
tab largechain
	*total number in HRR
	bys hsa year: egen temp = total(numberofdischarges)
	*total number per system
	bys providerid year : g temp1  = _n
	bys chainid_incl_nochain hsa year: egen temp2 = total(totnumdicarges_other) if temp1==1 
	* only one per system	
	bys chainid_incl_nochain hsa year temp2: g temp3  = _n
	* HHI - average
	g temp4 = (temp2/temp)^2                if temp3==1  & closed!=1
	bys hsa year: egen temp5 = total(temp4)
	replace temp5 = . if temp5==0
	bys hsa: egen hhi_discharge_sys_hsa = mean(temp5) 
	* HHI - 2008
	g temp6 = temp4 if year == 2008
	bys hsa: egen hhi_discharge_sys2008_hsa = max(temp6) 

drop temp*


sort providerid measure year
by providerid measure: g temp=_n
by providerid : g temp2=_n
loc suffix phi_
loc method brglm_penalty
* Gen
g te=nrhosphrr/popinhrr
su te if everchanged_ownerstat==0, d
g med=te>r(p50)

su mean_hhi_beds if everchanged_ownerstat==0, d
g med2=mean_hhi_beds>r(p50)

su mean_hhi_discharges if everchanged_ownerstat==0, d 
g med3=mean_hhi_discharges>r(p50)

g forprofitXsystem=forprofit*belongschain

g forprofitXhhi_dis=forprofit*mean_hhi_discharges

g forprofitXhhi_bed=forprofit*mean_hhi_bed

g forprofitXnrhosphrr=forprofit*te

rename new_hhi_discharge_sys_other new_hhi_dis_sys_other
rename hhi_discharge_sys_hsa        new_hhi_dis_sys_hsa
rename hhi_discharge_sys2008_hsa	new_hhi_dis_sys2008_hsa

foreach var in hhi_beds hhi_beds_other hhi_beds_own hhi_disc_measure hhi_disc_measure2008 hhi_discharge hhi_discharge2008 hhi_discharge_sys hhi_discharge_sys2008 hhi_discharge_sys_own hhi_dis_sys_other hhi_dis_sys_hsa hhi_dis_sys2008_hsa {
	_pctile new_`var' if t==1 & everchanged_ownerstat==0, nq(2)
	g mforprofitX`var'	= forprofit*(new_`var'>=r(r1))		//Median
	g mchainX`var'    	= belongschain*(new_`var'>=r(r1))
	g forprofitX`var' 	= forprofit*(new_`var')				//Standard
	g chainX`var' 		= belongschain*(new_`var')	
	g sforprofitX`var' 	= forprofit*(new_`var'^2)*100		//Squared
	g schainX`var' 		= belongschain*(new_`var'^2)*100	
	_pctile new_`var' if t==1 & everchanged_ownerstat==0, nq(10) // Monopolish
	g monop_`var'=(new_`var'>=r(r9))
	}

su alpha_`method'_pooled if temp2==1 & everchanged_ownerstat==0, d 
g lt_alpha_`method'_pooled = alpha_`method'_pooled <= r(p10)

su alpha_`method'_inter if temp==1 & everchanged_ownerstat==0, d 
g lt_alpha_`method'_inter = alpha_`method'_inter <= r(p10)

rename ebayes_alpha_brglm_penalty_inter ebay_alpha_brglm_penalty_inter


compress 
save /Users/jkun0001/Desktop/24_05_24_replicationpackage_all/_dodata/_processeddata/24_05_24_data_alphas_hhi_hsa.dta , replace

