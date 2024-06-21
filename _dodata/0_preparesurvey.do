clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile data1 data2 data3 data4 data5  

import delimited "_raw/HOSArchive_Revised_Flatfiles_20121001/HCAHPS Measures.csv", clear  stringcols(_all)  
g year = 2011
rename providernumber providerid 
keep providerid year percentofpatientswhoreportednoth
save `data1', replace 

import delimited "_raw/HOSArchive_Revised_Flatfiles_20131001/HCAHPS Measures.csv", clear stringcols(_all)  
g year = 2012
rename providernumber providerid 
keep providerid year percentofpatientswhoreportednoth
save `data2', replace 

import delimited "_raw/HOSArchive_Revised_Flatfiles_20141218/HCAHPS - Hospital.csv", clear stringcols(_all)  
g year = 2013
keep if hcahpsmeasureid=="H_RECMND_DN"
rename hcahpsanswerpercent percentofpatientswhoreportednoth
keep providerid year percentofpatientswhoreportednoth
save `data3', replace 

import delimited "_raw/HOSArchive_Revised_FlatFiles_20151210/HCAHPS - Hospital.csv", clear stringcols(_all)  
g year = 2014
keep if hcahpsmeasureid=="H_RECMND_DN"
rename hcahpsanswerpercent percentofpatientswhoreportednoth
keep providerid year percentofpatientswhoreportednoth
save `data4', replace 

import delimited "_raw/Hospital_Revised_Flatfiles/HCAHPS - Hospital.csv", clear stringcols(_all)  
g year = 2015
keep if hcahpsmeasureid=="H_RECMND_DN"
rename hcahpsanswerpercent percentofpatientswhoreportednoth
keep providerid year percentofpatientswhoreportednoth
save `data5', replace 

//append 
use `data1'
append using `data2'
append using `data3'
append using `data4'
append using `data5'

destring percentofpatientswhoreportednoth, force gen(survey_percentotrecommend)
drop percentofpatientswhoreportednoth
save _prepared/survey , replace 
