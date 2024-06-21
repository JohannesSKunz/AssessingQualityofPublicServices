clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1

glo pathdata "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/_finaldata/" 
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
cap log using $pathfold/_logfiles/e7_tab_hhi.txt, text replace
cap use $pathdata/maindata.dta
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


loc i  = 1
loc j  = 1 
	reg  `suffix'alpha_`method'_inter forprofit belongschain `covars1' `covars3' i.measure  , `ses'
	est sto reg`i'_`j'
	loc j = `j' + 1

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
