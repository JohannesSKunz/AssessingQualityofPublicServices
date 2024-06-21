clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile data1 data2 data3 data4 data5  

//2011
import delimited "_raw/HOSArchive_Revised_Flatfiles_20121001/READMISSION REDUCTION.csv", encoding(ISO-8859-1) stringcols(_all)   asdouble clear
replace providernumber="0"+providernumber if length(providernumber)==5
g syear=2011
keep hospitalname providernumber measurename numberofdischarges excessreadmissionratio syear
save `data1', replace 

//2012
import delimited "_raw/HOSArchive_Revised_Flatfiles_20131001/READMISSION REDUCTION.csv", encoding(ISO-8859-1) stringcols(_all)  asdouble clear
replace providernumber="0"+providernumber if length(providernumber)==5
g syear=2012
keep hospitalname providernumber measurename numberofdischarges excessreadmissionratio syear
save `data2', replace 

//2013
import delimited "_raw/HOSArchive_Revised_Flatfiles_20141218/READMISSION REDUCTION.csv", encoding(ISO-8859-1) stringcols(_all)  asdouble clear
replace providernumber="0"+providernumber if length(providernumber)==5
g syear=2013
keep hospitalname providernumber measurename numberofdischarges excessreadmissionratio syear
save `data3', replace 

//2014
import delimited "_raw/HOSArchive_Revised_FlatFiles_20151210/READMISSION REDUCTION.csv", encoding(ISO-8859-1) stringcols(_all) asdouble clear
cap rename provider_number providernumber
rename hospital_name hospitalname
rename measure_name measurename
rename excess_readmission_ratio excessreadmissionratio
rename number_of_discharges numberofdischarges
replace providernumber="0"+providernumber if length(providernumber)==5
g syear=2014
keep hospitalname providernumber measurename numberofdischarges excessreadmissionratio syear
save `data4', replace 

//2015
import delimited "_raw/Hospital_Revised_Flatfiles/READMISSION REDUCTION.csv", encoding(ISO-8859-1) stringcols(_all) asdouble clear
replace providernumber="0"+providernumber if length(providernumber)==5
g syear=2015
keep hospitalname providernumber measurename numberofdischarges excessreadmissionratio syear
save `data5', replace 

//append 
clear 
use `data1'
append using `data2'
append using `data3'
append using `data4'
append using `data5'

rename providernumber providerid
order providerid syear 
sort providerid syear 

//Merge hospital ipps information 
merge m:1 providerid syear using _prepared/ippshospitals , keep(1 3)
g ipps_miss=_merge==1
drop _merge 

//Merge hospital/hrr/couny information 
merge m:1 providerid syear using _prepared/generalhospitaldatahrrcounty , keep(1 3)
g main_miss=_merge==1
drop _merge 
rename syear year

// bring in main data, note new provider ids 
merge m:1 providerid year using _prepared/hrr_add, keepusing(new_prov year sysname pos_control shortname pcity pstate pzip hsa hrr status fcounty posbeds cothname category teachstatus) 

bro if _merge==1
rename _merge InCMSdata
order providerid year new_prov status shortname sysname pos_control cothname category teachstatus posbeds  pstate pzip hsa hrr fcounty pcity

merge m:1 providerid year using _prepared/survey 
rename _merge miss_survey

order providerid measurename year
drop shortname
order providerid measurename year hospitalname

replace measurename="READM-30-AMI-HRRP" if measurename=="Acute Myocardial Infarction (AMI) 30-Day Readmissions"
replace measurename="READM-30-HF-HRRP"  if measurename=="Heart Failure (HF) 30-Day Readmissions"
replace measurename="READM-30-PN-HRRP"  if measurename=="Pneumonia (PN) 30-Day Readmissions"
tab new_prov

* Drop new conditions
drop if measurename=="READM-30-HIP-KNEE-HRRP"
drop if measurename=="READM-30-COPD-HRRP"
drop if measurename=="READM-30-CABG-HRRP"

encode measurename ,  gen(measure)
tabulate measurename , gen(measure)

rename measure1 ind_ami
rename measure2 ind_hf
rename measure3 ind_pn

merge 1:1 providerid year measure using _prepared/sacarny 

format hospitalname %12s
format cothname %12s
compress
save _prepared/main , replace 








