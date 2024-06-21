clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile data ipps1 ipps2 ipps3 ipps4 ipps5

//Impact file 2011 (FY2012)
import delimited using "_raw/IPPS_FinalRule/FY 2012 Final Rule- IPPS Impact File PUF-August 15, 2011_1.txt", encoding(ISO-8859-1) stringcols(_all) asdouble clear 
keep providernumber name  beds rday residenttobedratio urgeo urspa
g syear=2011
save `ipps1', replace 

//Impact file 2012 (FY2013)
import delimited using "_raw/IPPS_FinalRule/FY 2013 Final Rule CN - IPPS Impact File PUF-March 2013.txt", encoding(ISO-8859-1) stringcols(_all) asdouble clear 
keep providernumber name  beds rday residenttobedratio urgeo urspa
g syear=2012
save `ipps2', replace 

//Impact file 2013 (FY2014)
import delimited using "_raw/IPPS_FinalRule/FY 2014 Final Rule IPPS Impact PUF-CN1-IFC-Jan 2014.txt", encoding(ISO-8859-1) stringcols(_all) asdouble clear 
keep providernumber name  beds rday residenttobedratio urgeo urspa
g syear=2013
save `ipps3', replace 

//Impact file 2014 (FY2015)
import delimited using "_raw/IPPS_FinalRule/FY 2015 IPPS Final Rule Impact PUF-(CN data).txt", encoding(ISO-8859-1) stringcols(_all) asdouble clear 
keep providernumber name  beds rday residenttobedratio urgeo urspa
g syear=2014
save `ipps4', replace 

//Impact file 2015 (FY2016)
import delimited using "_raw/IPPS_FinalRule/FY 2016 Correction Notice Impact PUF - (CN data).txt", encoding(ISO-8859-1) stringcols(_all) asdouble clear 
keep providernumber name  beds rday residenttobedratio urgeo urspa
g syear=2015
save `ipps5', replace 

//append 
clear 
use `ipps1'
append using `ipps2'
append using `ipps3'
append using `ipps4'
append using `ipps5'

destring residenttobedratio rday beds  , replace force 
rename providernumber providerid 
order providerid syear 
sort providerid syear 

save _prepared/ippshospitals, replace 
