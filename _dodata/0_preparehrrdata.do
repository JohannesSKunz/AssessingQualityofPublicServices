*** data downloaded 2016-11-05 from https://data.medicare.gov/data/archives/hospital-compare
clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000

*____________________________________________________________________________________________________________________
* HRR Crosswalk and Primary Care Access 
//2011 - lagged
import excel _raw/DartmouthAtlas/ZipHsaHrr10.xls, sheet("ziphsahrr10.csv") firstrow allstring clear
rename zipcode10 zipcode
replace zipcode="0"+zipcode if length(zipcode)==4
keep zipcode hrrnum
g syear=2011
tempfile hrr11
save `hrr11'

import excel _raw/DartmouthAtlas/2010_med_discharges_hrr.xls,  firstrow allstring clear
destring DischargesforAmbulatoryCareS , replace force  
destring BacterialPneumoniaDischargesp , replace force  
destring CongestiveHeartFailureDischar , replace force  
replace DischargesforAmbulatoryCareS=DischargesforAmbulatoryCareS-BacterialPneumoniaDischargesp-CongestiveHeartFailureDischar
keep HRR DischargesforAmbulatoryCareS
rename HRR hrrnum
merge 1:m hrrnum using `hrr11' ,  
rename _merge merge11
save `hrr11', replace 


//2012 - lagged
import excel _raw/DartmouthAtlas/ZipHsaHrr11.xls, sheet("ziphsahrr11") firstrow allstring clear
rename zipcode11 zipcode
replace zipcode="0"+zipcode if length(zipcode)==4
keep zipcode hrrnum
g syear=2012
tempfile hrr12
save `hrr12'

import excel _raw/DartmouthAtlas/2011_med_discharges_hrr.xls,  firstrow allstring clear
destring DischargesforAmbulatoryCareS  , replace force  
destring BacterialPneumoniaDischargesp , replace force  
destring CongestiveHeartFailureDischar , replace force  
replace DischargesforAmbulatoryCareS=DischargesforAmbulatoryCareS-BacterialPneumoniaDischargesp-CongestiveHeartFailureDischar
keep HRR DischargesforAmbulatoryCareS
rename HRR hrrnum
merge 1:m hrrnum using `hrr12' ,  
rename _merge merge12
save `hrr12', replace 


//2013 - lagged
import excel _raw/DartmouthAtlas/ZipHsaHrr12.xls, sheet("ZipHsaHrr12.csv") firstrow allstring clear
rename zipcode12 zipcode
replace zipcode="0"+zipcode if length(zipcode)==4
keep zipcode hrrnum
g syear=2013
tempfile hrr13
save `hrr13'

import excel _raw/DartmouthAtlas/2012_med_discharges_hrr.xls,  firstrow allstring clear
destring DischargesforAmbulatoryCareS , replace force  
destring BacterialPneumoniaDischargesp , replace force  
destring CongestiveHeartFailureDischar , replace force  
replace DischargesforAmbulatoryCareS=DischargesforAmbulatoryCareS-BacterialPneumoniaDischargesp-CongestiveHeartFailureDischar
keep HRR DischargesforAmbulatoryCareS
rename HRR hrrnum
merge 1:m hrrnum using `hrr13' ,  
rename _merge merge13
save `hrr13', replace 



//2014 - lagged
import excel _raw/DartmouthAtlas/ZipHsaHrr13.xls, sheet("ziphsahrr13.csv") firstrow allstring clear
rename zipcode13 zipcode
replace zipcode="0"+zipcode if length(zipcode)==4
keep zipcode hrrnum
g syear=2014
tempfile hrr14
save `hrr14'

import excel _raw/DartmouthAtlas/2013_med_discharges_hrr.xls,  firstrow allstring clear
destring DischargesforAmbulatoryCareS , replace force  
destring BacterialPneumoniaDischargesp , replace force  
destring CongestiveHeartFailureDischar , replace force  
replace DischargesforAmbulatoryCareS=DischargesforAmbulatoryCareS-BacterialPneumoniaDischargesp-CongestiveHeartFailureDischar
keep HRR DischargesforAmbulatoryCareS
rename HRR hrrnum
merge 1:m hrrnum using `hrr14' ,  
rename _merge merge14
save `hrr14', replace 

//2015 - lagged
import excel _raw/DartmouthAtlas/ZipHsaHrr14.xls, sheet("ziphsahrr14.csv") firstrow allstring clear
rename zipcode14 zipcode
replace zipcode="0"+zipcode if length(zipcode)==4
keep zipcode hrrnum
g syear=2015
tempfile hrr15
save `hrr15'

import excel _raw/DartmouthAtlas/2014_med_discharges_hrr.xls,  firstrow allstring clear
destring DischargesforAmbulatoryCareS , replace force  
destring BacterialPneumoniaDischargesp , replace force  
destring CongestiveHeartFailureDischar , replace force  
replace DischargesforAmbulatoryCareS=DischargesforAmbulatoryCareS-BacterialPneumoniaDischargesp-CongestiveHeartFailureDischar
keep HRR DischargesforAmbulatoryCareS
rename HRR hrrnum
merge 1:m hrrnum using `hrr15' ,  
rename _merge merge15
save `hrr15', replace 

//Append 
clear 
use `hrr11'
append using `hrr12'
append using `hrr13'
append using `hrr14'
append using `hrr15'
sort zipcode syear
drop  if hrrnum=="999"
drop merge*

compress
save _prepared/hrrdata, replace 



