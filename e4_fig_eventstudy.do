*** data downloaded 2016-11-05 from https://data.medicare.gov/data/archives/hospital-compare
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
cap log using $pathfold/_logfiles/e4_fig_eventstudy.txt, text replace
cap use $pathdata/maindata.dta
*-------------------------------------------------------------------------------


* Prepare
keep if everchanged_ownerstat == 1

* Eventstudy 
bro providermeasureid year ownership delta_ownership everchanged_ownerstat forprofit
bys providermeasureid (year): g dates=_n 
bys providermeasureid (year): g first = sum(forprofit) == 1
g temp3 = dates if first ==1 
bys providermeasureid (year): egen change = max(temp3)
g diff = dates - change 

egen posdiff =  group(diff)
reghdfe excessreadmissionratio forprofit i.posdiff , absorb(providermeasureid)  cluster(providerid)

tab posdiff , gen(dposdiff)
drop dposdiff4

* Penalty
reghdfe penalty dposdiff* , noomit absorb(providermeasureid)  cluster(providerid)

nlcom 	///
		(D1: _b[dposdiff1]) ///
		(D2: _b[dposdiff2]) ///
		(D3: _b[dposdiff3]) ///
		(D4: 0) ///
		(D5: _b[dposdiff5]) ///
		(D6: _b[dposdiff6]) ///
		(D7: _b[dposdiff7]) ///
		(D8: _b[dposdiff8]) ///
		(D9: _b[dposdiff9]) ///
		, post
		eststo reg1
coefplot reg1 , vert ///
	coeflabel(D1="-4" D2="-3" D3="-2" D4="-1" D5="0" D6="1" D7="2" D8="3" D9="4" )	///
	ytitle("Penalty") ///
	xtitle("Years till For-profit ownership change") ///
	yline(0, lc(red%50)) ///
	scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
	drop(_cons) name(gr1, replace)

* Excess readmission ratio
reghdfe excessreadmissionratio dposdiff* , noomit absorb(providermeasureid)  cluster(providerid)
nlcom 	///
		(D1: _b[dposdiff1]) ///
		(D2: _b[dposdiff2]) ///
		(D3: _b[dposdiff3]) ///
		(D4: 0) ///
		(D5: _b[dposdiff5]) ///
		(D6: _b[dposdiff6]) ///
		(D7: _b[dposdiff7]) ///
		(D8: _b[dposdiff8]) ///
		(D9: _b[dposdiff9]) ///
		, post
		eststo reg2
coefplot reg2 , vert ///
	coeflabel(D1="-4" D2="-3" D3="-2" D4="-1" D5="0" D6="1" D7="2" D8="3" D9="4" )	///
	ytitle("Excess readmission ratio") ///
	xtitle("Years till For-profit ownership change") ///
	yline(0, lc(red%50)) ///
	scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
	drop(_cons) name(gr2, replace)

	
graph combine gr1 gr2  , ysize(2)  row(1) xcommon graphregion(color(white)) 
   graph export $pathfold/_figures/e4_fig_eventstudy.png , replace 

   cap log close
