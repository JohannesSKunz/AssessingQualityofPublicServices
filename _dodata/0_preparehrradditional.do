clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile data1 data2 data3 data4 data5  

use _raw/Dartmouth_HOSPITALRESEARCHDATA/hosp11_5231.dta 
rename status11 status
g year=2011
save `data1'
clear 

use _raw/Dartmouth_HOSPITALRESEARCHDATA/hosp12_5218.dta 
rename status12 status
save `data2'
clear 

use _raw/Dartmouth_HOSPITALRESEARCHDATA/hosp13_5186.dta 
rename status13 status
save `data3'
clear 

use _raw/Dartmouth_HOSPITALRESEARCHDATA/hosp14_5173_atlas.dta 
g year=2014
rename status14 status
save `data4'
clear 

use _raw/Dartmouth_HOSPITALRESEARCHDATA/hosp15_5130_atlas.dta 
g year=2015
rename POSbeds posbeds 
rename NEW_PROV new_prov 
rename STATUS15 status
save `data5'
clear 

//append 
use `data1'
append using `data2'
append using `data3'
append using `data4'
append using `data5'


order provider new_prov hospname year sysname pos_control
sort provider  year
rename provider providerid

duplicates tag providerid year , gen(_dup) 
bys provider _dup : g temp=_n
drop if _dup==2 & temp!=1
drop temp
sort provider  year

tab new_prov

save _prepared/hrr_add.dta, replace 
