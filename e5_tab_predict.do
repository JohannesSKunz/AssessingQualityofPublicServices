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
cap log using $pathfold/_logfiles/e5_tab_predict.txt, text replace
cap use $pathdata/maindata.dta
*-------------------------------------------------------------------------------


* Prepare
keep if temp == 1
tab numberofhospitalsinchain
tab sysname if largechain

su mean_hhi_discharges if everchanged_ownerstat==0
sca mean=r(mean)
di mean
su mean_hhi_beds if everchanged_ownerstat==0
sca meanbed=r(mean)

sort hrrnum
bys hrrnum providerid:  gen tmon = _N

by providerid (hrrnum), sort: generate y = _n == 1
bro providerid hrrnum tmon y
sort hrrnum providerid

bys hrrnum: egen tothospinhrr = total(y)
loc var hhi_discharge_sys
replace totalpopestby100T = totalpopestby100T/100


loc var "age65andolderpct2010 ruralurban unemprate totalpopestby100T medhhincome10Tdollars allagesinpovertypercent DischargesforAmbulatoryCareS mean_hhi_discharges  hospperhead  ed1lessthanhspct2010  blacknonhispanicpct2010 hispanicpct2010"
reg forprofit `var' if temp2==1 
est sto reg1

reg belongschain `var' if temp2==1 
est sto  reg2

gen forprofitchain = forprofit * belongschain
reg forprofitchain `var' if temp2==1 
est sto  reg3

esttab reg1 reg2 reg3 using $pathfold/_tables/e5_tab_predict.tex , replace  b(3) se nostar drop(_cons) stats(N r2) ///
			coeflab(age65andolderpct2010    	 "Percent ages 65 and older (2010, county)" ///
					ruralurban 			    	 "Rural area (county)" ///
					unemprate 			  		 "Percent unemployed, in county" ///
					totalpopestby100T      	 	 "Total population in 100'000, in county" ///
					medhhincome10Tdollars   	 "Household median income in 10'000\$, in county" ///
					allagesinpovertypercent 	 "Percent living in poverty, in county" ///
					DischargesforAmbulatoryCareS "Discharges ACSCs per 1'000 enrollees, in HRR" ///
					mean_hhi_discharges 	     "Average HHI in discharges" ///
					hospperhead 	  		     "Hospitals per head in HRR" ///
					ed1lessthanhspct2010 	     "Percent less than high school (2010, county)" ///
					blacknonhispanicpct2010 	 "Percent black non-hispanic (2010, county)" ///
					hispanicpct2010 	     	 "Percent hispanic (2010, county)" ///
					) 

cap log close
