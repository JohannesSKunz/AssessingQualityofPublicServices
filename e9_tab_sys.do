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
cap log using $pathfold/_logfiles/e9_tab_sys.txt, text replace
cap use $pathdata/maindata.dta
*-------------------------------------------------------------------------------

* Estimate
keep if temp == 1

* Tab 4 
loc i  = 1
loc j  = 1 

* Base
qui su hhi_discharge_sys2008
sca mean  = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0  , `ses'
		est sto reg`i'_`j'
		test forprofit + forprofitXhhi_discharge_sys2008*mean=0
		estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1	

* Non-sys
qui su hhi_discharge_sys2008 if belongschain==0
sca mean  = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & belongschain==0  , `ses'
		est sto reg`i'_`j'
		test forprofit + forprofitXhhi_discharge_sys2008*mean=0
		estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1	

* sys
qui su hhi_discharge_sys2008 if belongschain==1
sca mean  = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & belongschain==1  , `ses'
		est sto reg`i'_`j'
		test forprofit + forprofitXhhi_discharge_sys2008* mean=0
		estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1	

* sys - small 
qui su hhi_discharge_sys2008 if everchanged_ownerstat==0 & belongschain==1 & largechain == 0
sca mean  = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & belongschain==1 & largechain == 0 , `ses'
		est sto reg`i'_`j'
		test forprofit + forprofitXhhi_discharge_sys2008*mean=0
		estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1			

* sys - large 
 su hhi_discharge_sys2008 if everchanged_ownerstat==0 & belongschain==1 & largechain == 1
sca mean  = r(mean)
reg  `suffix'alpha_`method'_inter forprofit forprofitXhhi_discharge_sys2008 hhi_discharge_sys2008 belongschain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & belongschain==1 & largechain == 1 , `ses'
		g esam = e(sample)
		est sto reg`i'_`j'
		test forprofit + forprofitXhhi_discharge_sys2008*mean=0
		estadd sca te=_b[forprofit] + _b[forprofitXhhi_discharge_sys2008] * mean
		estadd sca m=r(p)	
		loc j = `j' + 1			
				
			
esttab reg1_* using $pathfold/_tables/e9_tab_sys.tex , replace b(3) se keep(forprofit*) rename(fpXchainhhi_discharge_sys2008 forprofitXhhi_discharge_sys2008 fpXchainweihhi_discharge_sys2008 forprofitXhhi_discharge_sys2008) nostar stats(N te m, fmt(%9.0g %9.3f %9.3f))

* Test: Significantly different 
reg  `suffix'alpha_`method'_inter i.forprofit#i.largechain c.forprofitXhhi_discharge_sys2008#i.largechain i.largechain  `covars1' `covars3' i.measure i.hrr if everchanged_ownerstat==0 & belongschain==1  , `ses'

