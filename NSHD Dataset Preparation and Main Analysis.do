***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************

set maxvar 10000

**********************NSHD Dataset Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "NSHD\Data Files\NSHD Dataset.dta", clear



//Merge couple of variables missed in first data request

merge 1:1 nshdid_ntag1 using "S:\LHA_rmgpstc\ARUK\BMI-COG\NSHD\Data Files\Extra Variables,dta", keepusing(crow52 voc11r57 nv11r57 v11r57 a11r57)
drop _merge

//Rename ID and Sex and, Create Age and Add Ethnicity//

rename nshdid_ntag1 NSHD_ID
replace sex = . if sex <0
replace age99 = . if age99 < 0
rename age99 age

//No ethnicity as they're all white//


 ******************************CHILDHOOD VARIABLES*************************************

//Birthweight//

rename mbwtu birthweight
replace birthweight = . if birthweight < 0
replace birthweight = . if birthweight > 5000 & birthweight< . 

//Parent's BMI//

gen father_height = fht52 * 0.0254
replace father_height = . if father_height <0
gen father_weight = fwt52 * 0.456
replace father_weight = . if father_weight < 0
replace father_weight = . if father_weight > 300	// remove impossible values//
gen father_bmi = father_weight/(father_height^2)

gen mother_height = mht52 * 0.0254
replace mother_height = . if mother_height <1
gen mother_weight = mwt52rec * 0.456
replace mother_weight = . if mother_weight < 0
replace mother_weight = . if mother_weight > 600	//remove impossible values//
gen mother_bmi = mother_weight/(mother_height^2)

//Childhood SES//

replace fsc57t = . if fsc57t < 0
replace fsc57t = . if fsc57t > 8
replace fsc57t = . if fsc57t == 7
recode fsc57t (6 = 10) (8 = 10) (5 = 11) (4 = 12) (3 = 13) (2 = 14) (1 = 15)
rename fsc57t ses_10
label define ses_10 10 "V unskilled" 11 "IV partly-skilled" 12 "III manual" 13 "III non-manual" 14 "II managerial and Technical" 15 "professional"
label values ses_10 ses_10

//Childhood Overcrowding//

replace crow52 = . if crow52 < 0
gen crowd_10 = .
replace crowd_10 = 1 if crow52 == 1 
replace crowd_10 = 1 if crow52 == 2
replace crowd_10 = 2 if crow52 == 3
replace crowd_10 = 3 if crow52 == 4
replace crowd_10 = 4 if crow52 == 5
replace crowd_10 = 4 if crow52 == 6
replace crowd_10 = 4 if crow52 == 7
replace crowd_10 = 4 if crow52 == 8

//Age 10 Cognition//

rename v11r57 gc1_10
replace gc1_10 = . if gc1_10 < 0
gen harm_gc1_10 = gc1_10 * (50/40)			//GC1 - Verbal Ability (NFER)//

rename nv11r57 gf_10
replace gf_10 = . if gf_10 < 0
gen harm_gf_10 = gf_10 * (50/40)			//GF - Non-Verbal Ability (NFER)//

rename a11r57 harm_gq_10
replace harm_gq_10 = . if harm_gq_10 < 0	//GQ - Mathematics Test//

rename voc11r57 harm_gc2_10
replace harm_gc2_10 = . if harm_gc2_10 < 0	//GC2 - Reading Comprehension (NFER)//

pwcorr harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
pca harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
//screeplot//
predict cog_g_10, score						//Create g factor//

//Highest Education- taken from age 26//

replace lhqr = . if lhqr < 0
replace lhqr = . if lhqr > 8
rename lhqr education
recode education (0 = 10) (1/2 = 11) (3/5 = 12) (6 = 13) (7/8 = 14)
label define education 10 "No education" 11 "Below ordinary secondary qualifications" 12 "Ordinary Secondary Qualifications" 13 "Advanced Level Qualifications" 14 "Postgraduate or Above", modify
label values education education

******************************BMI AT ALL TIMEPOINTS*************************************

//Age 11 BMI//

rename bmi57u bmi_10
replace bmi_10 = . if bmi_10 < 0
replace bmi_10 = . if bmi_10 > 200

//Age 15 BMI//

rename bmi61u bmi_16
replace bmi_16 = . if bmi_16 < 0
replace bmi_16 = . if bmi_16 > 200

//Age 23 BMI//

rename bmi66u bmi_23
replace bmi_23 = . if bmi_23 < 0
replace bmi_23 = . if bmi_23 > 200

//Age 26 BMI//

rename bmi72u bmi_26
replace bmi_26 = . if bmi_26 < 0
replace bmi_26 = . if bmi_26 > 200

//Age 33 BMI//

rename bmi82u bmi_33
replace bmi_33 = . if bmi_33 < 0
replace bmi_33 = . if bmi_33 > 200

//Age 42 BMI//

rename bmi89u bmi_42
replace bmi_42 = . if bmi_42 < 0
replace bmi_42 = . if bmi_42 > 200

//Age 50 BMI//									//variable called bmi_46 to align with BCS do file//

rename bmi99u bmi_46
replace bmi_46 = . if bmi_46 < 0
replace bmi_46 = . if bmi_46 > 200

//z-score all timpoints//

zscore bmi_10 bmi_16 bmi_23 bmi_26 bmi_33 bmi_42 bmi_46 father_bmi mother_bmi birthweight

******************************MIDLIFE EXPOSURES*************************************

//Prepare any midlife variables that may be relevant either as exposures or covariates//

//Smoking//

replace cigsta99c = . if cigsta99c <0
replace cigsta99c = . if cigsta99c == 8
rename cigsta99c smoke_46
recode smoke_46 (1 = 12) (2 = 11) (3 = 10)
label define smoke_46 10 "Never" 11 "Ex-smoker" 12 "Current Smoker"
label values smoke_46 smoke_46

//Physical Activity //

replace exer99x = . if exer99x < 0
replace exer99x = . if exer99x > 2
rename exer99x pa_46
label define pa_46 0 "Lowest" 1 "Intermediate" 2 "Highest", modify
label values pa_46 pa_46

//SES 46//

replace sc53u = . if sc53u < 0
replace sc53u = . if sc53u == 888
rename sc53u ses_46

//Malaise//

replace ghq99_sumrec = . if ghq99_sumrec < 0
rename ghq99_sumrec malaise_46
gen malaise_cat_46 = .
replace malaise_cat_46 = 10 if malaise_46 == 0
replace malaise_cat_46 = 11 if malaise_46 == 1
replace malaise_cat_46 = 12 if malaise_46 == 2
replace malaise_cat_46 = 13 if malaise_46 == 3
replace malaise_cat_46 = 14 if malaise_46 == 4


******************************MIDLIFE OUTCOMES*************************************

//Prepare cognitive outcomes at 46//

replace anin = . if anin < 0
replace anin = . if anin == 999
rename anin cog_an_46 
replace wlt199 = . if wlt199 <0
replace wlt199 = . if wlt199 > 12
replace wlt199 = 10 if wlt199 == 11
replace wlt199 = 10 if wlt199 == 12
rename wlt199 cog_ir_46 
replace wlt499 = . if wlt499 <0
replace wlt499 = . if wlt499 > 12
replace wlt499 = 10 if wlt499 == 11
replace wlt499 = 10 if wlt499 == 12
rename wlt499 cog_dr_46 
replace cansp99 = . if cansp99 <0
rename cansp99 cog_ls_46

sum cog_an_46 cog_ir_46 cog_dr_46 cog_ls_46

//Create overall g score from individual tests using 4 variables documented in harmonisation paper//

pwcorr cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
pca cog_an_46 cog_dr_46 cog_ir_46 cog_ls_46
//screeplot//
predict cog_g_46, score

*******************************CUMULATIVE EXPOSURES*************************************

//BMI Cumulative Metrics from Tom//

merge 1:1 NSHD_ID using "Cumulative Metrics\Data Files\NSHD Combined Derived Cumulative Variables.dta"			//data from Tom but with males and females precombined into one dataset using other NSHD .do file//
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
replace auc25 = auc25_nshd_males if sex == 1 
replace auc25 = auc25_nshd_females if sex == 2
gen auc30 = .
replace auc30 = auc30_nshd_males if sex == 1
replace auc30 = auc30_nshd_females if sex == 2

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

save "NSHD\Data Files\NSHD_Pre_MI_Dataset.dta", replace

********************************PERFORM MI*****************************************

mi set wide
mi register regular sex age
mi register imputed z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_26 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi cog_g_10 ses_10 education malaise_cat_46 ses_46 pa_46 crowd_10
mi impute chained (regress) z_bmi_10 z_bmi_16 z_bmi_23 z_bmi_26 z_bmi_33 z_bmi_42 z_bmi_46 z_father_bmi z_mother_bmi cog_g_10 (ologit) ses_10 crowd_10 education malaise_cat_46 pa_46 ses_46 = sex cog_g_46 , add(50) rseed(54321) dots

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

save "NSHD\Data Files\Merged NSHD Dataset_NewModels.dta", replace


 