**** ADD proper labels, repair robustness


*** data downloaded 2016-11-05 from https://data.medicare.gov/data/archives/hospital-compare
clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1

loc datedata 20_01_08
loc dateest  24_02_12
cap cd "/Users/jkun0001/" 
cap cd "/Users/johanneskunz/" 

glo pathdata "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/" 
glo pathfold "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/" 

glo covars	"numberofdischarges totnumdicarges_other_leaveout bedsdischarges (condition-specific)sforAmbulatoryCareS openingnrhosphrr closingnrhosphrr allagesinpovertypercent medhhincome10Tdollars totalpopestby100T unemprate "
glo fes 	"_Iyear_2012 _Iyear_2013 _Iyear_2014 _Iyear_2015 _Imeasure_2 _Imeasure_3"
loc covars1 "i.teach_cons i.catsize_avbeds urban belongschain "
glo covars2 "forprofit_cons  beds100_399 beds400_ minorteaching majorteaching urban"
loc covars3 "age65andolderpct2010 whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 hispanicpct2010 ed1lessthanhspct2010 ed2hsdiplomaonlypct2010 ed3somecollegepct2010 ed4assocdegreepct2010 ed5collegepluspct2010"
tempfile alphas datamethod temp

loc ses "cluster(providerid)"
loc ses2 "cluster(hrr)"
*-------------------------------------------------------------------------------------------------
cap log close
cap log using $pathfold/_logfiles/e6_tab_comparison.txt, text replace
cap use $pathdata/_processeddata/24_05_24_data_alphas_hhi_hsa.dta


loc appendixvars hospitalname fcounty meanpenalty share_forprof_hosp_hrr std_alpha_brglm_penalty std_alpha_reg_penalty phi_alpha_brglm_penalty ebayes_alpha_reg_penalty alpha_brglm_penalty forprofitXhhi_discharge2008 chainXhhi_discharge2008 new_hhi_discharge2008 forprofitXhhi_discharge_sys_own chainXhhi_discharge_sys_own new_hhi_discharge_sys_own forprofitXhhi_dis_sys_other chainXhhi_dis_sys_other new_hhi_dis_sys_other alpha_brglm_penalty_pooled alpha_brglm_penalty_inter pcr_alpha_brglm_penalty_inter ebayes_alpha_reg_penalty_inter ebayes_alpha_reg_err_inter 

keep providerid chainid measure hsa year providermeasureid penalty excessreadmissionratio phi_alpha_brglm_penalty_inter phi_alpha_brglm_penalty_pooled pcr_alpha_brglm_penalty_pooled pcr_alpha_brglm_penalty all_readm_rate mort_rate mean_hhi_discharges mean_hhi_beds survey_percentotrecommend providerid forprofit belongschain  nrhosphrr totalpopestby100T hrr hrrnum teach_cons catsize_avbeds ruralurban urban everchanged_ownerstat ownership delta_ownership popinhrr numberofhospitalsinchain sysname largechain unemprate temp temp2  medhhincome10Tdollars allagesinpovertypercent DischargesforAmbulatoryCareS hospperhead numberofdischarges totnumdicarges_other_leaveout beds closingnrhosphrr openingnrhosphrr id readm_rate forprofitXhhi_beds forprofitXhhi_discharge forprofitXhhi_discharge_sys2008 forprofitXhhi_discharge_sys chainXhhi_beds new_hhi_discharge_sys2008 chainXhhi_discharge chainXhhi_discharge_sys2008 chainXhhi_discharge_sys new_hhi_beds new_hhi_discharge new_hhi_discharge_sys uninsuredadultsrawvalue new_hhi_dis_sys_hsa forprofitXhhi_dis_sys_hsa chainXhhi_dis_sys_hsa `appendixvars' `covars' `covars2' `covars3' `fes' 



foreach var in hrr teach_cons catsize_avbeds urban belongschain uninsuredadultsrawvalue `covars3' {
	replace `var'=0 if `var'==.
	}
	
order providerid id measure providermeasureid year forprofit hospitalname ownership  sysname chainid readm_rate excessreadmissionratio penalty meanpenalty all_readm_rate mort_rate survey_percentotrecommend  numberofdischarges beds popinhrr hrr hrrnum hsa urban fcounty  

rename new_* *


merge 1:1 providermeasureid year using $pathdata/_processeddata/24_02_12_data_alphas_hhi_hsa.dta , keepusing(new_hhi_discharge_sys2008_hsa)

_pctile hhi_discharge_sys2008 if temp == 1 & everchanged_ownerstat==0, nq(2)
g mforprofitXhhi_discharge_sys2008	= forprofit*(hhi_discharge_sys2008>=r(r1))		//Median
g mchainXhhi_discharge_sys2008	= belongschain*(hhi_discharge_sys2008>=r(r1))		//Median

_pctile hhi_discharge_sys2008 if temp == 1 & everchanged_ownerstat==0, nq(10) 		// Monopolish
g monop_hhi_discharge_sys2008=(hhi_discharge_sys2008>=r(r9))

rename new_hhi_discharge_sys2008_hsa	hhi_dis_sys2008_hsa
	g forprofitXhhi_dis_sys2008_hsa 	= forprofit*(hhi_dis_sys2008_hsa)			//Standard
	g chainXhhi_dis_sys2008_hsa 		= belongschain*(hhi_dis_sys2008_hsa)	


lab var id 						"Internal ID"
lab var measure 				"Condition"
lab var providermeasureid 		"Provider X Condition ID"
lab var chainid 				"Chain/chain-level ID"
lab var readm_rate 				"Raw readmission rate"
lab var meanpenalty 			"Averaged (over time) penalty rate, by condition"
lab var all_readm_rate 			"Overall hopsital wide 30-day readmission rate "
lab var beds 					"Number of beds, yearly count"
lab var popinhrr 				"Population in HRR in 100,000"
lab var hrrnum 					"Hospital Referral Region ID"
lab var hsa 					"HSA region ID"
lab var fcounty		 			"FIPS county ID"
lab var hospperhead				"Number of hospitals her population"
lab var ruralurban 				"Rural - Urban categories (RUCC 2013 - codes)"
lab var hhi_discharge      		"Mean HHI in HRRdischarges (condition-specific)s, by condition"
lab var hhi_discharge2008 		"HHI in HRRdischarges (condition-specific)s in 2008, by condition"
lab var hhi_discharge_sys 		"Mean HHI in HRRdischarges (condition-specific)s - chain-levellevel, by condition"
lab var hhi_discharge_sys2008 	"HHI in HRRdischarges (condition-specific)s 2008 - chain-levellevel, by condition"

label variable alpha_brglm_penalty_pooled "Alpha BRGLM Penalty Pooled"
label variable alpha_brglm_penalty_inter "Alpha BRGLM Penalty Intercept"
label variable alpha_brglm_penalty "Alpha BRGLM Penalty"
label variable phi_alpha_brglm_penalty_pooled "Phi Alpha BRGLM Penalty Pooled"
label variable phi_alpha_brglm_penalty_inter "Phi Alpha BRGLM Penalty Intercept"
label variable phi_alpha_brglm_penalty "Phi Alpha BRGLM Penalty"
label variable std_alpha_brglm_penalty "Standardized Alpha BRGLM Penalty"
label variable std_alpha_reg_penalty "Standardized Alpha Regression Penalty"
label variable pcr_alpha_brglm_penalty_pooled "Percentile Rank Alpha BRGLM Penalty Pooled"
label variable pcr_alpha_brglm_penalty "Percentile Rank Alpha BRGLM Penalty"
label variable pcr_alpha_brglm_penalty_inter "Percentile Rank Alpha BRGLM Penalty Intercept"
label variable ebayes_alpha_reg_penalty "EBayes Alpha Regression Penalty"
label variable ebayes_alpha_reg_penalty_inter "EBayes Alpha Regression Penalty Intercept"
label variable ebayes_alpha_reg_err_inter "EBayes Alpha Regression Error Intercept"

label variable numberofhospitalsinchain "Number of Hospitals in Chain"
label variable largechain "Large Chain (1/0), 30% highest - 20 hopsitals nation wide"
label variable forprofitXhhi_beds "For-Profit x HHI Beds"
label variable chainXhhi_beds "Chain x HHI Beds"
label variable forprofitXhhi_discharge "For-Profit x HHI discharges (condition-specific)"
label variable chainXhhi_discharge "Chain x HHI discharges (condition-specific)"
label variable forprofitXhhi_discharge2008 "For-Profit x HHI discharges (condition-specific) 2008"
label variable chainXhhi_discharge2008 "Chain x HHI discharges (condition-specific) 2008"
label variable forprofitXhhi_discharge_sys "For-Profit x HHI discharges (condition-specific) chain-level"
label variable chainXhhi_discharge_sys "Chain x HHI discharges (condition-specific) chain-level"
label variable forprofitXhhi_discharge_sys2008 "For-Profit x HHI discharges (condition-specific) chain-level 2008"
label variable chainXhhi_discharge_sys2008 "Chain x HHI discharges (condition-specific) chain-level 2008"
label variable temp "First observation of hopital X Conditon, use when only count once"
label variable temp2 "First observation of hopital, use when only count once"

label variable hhi_dis_sys_hsa "HHI discharges (condition-specific) chain-level HSA"
label variable forprofitXhhi_dis_sys_hsa "For-Profit x HHI discharges (condition-specific) chain-level HSA"
label variable chainXhhi_dis_sys_hsa "Chain x HHI discharges (condition-specific) chain-level HSA"
label variable hhi_dis_sys2008_hsa "HHI discharges (condition-specific) chain-level 2008 HSA"
label variable mforprofitXhhi_discharge_sys2008 "Median For-Profit x HHI discharges (condition-specific) chain-level 2008"
label variable mchainXhhi_discharge_sys2008 "Median Chain x HHI discharges (condition-specific) chain-level 2008"
label variable monop_hhi_discharge_sys2008 "Monopoly HHI discharges (condition-specific) chain-level 2008"
label variable forprofitXhhi_dis_sys2008_hsa "For-Profit x HHI discharges (condition-specific) chain-level 2008 HSA"
label variable chainXhhi_dis_sys2008_hsa "Chain x HHI discharges (condition-specific) chain-level 2008 HSA"	

* Prepare
sort providerid measure year
xi   i.year i.measure 
	
drop *_own *_other _merge
compress 
save $pathdata/_finaldata/maindata, replace 

* Rename and store
use /Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/_processeddata/22_02_16_data_alphas_hhi_rob.dta
save /Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/_finaldata/appendixdata.dta

