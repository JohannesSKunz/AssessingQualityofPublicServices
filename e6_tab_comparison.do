clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1

glo pathdata "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/_dodata/_finaldata/" 
glo pathfold "/Users/jkun0001/Desktop/24_05_24_replicationpackage_all2/" 

glo covars	"numberofdischarges totnumdicarges_other_leaveout beds DischargesforAmbulatoryCareS openingnrhosphrr closingnrhosphrr allagesinpovertypercent medhhincome10Tdollars totalpopestby100T unemprate "
glo fes 	"_Iyear_2012 _Iyear_2013 _Iyear_2014 _Iyear_2015 _Imeasure_2 _Imeasure_3"
loc covars1 "i.teach_cons i.catsize_avbeds urban belongschain "
glo covars2 "forprofit_cons  beds100_399 beds400_ minorteaching majorteaching urban"
loc covars3 "age65andolderpct2010 whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 hispanicpct2010 ed1lessthanhspct2010 ed2hsdiplomaonlypct2010 ed3somecollegepct2010 ed4assocdegreepct2010 ed5collegepluspct2010"
tempfile alphas datamethod temp

loc suffix phi_
loc method brglm_penalty
loc ses "cluster(providerid)"
loc ses2 "cluster(hrr)"
*-------------------------------------------------------------------------------------------------
cap log close
cap log using $pathfold/_logfiles/e6_tab_comparison.txt, text replace
cap use $pathdata/maindata.dta


* --------------------------------------------------------------
* Estimate

* Pooled fe
fese survey_percentotrecommend $covars  $fes ,  a(id) s(alpsurv)
	ebayes alpsurvb alpsurvse if temp2==1 , gen(ebayes_surv)

	* Mortality rate 
fese mort_rate $covars  $fes ,  a(id) s(alpmort)
	ebayes alpmortb alpmortse if temp2==1 , gen(ebayes_mort)
* Interacted fe
fese mort_rate $covars  $fes ,  a(providermeasureid) s(alpmort_inter)
	ebayes alpmort_interb alpmort_interse , gen(ebayes_mort_inter)
	
	
* Pooled fe
fese readm_rate $covars  $fes ,  a(id) s(alprr)
	ebayes alprrb alprrse if temp2==1 , gen(ebayes_rr)
* Interacted fe
fese readm_rate $covars  $fes ,  a(providermeasureid) s(alprr_inter)
	ebayes alprr_interb alprr_interse , gen(ebayes_rr_inter)

* Pooled FE
fese excessreadmissionratio $covars  $fes ,  a(id) s(alperr)
	ebayes alperrb alperrse if temp2==1 , gen(ebayes_err)

fese excessreadmissionratio $covars  $fes ,  a(providermeasureid) s(alperr_inter)
	ebayes alperr_interb alperr_interse , gen(ebayes_err_inter)
		
* ------------
* Raw mean 
loc i = 1
mean  readm_rate if forprofit ==1 , cluster(id)
	est sto me`i'_1
mean  readm_rate if forprofit ==0 , cluster(id)
	est sto me`i'_2
reg readm_rate forprofit , cluster(id)
	est sto me`i'_3


* Covars
reg ebayes_rr forprofit `covars1' `covars3'  if temp2==1 , cluster(id)
	est sto me`i'_5

* FE Cond	
reg ebayes_rr_inter forprofit `covars1' `covars3' _Imeasure_2 _Imeasure_3 if  temp ==1, cluster(id)
	est sto me`i'_6	
	loc i = `i' + 1

* ------------
* Excess Raw mean 
mean  excessreadmissionratio if forprofit ==1  , cluster(id)
	est sto me`i'_1
mean  excessreadmissionratio if forprofit ==0  , cluster(id)
	est sto me`i'_2
reg excessreadmissionratio forprofit , cluster(id)
	est sto me`i'_3

	
* Covars
reg ebayes_err forprofit `covars1' `covars3'  if temp2==1 , cluster(id)
	est sto me`i'_5

* FE Cond	
reg ebayes_err_inter forprofit `covars1' `covars3' _Imeasure_2 _Imeasure_3 if  temp ==1, cluster(id)
	est sto me`i'_6	
	loc i = `i' + 1	

* ------------
loc i =3 

mean  penalty if forprofit ==1 , cluster(id)
	est sto me`i'_1
mean  penalty if forprofit ==0 , cluster(id)
	est sto me`i'_2

probit penalty forprofit , cluster(id)
	margins , dydx(forprofit)
	
	est sto me`i'_3
	estadd sca me = r(table)[1,1] ,: me`i'_3
	estadd sca std = sqrt(r(V)[1,1]) ,: me`i'_3

	
* Covars
reg phi_alpha_brglm_penalty_pooled forprofit `covars1' `covars3'  if temp2==1 , cluster(id)
	est sto me`i'_5

* FE Cond	
reg phi_alpha_brglm_penalty_inter forprofit `covars1' `covars3' _Imeasure_2 _Imeasure_3 if  temp ==1, cluster(id)
	est sto me`i'_6	
	loc i = `i' + 1	

* ------------
loc i =4

mean  survey_percentotrecommend if forprofit ==1 &  temp2==1, cluster(id)
	est sto me`i'_1
mean  survey_percentotrecommend if forprofit ==0 &  temp2==1 , cluster(id)
	est sto me`i'_2
reg survey_percentotrecommend forprofit if temp2==1 , cluster(id)
	est sto me`i'_3

	
* Covars
reg ebayes_surv forprofit `covars1' `covars3'  if temp2==1 , cluster(id)
	est sto me`i'_5


* ------------
loc i =5
replace mort_rate = mort_rate/100

mean  mort_rate if forprofit ==1 , cluster(id)
	est sto me`i'_1
mean  mort_rate if forprofit ==0 , cluster(id)
	est sto me`i'_2
reg mort_rate forprofit , cluster(id)
	est sto me`i'_3

* Covars
reg ebayes_mort forprofit `covars1' `covars3'  if temp2==1 , cluster(id)
	est sto me`i'_5

* FE Cond	
reg ebayes_mort_inter forprofit `covars1' `covars3' _Imeasure_2 _Imeasure_3 if  temp ==1, cluster(id)
	est sto me`i'_6	
	loc i = `i' + 1	
	
* ------------
esttab me4_* using $pathfold/_tables/e6_tab_comparison.tex , replace ///
	b(3) keep(survey_percentotrecommend) se nostar rename(forprofit survey_percentotrecommend)	

esttab me5_* using $pathfold/_tables/e6_tab_comparison.tex , append ///
	b(5) keep(mort_rate) se nostar rename(forprofit mort_rate)	
	
esttab me1_* using $pathfold/_tables/e6_tab_comparison.tex , append ///
	b(3) keep(readm_rate) se nostar rename(forprofit readm_rate)

esttab me2_* using $pathfold/_tables/e6_tab_comparison.tex , append ///
	b(3) keep(excessreadmissionratio) se nostar rename(forprofit excessreadmissionratio)

esttab me3_* using $pathfold/_tables/e6_tab_comparison.tex , append ///
	b(3) keep(penalty) margin se nostar rename(forprofit penalty) stats(N me std)
	


		
cap log close

	
	
