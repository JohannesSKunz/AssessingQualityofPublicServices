clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1

glo pathdata "/Users/jkun0001/Downloads/AssessingQualityofPublicServices-main/_dodata/_finaldata/" 
glo pathfold "/Users/jkun0001/Downloads/AssessingQualityofPublicServices-main/" 

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
cap log using $pathfold/_logfiles/e2_fig_maps.txt, text replace
cap use $pathdata/maindata.dta


*-------------------------------------------------------------------------------------------------
g quality_nonprofit = `suffix'alpha_`method'_inter
	replace quality_nonprofit = . if forprofit == 0
g quality_forprofit = `suffix'alpha_`method'_inter
	replace quality_forprofit = . if forprofit == 1

* Collapse
collapse (mean) quality_nonprofit quality_forprofit `suffix'alpha_`method'_inter `suffix'alpha_`method'_pooled  forprofit belongschain hhi_beds (sum) nrhosphrr totalpopestby100T , by(hrr)
g hospperhead=nrhosphrr/totalpopestby100T
rename hrr HRRNUM
g gap_forprofit = quality_nonprofit - quality_forprofit

save `temp', replace 

su `suffix'alpha_`method'_inter , d

***** Load shape file
use /Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/hrr_bdry/usdb.dta , clear 
merge 1:1 HRRNUM using `temp' , keep(3) nogen 

* Figure 

loc i=1
format `suffix'alpha_`method'_inter %5.2f
spmap `suffix'alpha_`method'_inter using /Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/hrr_bdry/uscoord  , ///
	ysize(5) xsize(10) id(id) fcolor(Reds2) cln(5)  name(gr1, replace) legend(size(medium)) graphregion(margin(zero)) //clm()
graph export $pathfold/_figures/e2_fig_maps_a.png , replace 

format forprofit %5.2f
spmap forprofit using /Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/hrr_bdry/uscoord  , ///
	ysize(5) xsize(10) id(id) fcolor(Reds2) cln(5)  name(gr2, replace) legend(size(medium)) graphregion(margin(zero))  //clm()
graph export $pathfold/_figures/e2_fig_maps_b.png , replace 
		
format belongschain %5.2f
spmap belongschain using /Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/hrr_bdry/uscoord  , ///
	ysize(5) xsize(10) id(id) fcolor(Reds2) cln(5)  name(gr3, replace) legend(size(medium)) graphregion(margin(zero)) //clm()
graph export $pathfold/_figures/e2_fig_maps_c.png , replace 	

format hhi_beds %5.2f
spmap hhi_beds using /Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/hrr_bdry/uscoord  , ///
	ysize(5) xsize(10) id(id) fcolor(Reds2) cln(5) name(gr4, replace) legend(size(medium)) graphregion(margin(zero)) //clm()
graph export $pathfold/_figures/e2_fig_maps_d.png , replace 	


cap log close
