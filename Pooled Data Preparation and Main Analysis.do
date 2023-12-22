***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************

set maxvar 10000

log using "Pooled Log"

**********************Pooling and Preparing Data for Analysis***************************
****************************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\Final Do Files for Open Access - In Progress"

use "S:\LHA_rmgpstc\ARUK\BMI-COG\NSHD\Data Files\NSHD_Pre_MI_Dataset.dta", clear
rename NSHD_ID PID
gen cohort = 1
save "S:\LHA_rmgpstc\ARUK\BMI-COG\NSHD\Data Files\NSHD for appending.dta", replace

use "S:\LHA_rmgpstc\ARUK\BMI-COG\NCDS\Data Files\NCDS_Pre_MI_Dataset.dta", clear
rename ncdsid PID
gen cohort = 2
save "S:\LHA_rmgpstc\ARUK\BMI-COG\NCDS\Data Files\NCDS for appending.dta", replace

use "S:\LHA_rmgpstc\ARUK\BMI-COG\BCS70\Data Files\BCS70_Pre_MI_Dataset.dta", clear
rename bcsid PID
gen cohort = 3
save "S:\LHA_rmgpstc\ARUK\BMI-COG\BCS70\Data Files\BCS70 for appending.dta", replace

use "S:\LHA_rmgpstc\ARUK\BMI-COG\NSHD\Data Files\NSHD for appending.dta", clear

keep PID mother_bmi father_bmi birthweight harm_gc1_10 harm_gc2_10 harm_gf_10 harm_gq_10 cog_g_10 bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 age_first_over_ob auc25 tot_duration_over_ob cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46 cog_g_46 bmi_46 sex ses_10 crowd_10 education ses_46 pa_46 smoke_46 malaise_cat_46 ever_over ovdur5 obdur5 cohort 

append using "S:\LHA_rmgpstc\ARUK\BMI-COG\NCDS\Data Files\NCDS for appending.dta", keep(PID mother_bmi father_bmi birthweight harm_gc1_10 harm_gc2_10 harm_gf_10 harm_gq_10 cog_g_10 bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 age_first_over_ob auc25 tot_duration_over_ob cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46 cog_g_46 bmi_46 sex ses_10 crowd_10 education ses_46 pa_46 smoke_46 malaise_cat_46 ever_over ovdur5 obdur5 cohort) force

append using "S:\LHA_rmgpstc\ARUK\BMI-COG\BCS70\Data Files\BCS70 for appending.dta", keep(PID mother_bmi father_bmi birthweight harm_gc1_10 harm_gc2_10 harm_gf_10 harm_gq_10 cog_g_10 bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 age_first_over_ob auc25 tot_duration_over_ob cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46 cog_g_46 bmi_46 sex ses_10 crowd_10 education ses_46 pa_46 smoke_46 malaise_cat_46 ever_over ovdur5 obdur5 cohort) force

zscore bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 father_bmi mother_bmi birthweight

recode ses_10 (1=10) (2=11) (3=12) (4=13) (5=14) (6=15) if cohort == 3
recode education (1=10) (2=11) (3=12) (4=13) (5=14) (6=15) if cohort == 2
recode smoke_46 (10=1) (11=2) (12=3) if cohort == 1
recode smoke_46 (4=3) if cohort == 2
recode smoke_46 (4=3) if cohort == 3

********************************PERFORM MI*****************************************

mi set wide
mi register regular sex	age
mi register imputed z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi ses_46 smoke_46 malaise_cat_46 cog_g_10 ses_10 crowd_10 education z_birthweight pa_46
mi impute chained (regress) z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi cog_g_10 z_birthweight (ologit) ses_10 crowd_10 education ses_46 smoke_46 malaise_cat_46 pa_46 = sex cog_g_46, add(50) rseed(54321) dots


******************************PARTICIPANT CHARACTERISTICS*********************************************************

sum mother_bmi father_bmi birthweight harm_gc1_10 harm_gc2_10 harm_gf_10 harm_gq_10 bmi_10 bmi_16 bmi_23 bmi_33 bmi_42 bmi_46 age_first_over_ob auc25 tot_duration_over_ob cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46 bmi_46, det
tab1 sex ses_10 education ses_46 pa_46 smoke_46 ever_over crowd_10

******************************INDIVIDUAL TIMEPOINT REGRESSIONS CONTINUOUS BMI*************************************

mi estimate: regress cog_g_46 z_bmi_10 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_10 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_10 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_16 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_16 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_16 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_23 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_23 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_23 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_33 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_33 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_33 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_42 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_42 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_42 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_46 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_46 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_46 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

*************************SAME BUT WITH EACH BMI CONDITIONED ON PREVIOUS TO INDICATE CHANGE*********************************

mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_16 z_bmi_10 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_23 z_bmi_16 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_33 z_bmi_23 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_42 z_bmi_33 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 i.sex i.cohort
mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 i.sex cog_g_10 i.cohort
mi estimate: regress cog_g_46 z_bmi_46 z_bmi_42 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort

******************************LIFE-COURSE BURDEN REGRESSIONS*************************************

//Ever O/O vs never O/O//

mi estimate: regress cog_g_46 i.ever_over i.sex i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ever_over i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ever_over i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Age when first O/O//

mi estimate: regress cog_g_46 age_first_over_obese i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 age_first_over_obese i.sex cog_g_10 i.cohort if tot_duration_over_ob <.		
mi estimate: regress cog_g_46 age_first_over_obese i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Categories of age first O/O vs never O/O//

gen agefirstq = .
replace agefirstq = 1 if age_first_over_ob > 23 & age_first_over_ob <= 40
replace agefirstq = 2 if age_first_over_ob <= 23
replace agefirstq = 0 if age_first_over_ob == .   

mi estimate: regress cog_g_46 i.agefirstq i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.agefirstq i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.agefirstq i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Duration of O/O Continuous//

mi estimate: regress cog_g_46 tot_duration_over_ob i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 tot_duration_over_ob i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 tot_duration_over_ob i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Duration of O/O split into ~5 year groups vs never O/O//

mi estimate: regress cog_g_46 i.ovdur5 i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.ovdur5 i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.ovdur5 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Cumulative Exposure to O/O Continuous//

zscore auc25
mi estimate: regress cog_g_46 z_auc25 i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 z_auc25 i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 z_auc25 i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

//Cumulative Exposure to O/O split into quintiles vs never O/O

xtile auc25q = auc25 if auc25 > 0, n(5) 
replace auc25q = 0 if auc25q == .
tab auc25q
mi estimate: regress cog_g_46 i.auc25q i.sex i.cohort if tot_duration_over_ob <.	 
mi estimate: regress cog_g_46 i.auc25q i.sex cog_g_10 i.cohort if tot_duration_over_ob <.
mi estimate: regress cog_g_46 i.auc25q i.sex i.ses_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.crowd_10 i.cohort if tot_duration_over_ob <.	 

******************************CHILD IQ vs BMI Trajectories*************************************

mi passive: egen cog_g_10t = cut(cog_g_10), group(3)

mi estimate: regress z_bmi_10 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_16 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_23 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_33 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_42 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_46 i.cog_g_10t i.sex i.cohort
mimrgns i.cog_g_10t

mi estimate: regress z_bmi_10 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_16 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_23 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_33 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_42 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort 
mimrgns i.cog_g_10t
mi estimate: regress z_bmi_46 i.cog_g_10t i.sex z_father_bmi z_mother_bmi z_birthweight i.ses_10 i.crowd_10 i.cohort
mimrgns i.cog_g_10t

******************************STRUCTURAL EQUATION MODELS*************************************

sem (C10 -> harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10) (C46 -> cog_ir_46 cog_an_46 cog_ls_46 cog_dr_46) (sex -> C10) (sex -> bmi_10) (sex -> education) (sex -> auc25) (sex -> C46) (sex -> bmi_46) (ses_10 -> bmi_10) (ses_10 -> C10) (ses_10 -> education) (ses_10 -> auc25) (ses_10 -> C46) (ses_10 -> bmi_46) (crowd_10 -> C10) (crowd_10 -> bmi_10) (crowd_10 -> education) (crowd_10 -> auc25) (crowd_10 -> C46) (crowd_10 -> bmi_46) (C10 -> education) (C10 -> auc25) (C10 -> C46) (C10 -> bmi_46) (bmi_10 -> education) (bmi_10 -> auc25) (bmi_10 -> bmi_46) (bmi_10 -> C46) (education -> auc25) (education -> C46) (education -> bmi_46) (auc25 -> C46) (auc25 -> bmi_46), stand method (mlmv) cov(e.C10*e.bmi_10 e.C46*e.bmi_46) vce(robust)

estat gof, stats(all)
estat teffects

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
local z_cog_an_46_adj1 "i.sex i.cohort"
local z_cog_ir_46_adj1 "i.sex i.cohort"
local z_cog_dr_46_adj1 "i.sex i.cohort"
local z_cog_ls_46_adj1 "i.sex i.cohort"
local z_cog_an_46_adj3 "i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi i.cohort"
local z_cog_ir_46_adj3 "i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi i.cohort"
local z_cog_dr_46_adj3 "i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi i.cohort"
local z_cog_ls_46_adj3 "i.sex i.ses_10 cog_g_10 i.crowd_10 i.education birthweight father_bmi mother_bmi i.cohort"
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

mi estimate: regress z_cog_an_46 z_bmi_16 z_bmi_10 i.sex i.cohort
mi estimate: regress z_cog_an_46 z_bmi_16 z_bmi_10 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_an_46 z_bmi_23 z_bmi_16 i.sex i.cohort
mi estimate: regress z_cog_an_46 z_bmi_23 z_bmi_16 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_an_46 z_bmi_33 z_bmi_23 i.sex i.cohort
mi estimate: regress z_cog_an_46 z_bmi_33 z_bmi_23 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_an_46 z_bmi_42 z_bmi_33 i.sex i.cohort
mi estimate: regress z_cog_an_46 z_bmi_42 z_bmi_33 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_an_46 z_bmi_46 z_bmi_42 i.sex i.cohort
mi estimate: regress z_cog_an_46 z_bmi_46 z_bmi_42 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

//Immediate Recall//

mi estimate: regress z_cog_ir_46 z_bmi_16 z_bmi_10 i.sex i.cohort
mi estimate: regress z_cog_ir_46 z_bmi_16 z_bmi_10 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_ir_46 z_bmi_23 z_bmi_16 i.sex i.cohort
mi estimate: regress z_cog_ir_46 z_bmi_23 z_bmi_16 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_ir_46 z_bmi_33 z_bmi_23 i.sex i.cohort
mi estimate: regress z_cog_ir_46 z_bmi_33 z_bmi_23 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_ir_46 z_bmi_42 z_bmi_33 i.sex i.cohort
mi estimate: regress z_cog_ir_46 z_bmi_42 z_bmi_33 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_ir_46 z_bmi_46 z_bmi_42 i.sex i.cohort
mi estimate: regress z_cog_ir_46 z_bmi_46 z_bmi_42 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

//Delayed Recall//

mi estimate: regress z_cog_dr_46 z_bmi_16 z_bmi_10 i.sex i.cohort
mi estimate: regress z_cog_dr_46 z_bmi_16 z_bmi_10 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_dr_46 z_bmi_23 z_bmi_16 i.sex i.cohort
mi estimate: regress z_cog_dr_46 z_bmi_23 z_bmi_16 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_dr_46 z_bmi_33 z_bmi_23 i.sex i.cohort
mi estimate: regress z_cog_dr_46 z_bmi_33 z_bmi_23 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_dr_46 z_bmi_42 z_bmi_33 i.sex i.cohort
mi estimate: regress z_cog_dr_46 z_bmi_42 z_bmi_33 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_dr_46 z_bmi_46 z_bmi_42 i.sex i.cohort
mi estimate: regress z_cog_dr_46 z_bmi_46 z_bmi_42 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

//Processing Speed//

mi estimate: regress z_cog_ls_46 z_bmi_16 z_bmi_10 i.sex i.cohort
mi estimate: regress z_cog_ls_46 z_bmi_16 z_bmi_10 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_ls_46 z_bmi_23 z_bmi_16 i.sex i.cohort
mi estimate: regress z_cog_ls_46 z_bmi_23 z_bmi_16 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_ls_46 z_bmi_33 z_bmi_23 i.sex i.cohort
mi estimate: regress z_cog_ls_46 z_bmi_33 z_bmi_23 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

mi estimate: regress z_cog_ls_46 z_bmi_42 z_bmi_33 i.sex i.cohort
mi estimate: regress z_cog_ls_46 z_bmi_42 z_bmi_33 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort

mi estimate: regress z_cog_ls_46 z_bmi_46 z_bmi_42 i.sex i.cohort
mi estimate: regress z_cog_ls_46 z_bmi_46 z_bmi_42 i.sex i.ses_10 i.crowd_10 cog_g_10 i.education z_birthweight z_mother_bmi z_father_bmi i.cohort 

save "BCS70\Data Files\Merged Pooled Dataset_NewModels.dta", replace

log close