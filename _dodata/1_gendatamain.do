*** data downloaded 2016-11-05 from https://data.medicare.gov/data/archives/hospital-compare
clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile hospitaldata data1 data2 data3 data4 data5

*____________________________________________________________________________________________________________________
//Hospital compare 
import delimited "_raw/HOSArchive_Revised_Flatfiles_20121001/Hospital_Data.csv", encoding(ISO-8859-1)  asdouble stringcols(_all) clear 
cap rename  countyname county
cap rename providerid providernumber
g syear=2011
save `data1', replace 

import delimited "_raw/HOSArchive_Revised_Flatfiles_20131001/Hospital_Data.csv", encoding(ISO-8859-1)  asdouble clear stringcols(_all) 
cap rename  countyname county
cap rename providerid providernumber
g syear=2012
save `data2', replace 

import delimited "_raw/HOSArchive_Revised_Flatfiles_20141218/Hospital General Information.csv", encoding(ISO-8859-1)  asdouble clear stringcols(_all) 
cap rename  countyname county
cap rename providerid providernumber
g syear=2013
save `data3', replace 

import delimited "_raw/HOSArchive_Revised_FlatFiles_20151210/Hospital General Information.csv", encoding(ISO-8859-1)  asdouble clear stringcols(_all) 
cap rename  countyname county
cap rename providerid providernumber
g syear=2014
save `data4', replace 

import delimited "_raw/Hospital_Revised_Flatfiles/Hospital General Information.csv", encoding(ISO-8859-1)  asdouble clear stringcols(_all) 
cap rename  countyname county
cap rename providerid providernumber
g syear=2015
save `data5', replace 

*__________________________________________________________________________________________________________
*Append
clear 
use `data1'
append using `data2'
append using `data3'
append using `data4'
append using `data5' 
 
bys providernumber county: g temp=_N
bys providernumber : egen temp2=max(temp)
g temp3=county if temp==temp2
sort providernumber temp
bys providernumber : replace temp3=temp3[_N]
g countycorreced=county!=temp3
replace county=temp3 if county!=temp3

order providernumber syear
sort providernumber syear
drop temp* hospitaloverallratingfootnote phonenumber hospitaloverallrating meetscriteriaformeaningfuluseofe address address1 address2 address3 mortalitynationalcomparison mortalitynationalcomparisonfootn safetyofcarenationalcomparison safetyofcarenationalcomparisonfo readmissionnationalcomparison readmissionnationalcomparisonfoo patientexperiencenationalcompari v22 effectivenessofcarenationalcompa v24 timelinessofcarenationalcomparis v26 efficientuseofmedicalimagingnati v28

replace hospitalownership= "Government" if hospitalownership=="Government - Federal" 
replace hospitalownership= "Government" if hospitalownership=="Government - Hospital District or Authority" 
replace hospitalownership= "Government" if hospitalownership=="Government - Local" 
replace hospitalownership= "Government" if hospitalownership=="Government - State" 
replace hospitalownership= "Voluntary non-profit" if hospitalownership=="Voluntary non-profit - Church" 
replace hospitalownership= "Voluntary non-profit" if hospitalownership=="Voluntary non-profit - Other" 
replace hospitalownership= "Voluntary non-profit" if hospitalownership=="Voluntary non-profit - Private" 
replace hospitalownership= "Other" if hospitalownership!="Voluntary non-profit" & hospitalownership!= "Government"
tabulate hospitalownership, gen(hospitalownership)
rename hospitalownership1 government 
tab hospitalownership government
rename hospitalownership2 forprofit 
tab hospitalownership forprofit
rename hospitalownership3 nonprofit 
tab hospitalownership nonprofit

*__________________________________________________________________________________________________________
*add hrr infos 
merge m:1 zipcode syear using _prepared/hrrdata

preserve 
keep  if _merge==3
g one=1 
bys hrrnum syear: egen nrhospitalsinhrr=total(one) 
sort providernumber syear 
by providernumber: g changenrhospitalsinhrr=nrhospitalsinhrr-nrhospitalsinhrr[_n-1]
replace changenrhospitalsinhrr=0 if changenrhospitalsinhrr==. 
g nropeninginhrr=changenrhospitalsinhrr if changenrhospitalsinhrr>0
replace nropeninginhrr=0 if nropeninginhrr==.
g   openinginhrr=changenrhospitalsinhrr>0
replace openinginhrr=0 if openinginhrr==.
g nrclosinginhrr=changenrhospitalsinhrr*-1 if changenrhospitalsinhrr<0
replace nrclosinginhrr=0 if nrclosinginhrr==.
g   closinginhrr=changenrhospitalsinhrr<0
replace closinginhrr=0 if closinginhrr==.
save `hospitaldata', replace  
restore 

keep if _merge==1
append using  `hospitaldata'
g hrrmiss=_merge==1
drop _merge one
local varlist nrhospitalsinhrr changenrhospitalsinhrr nropeninginhrr openinginhrr nrclosinginhrr closinginhrr 
foreach varn of local varlist {
replace `varn'=0 if hrrmiss==1
}
rename providernumber providerid
save `hospitaldata', replace  
*__________________________________________________________________________________________________________
*add county infos 

//for mergining 
replace county="EMPORIA CITY" if county=="Emporia City" & state=="VA"
replace county="BEDFORD CITY" if county=="Bedford City" & state=="VA"
replace county="WRANGELL CITY AND BOROUGH" if providerid=="021305" & state=="AK"
replace county="PETERSBURG CENSUS AREA" if providerid=="021304" & state=="AK"
replace county="KENAI PENINSULA" if providerid=="020024" & state=="AK"
replace county="VALDEZ CORDOVA" if providerid=="021301" & state=="AK"
replace county="VALDEZ CORDOVA" if providerid=="021307" & state=="AK"
replace county="WRANGELL CITY AND BOROUGH" if providerid=="021305" & state=="AK"
replace county="PETERSBURG CENSUS AREA" if providerid=="021304" & state=="AK"
replace county="NORTH SLOPE" if providerid=="021312" & state=="AK"
replace county="KENAI PENINSULA" if providerid=="021302" & state=="AK"
replace county="VALDEZ CORDOVA" if providerid=="021301" & state=="AK"
replace county="KENAI PENINSULA" if providerid=="021313" & state=="AK"
replace county="AMERICAN SAMOA" if providerid=="640001" & state=="AS"
replace county="PIMA" if providerid=="03013F" & state=="AZ"
replace county="MARICOPA" if providerid=="03012F" & state=="AZ"
replace county="FRESNO" if providerid=="05025F" & state=="CA"
replace county="NEW HAVEN" if providerid=="07003F" & state=="CT"
replace county="DISTRICT OF COLUMBIA" if providerid=="09002F" & state=="DC"
replace county="NEW CASTLE" if providerid=="08002F" & state=="DE"
replace county="ALACHUA" if providerid=="10057F" & state=="FL"
replace county="GUAM" if providerid=="650001" & state=="GU"
replace county="ADA" if providerid=="13003F" & state=="ID"
replace county="CADDO" if providerid=="19048F" & state=="LA"
replace county="HAMPSHIRE" if providerid=="22009F" & state=="MA"
replace county="MIDDLESEX" if providerid=="22001F" & state=="MA"
replace county="BALTIMORE CITY" if providerid=="21020F" & state=="MD"
replace county="KENNEBEC" if providerid=="20003F" & state=="ME"
replace county="BOONE" if providerid=="26023F" & state=="MO"
replace county="RANKIN" if providerid=="250138" & state=="MS"
replace county="CASS" if providerid=="35002F" & state=="ND"
replace county="BERNALILLO" if providerid=="32005F" & state=="NM"
replace county="BRONX" if providerid=="33016F" & state=="NY"
replace county="ALBANY" if providerid=="33009F" & state=="NY"
replace county="DOUGLAS" if providerid=="38004F" & state=="OR"
replace county="ALLEGHENY" if providerid=="39012F" & state=="PA"
replace county="PROVIDENCE" if providerid=="41005F" & state=="RI"
replace county="CHARLESTON" if providerid=="42029F" & state=="SC"
replace county="SHANNON" if providerid=="430081" & state=="SD"
replace county="BERKELEY" if providerid=="51005F" & state=="WV"

//state county identifier: FIPS 
merge m:1 state county using "_prepared/crosswalk.dta" , keepusing(FIPSStatecountycode) keep(1 3)
drop _merge
rename FIPSStatecountycode countyid

merge m:1 countyid syear using _prepared/countydata , keep(1 3)
g countymiss=_merge==1
drop _merge
local varlist allagesinpovertypercent medhhincome10Tdollars totalpopestby100T unemprate ruralurban DischargesforAmbulatoryCareS
foreach varn of local varlist {
replace `varn'=0 if countymiss==1
}

compress
save _prepared/generalhospitaldatahrrcounty, replace 


