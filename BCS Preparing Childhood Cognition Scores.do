***************************************************************************
********************BMI and Cognition Analysis***********************
***************************************************************************


**********************BCS Childhood Cognition Preparation***************************
***************************************************************************

cd "S:\LHA_rmgpstc\ARUK\BMI-COG\"
use "BCS70\Data Files\sn3723.dta", clear

//BAS WORD SIMILARITIES//

//Remove missing values//
forvalues i = 4201/4221 {
	replace i`i' = . if i`i' < 0 
}

//Recode so that 0 = incorrect and 1 = correct//
forvalues i = 4201/4221 {
	recode i`i' (1=1 "Correct") (2=0 "Incorrect"), gen(i`i'_dich)
}

//Identify individuals with all missing values so can be removed from final count rather than appearing as 0//
egen mcount_gc1_10 = rowmiss(i4201_dich - i4221_dich)

//Generate Score - matches summary statistics on Closer.ac.uk so is correct//
egen gc1_10 = rowtotal(i4201_dich - i4221_dich)
replace gc1_10 = . if mcount_gc1_10 == 21
gen harm_gc1_10 = gc1_10 * (50/21)

//BAS MATRICES//

//Remove missing values//
forvalues i = 3617/3644 {
	replace i`i' = . if i`i' < 0 
}

//Recode so that 0 = incorrect/no response and 1 = correct//
forvalues i = 3617/3644 {
	recode i`i' (1=1 "Acceptable Response") (2=0 "Unacceptable or No Response") (9=0 "Unacceptable or No Response"), gen(i`i'_dich)
}

//Identify individuals with all missing values so can be removed from final count rather than appearing as 0//
egen mcount_gf_10 = rowmiss(i3617_dich - i3644_dich)

//Generate Score - matches summary statistics on Closer.ac.uk so is correct//
egen gf_10 = rowtotal(i3617_dich - i3644_dich)
replace gf_10 = . if mcount_gf_10 == 28
gen harm_gf_10 = gf_10 * (50/28)

//FRIENDLY MATHS SCORE//

//Remove missing values//
forvalues i = 4001/4072 {
	replace i`i' = . if i`i' < -3 
}

//Recode so that 0 = incorrect/no response and 1 = correct//
forvalues i = 4001/4072 {
	recode i`i' (1=1 "Acceptable Response") (2=0 "Unacceptable or No Response") (-3=0 "Unacceptable or No Response"), gen(i`i'_dich)
}

//Identify individuals with all missing values so can be removed from final count rather than appearing as 0//
egen mcount_gq_10 = rowmiss(i4001_dich - i4072_dich)

//Generate Score - matches summary statistics on Closer.ac.uk so is correct//
egen gq_10 = rowtotal(i4001_dich - i4072_dich)
replace gq_10 = . if gq_10 == 0
replace gq_10 = . if gq_10 == 72
gen harm_gq_10 = gq_10 * (50/72)

//PICTORIAL LANGUAGE COMPREHENSION TEST//

//Remove missing values//
forvalues i = 8/62 {
	replace i`i' = . if i`i' < 0 
}

forvalues i = 66/110 {
	replace i`i' = . if i`i' < 0 
}

//Recode so that 0 = incorrect and 1 = correct//
forvalues i = 8/62 {
	recode i`i' (0=1 "Correct") (1=0 "Incorrect") (2=0 "Incorrect") (3=0 "Incorrect") (4=0 "Incorrect"), gen(i`i'_dich)
}

forvalues i = 66/97 {
	recode i`i' (0=1 "Correct") (1=0 "Incorrect") (2=0 "Incorrect") (3=0 "Incorrect") (4=0 "Incorrect"), gen(i`i'_dich)
}

forvalues i = 98/110 {
	recode i`i' (1=1 "Correct") (2=0 "Incorrect"), gen(i`i'_dich)
}


//Identify individuals with all missing values so can be removed from final count rather than appearing as 0//
egen mcount_gc2_10 = rowmiss(i8_dich - i110_dich)

//Generate Score - matches summary statistics on Closer.ac.uk so is correct//
egen gc2_10 = rowtotal(i8_dich - i110_dich)
replace gc2_10 = . if mcount_gc2_10 == 100
gen harm_gc2_10 = gc2_10 * (50/100)

pca harm_gc1_10 harm_gf_10 harm_gq_10 harm_gc2_10
//screeplot//
predict cog_g_10, score


save "BCS70\Data Files\Childhood Cognition.dta", replace