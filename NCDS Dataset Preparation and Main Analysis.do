***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************
set maxvar 10000

**********************NCDS Dataset Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "NCDS\Data Files\ncds_2008_followup.dta", clear

//Rename ID and Sex, Create Age, and Add Ethnicity//

rename NCDSID ncdsid
replace ND8SEX = . if ND8SEX <0
rename ND8SEX sex
gen monthstotal = ( N8INTYR*12) + N8INTMON
gen monthsdob = (1958*12)+3
gen age = monthstotal - monthsdob
merge 1:1 ncdsid using "NCDS\Data Files\ncds6.dta", keepusing(ethnic)
replace ethnic = . if ethnic > 97
recode ethnic (1/3 = 1) (4/16 = 2)
label define ethnic 1 "White" 2 "Non-White", modify
label values ethnic ethnic
drop if _merge == 2
drop _merge


 ******************************CHILDHOOD VARIABLES*************************************

//Birthweight//

merge 1:1 ncdsid using "NCDS\Data Files\ncds0123.dta", keepusing(n646)
replace n646 = . if n646 < 0
replace n646 = . if n646 > 500 & n646< . 
gen birthweight = n646 * 28.35			//convert from oz to g//
drop if _merge == 2		//to remove variables added to dataset that have no age 46 values//
drop _merge

//Parent's BMI//

merge 1:1 ncdsid using "NCDS\Data Files\ncds0123.dta", keepusing(n1196 n1199 n1202 n1205)
replace n1196 = . if n1196 < 0
replace n1199 = . if n1199 < 0
replace n1202 = . if n1202 < 0
replace n1205 = . if n1205 < 0

gen father_height = (n1199 * 2.54)/100
recode n1196 (13 = 6.5) (14 = 7) (15 = 7.5) (16 = 8) (17 = 8.5) (18 = 9) (19 = 9.5) (20 = 10) (21 = 10.5) (22 = 11) (23 = 11.5) (24 = 12) (25 = 12.5) (26 = 13) (27 = 13.5) (28 = 14) (29 = 14.5) (30 = 15) (31 = 15.5) (32 = 16) (33 = 16.5) (34 = 17) (35 = 17.5) (36 = 18) (37 = 18.5) (38 = 19) (39 = 19.5)
gen father_weight = n1196 * 6.35
gen father_bmi = father_weight/(father_height^2)

gen mother_height = (n1205 * 2.54)/100
recode n1202 (13 = 6.5) (14 = 7) (15 = 7.5) (16 = 8) (17 = 8.5) (18 = 9) (19 = 9.5) (20 = 10) (21 = 10.5) (22 = 11) (23 = 11.5) (24 = 12) (25 = 12.5) (26 = 13) (27 = 13.5) (28 = 14) (29 = 14.5) (30 = 15) (31 = 15.5) (32 = 16) (33 = 16.5) (34 = 17) (35 = 17.5) (36 = 18) (37 = 18.5) (38 = 19)
gen mother_weight = n1202 * 6.35
gen mother_bmi = mother_weight/(mother_height^2)
drop if _merge == 2
drop _merge father_height father_weight mother_height mother_weight 

//Childhood SES//

merge 1:1 ncdsid using "NCDS\Data Files\ncds0123.dta", keepusing(n2384)
replace n2384 = . if n2384 < 1
replace n2384 = . if n2384 == 8
rename n2384 ses_10
recode ses_10 (7 = 10) (5/6 = 11) (4 = 12) (3 = 13) (2 = 14) (1 = 15) 
label define ses_10 10 "V unskilled" 11 "IV partly-skilled" 12 "III manual" 13 "III non manual" 14 "II managerial and Technical" 15 "I professional", modify
label values ses_10 ses_10
drop if _merge == 2 
drop _merge 

//Childhood Overcrowding//

merge 1:1 ncdsid using "NCDS\Data Files\ncds0123.dta", keepusing(n607)
replace n607 = . if n607 < 0
rename n607 crowd_10
drop if _merge == 2
drop _merge

//Age 10 Cognition//

merge 1:1 ncdsid using "NCDS\Data Files\Childhood Cognition.dta", keepusing(harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10 cog_g_10)	//created using separate do file called Preparing Childhood Cognitive Scores//
drop if _merge == 2
drop _merge

//Highest Education- taken from age 33 - check splits for both this and BCS//

merge 1:1 ncdsid using "NCDS\Data Files\ncds5cmi.dta", keepusing(hqual33)
replace hqual33 = . if hqual33 < 0
rename hqual33 education
recode education (0 = 1) (1 = 2) (2/3 = 3) (4 = 4) (5 = 5)
label define education 1 "No education" 2 "Below ordinary secondary qualifications" 3 "Ordinary Secondary Qualifications" 4 "Advanced Level Qualifications" 5 "Postgraduate or Above", modify
label values education education
drop if _merge == 2
drop _merge

******************************BMI AT ALL TIMEPOINTS*************************************

//Age 11 BMI//

merge 1:1 ncdsid using "NCDS\Data Files\ncds0123.dta", keepusing(dvht11 dvwt11 dvht16 dvwt16)
replace dvht11 = . if dvht11 < 1
replace dvwt11 = . if dvwt11 < 1
gen bmi_10 = dvwt11/(dvht11^2)
drop if _merge == 2
drop _merge

//Age 16 BMI//

replace dvht16 = . if dvht16 < 1
replace dvwt16 = . if dvwt16 < 1
gen bmi_16 = dvwt16/(dvht16^2)

//Age 23 BMI//

merge 1:1 ncdsid using "NCDS\Data Files\ncds4.dta", keepusing(dvht23 dvwt23)
replace dvht23 = . if dvht23 < 0
replace dvwt23 = . if dvwt23 < 0
gen bmi_23 = dvwt23/(dvht23^2)
drop if _merge == 2
drop _merge

//Age 33 BMI//

merge 1:1 ncdsid using "NCDS\Data Files\ncds5cmi.dta", keepusing(n504731 n504734)
replace n504731 = . if n504731 < 0
replace n504731 = . if n504731 > 202			//remove impossible values//
replace n504731 = . if n504731 == 0
zscore n504731
replace n504731 = . if z_n504731 < -3
zscore n504734
replace n504734 = . if n504734 <= 0
replace n504734 = . if z_n504734 > 3			//some impossible values for weight so remove anything > 3SDs from mean//
gen bmi_33 = n504734/((n504731/100)^2)
replace bmi_33 = . if bmi_33 < 15				//above this point the 23 and 33 BMIs correspond well, but below there is big mismatch suggesting problems with data entry at 23 when looking at numbers at low end of spectrum//
drop if _merge == 2
drop _merge

//Age 42 BMI//

merge 1:1 ncdsid using "NCDS\Data Files\ncds6.dta", keepusing(wtkilos2 wtstone2 wtpound2 htmetre2 htcms2 htfeet2 htinche2)
replace wtstone2 = . if wtstone2 >= 98
replace wtpound2 = . if wtpound2 >= 98
replace htfeet2 = . if htfeet2 >= 98
replace htinche2 = . if htinche2 >=98
gen height = ((htfeet2*12)+htinche2) * 0.0254	//to convert first to inches then meters//
gen height2 = ((htmetre2*100)+htcms2)/100		//to convert limited numbers of heights given in metric and then add to total//
replace height = height2 if height == .
gen weight = ((wtstone2*14)+wtpound2) * 0.4536	//to convert first to lbs then to kg//
replace weight = wtkilos2 if weight == .
gen bmi_42 = weight/(height^2)
drop if _merge == 2
drop _merge 

//Age 50 BMI//									//called bmi_46 to align with BCS do file//

replace N8WTSTE2 = . if N8WTSTE2 < 0
replace N8WTPOD2 = . if N8WTPOD2 < 0
gen weight_46 = (N8WTPOD2+(N8WTSTE2*14))/2.2		//lbs to kgs//
replace N8WTKIS2 = . if N8WTKIS2 < 0
replace weight_46 = N8WTKIS2 if weight_46 == .

merge 1:1 ncdsid using "NCDS\Data Files\ncds42-4_biomedical_eul.dta", keepusing(htres)
replace htres = . if htres < 0
gen height_46 = htres/100							//cm to m//
gen bmi_46 = weight_46/(height_46^2)				//name 46 to match BCS code//
drop if _merge == 2
drop _merge

//z-score all timpoints//

zscore bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 father_bmi mother_bmi birthweight

******************************MIDLIFE EXPOSURES*************************************

//Prepare any midlife variables that may be relevant either as exposures or covariates//

//Sleep//

replace N8SCQ13 = . if N8SCQ13 <0
rename N8SCQ13 sleep_46

//Smoking//

replace N8SMOKIG = . if N8SMOKIG <0
rename N8SMOKIG smoke_46

//Physical Activity //

merge 1:1 ncdsid using "NCDS\Data Files\ncds6.dta", keepusing(breathls)
replace breathls = . if breathls == 9
rename breathls pa_46
recode pa_46 (2 = 1) (3 = 2) (4 = 2) (5 = 3) (6 = 3)
recode pa_46 (3=0) (2=1) (1=2)		//switch to increasing order of PA rather than decreasing//
label define pa_46 0 "Lowest" 1 "Intermediate" 2 "Highest", modify
label values pa_46 pa_46
drop if _merge == 2
drop _merge	

//SES 46//

merge 1:1 ncdsid using "NCDS\Data Files\ncds6.dta", keepusing(sc)
replace sc = . if sc == 6
rename sc ses_46
recode ses_46 (3.1 = 3) (3.2 = 4) (4 = 5) (5 =6)
drop _merge

//Wellbeing 46//

replace ND8WEMWB= . if ND8WEMWB<0
rename ND8WEMWB wellbeing_46

//Malaise 46//

replace ND8MAL = . if ND8MAL < 0
rename ND8MAL malaise_46

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

replace N8CFANI = . if N8CFANI <0
rename N8CFANI cog_an_46 
replace N8CFLISN = . if N8CFLISN <0
rename N8CFLISN cog_ir_46 
replace N8CFLISD = . if N8CFLISD <0
rename N8CFLISD cog_dr_46
replace N8CFCOR = . if N8CFCOR <0
rename N8CFCOR cog_lc_46
replace N8CFMIS = . if N8CFMIS <0
rename N8CFMIS cog_lm_46
replace N8CFRC = . if N8CFRC <0
rename N8CFRC cog_ls_46

sum cog_an_46 cog_ir_46 cog_dr_46 cog_lc_46 cog_lm_46 cog_ls_46

//Create overall g score from individual tests - have used 4 variables mentioned in harmonisation paper//

pwcorr cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
pca cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
//screeplot//
predict cog_g_46, score

******************************CUMULATIVE EXPOSURES*************************************

//BMI Cumulative Metrics from Tom//

merge 1:1 ncdsid using "Cumulative Metrics\Data Files\NCDS Combined Derived Cumulative Variables.dta"			//data from Tom but with males and females precombined into one dataset//
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
replace auc25 = auc25_ncds_males if sex == 1 
replace auc25 = auc25_ncds_females if sex == 2
gen auc30 = .
replace auc30 = auc30_ncds_males if sex == 1
replace auc30 = auc30_ncds_females if sex == 2

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

save "NCDS\Data Files\NCDS_Pre_MI_Dataset.dta", replace

********************************PERFORM MI*****************************************

mi set wide
mi register regular sex age
mi register imputed z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi ses_46 pa_46 sleep_46 smoke_46 cog_g_10 ses_10 education z_birthweight malaise_cat_46 crowd_10
mi impute chained (regress) z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi cog_g_10 z_birthweight sleep_46 (ologit) ses_10 crowd_10 education smoke_46 malaise_cat_46 pa_46 ses_46 = sex cog_g_46, add(50) rseed(54321) dots


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

save "NCDS\Data Files\Merged NCDS Dataset_NewModels.dta", replace


 