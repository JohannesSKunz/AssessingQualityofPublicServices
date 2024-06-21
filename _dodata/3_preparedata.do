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
order providerid measure providermeasureid year hospitalname new_prov sysname excessreadmissionratio readm_rate readm_npatients numberofdischarges survey_percentotrecommend mort_rate mort_npatients all_readm_rate all_readm_npatients hrr hrrnum

sort providermeasureid year
replace providermeasureid=providermeasureid[_n-1]+1 if providermeasureid==.
label var providermeasureid      "Provider by Measure Number"

bys providerid year: g t=_n
	label var t      "Yearly hospital first observation"
xtset providermeasureid year

drop status _merge ipps_miss city state zipcode county countycorreced hrrmiss closinginhrr nrclosinginhrr openinginhrr nropeninginhrr changenrhospitalsinhrr nrhospitalsinhrr countyid countymiss main_miss InCMSdata miss_survey

*-------------------------------------------------------
drop hrrnum 
g myear=-year

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
// Readmissions -- Peanlty 
su excessreadmissionratio, d 

g penalty=(excessreadmissionratio>1 & excessreadmissionratio!=.) 
	replace penalty=. if year<=2010 | year>=2016
	replace penalty=. if measure == .	
	label var penalty      "Penalty status (0/1), main outcome"

g penalty_placebo25=(excessreadmissionratio>.9503 & excessreadmissionratio!=.) 
	replace penalty_placebo25=. if year<=2010 | year>=2016
	replace penalty_placebo25=. if measure == .	
	label var penalty_placebo25      "Penalty status (0/1), main outcome, 25 percentile .9503"
	
g penalty_placebo75=(excessreadmissionratio>1.0504  & excessreadmissionratio!=.) 
	replace penalty_placebo75=. if year<=2010 | year>=2016
	replace penalty_placebo75=. if measure == .	
	label var penalty_placebo75      "Penalty status (0/1), main outcome, 75 percentile 1.0504"
		
	
bys providerid measure: egen double meanpenalty=mean(penalty) if excessreadmissionratio!=.

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

	order providerid measure providermeasureid year hospitalname new_prov sysname penalty excessreadmissionratio meanpenalty numberofdischarges toofewdiscarges totnumdicarges_other totnumdicarges_other_leaveout  
	sort providerid measure year
	
*-------------------------------------------------------		
// Size: beds 
bro providerid measure year t hospitalname new_prov sysname penalty toofewdiscarges excessreadmissionratio numberofdischarges posbeds beds 	 

replace beds = posbeds if beds==.

// Size of hospital 
egen catsize_beds = cut(beds), at(0,100,400,5000) icodes 
		tab catsize_beds
		label var catsize_beds     "Category number of beds, time varying"

// Change in the size 
bys providerid measure (year): g temp=catsize_beds-catsize_beds[_n-1] if catsize_beds[_n-1]!=.
		g delta_catsize_beds=(temp!=0 & temp !=.)
		replace delta_catsize_beds =. if numberofdischarges==.
		su delta_catsize_beds if t==1 & penalty!=.
		drop temp 
		label var delta_catsize_beds     "Change bed size category (0/1), time varying"
		
// Time constant size 
bys providerid measure (year): egen temp=mean(beds)
		egen catsize_avbeds = cut(temp), at(0,100,400,5000) icodes 
		replace catsize_avbeds=. if numberofdischarges==.
		label var catsize_avbeds     "Category average number of beds, time constant"
	drop posbeds temp 
	
	
*-------------------------------------------------------	
* Teaching 	
bro providerid measure providermeasureid year hospitalname new_prov sysname penalty residenttobedratio rday teachstatus

// Time varying teaching status 
g temp="1 minor"
	replace temp="0 none"  if  residenttobedratio==0 	& rday==0
	replace temp="2 major" if  residenttobedratio>=0.25 & rday>=0.25
	replace temp="" 	   if  residenttobedratio==. 	& rday==.

encode 	temp , gen(teach)
	label var teach     "Teaching status 0 Rtobed=0, 1 if <0.25, 2 if > , time varying"	

	bys providerid measure (year): g temp1=teach-teach[_n-1] if teach[_n-1]!=.
		g delta_teach=(temp1!=0 & temp1 !=.)	
		replace delta_teach=. if teach==.
		label var delta_teach     "Change in teaching status (0/1), time varying"	
	drop teachstatus temp temp1 
	
// Time constant 
	bys providerid measure (year): egen temp=mean(teach)
		g teach_cons = . 
			replace teach_cons=0 if temp<1.5
			replace teach_cons=1 if temp<2.5  & temp>=1.5
			replace teach_cons=2 if temp>=2.5 & temp!=.
		label var teach_cons     "Averaged teaching stauts , time constant"	
			
			drop temp residenttobedratio rday 

*-------------------------------------------------------		
// Ownership 
replace hospitalownership = pos_control if hospitalownership==""

	bro providerid providerid measure providermeasureid year hospitalname new_prov sysname penalty excessreadmissionratio meanpenalty hospitalownership

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

bys providerid measure (year): g temp=chainid-chainid[_n-1] if ownership[_n-1]!=.
		g delta_chain=(temp!=0 & temp !=.)	
		label var delta_chain      "Change in chain (0/1), time varying"

	drop temp

*-------------------------------------------------------			
// Closed 
g closed=new_prov=="Closed"
		label var closed      "Indicator hospital closed (0/1), usually next year entry time varying"

// Merged 
g merged=(new_prov!="" & new_prov!="Closed")
		label var merged      "Indicator hospital merger (0/1), usually next year entry time varying"

g mergedid=	new_prov if merged==1
		label var mergedid      "Hospital ID merger, time varying"
	drop new_prov
	
	

*-------------------------------------------------------
* Location - Urban definition following Gu et al 2014
bro providerid measure providermeasureid year hospitalname penalty hrr hrrnum pstate pzip hsa fcounty pcity urgeo urspa 

// Set to rural if missing 
replace urgeo = "RURAL" if urgeo==""

// Make time constant 
g urban=(urgeo=="LURBAN" | urgeo=="OURBAN")
bys providerid: egen temp=max(urban)
replace urban=temp
		label var urban      "Indicator Urban 1 Rural 0 , time varying"

drop urgeo urspa temp metro rural

bro providerid measure providermeasureid year hospitalname penalty hrr hrrnum pstate pzip hsa fcounty pcity urban ruralurban

bro providerid measure providermeasureid year hospitalname penalty excessreadmissionratio ownership hrr hrrnum pstate beds numberofdischarges all_readm_npatients if hrr==5

*-------------------------------------------------------
* Local Market  : Number of hospitals 
// count unique  
bys hrr year providerid : g temp = _n if _n==1 & closed!=1
bys hrr year : egen nrhosphrr = total(temp)
label var nrhosphrr   "All hospitals in hrr by year"
drop temp 
*-------------------------------------------------------
* Local Market  : Opening, closing 
// Increase/decrease 
bys providermeasureid (year): g delta_nrhosphrr=nrhosphrr-nrhosphrr[_n-1]
label var delta_nrhosphrr   "Change in hospitals in hrr by year, with any of the 3 conditions"

g openingnrhosphrr=delta_nrhosphrr>0
	label var openingnrhosphrr   "Pos. Change in hospitals in hrr by year, with any of the 3 conditions"
g closingnrhosphrr=delta_nrhosphrr<0
	label var closingnrhosphrr   "Neg. Change in hospitals in hrr by year, with any of the 3 conditions"

	
*-------------------------------------------------------
* By pop 
bys hrr year measure: egen popinhrr=total(totalpopestby100T)
g hospperhead=nrhosphrr/popinhrr

*-------------------------------------------------------
// Indicator 
qui su hospperhead , d
g abovemedcomp=hospperhead>=r(p50)
label var abovemedcomp   "Indicator Above median competition in HRR number of hospitals"
// Constant: Max 
bys providerid: egen abovemedcomp_const=max(abovemedcomp)
label var abovemedcomp_const   "Indicator Above median competition in HRR number of hospitals, constant"

	
*-------------------------------------------------------
* Local Market  : For-profit competitiors 
bys hrr year providerid : g temp = _n if _n==1 & closed!=1 & ownership==3
bys hrr year : egen temp2 = total(temp)
g share_forprof_hosp_hrr = temp2/nrhosphrr
label var share_forprof_hosp_hrr   "Share of for-profit hospitals in hrr by year"
drop temp temp2 

*-------------------------------------------------------
sort hrr year measure 
bro providerid hrr year measure nrhosphrr beds

* Local Market  : Beds
bys hrr year providerid : g temp = beds if _n==1 & closed!=1
bys hrr year : egen nrbedshrr = total(temp)
label var nrbedshrr   "All beds in hrr by year"
drop temp 

// Concentration: HHI-beds
g temp = (beds/nrbedshrr)^2
bys hrr year providerid : g temp1 = temp if _n==1 & closed!=1
bys hrr year : egen hhi_beds = total(temp1) 
label var hhi_beds   "HHI beds in hrr by year"
drop temp temp1

// Average HHI over time 
bys hrr: egen mean_hhi_beds=mean(hhi_beds) if hhi_beds!=0 & hhi_beds!=.
bys hrr: egen temp=max(mean_hhi_beds) 
replace mean_hhi_beds=temp 
label var mean_hhi_beds   "Mean HHI in HRR number of beds, constant"
drop temp 

* ------------------------------------------
* Chains HHI 
bro providerid hospitalname year sysname chainid hrr hrrnum hhi_beds 

* Number of hospitals in chain (any condition but no double counting)
	egen ne = group(providerid)
	g chainid_inclnochian = chainid*10000
	replace chainid_inclnochian = ne if chainid_inclnochian==.
	egen chainid_incl_nochain = group(chainid_inclnochian)
	drop ne chainid_inclnochian

bys chainid_incl_nochain year measure : g nrhospinchain_cond = _N
bys chainid_incl_nochain measure: egen numberofhospitalsinchain = max(nrhospinchain_cond)

g largechain=numberofhospitalsinchain >= 10
label var largechain   "Chain larger than 10, time varying"

* HHI for chains 
bro providerid hospitalname year sysname chainid_incl_nochain hrr beds totnumdicarges_other mean_hhi_beds 
bys chainid_incl_nochain year hrrnum measure: egen nrbeds_chain_hrr = total(beds)

// Concentration: HHI-beds
cap drop temp*
g temp = (nrbeds_chain_hrr/nrbedshrr)^2
bys hrr year chainid_incl_nochain : g temp1 = temp if _n==1 & closed!=1
bys hrr year : egen hhisys_beds = total(temp1) 
label var hhisys_beds   "HHI system beds in hrr in first year observed"
drop temp temp1

// Average HHI over time 
bys hrr: egen mean_hhisys_beds=mean(hhisys_beds) if hhisys_beds!=0 & hhisys_beds!=.
bys hrr: egen temp=max(mean_hhisys_beds) 
replace mean_hhisys_beds=temp 
label var mean_hhisys_beds   "Mean HHI - sys in HRR number of beds, constant"
drop temp* 

* Check HHI sys should always be larger (more monopolisitc) than HHI-hospital 
bro providerid hospitalname year sysname chainid_incl_nochain hrr beds totnumdicarges_other mean_hhi_beds mean_hhisys_beds if mean_hhi_beds<mean_hhisys_beds
su  mean_hhi_beds mean_hhisys_beds

*-------------------------------------------------------
* Local Market  : Total Discharges
sort measure providerid year
bys hrr year providerid : g temp = totnumdicarges_other if _n==1 & closed!=1
bys hrr year : egen nrtotnumdicargeshrr = total(temp)
label var nrtotnumdicargeshrr   "All discarges in all-em-cond in hrr by year"
drop temp 

// Concentration: HHI-beds
g temp = (totnumdicarges_other/nrtotnumdicargeshrr)^2
bys hrr year providerid : g temp1 = temp if _n==1 & closed!=1
bys hrr year : egen hhi_discharges = total(temp1) 
label var hhi_discharges   "HHI discarges all conditions in hrr by year"
drop temp temp1

// Average HHI over time 
bys hrr: egen mean_hhi_discharges=mean(hhi_discharges) if hhi_discharges!=0 & hhi_discharges!=.
bys hrr: egen temp=max(mean_hhi_discharges) 
replace mean_hhi_discharges=temp 
label var mean_hhi_discharges   "Mean HHI in HRR discarges all condition, constant"
drop temp

*-------------------------------------------------------
* System 
bys hrr year chainid_incl_nochain : g temp = totnumdicarges_other if _n==1 
bys hrr year : egen nrtotnumdicargeshrrsys = total(temp)
label var nrtotnumdicargeshrrsys   "All discarges in all-em-cond in hrr by year"
drop temp 

// Concentration: HHI-beds
g temp = (totnumdicarges_other/nrtotnumdicargeshrrsys)^2
bys hrr year chainid_incl_nochain : g temp1 = temp if _n==1 
bys hrr year : egen hhisys_discharges = total(temp1) 
label var hhisys_discharges   "HHI discarges all conditions in hrr by year"
drop temp temp1

// Average HHI over time 
bys hrr: egen mean_hhisys_discharges=mean(hhisys_discharges) if hhisys_discharges!=0 & hhisys_discharges!=.
bys hrr: egen temp=max(mean_hhisys_discharges) 
replace mean_hhisys_discharges=temp 
label var mean_hhisys_discharges   "Mean HHI in HRR system discarges all condition, constant"
drop temp

*-------------------------------------------------------
* Lagged 2008
g temp = mean_hhi_discharges if year == 2008
bys hrr: egen mean_hhi_discharges_2008 =  max(temp)
	label var mean_hhi_discharges_2008   "Mean HHI in HRR discarges all condition, 2008"

g temp2 = mean_hhisys_discharges if year == 2008
bys hrr: egen mean_hhisys_discharges_2008 =  max(temp2)
	label var mean_hhisys_discharges_2008   "Mean HHI in HRR system discarges all condition, 2008"

drop temp*

bro providerid hospitalname year sysname chainid_incl_nochain hrr beds totnumdicarges_other mean_hhi_beds mean_hhisys_beds mean_hhi_discharges if hrr==187
*-------------------------------------------------------
label var medhhincome10Tdollars   "County-level median household income in 10T dollar, time varying"
label var totalpopestby100T   	  "County-level population in 100T dollar, time varying"
label var unemprate   	  		  "County-level unemployment rate, time varying"
label var hsa   	  			  "HSA geo cd"
label var cothname   	  	      "Teaching hospital name"
label var mort_rate   	  	      "Mortality rate, by measure and time"
label var mort_npatients   	  	  "Mortality rate - denominator, by measure and time"
label var mort_npatients   	  	  "Mortality rate - denominator, by measure and time"

bys   providerid: egen 	 indata   = max(measure)
order providerid measure indata 
drop if indata==.
drop indata myear

bys   providerid: egen 	 indata   = max(excessreadmissionratio)
order providerid measure indata 
drop if indata==.
drop indata 
*/

compress 
save 21_03_16_data_main.dta , replace

