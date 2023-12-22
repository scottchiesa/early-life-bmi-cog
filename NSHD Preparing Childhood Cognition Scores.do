***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************


**********************NCDS Childhood Cognition Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "NSHD\Data Files\NSHD Dataset.dta", clear

//GC1 - Verbal Ability (NFER)//

rename v1157 gc1_10
replace gc1_10 = . if gc1_10 < 0
gen harm_gc1_10 = gc1_10 * (50/40)

//GF - Non-Verbal Ability (NFER)//

rename nv1157 gf_10
replace gf_10 = . if gf_10 < 0
gen harm_gf_10 = gf_10 * (50/40)

//GQ - Mathematics Test//

rename a1157 harm_gq_10
replace harm_gq_10 = . if harm_gq_10 < 0

//GC2 - Reading Comprehension (NFER)//

rename voc1157 harm_gc2_10
replace harm_gc2_10 = . if harm_gc2_10 < 0

//Create latent g factor//

pwcorr harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
pca harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
screeplot
predict cog_g_10, score

save "NSHD\Data Files\Childhood Cognition.dta", replace
