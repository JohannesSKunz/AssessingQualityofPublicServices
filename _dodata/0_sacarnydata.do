clear all
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/"

use _raw/Sacarny_hospitaloutcomes/mortreadm.v12.dta
drop hk_readm_rate hk_readm_npatients copd_mort_npatients copd_mort_rate copd_readm_npatients copd_readm_rate stk_mort_npatients stk_mort_rate stk_readm_npatients stk_readm_rate cabg_mort_npatients cabg_mort_rate cabg_readm_npatients cabg_readm_rate
rename pn providerid 

rename ami_mort_rate 		mort_rate1
rename ami_mort_npatients 	mort_npatients1
rename hf_mort_rate			mort_rate2
rename hf_mort_npatients	mort_npatients2
rename pn_mort_rate			mort_rate3
rename pn_mort_npatients	mort_npatients3

rename ami_readm_rate		readm_rate1
rename ami_readm_npatients	readm_npatients1
rename hf_readm_rate		readm_rate2
rename hf_readm_npatients	readm_npatients2
rename pn_readm_rate		readm_rate3
rename pn_readm_npatients	readm_npatients3

reshape long readm_rate readm_npatients mort_rate mort_npatients, i(providerid year) j(measure)

save _prepared/sacarny, replace 


 
 
