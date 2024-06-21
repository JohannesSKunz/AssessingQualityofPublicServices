clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
tempfile countydata 

*__________________________________________________________________________________________________________
* Prepare Population based on Census:
import delimited _raw/Census/Rural_Atlas_Update14/People.csv, encoding(ISO-8859-1) stringcols(1) clear
keep fips whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 hispanicpct2010 ed1lessthanhspct ed2hsdiplomaonlypct ed3somecollegepct ed4assocdegreepct ed5collegepluspct age65andolderpct2010
rename fips countyid
replace countyid="0"+countyid if length(countyid)==4
foreach var in ed1lessthanhspct ed2hsdiplomaonlypct ed3somecollegepct ed4assocdegreepct ed5collegepluspct {
rename `var' `var'2010 
}
save `countydata' , replace 

*____________________________________________________________________________________
* Prepare Rural Urban identifier from 2013 definition and 2010 Population estimates Census 
import excel _raw/Census/ruralurbancodes2013.xls, sheet("Rural-urban Continuum Code 2013") firstrow clear
rename FIPS countyid 
drop State County_Name 
rename RUCC_2013 ruralurban
label define ruralurbanl 1 "Metro - Counties in metro areas of 1 million population or more"    ///
						 2 "Metro - Counties in metro areas of 250,000 to 1 million population" ///
						 3 "Metro - Counties in metro areas of fewer than 250,000 population" ///
					 	 4 "Nonmetro - Urban population of 20,000 or more, adjacent to a metro area" ///
					 	 5 "Nonmetro - Urban population of 20,000 or more, not adjacent to a metro area" ///
						 6 "Nonmetro - Urban population of 2,500 to 19,999, adjacent to a metro area" ///
						 7 "Nonmetro - Urban population of 2,500 to 19,999, not adjacent to a metro area" ///
						 8 "Nonmetro - Completely rural or less than 2,500 urban population, adjacent to a metro area " ///
						 9 "Nonmetro - Completely rural or less than 2,500 urban population, not adjacent to a metro area  " 
label values ruralurban ruralurbanl  

g metro=ruralurban<4
label variable metro "Metropolitan area (2010), ruralurban<4"
g rural=ruralurban>7  
label variable rural "Rural area (2010), ruralurban>7"
drop Population_2010
drop 	Description		
drop if countyid=="0"
merge 1:1 countyid using `countydata' 
drop if countyid=="0"
drop _merge
save `countydata' , replace 



*_________________________________________________________________________________________________________
* Prepare Unemployment rate based on American Comunity Survey 
import delimited _raw/Census/Rural_Atlas_Update14/Jobs.csv, encoding(ISO-8859-1) stringcols(1) clear
keep fips unemprate2008 unemprate2009  unemprate2010 unemprate2011 unemprate2012 unemprate2013  unemprate2014 unemprate2015
reshape long unemprate, i(fips) j(year) 
rename year syear
rename fips countyid
replace countyid="0"+countyid if length(countyid)==4
drop if syear<2011
drop if countyid=="0"
merge m:1 countyid using `countydata' 
drop if unemprate==. & _merge==1
drop if countyid=="0"
drop _merge
save `countydata' , replace 



*_________________________________________________________________________________________________________
* Prepare Population based on Census:  (time varying) totalpopulation
import delimited _raw/Census/Rural_Atlas_Update14/People.csv, encoding(ISO-8859-1) stringcols(1) clear
keep fips totalpopest2*
reshape long totalpopest, i(fips) j(syear) 
rename fips countyid
replace countyid="0"+countyid if length(countyid)==4
tempfile pop
g totalpopestby100T=totalpopest/100000
drop if syear<2011
drop if countyid=="0"
merge m:1 countyid syear using `countydata' 
drop _merge
save `countydata' , replace 

*_________________________________________________________________________________________________________
*Poverty/Householdincome
import delimited _raw/Census/SAIPESNC_05APR17_15_02_58_98.csv, encoding(ISO-8859-1) stringcols(3)  clear
keep year countyid allagesinpovertypercent medianhouseholdincomeindollars 
rename year syear
destring allagesinpovertypercent, replace force
replace medianhouseholdincomeindollars = subinstr(medianhouseholdincomeindollars, "$", "", 1)
replace medianhouseholdincomeindollars = subinstr(medianhouseholdincomeindollars, ",", "", .)
destring medianhouseholdincomeindollars, gen(medianhouseholdincomedollars) force
g medhhincome10Tdollars=medianhouseholdincomedollars/10000
drop if syear<2011
drop if countyid=="0"

merge m:1 countyid syear using `countydata' 
drop medianhouseholdincomeindollars medianhouseholdincomedollars totalpopest
drop _merge
drop if syear==.
drop if countyid==""
compress
save _prepared/countydata , replace 




