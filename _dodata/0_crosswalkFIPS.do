**Iport crosswalk
clear all
cd "/Users/jkun0001/Desktop/_data/Hospitalcompare/_raw/"


import excel Census/FIPScrosswalk/FY_13_NPRM_County_to_CBSA_Xwalk/CBSAtoCountycrosswalk_FY13.xls, sheet("CBSAtoCountycrosswalk_FY12") firstrow clear

rename State state 
rename County county
duplicates tag  state county , gen(doub)
bys doub: g t=_n
drop if doub==1 & t>1
drop doub t 

replace county="SAINT CLAIR" if county=="ST. CLAIR" & state=="AL"
replace county="KODIAK ISLAND" if county=="KODIAK ISLAND BOROUGH" & state=="AK"
replace county="MATANUSKA SUSITNA" if county=="MATANUSKA-SUSITNA" & state=="AK"
replace county="NORTH SLOPE" if county=="NORTH SLOPE BOROUH" & state=="AK"
replace county="SITKA" if county=="SITKA BOROUGH" & state=="AK"
replace county="VALDEZ CORDOVA" if county=="VALDEZ-CORDOVA" & state=="AK"
replace county="SAINT FRANCIS" if county=="ST. FRANCIS" & state=="AR"
replace county="SAINT FRANCIS" if county=="AMERICAN SAMOA" & state=="AS"
replace county="LA PAZ" if county=="LAPAZ" & state=="AZ"
replace county="DISTRICT OF COLUMBIA" if county=="THE DISTRICT" & state=="DC"
replace county="SAINT JOHNS" if county=="ST. JOHNS" & state=="FL"
replace county="SAINT LUCIE" if county=="ST. LUCIE" & state=="FL"
replace county="DEKALB" if county=="DE KALB" & state=="GA"
replace county="MCDUFFIE" if county=="MC DUFFIE" & state=="GA"
replace county="DEKALB" if county=="DE KALB" & state=="IL"
replace county="DEWITT" if county=="DE WITT" & state=="IL"
replace county="DUPAGE" if county=="DU PAGE" & state=="IL"
replace county="MCDONOUGH" if county=="MC DONOUGH" & state=="IL"
replace county="MCHENRY" if county=="MC HENRY" & state=="IL"
replace county="MCLEAN" if county=="MC LEAN" & state=="IL"
replace county="SAINT CLAIR" if county=="ST. CLAIR" & state=="IL"
replace county="ST JOSEPH" if county=="ST. JOSEPH" & state=="IN"
replace county="MCCRACKEN" if county=="MC CRACKEN" & state=="KY"
replace county="EAST BATON ROUGE" if county=="E. BATON ROUGE" & state=="LA"
replace county="JEFFERSON DAVIS" if county=="JEFFRSON DAVIS" & state=="LA"
replace county="SAINT BERNARD" if county=="ST. BERNARD" & state=="LA"
replace county="SAINT CHARLES" if county=="ST. CHARLES" & state=="LA"
replace county="SAINT HELENA" if county=="ST. HELENA" & state=="LA"
replace county="SAINT JAMES" if county=="ST. JAMES" & state=="LA"
replace county="SAINT LANDRY" if county=="ST. LANDRY" & state=="LA"
replace county="SAINT MARTIN" if county=="ST. MARTIN" & state=="LA"
replace county="SAINT MARY" if county=="ST. MARY" & state=="LA"
replace county="SAINT TAMMANY" if county=="ST. TAMMANY" & state=="LA"
replace county="ST JOHN THE BAPTIST" if county=="ST. JOHN BAPTIST" & state=="LA"
replace county="SAINT MARYS" if county=="ST. MARYS" & state=="MD"
replace county="SAINT JOSEPH" if county=="ST. JOSEPH" & state=="MI"
replace county="SAINT CLAIR" if county=="ST. CLAIR" & state=="MI"
replace county="LAKE OF THE WOODS" if county=="LAKE OF  WOODS" & state=="MN"
replace county="MCLEOD" if county=="MC LEOD" & state=="MN"
replace county="SAINT LOUIS" if county=="ST. LOUIS" & state=="MN"
replace county="YELLOW MEDICINE" if county=="YELLOW MEDCINE" & state=="MN"
replace county="SAINT CHARLES" if county=="ST. CHARLES" & state=="MO"
replace county="SAINT CLAIR" if county=="ST. CLAIR" & state=="MO"
replace county="SAINT FRANCOIS" if county=="ST. FRANCOIS" & state=="MO"
replace county="SAINT LOUIS" if county=="ST. LOUIS" & state=="MO"
replace county="SAINT LOUIS CITY" if county=="ST. LOUIS CITY" & state=="MO"
replace county="SAINTE GENEVIEVE" if county=="STE. GENEVIEVE" & state=="MO"
replace county="DESOTO" if county=="DE SOTO" & state=="MS"
replace county="MCDOWELL" if county=="MC DOWELL" & state=="NC"
replace county="SCOTTS BLUFF" if county=="SCOTT BLUFF" & state=="NE"
replace county="SAINT LAWRENCE" if county=="ST. LAWRENCE" & state=="NY"
replace county="MCKEAN" if county=="MC KEAN" & state=="PA"
replace county="NORTHUMBERLAND" if county=="NORTHUMBERLND" & state=="PA"
replace county="MCPHERSON" if county=="MC PHERSON" & state=="SD"
replace county="DEKALB" if county=="DE KALB" & state=="TN"
replace county="MCMINN" if county=="MC MINN" & state=="TN"
replace county="MCNAIRY" if county=="MC NAIRY" & state=="TN"
replace county="MCLENNAN" if county=="MC LENNAN" & state=="TX"
replace county="SALEM" if county=="SALEM CITY" & state=="VA"
replace county="SAINT CROIX" if county=="ST. CROIX" & state=="WI"
replace county="MCDOWELL" if county=="MC DOWELL" & state=="WV"

save ../_prepared/crosswalk, replace 


 
 
