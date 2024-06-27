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
cap log using $pathfold/_logfiles/e1_fig_quality.txt, text replace
cap use $pathdata/maindata.dta


*------------------------------------------------------------------------------- 
* Drop time dimension
loc method brglm_penalty
collapse (first) pcr_alpha_`method'_pooled  (mean) pcr_alpha_`method' all_readm_rate mort_rate survey_percentotrecommend  , by(providerid)

* bin-ranks
egen double temp = cut(pcr_alpha_`method'_pooled), at(0(0.01)1.011) 
replace temp=0.99 if temp==1
replace temp=temp+0.01

bys temp : egen outcome1=mean(all_readm_rate) // interacted, use 
bys temp : egen outcome2=mean(mort_rate) // interacted, use 
bys temp : egen outcome3=mean(survey_percentotrecommend) // interacted, use 


**********
* Graph

//settings 
global msym "Oh"
global msiz "tiny"
global xsiz "6"
global xfsiz "60"
global yfsiz "80"

qui su temp
	glo low = `r(min)'
	glo high= `r(max)'
	
tw  ///
	(scatter outcome1 temp  	   , mlcolor(gs1%50)  msize($msiz) msymbol( $msym )  ) ///
	(lfit  outcome1  temp 	 ,  range($low $high) ls(solid) lw(thin)  lcolor(gs1)) ///
	,   ysize(4) xsize($xsiz) fysize($yfsiz) fxsize($xfsiz) scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
		name(gr1, replace) title("A. Average overall readmission rate", size(small)) ytitle("") xtitle("") legend(off)
	
	reg outcome1  temp 
	di "  b =  " _b[temp] "  (se  " _se[temp] ")  R2:  " e(r2)
	
tw  ///
	(scatter  outcome2 temp 	  , mlcolor(gs1%50)  msize($msiz) msymbol( $msym )  ) ///
	(lfit  outcome2 temp 	  ,  range($low $high) ls(solid) lw(thin)  lcolor(gs1)) ///
	,   ylab(,) ysize(4) xsize($xsiz) fysize($yfsiz) fxsize($xfsiz) scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
		name(gr2, replace) title("B. Average mortality rate, same conditions", size(small)) ytitle("") xtitle("") legend(off)

	reg outcome2  temp 
	di "  b =  " _b[temp] "  (se  " _se[temp] ")  R2:  " e(r2)		
		
tw  ///
	(scatter  outcome3 temp  	  , mlcolor(gs1%50)  msize($msiz) msymbol( $msym )  ) ///
	(lfit outcome3 temp 	   ,  range($low $high) ls(solid) lw(thin)  lcolor(gs1)) ///
	,   ylab(,)  ysize(4) xsize($xsiz) fysize($yfsiz) fxsize($xfsiz) scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
		name(gr3, replace) title("C. Survey-share hospital not recommend", size(small)) ytitle("") xtitle("") legend(off)

	reg outcome3  temp 
	di "  b =  " _b[temp] "  (se  " _se[temp] ")  R2:  " e(r2)		
		
graph combine gr1 gr2 gr3, ///
	l1title("Within hospital outcome measures", size(small)) ///
	b1title("Percentile ranking based on time-constant hospital component", size(small)) ///
	row(1) scheme(s2mono) graphregion(color(white)) xcommon

graph export $pathfold/_figures/e1_fig_quality.png , replace 

cap log close

