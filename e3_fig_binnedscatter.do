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
cap log using $pathfold/_logfiles/e3_fig_binnedscatter.txt, text replace
cap use $pathdata/maindata.dta
*-------------------------------------------------------------------------------

bys providerid (measure year): g tx=_n
keep if tx == 1

collapse (mean) belongschain forprofit mean_hhi_discharges , by(hrrnum)

xtile prc=mean_hhi_discharges , nq(100)
bys prc: egen me_fp = mean(forprofit)
bys prc: egen me_ch = mean(belongschain)
bys prc: g t = _n 

reg me_fp prc if t == 1  
local r2: display %5.4f e(r2)	
local b:  display %5.4f _b[prc]	
local se:  display %5.4f _se[prc]	
tw (scatter me_fp prc if t ==1 ) (lfit me_fp prc) , ///
	ytitle("Share of for-profit hospitals in HRR") ///
	xtitle("Market concentration (HHI percentile bins)    ") ///
 	xlab(0(20)100) xscale(r(0 100)) /// 
 	ylab(0(0.2)1) yscale(r(0 1.1)) /// 
    scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
	legend(off) ///
	note("Coeff(SE): `b'(`se')"  "R-squared=`r2'" , pos(2) ring(0) size(medium)) ///
	name(gr1, replace)
    graph export $pathfold/_figures/e3_fig_binnedscatter_a.png , replace 

reg me_ch prc if t == 1  
local r2: display %5.4f e(r2)	
local b:  display %5.4f _b[prc]	
local se:  display %5.4f _se[prc]	
tw (scatter me_ch prc if t ==1 ) (lfit me_ch prc) , ///
	ytitle("Share of chain hospitals in HRR") ///
	xtitle("Market concentration (HHI percentile bins)    ") ///
 	xlab(0(20)100) xscale(r(0 100)) /// 
 	ylab(0(0.2)1) yscale(r(0 1.1)) /// 
    scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
	legend(off) ///
	note("Coeff(SE): `b'(`se')"  "R-squared=`r2'", pos(2) ring(0) size(medium)) ///
	name(gr2, replace)
    graph export $pathfold/_figures/e3_fig_binnedscatter_b.png , replace 
	
	
	cap log close

	
			
