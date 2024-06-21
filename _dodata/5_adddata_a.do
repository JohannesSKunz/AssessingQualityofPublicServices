clear all 
set more off 
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"
set maxvar 32767 
set mat 11000
use _prepared/main

drop measurename 
format hospitalname %12s
format cothname %12s
sort providerid year measure
label var year      	"Financial year"
label var hrr  			"Hospital referral region"
label var sysname   	"Name of chain"
label var new_prov 		"Change provider or closure"
label var readm_rate 	"Readmission Rate"

replace measure = 0 if measure ==. 

egen providermeasureid=group(providerid measure)

sort providermeasureid year
replace providermeasureid=providermeasureid[_n-1]+1 if providermeasureid==.
label var providermeasureid      "Provider by Measure Number"

bys providerid year: g t=_n
	label var t      "Yearly hospital first observation"
xtset providermeasureid year

// Drop not needed variables 
drop status _merge ipps_miss city state zipcode county countycorreced hrrmiss closinginhrr nrclosinginhrr openinginhrr nropeninginhrr changenrhospitalsinhrr nrhospitalsinhrr countyid countymiss main_miss InCMSdata miss_survey

*-------------------------------------------------------
drop hrrnum 
g myear=-year

// Fill in missing time variant information
loc filli "hospitalname sysname hospitalownership cothname" 
 foreach var of local filli {
	capture confirm string variable `var'
           if !_rc {
				bys providerid measure (year)  : replace `var' = `var'[_n-1] if `var'==""
                bys providerid measure (myear) : replace `var' = `var'[_n-1] if `var'==""
				}
           else {
                bys providerid measure (year)  : replace `var' = `var'[_n-1] if `var'==.
                bys providerid measure (myear) : replace `var' = `var'[_n-1] if `var'==.
				}
		}
				
// Fill in missing time invariant information
loc filli "hrr  pstate pzip hsa fcounty pcity urgeo urspa ruralurban" 
 foreach var of local filli {
	capture confirm string variable `var'
           if !_rc {
				bys providerid (year)  : replace `var' = `var'[_n-1] if `var'==""
                bys providerid (myear) : replace `var' = `var'[_n-1] if `var'==""
				}
           else {
                bys providerid (year)  : replace `var' = `var'[_n-1] if `var'==.
                bys providerid (myear) : replace `var' = `var'[_n-1] if `var'==.
				}
		}		
		
	tostring hrr , gen(hrrnum)
		
*-------------------------------------------------------	
// Destring 
destring  numberofdischarges excessreadmissionratio  , replace force 

*-------------------------------------------------------	
// Discarges
replace   numberofdischarges=readm_npatients if numberofdischarges==. & readm_npatients!=.
	drop  readm_npatients hospitaltype name
	label var numberofdischarges      "Number of discharges by measure"

g toofewdiscarges = numberofdischarges<25
	replace toofewdiscarges = . if numberofdischarges==.
	label var toofewdiscarges      "Indicator discharges by measure below 25"

bys providerid year : egen totnumdicarges_other = total(numberofdischarges)
	replace totnumdicarges_other = . if numberofdischarges==.
		label var totnumdicarges_other     "Total discarges hospital"

g totnumdicarges_other_leaveout=totnumdicarges_other-numberofdischarges
		label var totnumdicarges_other_leaveout "Total discarges hospital, excluding measure"

	order providerid measure providermeasureid year hospitalname new_prov sysname excessreadmissionratio numberofdischarges toofewdiscarges totnumdicarges_other totnumdicarges_other_leaveout  
	sort providerid measure year
	
*-------------------------------------------------------		
// Size: beds 
	replace beds = posbeds if beds==.
		
*-------------------------------------------------------	
// Ownership 
replace hospitalownership = pos_control if hospitalownership==""

	bro providerid providerid measure providermeasureid year hospitalname new_prov sysname  excessreadmissionratio hospitalownership

replace hospitalownership = "Other" 				if hospitalownership == "1.For-profit"
replace hospitalownership = "Voluntary non-profit"  if hospitalownership == "2.Non-profit"
replace hospitalownership = "Government" 			if hospitalownership == "3.Government"
	drop pos_control category government forprofit nonprofit

	encode hospitalownership , gen(ownership)
	bys providerid measure (year): g temp=ownership-ownership[_n-1] if ownership[_n-1]!=.
		g delta_ownership=(temp!=0 & temp !=.)	
		replace delta_ownership=. if ownership==.
		label var delta_ownership     "Change in ownership (0/1), time varying"
	su delta_ownership if t==1
	
	bys providerid : egen everchanged_ownerstat=max(delta_ownership)
		replace everchanged_ownerstat=. if ownership==.
		label var everchanged_ownerstat     "Ever changed ownership (0/1), time constant"
	drop temp hospitalownership
	
	
g forprofit=ownership==3
replace forprofit=. if ownership==.	
		label var forprofit     "Forprofit ownership (0/1), time varying"


*-------------------------------------------------------		
// Chain 
g belongschain = sysname != ""
		label var belongschain     "Belongs to a chain (0/1), time varying"

egen chainid = group(sysname)
		label var chainid          "Chain id"

*-------------------------------------------------------			
// Closed 
g closed=new_prov=="Closed"
		label var closed      "Indicator hospital closed (0/1), usually next year entry time varying"

// count unique hospitals 
bys hrr year providerid : g temp = _n if _n==1 & closed!=1
bys hrr year : egen nrhosphrr = total(temp)
label var nrhosphrr   "All hospitals in hrr by year"
drop temp 
*-------------------------------------------------------
* By pop 
bys hrr year measure: egen popinhrr=total(totalpopestby100T)
g hospperhead=nrhosphrr/popinhrr

	egen ne = group(providerid)
	g chainid_inclnochian = chainid*10000
	replace chainid_inclnochian = ne if chainid_inclnochian==.
	egen chainid_incl_nochain = group(chainid_inclnochian)
	drop ne chainid_inclnochian

bys chainid_incl_nochain year measure : g nrhospinchain_cond = _N
bys chainid_incl_nochain measure: egen numberofhospitalsinchain = max(nrhospinchain_cond)

*-------------------------------------------------------
* Local Market  : Beds
bys hrr year providerid beds : g temp = beds if _n==1 & closed!=1
bys hrr year : egen nrbedshrr = total(temp)
label var nrbedshrr   "All beds in hrr by year"

* HHI for chains 
bys hrr year chainid_incl_nochain: egen nrbeds_chain_hrr = total(temp)
keep providerid sysname measure numberofdischarges chainid_incl_nochain year hrr nrbedshrr nrbeds_chain_hrr beds totnumdicarges_other closed hsa 
* ------------------------------------------------------------------------------
// Concentration: HHI-beds
g temp1 = (beds/nrbedshrr)^2
bys hrr year providerid beds: g temp2 = temp1 if _n==1 & closed!=1
bys hrr year : egen hhi_beds = total(temp2) 
label var hhi_beds   "HHI beds in hrr by year"

// Average HHI over time 
bys hrr: egen mean_hhi_beds=mean(hhi_beds) if hhi_beds!=0 & hhi_beds!=.
bys hrr: egen temp3=max(mean_hhi_beds) 
replace mean_hhi_beds=temp3 
label var mean_hhi_beds   "Mean HHI in HRR number of beds, constant"

bys  providerid: egen mean_hhi_beds_own=mean(temp1) if hhi_beds!=0 & hhi_beds!=.
bys  providerid: egen hhi_beds_own=max(mean_hhi_beds_own) 
g hhi_beds_other = mean_hhi_beds - hhi_beds_own
drop hhi_beds
rename mean_hhi_beds hhi_beds
drop temp* mean*

order providerid sysname chainid_incl_nochain year closed hrr beds nrbeds_chain_hrr nrbedshrr hhi_beds hhi_beds_other hhi_beds_own totnumdicarges_other
sort hrr year measure 

* ------------------------------------------------------------------------------
// Concentration: HHI-beds - System
bro providerid sysname chainid_incl_nochain measure year closed hrr hhi_beds numberofdischarges totnumdicarges_other

* 1 all discharges: by hospital 
sort  providerid year measure 

	*total number in HRR
	bys hrr year: egen temp = total(numberofdischarges)
	* only one per hopsital
	bys providerid year : g temp1  = _n
	* HHI - average
	g temp2 = (totnumdicarges_other/temp)^2 if temp1==1  & closed!=1
	bys hrr year: egen temp3 = total(temp2)
	replace temp3 = . if temp3==0
	bys hrr: egen hhi_discharge = mean(temp3) 
	* HHI - 2008
	g temp4 = temp3 if year == 2008
	bys hrr: egen hhi_discharge2008 = max(temp4) 
	* Assess
	su hhi_beds  hhi_discharge 
	drop tem*


* 2 condition specific discharges 
bro providerid sysname chainid_incl_nochain measure year beds hhi_beds numberofdischarges hhi_discharge hhi_discharge2008

	* total number in HRR by condition 
	bys measure year hrr : egen temp = total(numberofdischarges)
	* HHI - average
	g temp2 = (numberofdischarges/temp)^2 if  closed!=1
	bys measure year hrr: egen temp3 = total(temp2)
	replace temp3 = . if temp3==0
	bys hrr measure: egen hhi_disc_measure = mean(temp3) 
	* HHI - 2008
	g temp4 = temp3 if year == 2008
	bys hrr measure: egen hhi_disc_measure2008 = max(temp4) 	
	*Assess
	su 	hhi_beds  hhi_discharge hhi_discharge2008 hhi_disc_measure hhi_disc_measure2008
		drop tem*
	
* 3 Systemwide discharges 
bro providerid sysname chainid_incl_nochain measure year closed hrr numberofdischarges totnumdicarges_other hhi_discharge if hrr==187
	
	*total number in HRR
	bys hrr year: egen temp = total(numberofdischarges)
	
	*total number per system
	bys providerid year : g temp1  = _n
	bys chainid_incl_nochain hrr year: egen temp2 = total(totnumdicarges_other) if temp1==1 
	
	* only one per system	
	bys chainid_incl_nochain hrr year temp2: g temp3  = _n
	
	* HHI - average
	g temp4 = (temp2/temp)^2                if temp3==1  & closed!=1
	bys hrr year: egen temp5 = total(temp4)
	replace temp5 = . if temp5==0
	bys hrr: egen hhi_discharge_sys = mean(temp5) 
	* HHI - 2008
	g temp6 = temp4 if year == 2008
	bys hrr: egen hhi_discharge_sys2008 = max(temp6) 

	* 4 Own system 
	bys  chainid_incl_nochain hrr: egen hhi_discharge_sys_own=mean(temp4) 
	
	bys  chainid_incl_nochain hrr: egen temp7 = max(hhi_discharge_sys_own) 

	* 5 Other system 
	g hhi_discharge_sys_other = hhi_discharge_sys - temp7

	* Assess
	su hhi_beds  hhi_discharge hhi_discharge_sys hhi_discharge_sys_own hhi_discharge_sys_other 
	drop tem*

* 4 HSA discharges 
	
	*total number in HRR
	bys hsa year: egen temp = total(numberofdischarges)
	
	*total number per system
	bys providerid year : g temp1  = _n
	bys chainid_incl_nochain hsa year: egen temp2 = total(totnumdicarges_other) if temp1==1 
	
	* only one per system	
	bys chainid_incl_nochain hsa year temp2: g temp3  = _n
	
	* HHI - average
	g temp4 = (temp2/temp)^2                if temp3==1  & closed!=1
	bys hsa year: egen temp5 = total(temp4)
	replace temp5 = . if temp5==0
	bys hsa: egen hhi_discharge_sys_hsa = mean(temp5) 
	* HHI - 2008
	g temp6 = temp4 if year == 2008
	bys hsa: egen hhi_discharge_sys2008_hsa = max(temp6) 	
	
	
keep providerid year measure hhi*
rename hhi* new_hhi*
merge  1:1 providerid year measure using /Users/jkun0001/Desktop/24_05_24_data/20_01_08_data_alphas.dta , keep(2 3) nogen
compress 
save /Users/jkun0001/Desktop/_estimate/21_03_17_estimate/20_01_08_data_alphas_hhi.dta , replace


