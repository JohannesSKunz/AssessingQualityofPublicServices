clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1

glo pathdata "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/" 
glo pathfold "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/" 

glo covars	"numberofdischarges totnumdicarges_other_leaveout beds DischargesforAmbulatoryCareS openingnrhosphrr closingnrhosphrr allagesinpovertypercent medhhincome10Tdollars totalpopestby100T unemprate "
glo fes 	"_Iyear_2012 _Iyear_2013 _Iyear_2014 _Iyear_2015 _Imeasure_2 _Imeasure_3"
loc covars1 "i.teach_cons i.catsize_avbeds urban belongschain "
glo covars2 "forprofit_cons  beds100_399 beds400_ minorteaching majorteaching urban"
loc covars3 "age65andolderpct2010 whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 hispanicpct2010 ed1lessthanhspct2010 ed2hsdiplomaonlypct2010 ed3somecollegepct2010 ed4assocdegreepct2010 ed5collegepluspct2010"
tempfile alphas datamethod temp

loc suffix phi_
loc method brglm_penalty
loc ses "cluster(providerid)"
loc ses2 "cluster(hrr)"
*-------------------------------------------------------------------------------------------------
cap log close
cap log using $pathfold/_logfiles/e8_tab_rob.txt, text replace
cap use $pathdata/_finaldata/maindata.dta
*-------------------------------------------------------------------------------
* Estimate
keep if temp == 1
tab numberofhospitalsinchain
tab sysname if largechain

su mean_hhi_discharges if everchanged_ownerstat==0
sca mean=r(mean)
di mean
su mean_hhi_beds if everchanged_ownerstat==0
sca meanbed=r(mean)


loc j  = 1 
loc rname ""	
qui su hhi_discharge_sys2008
sca mean  = r(mean)

reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	
g esample = e(sample)==1
		
reg  `suffix'alpha_`method'_inter forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------

reg  `suffix'alpha_`method'_inter forprofit mforprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg1_`j'
test forprofit + mforprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[mforprofitXhhi_discharge_sys2008] 
estadd sca m=r(p)	
loc j = `j' + 1	

reg  `suffix'alpha_`method'_inter forprofit mchainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg2_`j'
test belongschain + mchainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[mchainXhhi_discharge_sys2008] 
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & esample ==1 & nrhosphrr != 1 , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

reg  `suffix'alpha_`method'_inter forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & esample ==1 & nrhosphrr != 1 , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------

reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & esample ==1 & monop_hhi_discharge_sys2008 != 1 , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

reg  `suffix'alpha_`method'_inter forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & esample ==1 & monop_hhi_discharge_sys2008 != 1 , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------

reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain uninsuredadultsrawvalue `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	
		
reg  `suffix'alpha_`method'_inter forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008  uninsuredadultsrawvalue `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------

reg  `suffix'alpha_`method'_pooled forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & temp2 ==1 , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	
		
reg  `suffix'alpha_`method'_pooled forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & temp2==1 , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------

reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hsa if everchanged_ownerstat==0  , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_discharge_sys2008* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	
		
reg  `suffix'alpha_`method'_inter forprofit chainXhhi_discharge_sys2008 hhi_discharge_sys2008   `covars1' `covars3' i.measure i.hsa if everchanged_ownerstat==0  , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_discharge_sys2008* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_discharge_sys2008] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

* --------------------------------
su hhi_dis_sys2008_hsa
sca mean = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_dis_sys2008_hsa hhi_dis_sys2008_hsa belongschain  `covars1' `covars3' i.measure i.hsa if everchanged_ownerstat==0  , `ses'
est sto reg1_`j'
test forprofit + forprofitXhhi_dis_sys2008_hsa* mean=0
estadd sca te=_b[forprofit] + _b[forprofitXhhi_dis_sys2008_hsa] * mean
estadd sca m=r(p)	
loc j = `j' + 1	
		
reg  `suffix'alpha_`method'_inter forprofit chainXhhi_dis_sys2008_hsa hhi_dis_sys2008_hsa   `covars1' `covars3' i.measure i.hsa if everchanged_ownerstat==0  , `ses'
est sto reg2_`j'
test belongschain + chainXhhi_dis_sys2008_hsa* mean=0
estadd sca te=_b[belongschain] + _b[chainXhhi_dis_sys2008_hsa] * mean
estadd sca m=r(p)	
loc j = `j' + 1	

loc mtit "mtitle("Base" "Median" "Monop" "Monolish" "Uninsured" "Pooled" "HSA FE" "HSA")"		
esttab reg1* using $pathfold/_tables/e8_tab_rob.tex , replace keep(forprofit interaction) b(3) se nostar stats(N r2 te m) ///
			   rename(forprofitXhhi_discharge_sys2008 interaction ///
					  mforprofitXhhi_discharge_sys2008 interaction ///
					  forprofitXhhi_dis_sys2008_hsa interaction)
			   
			   
esttab reg2* using $pathfold/_tables/e8_tab_rob.tex , append keep(belongschain interaction) b(3) se nostar stats(N r2 te m) ///
			   rename(chainXhhi_discharge_sys2008 interaction ///
					  mchainXhhi_discharge_sys2008 interaction ///
					  chainXhhi_dis_sys2008_hsa interaction)
					   
	
	
	
	
	
	
	
	
	exit 
	
	
	
	reg  `suffix'alpha_`method'_inter forprofit belongschain `covars1' `covars3' i.measure if everchanged_ownerstat==0  , `ses'
	est sto reg`i'_`j'
	loc j = `j' + 1
	
	reg  `suffix'alpha_`method'_inter forprofit  belongschain `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
	est sto reg`i'_`j'	
	loc j = `j' + 1		

	loc rname ""	
	foreach var in hhi_beds hhi_discharge hhi_discharge_sys hhi_discharge_sys2008 {
		qui su `var'
		sca mean  = r(mean)
		reg  `suffix'alpha_`method'_inter forprofit forprofitX`var' `var' belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
		est sto reg`i'_`j'
		test forprofit + forprofitX`var'* mean=0
		estadd sca te=_b[forprofit] + _b[forprofitX`var'] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1	
			loc rname "`rname' forprofitX`var' "interaction""
		}
	
* ----------------------	
loc i = `i' + 1 
loc j  = 1 
	reg  `suffix'alpha_`method'_inter   forprofit `covars1' `covars3' i.measure  , `ses'
	est sto reg`i'_`j'
	loc j = `j' + 1

	reg  `suffix'alpha_`method'_inter  forprofit `covars1' `covars3' i.measure if everchanged_ownerstat==0  , `ses'
	est sto reg`i'_`j'
	loc j = `j' + 1
	
	reg  `suffix'alpha_`method'_inter   forprofit `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
	est sto reg`i'_`j'	
	loc j = `j' + 1		

	loc rname2 ""	
	foreach var in hhi_beds hhi_discharge hhi_discharge_sys hhi_discharge_sys2008 {
		qui su `var'
		sca mean  = r(mean)
		reg  `suffix'alpha_`method'_inter  chainX`var' `var' forprofit `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
		est sto reg`i'_`j'
		test belongschain + chainX`var'* mean=0
		estadd sca te=_b[belongschain] + _b[chainX`var'] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1	
			loc rname2 "`rname2' chainX`var' "interaction""
		}
	
	
loc set  "se  keep(forprofit* interaction) nostar stats(N te m, fmt(%9.0g %9.3f %9.3f)) " // 

loc set2  "se  keep(belongschain interaction) nostar stats(N te m, fmt(%9.0g %9.3f %9.3f)) " // 

esttab reg1* using $pathfold/_tables/e7_tab_hhi.tex , replace b(3)  `set'	rename(`rname')  
esttab reg2* using $pathfold/_tables/e7_tab_hhi.tex , append b(3) `set2'	rename(`rname2')  

cap log close
