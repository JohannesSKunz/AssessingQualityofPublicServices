clear all 
set more off 

set maxvar 32767 
set mat 11000
version 14.1
cap cd "/Users/jkun0001/" 
cap cd "/Users/johanneskunz/" 

glo pathdata "/Users/jkun0001/Desktop/_data/Hospitalcompare" 
glo pathfold "/Users/jkun0001/Dropbox/workingpapers/KunzPropperStaubWinkelmann/estimation/21_03_08_estimation_newtabs/" 

***Choose alphas
glo covars	" numberofdischarges totnumdicarges_other_leaveout beds DischargesforAmbulatoryCareS openingnrhosphrr closingnrhosphrr allagesinpovertypercent medhhincome10Tdollars totalpopestby100T unemprate "
glo fes 	" _Iyear_2012 _Iyear_2013 _Iyear_2014 _Iyear_2015 "
glo covars2 " forprofit_cons  beds100_399 beds400_ minorteaching majorteaching urban"
tempfile alphas datamethod 


* ----------------------------------------------------------------------------------------------------
use /Users/jkun0001/Desktop/_data/Hospitalcompare/21_03_16_data_main.dta
cd $pathfold
cap log close
cap log using __logfiles/_estimate.txt, text append

do _sampleselection
xi   i.year i.measure

	
xtbrglm penalty $covars  $fes if measure==1 ,   identifier(id) savefe cluster(id) 
	rename  __feid  brglm_pen_ami
	
xtbrglm penalty $covars  $fes if measure==2 ,   identifier(id) savefe cluster(id) 
	rename  __feid  brglm_pen_hf
	
xtbrglm penalty $covars  $fes if measure==3 ,   identifier(id) savefe cluster(id) 
	rename  __feid  brglm_pen_pn
	
g brglm_pen_cond = brglm_pen_ami if measure==1
replace  brglm_pen_cond = brglm_pen_hf  if measure==2
replace  brglm_pen_cond = brglm_pen_pn  if measure==3
	
glo fes 	"_Iyear_2012 _Iyear_2013 _Iyear_2014 _Iyear_2015 _Imeasure_2 _Imeasure_3"

fese readm_rate $covars  $fes ,  a(id) s(alprr)
	ebayes alprrb alprrse , gen(ebayes_rr)

fese excessreadmissionratio $covars  $fes ,  a(id) s(alperr)
	ebayes alperrb alperrse , gen(ebayes_err)	
	
xtbrglm penalty $covars  $fes  ,  fesefast identifier(id) savefe cluster(id) 
	rename  __feid  brglm_pen
	rename __feidse brglm_pense

fese readm_rate $covars  $fes ,  a(providermeasureid) s(alprr_cond)
	ebayes alprr_condb alprr_condse , gen(ebayes_rr_cond)

	
fese excessreadmissionratio $covars  $fes ,  a(providermeasureid) s(alperr_cond)
	ebayes alperr_condb alperr_condse , gen(ebayes_err_cond)

xtbrglm penalty $covars  $fes  ,  fesefast identifier(providermeasureid) savefe cluster(id) 
	rename __feprovidermeasureid   brglm_pen_inter
	rename __feprovidermeasureidse brglm_pense_inter
	

g phibrglm_pen=normal(brglm_pen)
g phibrglm_pen_inter=normal(brglm_pen_inter)
g phibrglm_pen_cond=normal(brglm_pen_cond)
	
bys providerid measure: g temp=_n
keep if temp==1

by providerid : g temp2=_n

g te=nrhosphrr/popinhrr
su te if everchanged_ownerstat==0, d
g med=te>r(p50)

su mean_hhi_beds if everchanged_ownerstat==0, d
g med2=mean_hhi_beds>r(p50)

su mean_hhi_discharges if everchanged_ownerstat==0, d 
g med3=mean_hhi_discharges>r(p50)

g forprofitXsystem=forprofit*belongschain

g forprofitXhhi_dis=forprofit*mean_hhi_discharges

g forprofitXhhi_bed=forprofit*mean_hhi_bed

g forprofitXnrhosphrr=forprofit*te

loc covars1 "i.teach_cons i.catsize_avbeds urban  "
loc covars2 "age65andolderpct2010 whitenonhispanicpct2010 blacknonhispanicpct2010 asiannonhispanicpct2010 hispanicpct2010 ed1lessthanhspct2010 ed2hsdiplomaonlypct2010 ed3somecollegepct2010 ed4assocdegreepct2010 ed5collegepluspct2010"

foreach var in hrr teach_cons catsize_avbeds urban belongschain `covars2' {
replace `var'=0 if `var'==.
}

g belongschainXhhi_dis=belongschain*mean_hhi_discharges
	
compress	
	
save /Users/jkun0001/Desktop/_data/Hospitalcompare/21_03_16_data_main_alphas.dta , replace
	