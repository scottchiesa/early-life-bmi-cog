***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************


**********************NCDS Childhood Cognition Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "NCDS\Data Files\ncds0123.dta", clear

//GC1 - Verbal Ability (NFER)//

rename n914 gc1_10
replace gc1_10 = . if gc1_10 < 0
gen harm_gc1_10 = gc1_10 * (50/40)

//GF - Non-Verbal Ability (NFER)//

rename n917 gf_10
replace gf_10 = . if gf_10 < 0
gen harm_gf_10 = gf_10 * (50/40)

//GQ - Mathematics Test//

rename n926 gq_10
replace gq_10 = . if gq_10 < 0
gen harm_gq_10 = gq_10 * (50/40)

//GC2 - Reading Comprehension (NFER)//

rename n923 gc2_10
replace gc2_10 = . if gc2_10 < 0
gen harm_gc2_10 = gc2_10 * (50/35)

//Create latent g factor//

pwcorr harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
pca harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
screeplot
predict cog_g_10, score

save "NCDS\Data Files\Childhood Cognition.dta", replace
