***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************

set maxvar 10000

**********************BCS Dataset Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "BCS70\Data Files\bcs_age46_main.dta", clear

//Rename Age and Sex, Create Age and add Ethnicity//

replace BD10AGEINT = . if BD10AGEINT <0
rename BD10AGEINT midlife_age
replace B10CMSEX = . if B10CMSEX <0
rename B10CMSEX sex
rename BCSID bcsid
rename midlife_age age
merge 1:1 bcsid using "BCS70\Data Files\bcs2000.dta", keepusing(ethnic)
replace ethnic = . if ethnic > 97
recode ethnic (1/3 = 1) (4/16 = 2)
label define ethnic 1 "White" 2 "Non-White", modify
label values ethnic ethnic
rename bcsid BCSID
drop if _merge == 2
drop _merge

******************************CHILDHOOD VARIABLES*************************************

//Birthweight//

merge 1:1 BCSID using "BCS70\Data Files\bcs70_1975_developmental_history.dta", keepusing(VAR5542)
replace VAR5542 = . if VAR5542 < 0
rename VAR5542 birthweight
drop if _merge == 2		//to remove variables added to dataset that have no age 46 values//
drop _merge

//Parents BMI//

merge 1:1 BCSID using "BCS70\Data Files\sn3723.dta", keepusing(e1_1 e1_2 e2_1 e2_2)
replace e1_1 = . if e1_1 < 0
replace e1_2 = . if e1_2 < 0
replace e2_1 = . if e2_1 < 0
replace e2_2 = . if e2_2 < 0

gen father_bmi = e2_2/((e2_1/100)^2)
gen mother_bmi = e1_2/((e1_1/100)^2)
drop if _merge == 2
drop _merge 

//Childhood SES//

merge 1:1 BCSID using "BCS70\Data Files\bcs2derived.dta", keepusing(BD2SOC)
replace BD2SOC = . if BD2SOC < 1
rename BD2SOC ses_10
drop if _merge == 2 
drop _merge

//Childhood Overcrowding//

rename BCSID bcsid
merge 1:1 bcsid using "BCS70\Data Files\f699b.dta", keepusing(e228b)
replace e228b = . if e228b < 0
gen crowd_10 = .
replace crowd_10 = 1 if e228b <=1
replace crowd_10 = 2 if e228b > 1 & e228b <= 1.5
replace crowd_10 = 3 if e228b > 1.5 & e228b <= 2
replace crowd_10 = 4 if e228b > 2 & e228b < .
drop if _merge == 2
drop _merge
rename bcsid BCSID

//Age 10 Cognition//

merge 1:1 BCSID using "BCS70\Data Files\Childhood Cognition.dta", keepusing(harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10 cog_g_10)	//created using do file called Preparing Childhood Cognitive Scores//
drop if _merge == 2
drop _merge

//Highest Education//

merge 1:1 BCSID using "BCS70\Data Files\bcs6derived.dta", keepusing(HIACA00)
drop if _merge == 2
drop _merge

replace HIACA00 = . if HIACA00 < 0
rename HIACA00 education
recode education (0 = 10) (1/2 = 11) (3/5 = 12) (6 = 13) (7/8 = 14)
label define education 10 "No education" 11 "Below Ordinary Secondary Education" 12 "Ordinary Secondary Qualifications" 13 "Advanced Level Qualifications" 14 "Postgraduate or Above", modify
label values education education

****************************BMI AT ALL TIMEPOINTS*********************************

//Age 10 BMI//

merge 1:1 BCSID using "BCS70\Data Files\sn3723.dta", keepusing(meb17 meb19_1)
replace meb17 = . if meb17 < 0
replace meb19_1 = . if meb19_1 < 0
gen height = meb17/1000
gen weight = meb19_1/10
gen bmi_10 = weight/(height^2)
drop if _merge == 2
drop _merge height weight

//Age 16 BMI//

rename BCSID bcsid
merge 1:1 bcsid using "BCS70\Data Files\bcs7016x.dta", keepusing(rd2_1 rd4_1)
replace rd4_1 = . if rd4_1 <0
rename rd4_1 weight
replace rd2_1 = . if rd2_1 <0
rename rd2_1 height
gen bmi_16 = weight/(height^2)
drop if _merge == 2 
drop _merge height weight

//Age 26 BMI//

merge 1:1 bcsid using "BCS70\Data Files\bcs96x.dta", keepusing(b960439 b960441 b960443 b960433 b960434 b960436 b960437)
replace b960439 = . if b960439 < 0
replace b960441 = . if b960441 < 0
replace b960433 = . if b960433 < 0
replace b960434 = . if b960434 < 0
replace b960436 = . if b960436 < 0
replace b960437 = . if b960437 < 0
gen height = ((b960433*12)+b960434) * 0.0254	//to convert first to inches then meters//
gen height2 = ((b960436*100)+b960437)/100		//to convert limited numbers of heights given in metric and then add to total//
replace height = height2 if height == .
gen weight = ((b960439*14)+b960441) * 0.4536	//to conver first to lbs then to kg//
replace weight = b960443 if weight == .
gen bmi_23 = weight/(height^2)					//name 23 to match NCDS code//
drop if _merge == 2
drop _merge height height2 weight

//Age 30 BMI//

merge 1:1 bcsid using "BCS70\Data Files\bcs2000.dta", keepusing(wtkilos2 wtstone2 wtpound2 htmetre2 htcms2 htfeet2 htinche2)
replace wtstone2 = . if wtstone2 >= 98
replace wtpound2 = . if wtpound2 >= 98
replace htfeet2 = . if htfeet2 >= 98
replace htinche2 = . if htinche2 >=98
gen height = ((htfeet2*12)+htinche2) * 0.0254	//to convert first to inches then meters//
gen height2 = ((htmetre2*100)+htcms2)/100		//to convert limited numbers of heights given in metric and then add to total//
replace height = height2 if height == .
gen weight = ((wtstone2*14)+wtpound2) * 0.4536	//to conver first to lbs then to kg//
replace weight = wtkilos2 if weight == .
gen bmi_30 = weight/(height^2)
drop if _merge == 2
drop _merge weight

//Age 34 BMI//

merge 1:1 bcsid using "BCS70\Data Files\bcs_2004_followup.dta", keepusing(bd7bmi)
replace bd7bmi = . if bd7bmi < 0
rename bd7bmi bmi_33							//name 33 to match NCDS code//
drop if _merge == 2
drop _merge

//Age 42 BMI//

rename bcsid BCSID
merge 1:1 BCSID using "BCS70\Data Files\bcs70_2012_flatfile.dta", keepusing(B9HTMEES B9HTCMS B9HTFEET B9HTINES B9WTKIS B9WTSTE B9WTPOD)
replace B9HTMEES = . if B9HTMEES < 0
replace B9HTCMS = . if B9HTCMS < 0
replace B9HTFEET = . if B9HTFEET < 0
replace B9HTINES = . if B9HTINES < 0
replace B9WTKIS = . if B9WTKIS < 0
replace B9WTSTE = . if B9WTSTE < 0
replace B9WTPOD = . if B9WTPOD < 0
replace height = height2 if height == .			//use height from previous wave as not many heights measured here//
gen weight = ((B9WTSTE*14)+B9WTPOD) * 0.4536	//to convert first to lbs then to kg//
replace weight = B9WTKIS if weight == .
gen bmi_42 = weight/(height^2)
drop if _merge == 2
drop _merge height height2 weight

//Age 46 BMI//

replace BD10MBMI = . if BD10MBMI <0
rename BD10MBMI bmi_46

//z-score all timpoints//

zscore bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 father_bmi mother_bmi birthweight

******************************MIDLIFE EXPOSURES*************************************

//Prepare any midlife variables that may be relevant either as exposures or covariates//

//Blood Pressure//

replace B10BPSYSR2 = . if B10BPSYSR2 <0
replace B10BPSYSR3 = . if B10BPSYSR3 <0
gen sbp_46 = (B10BPSYSR2+B10BPSYSR3)/2

replace B10BPDIAR2 = . if B10BPDIAR2 <0
replace B10BPDIAR3 = . if B10BPDIAR3 <0
gen dbp_46 = (B10BPDIAR2+B10BPDIAR3)/2

//Blood markers//

replace B10CHOL = . if B10CHOL <0
gen chol_46 = B10CHOL * 38.67	//convert mmol/l to mg/dl//
replace B10HDL = . if B10HDL <0
gen hdl_46 = B10HDL * 38.67
gen non_hdl_46 = chol_46 - hdl_46
replace B10HBA1C = . if B10HBA1C <0
gen hba1c_46 = (0.0915*B10HBA1C)+2.15	//convert % to mmol/mol//

//Sleep//

replace B10HSLEEP = . if B10HSLEEP <0
rename B10HSLEEP sleep_46

//Smoking//

replace B10SMOKIG = . if B10SMOKIG <0
rename B10SMOKIG smoke_46

//Physical Activity//

merge 1:1 BCSID using "BCS70\Data Files\bcs70_2012_flatfile.dta", keepusing(B9EXERS)
replace B9EXERS = . if B9EXERS < 0
rename B9EXERS pa_46
recode pa_46 (1 = 0) (2 = 1) (3 = 1) (4 = 1) (5 = 2) (6 = 2) (7 = 2)
label define pa_46 0 "Lowest" 1 "Intermediate" 2 "Highest", modify 
drop if _merge == 2
drop _merge		

//SES 46//

merge 1:1 BCSID using "BCS70\Data Files\bcs70_2012_flatfile.dta", keepusing(B9CSC)
replace B9CSC= . if B9CSC < 0
recode B9CSC (3.1 = 3) (3.2 = 4) (4 = 5) (5 = 6)
rename B9CSC ses_46
drop _merge

//Wellbeing 46//

replace BD10WEMWB= . if BD10WEMWB<0
rename BD10WEMWB wellbeing_46

//Malaise 46//

replace BD10MAL = . if BD10MAL < 0
rename BD10MAL malaise_46

gen malaise_cat_46 = .
replace malaise_cat_46 = 10 if malaise_46 == 0
replace malaise_cat_46 = 11 if malaise_46 == 1
replace malaise_cat_46 = 11 if malaise_46 == 2
replace malaise_cat_46 = 12 if malaise_46 == 3
replace malaise_cat_46 = 12 if malaise_46 == 4
replace malaise_cat_46 = 13 if malaise_46 == 5
replace malaise_cat_46 = 13 if malaise_46 == 6
replace malaise_cat_46 = 14 if malaise_46 == 7
replace malaise_cat_46 = 14 if malaise_46 == 8
replace malaise_cat_46 = 14 if malaise_46 == 9

******************************MIDLIFE OUTCOMES*************************************

//Prepare cognitive outcomes at 46//

replace B10CFANI = . if B10CFANI <0
rename B10CFANI cog_an_46 
replace B10CFLISN = . if B10CFLISN <0
rename B10CFLISN cog_ir_46 
replace B10CFLISD = . if B10CFLISD <0
rename B10CFLISD cog_dr_46
replace B10CFCOR = . if B10CFCOR <0
rename B10CFCOR cog_lc_46
replace B10CFMIS = . if B10CFMIS <0
rename B10CFMIS cog_lm_46
replace B10CFRC = . if B10CFRC <0
rename B10CFRC cog_ls_46

sum cog_an_46 cog_ir_46 cog_dr_46 cog_lc_46 cog_lm_46 cog_ls_46

//Create overall g score from individual tests - only use 4 variables mentioned in harmonisation paper//

pwcorr cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
pca cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
//screeplot//
predict cog_g_46, score

******************************CUMULATIVE EXPOSURES*************************************

//BMI Cumulative Metrics from Tom//
rename BCSID bcsid
merge 1:1 bcsid using "Cumulative Metrics\Data Files\BCS Combined Derived Cumulative Variables.dta"				//data from Tom but with males and females precombined into one dataset//
drop if _merge == 2
drop _merge	

//classify never been overweight as 0 rather than missing//

replace tot_duration_over_ob = 0 if num_times_over_obese == 0 & overweight_all_way !=1

//generate ever overweight variable//

gen ever_over = 1 if tot_duration_over_ob > 0 & tot_duration_over_ob < .
replace ever_over = 0 if tot_duration_over_ob == 0
tab ever_over

//classify never been obese as 0 rather than missing//

replace tot_duration_obese = 0 if num_times_obese == 0 & obese_all_way !=1

//generate ever obese variable//

gen ever_obese = 1 if tot_duration_obese > 0 & tot_duration_obese < .
replace ever_obese = 0 if tot_duration_obese == 0
tab ever_obese

//generate AUC risk for time spent overweight or obese//

gen auc25 = .
replace auc25 = auc25_bcs_male if sex == 1 
replace auc25 = auc25_bcs_female if sex == 2
gen auc30 = .
replace auc30 = auc30_bcs_male if sex == 1
replace auc30 = auc30_bcs_female if sex == 2

sum auc25
sum auc30
sum auc25 if ever_over == 1
sum auc30 if ever_obese == 1

replace auc25 = 0 if num_times_over_obese == 0 & overweight_all_way != 1
replace auc30 = 0 if num_times_obese == 0 & obese_all_way != 1

tab1 auc25 auc30

//generate categories of overweight duration//

gen ovdur5 = .
replace ovdur5 = 0 if ever_over == 0
replace ovdur5 = 1 if tot_duration_over_ob < 5 & ever_over ==1
replace ovdur5 = 2 if tot_duration_over_ob >= 5 & tot_duration_over_ob <10
replace ovdur5 = 3 if tot_duration_over_ob >= 10 & tot_duration_over_ob <15
replace ovdur5 = 4 if tot_duration_over_ob >= 15 & tot_duration_over_ob <20
replace ovdur5 = 5 if tot_duration_over_ob >= 20 & tot_duration_over_ob <=30

//generate categories of obesity duration//

gen obdur5 = .
replace obdur5 = 0 if ever_obese == 0
replace obdur5 = 1 if tot_duration_obese < 5 & ever_obese ==1
replace obdur5 = 2 if tot_duration_obese >= 5 & tot_duration_obese <10
replace obdur5 = 3 if tot_duration_obese >= 10 & tot_duration_obese <15
replace obdur5 = 4 if tot_duration_obese >= 15 & tot_duration_obese <20
replace obdur5 = 5 if tot_duration_obese >= 20 & tot_duration_obese <=30

tab1 ovdur5 obdur5

save "BCS70\Data Files\BCS70_Pre_MI_Dataset.dta", replace

********************************PERFORM MI*****************************************

mi set wide
mi register regular sex age	
mi register imputed z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi malaise_cat_46 ses_46 pa_46 sleep_46 smoke_46 cog_g_10 ses_10 crowd_10 education z_birthweight 
mi impute chained (regress) z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi cog_g_10 z_birthweight pa_46 sleep_46 (ologit) ses_10 crowd_10 education malaise_cat_46 ses_46 smoke_46 = sex cog_g_46, add(50) rseed(54321) dots


******************************PARTICIPANT CHARACTERISTICS*********************************************************

sum mother_bmi father_bmi birthweight harm_gc1_10 harm_gc2_10 harm_gf_10 harm_gq_10 bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 age_first_over_ob auc25 tot_duration_over_ob cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46 bmi_46, det
tab1 sex ses_10 education ses_46 pa_46 smoke_46 ever_over crowd_10

******************************INDIVIDUAL TIMEPOINT REGRESSIONS CONTINUOUS BMI*************************************

mi estimate: regress cog_g_46 z_bmi_10 age i.sex
mi estimate: regress cog_g_46 z_bmi_10 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_10 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_16 age i.sex
mi estimate: regress cog_g_46 z_bmi_16 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_16 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_23 age i.sex
mi estimate: regress cog_g_46 z_bmi_23 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_23 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_33 age i.sex
mi estimate: regress cog_g_46 z_bmi_33 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_33 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_42 age i.sex
mi estimate: regress cog_g_46 z_bmi_42 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_42 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_46 age i.sex
mi estimate: regress cog_g_46 z_bmi_46 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_46 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

*************************SAME BUT WITH EACH BMI CONDITIONED ON PREVIOUS TO INDICATE CHANGE*********************************

mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 age i.sex
mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 age i.sex
mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10

mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 age i.sex
mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 

mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 age i.sex
mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 

mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 age i.sex
mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 age i.sex cog_g_10
mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 

******************************LIFE-COURSE BURDEN REGRESSIONS*************************************

//Ever O/O vs never O/O//

mi estimate: regress cog_g_46 i.ever_over age i.sex if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ever_over age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ever_over age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Age when first O/O//

mi estimate: regress cog_g_46 age_first_over_obese age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 age_first_over_obese i.sex cog_g_10 if tot_duration_over_ob <.		
mi estimate: regress cog_g_46 age_first_over_obese age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Categories of age first O/O vs never O/O//

gen agefirstq = .
replace agefirstq = 1 if age_first_over_ob > 23 & age_first_over_ob <= 40
replace agefirstq = 2 if age_first_over_ob <= 23
replace agefirstq = 0 if age_first_over_ob == .   

mi estimate: regress cog_g_46 i.agefirstq age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.agefirstq age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.agefirstq age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Duration of O/O Continuous//

mi estimate: regress cog_g_46 tot_duration_over_ob age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 tot_duration_over_ob age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 tot_duration_over_ob age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Duration of O/O split into ~5 year groups vs never O/O//

mi estimate: regress cog_g_46 i.ovdur5 age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.ovdur5 age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ovdur5 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Cumulative Exposure to O/O Continuous//

zscore auc25
mi estimate: regress cog_g_46 z_auc25 age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 z_auc25 age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 z_auc25 age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

//Cumulative Exposure to O/O split into quintiles vs never O/O

xtile auc25q = auc25 if auc25 > 0, n(5) 
replace auc25q = 0 if auc25q == .
tab auc25q
mi estimate: regress cog_g_46 i.auc25q age i.sex if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.auc25q age i.sex cog_g_10 if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.auc25q age i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 if tot_duration_over_ob <.	 

******************************CHILD IQ vs BMI Trajectories*************************************

mi passive: egen cog_g_10t = cut(cog_g_10), group(3)

mi estimate: regress z_bmi_10 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_16 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_23 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_33 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_42 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_46 i.cog_g_10t age i.sex
mimrgns i.cog_g_10t

mi estimate: regress z_bmi_10 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_16 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_23 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_33 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_42 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_46 i.cog_g_10t age i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 
mimrgns i.cog_g_10t

******************************STRUCTURAL EQUATION MODELS*************************************

sem (C10 -> harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10) (C46 -> cog_ir_46 cog_an_46 cog_ls_46 cog_dr_46) (sex -> C10) (sex -> bmi_10) (sex -> education) (sex -> auc25) (sex -> C46) (sex -> bmi_46) (ses_10 -> bmi_10) (ses_10 -> C10) (ses_10 -> education) (ses_10 -> auc25) (ses_10 -> C46) (ses_10 -> bmi_46) (crowd_10 -> C10) (crowd_10 -> bmi_10) (crowd_10 -> education) (crowd_10 -> auc25) (crowd_10 -> C46) (crowd_10 -> bmi_46) (C10 -> education) (C10 -> auc25) (C10 -> C46) (C10 -> bmi_46) (bmi_10 -> education) (bmi_10 -> auc25) (bmi_10 -> bmi_46) (bmi_10 -> C46) (education -> auc25) (education -> C46) (education -> bmi_46) (auc25 -> C46) (auc25 -> bmi_46), stand method (mlmv) cov(e.C10*e.bmi_10 e.C46*e.bmi_46) 

estat gof, stats(all)

sem, coeflegend

estat stdize: nlcom (total_bmi_cog: _b[education:bmi_10] *_b[C46: education] + _b[auc25: bmi_10] *_b[C46: auc25] + _b[education: bmi_10] *_b[auc25: education] *_b[C46: auc25] + _b[C46: bmi_10]) (indirect_bmi_cog: _b[education:bmi_10] *_b[C46: education] + _b[auc25: bmi_10] *_b[C46: auc25] + _b[education: bmi_10] *_b[auc25: education] *_b[C46: auc25]) (direct_bmi_cog: _b[C46: bmi_10]) (bmi10_edu_c46: _b[education:bmi_10] *_b[C46: education]) (bmi_10_auc_c46: _b[auc25: bmi_10] *_b[C46: auc25]) (bmi_10_edu_auc_c46: _b[education: bmi_10] *_b[auc25: education] *_b[C46: auc25]) (total_cog_bmi: _b[education:C10] *_b[bmi_46: education] + _b[auc25: C10] *_b[bmi_46: auc25] + _b[education: C10] *_b[auc25: education] *_b[bmi_46: auc25] + _b[bmi_46: C10]) (indirect_cog_bmi: _b[education:C10] *_b[bmi_46: education] + _b[auc25: C10] *_b[bmi_46: auc25] + _b[education: C10] *_b[auc25: education] *_b[bmi_46: auc25]) (direct_cog_bmi: _b[bmi_46: C10]) (c10_edu_bmi46: _b[education:C10] *_b[bmi_46: education]) (c10_auc_bmi46: _b[auc25: C10] *_b[bmi_46: auc25]) (c10_edu_auc_bmi46: _b[education: C10] *_b[auc25: education] *_b[bmi_46: auc25]) 

estat teffects, stand

*******************************************************************************************************************************************************************************
**************************************RUN ALL MODELS AGAIN BUT WITH INDIVIDUAL COGNITIVE TESTS USED TO CALCULATE G FACTOR******************************************************
*******************************************************************************************************************************************************************************

*****************************************LOOP CODE TO RUN ALL ANALYSES EXCEPT CHANGE (AS NOT SURE HOW TO INCLUDE HERE)*********************************************************

//Convert cognitive domains to z-scores to standardise outcomes//

zscore cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46

//Two modes for cont and cat exposures//
local cont ""
local cat "i."
//Exposures//
local cont_exp "z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 age_first_over_obese tot_duration_over_ob z_auc25"
local cat_exp "ever_over agefirstq ovdur5 auc25q"
local z_cog_an_46_adj1 "age i.sex"
local z_cog_ir_46_adj1 "age i.sex"
local z_cog_dr_46_adj1 "age i.sex"
local z_cog_ls_46_adj1 "age i.sex"
local z_cog_an_46_adj3 "age i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi"
local z_cog_ir_46_adj3 "age i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi"
local z_cog_dr_46_adj3 "age i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi"
local z_cog_ls_46_adj3 "age i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi"
foreach outcome of varlist (z_cog_an_46 z_cog_ir_46 z_cog_dr_46 z_cog_ls_46){
foreach mode in cont cat {
foreach exp of local `mode'_exp {
local h=3
forval model=1/3 {
di _n "Association between `exp' and `outcome', Model `model'"
regress `outcome' ``mode''`exp' ``outcome'_adj`model'' if `exp'!=9
}
}
}
}

***************************************************************NOW THE CONDITIONED ONES*****************************************************************************************

//Animals//

mi estimate: regress z_cog_an_46 z_bmi_16 z_bmi_10 age i.sex
mi estimate: regress z_cog_an_46 z_bmi_16 z_bmi_10 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi

mi estimate: regress z_cog_an_46 z_bmi_23 z_bmi_16 age i.sex
mi estimate: regress z_cog_an_46 z_bmi_23 z_bmi_16 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_an_46 z_bmi_33 z_bmi_23 age i.sex
mi estimate: regress z_cog_an_46 z_bmi_33 z_bmi_23 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_an_46 z_bmi_42 z_bmi_33 age i.sex
mi estimate: regress z_cog_an_46 z_bmi_42 z_bmi_33 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_an_46 z_bmi_46 z_bmi_42 age i.sex
mi estimate: regress z_cog_an_46 z_bmi_46 z_bmi_42 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

//Immediate Recall//

mi estimate: regress z_cog_ir_46 z_bmi_16 z_bmi_10 age i.sex
mi estimate: regress z_cog_ir_46 z_bmi_16 z_bmi_10 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi

mi estimate: regress z_cog_ir_46 z_bmi_23 z_bmi_16 age i.sex
mi estimate: regress z_cog_ir_46 z_bmi_23 z_bmi_16 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ir_46 z_bmi_33 z_bmi_23 age i.sex
mi estimate: regress z_cog_ir_46 z_bmi_33 z_bmi_23 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ir_46 z_bmi_42 z_bmi_33 age i.sex
mi estimate: regress z_cog_ir_46 z_bmi_42 z_bmi_33 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ir_46 z_bmi_46 z_bmi_42 age i.sex
mi estimate: regress z_cog_ir_46 z_bmi_46 z_bmi_42 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

//Delayed Recall//

mi estimate: regress z_cog_dr_46 z_bmi_16 z_bmi_10 age i.sex
mi estimate: regress z_cog_dr_46 z_bmi_16 z_bmi_10 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi

mi estimate: regress z_cog_dr_46 z_bmi_23 z_bmi_16 age i.sex
mi estimate: regress z_cog_dr_46 z_bmi_23 z_bmi_16 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_dr_46 z_bmi_33 z_bmi_23 age i.sex
mi estimate: regress z_cog_dr_46 z_bmi_33 z_bmi_23 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_dr_46 z_bmi_42 z_bmi_33 age i.sex
mi estimate: regress z_cog_dr_46 z_bmi_42 z_bmi_33 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_dr_46 z_bmi_46 z_bmi_42 age i.sex
mi estimate: regress z_cog_dr_46 z_bmi_46 z_bmi_42 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

//Processing Speed//

mi estimate: regress z_cog_ls_46 z_bmi_16 z_bmi_10 age i.sex
mi estimate: regress z_cog_ls_46 z_bmi_16 z_bmi_10 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi

mi estimate: regress z_cog_ls_46 z_bmi_23 z_bmi_16 age i.sex
mi estimate: regress z_cog_ls_46 z_bmi_23 z_bmi_16 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ls_46 z_bmi_33 z_bmi_23 age i.sex
mi estimate: regress z_cog_ls_46 z_bmi_33 z_bmi_23 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ls_46 z_bmi_42 z_bmi_33 age i.sex
mi estimate: regress z_cog_ls_46 z_bmi_42 z_bmi_33 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

mi estimate: regress z_cog_ls_46 z_bmi_46 z_bmi_42 age i.sex
mi estimate: regress z_cog_ls_46 z_bmi_46 z_bmi_42 age i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi 

save "BCS70\Data Files\Merged BCS70 Dataset_NewModels.dta", replace