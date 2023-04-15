**This .do file was created by Austin Henderson austin.m.henderson@wsu.edu austinhenderson47@gmail.com
**to analyze data related to the socioeconomic impacts of COVID in AI/AN Populations as
**part of the CONCERTS study. Please contact Austin with any questions.



clear
use "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\concerts_patient_29aug22.dta"

**Table of Contents
**Section 1: Data work. Creation of new variables, labeling, recoding, etc. 

**Section 2: Descriptive statistics and statistical tests based on simple comparisons

**Section 3: Regression analyses

**Section 4: Mediator analysis

**Section 5: Appendix 


**# Section 1: Data work
	**Generating binary gender identity variable
		gen gender=gender_identity if gender_identity==1
		replace gender=gender_identity if gender_identity==2
		lab define genderlab 1 "Male" 2 "Female"
		lab var gender "Sex"
		lab val gender genderlab
		
		gen female=.
		replace female=0 if gender==1
		replace female=1 if gender==2 
		
		
		
	**Collapsing income variable
		gen incomecategory=.
		replace incomecategory=1 if income==1 | income==2
		replace incomecategory=2 if income==3 | income==4 | income==5 | income==6 
		replace incomecategory=3 if income==7 | income==8 | income==9 | income==10
		replace incomecategory=4 if income==11 | income==12 | income==13 | income==14 | income==15  
		
		lab var incomecategory "Total household income (past 12 months)"
		lab define incomecategorylab 1 "<$15,000" 2 "$15,000-34,999" 3 "$35,000-59,999" 4 ">=$60,000", modify
		lab val incomecategory incomecategorylab
		
	**Generating age brackets
		gen agebracket=.
			replace agebracket=1 if age>=18 & age<30
			replace agebracket=2 if age>=30 & age<40
			replace agebracket=3 if age>=40 & age<50
			replace agebracket=4 if age>=50 & age<60
			replace agebracket=5 if age>=60 & age<70
			replace agebracket=6 if age>=70 & age!=.
			
		lab var agebracket "Age"
		lab define agebracketlab 1 "18-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70+"
		lab val agebracket agebracketlab
		
		gen fiftyfiveage=.
			replace fiftyfiveage=1 if age<55 & age!=.
			replace fiftyfiveage=2 if age>=55 & age!=.
			
	**Losing job is somewhat or very likely
		gen jobsec_laidoff_likely=.
			replace jobsec_laidoff_likely=1 if jobsec_laidoff==1
			replace jobsec_laidoff_likely=1 if jobsec_laidoff==2
			replace jobsec_laidoff_likely=0 if jobsec_laidoff==3

	**Fixing easy/likely question problems
		replace jobsec_newjob=1 if jobsec_newjob==4
		replace jobsec_newjob=2 if jobsec_newjob==5
		replace jobsec_newjob=3 if jobsec_newjob==6
		
		lab define jobsec_newjoblab 1 "Very easy" 2 "Somewhat easy" 3 "Not at all easy" 888 "Not currently working", modify
		lab val jobsec_newjob jobsec_newjoblab
		
	**Labelling group6
		lab var groups6 "Occupational Classification"
		lab define occupationlab 1 "Management, Business, Science, and Arts" 2 "Service" 3 "Sales and Office" 4 "Natural Resources, Construction, and Maintenance Operations" 5 "Production, Transportation, and Material Moving" 6 "Military Specific and Other"
		lab val groups6 occupationlab
		
	**Generatingworktype
		**First, most restricted
		gen primarywork=.
			replace primarywork=1 if work==1 | work==2 | work==3 | work==4 | work==5
			replace primarywork=0 if work==6 | work==7 | work==8 | work==9 | work==10
		
		**Second, unemployed
		gen outofwork=.
			replace outofwork=1 if work==3 | work==4 | work==5
			replace outofwork=0 if work==1 | work==2 | work==6 | work==7 | work==8 | work==9 | work==10
			
		**Third, just temporarily laid off and unemployed and looking for work
		gen temporlooking=.
			replace temporlooking=1 if work==3 | work==4 
			replace temporlooking=0 if work==1 | work==2 | work==5 | work==6 | work==7 | work==8 | work==9 | work==10
	
	**Food insecurity
		gen foodinsnotenough=.
			replace foodinsnotenough=1 if foodins_notenough==1 | foodins_notenough==2
			replace foodinsnotenough=0 if foodins_notenough==0
		
		gen foodinsafford=.
			replace foodinsafford=1 if foodins_afford==1 | foodins_afford==2
			replace foodinsafford=0 if foodins_afford==0
	
		gen foodinsskipfreq=.
			replace foodinsskipfreq=1 if foodins_skip_freq==1 | foodins_skip_freq==2
			replace foodinsskipfreq=0 if foodins_skip_freq==0 | foodins_skip_freq==.
		
		
		gen foodinsecurescore=.
			replace foodinsecurescore = foodinsnotenough + foodinsafford + foodins_eatless + foodins_noteat + foodins_skip + foodinsskipfreq 
 			
		gen foodinsecurebinary=.
			replace foodinsecurebinary=1 if foodinsecurescore >1  &  foodinsecurescore!=.
			replace foodinsecurebinary=0 if foodinsecurescore ==0 |  foodinsecurescore==1
			
		lab define foodinsecurelab 0 "Food secure" 1 "Food insecure", modify
		lab val foodinsecurebinary foodinsecurelab
			
			
	**Setting survey weights
			svyset [pw=ipw]
			
	**Setting lasso variable lists

	
	vl set
vl drop 	(record_id ipw weight covidkp_dthrate smoke_years payment_amt covid_testdate today age height_inches sleep_hrs sleep_min groups23 covidlf_reslngd covidlf_othreslngd covidlf_othresshtd smoke_years covid_testdate covidlf_resshtd audit_tot site height_feet educat4 workcat employed_ew maricat5 maricat3 covid_pos covidwb_losejob primarywork outofwork temporlooking foodinsecurebinary foodinsecurescore foodinsskipfreq foodinsafford foodins_notenough foodins_afford foodins_skip foodins_skip_freq foodins_eatless foodins_noteat foodins_tot foodins_cat smoke_adultcurrent exposure_smokemany smoke_years vape_adultcurrent exposure_vape vaper_years sub_cannabis_impair sub_rx_impair sub_illicit_impair payment_freq covpay_supp covpay_suppamt covid_notest_why___1 covid_notest_why___2 covid_notest_why___3 covid_notest_why___4 covid_notest_why___5  covid_dreasy covid_nomedcare covid_stayhome covid_hometime covid_distancehh covid_distancehh_unable covid_er covid_hospadmit covid_hhtestpos covidlf_trvl covidlf_moveloc covidwb_oth safevacc novacc_risk novacc_notser novacc_toolate novacc_safety novacc_meds novacc_hadcov novacc_exp novacc_loc novacc_distrust novacc_drugco novacc_prsnl novacc_guinea novacc_notforaian novacc_allergic novacc_needles yesvacc_famsafe yesvacc_commsafe yesvacc_selfsafe yesvacc_hlthprb yesvacc_dr yesvacc_sick yesvacc_safeothers yesvacc_normal jobsec_laidoff_likely covid_drpos covid_testpos covidwb_wgs employed foodinsnotenough covidwb_food work covidlf_income covidpa_lvwork jobsec_laidoff)
	
	
		
	vl move (trouble_sleep covidlf_othres covidlf_res covidkp_dist traveltime pss_tot kpds_tot) vlcontinuous
	vl move (income) vlcategorical

		
				vl create categoricalbigfood = vlcategorical - (site height_feet educat4 workcat employed_ew maricat5 maricat3 covid_pos covidwb_losejob primarywork outofwork temporlooking foodinsecurebinary foodinsecurescore foodinsskipfreq foodinsafford foodins_notenough foodins_afford foodins_skip foodins_skip_freq foodins_eatless foodins_noteat foodins_tot foodins_cat smoke_adultcurrent exposure_smokemany smoke_years vape_adultcurrent exposure_vape vaper_years sub_cannabis_impair sub_rx_impair sub_illicit_impair payment_freq covpay_supp covpay_suppamt covid_notest_why___1 covid_notest_why___2 covid_notest_why___3 covid_notest_why___4 covid_notest_why___5  covid_dreasy covid_nomedcare covid_stayhome covid_hometime covid_distancehh covid_distancehh_unable covid_er covid_hospadmit covid_hhtestpos covidlf_trvl covidlf_moveloc covidwb_oth safevacc novacc_risk novacc_notser novacc_toolate novacc_safety novacc_meds novacc_hadcov novacc_exp novacc_loc novacc_distrust novacc_drugco novacc_prsnl novacc_guinea novacc_notforaian novacc_allergic novacc_needles yesvacc_famsafe yesvacc_commsafe yesvacc_selfsafe yesvacc_hlthprb yesvacc_dr yesvacc_sick yesvacc_safeothers yesvacc_normal jobsec_laidoff_likely covid_drpos covid_testpos covidwb_wgs employed foodinsnotenough covidwb_food work )


**# Section 2: Descriptive Statistics 
			**Demographics
				collect clear 
				
				table (var) (covid_pos) [pweight=ipw] if primarywork==1, ///
				statistic(fvpercent  female educat4 incomecategory agebracket) ///
				
				
					collect recode result   fvfrequency = column1 ///
											fvpercent   = column2 ///
											mean	    = column1 ///
											sd 		    = column2
					collect style row stack, nobinder spacer 
					collect style header covid_pos, title(hide)
					collect style header result, level(hide)

					collect style cell var[female educat4 incomecategory agebracket]#result[column2], nformat(%6.1f) sformat("%s%%")
					collect style cell var[age]#result[column1 column2], nformat(%6.1f)
					collect style cell var[age]#result[column2], sformat("(%s)")
					collect label values cmdset 0 "Not Infected" 1 "Infected"
					collect style cell border_block, border(right, pattern(nil))
					collect layout (var) (covid_pos#result[column1 column2])
				
				collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\WeightedTables\descriptivetable1.docx", replace
	

	
	**Education levels
		svy: tab female educat4, pearson
		
	**Household income
		svy: tab female incomecategory, pearson
		
	**Household composition
		svy: tab female household_famgen, pearson
		
		
**# Section 2.1. Descriptives statistics for work type
			*Partial variable list: covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm 
			*isolate_maintain_job quarantine_maintain_job
			
		collect clear 

		table (var) (gender) [pweight=ipw], ///
		statistic (fvpercent employed employed_ew work) 
		
		collect style row stack, nobinder spacer
		collect style cell var[employed employed_ew work], nformat(%6.1f) sformat("%s%%")
		collect style header result, level(hide)
		collect style cell border_block, border(right, pattern(nil))
		collect layout (var) (gender)
		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\WeightedTables\employment.docx", replace
		
			**Full- or Part-Time
				svy: tab gender employed, pearson
			
			**Essential work
				svy: tab gender employed_ew, pearson
			
	**3.1.2 Occupations
	svy: tab groups6 if gender==1 & primarywork==1		
			
			
			
			
			
			
**# Section 2: Job and wage loss by occupational classification	and gender


		svy: tab groups6 covidwb_losejob if covid_pos==1 & female==1	 & primarywork==1
		svy: tab groups6 covidwb_losejob if covid_pos==0 & female==1 	 & primarywork==1
		svy: tab groups6 covidwb_losejob if female==1					 & primarywork==1
		svy: tab groups6 covidwb_losejob if covid_pos==1 & female==0	 & primarywork==1
		svy: tab groups6 covidwb_losejob if covid_pos==0 & female==0	 & primarywork==1
		svy: tab groups6 covidwb_losejob if female==0  					 & primarywork==1



		**** Consequence of infection (job category-wise)

		svy: tab groups6 covidwb_wgs if covid_pos==1 & female==1 	& primarywork==1
		svy: tab groups6 covidwb_wgs if covid_pos==0 & female==1 	& primarywork==1
		svy: tab groups6 covidwb_wgs if female==1 					& primarywork==1
		svy: tab groups6 covidwb_wgs if covid_pos==1 & female==0 	& primarywork==1
		svy: tab groups6 covidwb_wgs if covid_pos==0 & female==0	& primarywork==1
		svy: tab groups6 covidwb_wgs if female==0 					& primarywork==1
				
		
		**Job loss
			svy: tab covidwb_losejob covid_pos if gender==1 & primarywork==1, pearson
			svy: tab covidwb_losejob covid_pos if gender==2 & primarywork==1, pearson
			
		**Wage loss
			svy: tab covidwb_wgs covid_pos if gender==1 & primarywork==1, pearson
			svy: tab covidwb_wgs covid_pos if gender==2 & primarywork==1, pearson
			svy: tab gender covidwb_wgs if covid_pos==0 & primarywork==1, pearson
				
		**Food Insecurity
			svy: tab gender covidwb_food if primarywork==1, pearson
				
		
		
		
		
		
		
**# Section 3: Analyses 	
		
	**# Section 3.1 OLS job loss with industry classification
		
		collect clear
				collect create Jobloss
					reg covidwb_losejob  i.covid_pos i.gender i.educat4 i.agebracket i.site if primarywork==1 				[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])	
				
					reg covidwb_losejob  i.covid_pos i.gender i.groups6 i.educat4 i.agebracket i.site if  primarywork==1 	[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])
					
					dsregress covidwb_losejob covid_pos if primarywork==1 , controls($continuousbig i.($categoricalbigfood)) selection(bic) missingok
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])	
					
					reg covidwb_losejob  i.covid_pos i.gender i.educat4 i.agebracket i.site 								[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])	
				
					reg covidwb_losejob  i.covid_pos i.gender i.groups6 i.educat4 i.agebracket i.site 						[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[5])
					
					dsregress covidwb_losejob covid_pos, controls($continuousbig i.($categoricalbigfood)) selection(bic) missingok
					collect get _r_b _r_ci, name (Jobloss) tag (model[6])	
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_jobloss.docx", replace

	

	
	
	**# Section 3.2 Indirect effects

		collect clear
				collect create Foodinsecure

					reg 	foodinsecurebinary covidwb_losejob covid_pos i.gender   i.educat4 i.agebracket i.site  if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[1])
					
					reg 	foodinsecurebinary covid_pos i.gender   i.educat4 i.agebracket i.site if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[2])
					
					dsregress foodinsecurebinary covidwb_losejob if primarywork==1 , controls($continuousbig i.($categoricalbigfood)) selection(bic) missingok
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[3])	
					
					reg 	foodinsecurebinary covidwb_losejob covid_pos i.gender   i.educat4 i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[4])
					
					reg 	foodinsecurebinary covid_pos i.gender   i.educat4 i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[5])
					
					dsregress foodinsecurebinary covidwb_losejob, controls($continuousbig i.($categoricalbigfood)) selection(bic) missingok
					collect get _r_b _r_ci, name (Foodinsecure) tag (model[6])	
					
					
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_Food_insecurity.docx", replace
		
	
	
	**This allows estimation of A*C from the methods
svy: gsem (foodinsecurebinary <- covidwb_losejob i.gender  i.groups6 i.educat4 i.agebracket i.site) (covidwb_losejob <- covid_pos i.gender i.groups6  i.educat4 i.agebracket i.site ) if primarywork==1

nlcom _b[foodinsecurebinary:covidwb_losejob]*_b[covidwb_losejob:covid_pos]
	
	
	
	
	
	
	
	
	
	
	
**# Appendix
**# Appendix Section 1: Descriptive statistics of the whole sample
			**Demographics
				collect clear 
				
				table (var) (gender) [pweight=ipw], statistic(mean age) ///
				statistic(sd age) ///
				statistic(fvfrequency female educat4 incomecategory maricat3 household_famgen housing) ///
				statistic(fvpercent female educat4 incomecategory maricat3 household_famgen housing) ///
				
				
					collect recode result   fvfrequency = column1 ///
											fvpercent   = column2 ///
											mean	    = column1 ///
											sd 		    = column2
					collect style row stack, nobinder spacer 
					collect style header gender, title(hide)
					collect style header result, level(hide)
					collect style cell var[female educat4 incomecategory maricat3 household_famgen housing]#result[column1], nformat(%6.0fc)
					collect style cell var[female educat4 incomecategory maricat3 household_famgen housing]#result[column2], nformat(%6.1f) sformat("%s%%")
					collect style cell var[age]#result[column1 column2], nformat(%6.1f)
					collect style cell var[age]#result[column2], sformat("(%s)")
					collect label values cmdset 1 "Male" 2 "Female"
					collect style cell border_block, border(right, pattern(nil))
					collect layout (var) (gender#result[column1 column2])
				
				collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\Appendix\descriptivetable1.docx", replace
	
		**Slightly different variables.
			**Demographics
				collect clear 
				
				table (var) (gender) [pweight=ipw], ///
				statistic(fvpercent female employed_ew educat4 incomecategory agebracket) ///
				
				
					collect recode result   fvfrequency = column1 ///
											fvpercent   = column2 ///
											mean	    = column1 ///
											sd 		    = column2
					collect style row stack, nobinder spacer 
					collect style header gender, title(hide)
					collect style header result, level(hide)

					collect style cell var[female employed_ew educat4 incomecategory agebracket]#result[column2], nformat(%6.1f) sformat("%s%%")
					collect style cell var[age]#result[column1 column2], nformat(%6.1f)
					collect style cell var[age]#result[column2], sformat("(%s)")
					collect label values cmdset 1 "Male" 2 "Female"
					collect style cell border_block, border(right, pattern(nil))
					collect layout (var) (gender#result[column1 column2])
				
				collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\Appendix\descriptivetable2.docx", replace
	
	svyset [pw=ipw]
	
	**Education levels
		svy: tab female educat4, pearson
		
	**Household income
		svy: tab female incomecategory, pearson
		
	**Household composition
		svy: tab female household_famgen, pearson
**# Appendix: Workplace conditions and precarity
			*covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm 
			*isolate_maintain_job quarantine_maintain_job
			
			collect clear 

		table (var) (gender) [pweight=ipw], ///
		statistic (fvfrequency employed employed_ew work) ///
		statistic (fvpercent employed employed_ew work) 
		
			collect style row stack, nobinder spacer
			collect recode result   fvfrequency = column1 ///
									fvpercent   = column2 
			collect style cell var[employed employed_ew work]#result[column1], nformat(%6.0fc)
			collect style cell var[employed employed_ew work]#result[column2], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (gender#result[column1 column2])

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\Appendix\employment.docx", replace
		
		
		**Precarity 
		collect clear 

		table (var) (gender) [pweight=ipw], ///
		statistic (fvfrequency covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job) ///
		statistic (fvpercent covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job) 
		
			collect style row stack, nobinder spacer
			collect recode result   fvfrequency = column1 ///
									fvpercent   = column2 
			collect style cell var[covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job]#result[column1], nformat(%6.0fc)
			collect style cell var[covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job]#result[column2], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (gender#result[column1 column2])

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\Appendix\jobprecarity.docx", replace
		
		
			

			
			
**# Appendix: Consequences of COVID in men
		collect clear 

		table (var) (covid_pos) [pweight=ipw] if gender==1, ///
		statistic (fvfrequency covidwb_losejob covidwb_wgs covidwb_food covidwb_chldcare covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) ///
		statistic (fvpercent covidwb_losejob covidwb_wgs covidwb_food covidwb_chldcare covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) 
		
			collect style row stack, nobinder spacer
			collect recode result   fvfrequency = column1 ///
									fvpercent   = column2 ///
									mean	    = column1 ///
									sd 		    = column2
			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move]#result[column1], nformat(%6.0fc)
			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move]#result[column2], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (covid_pos#result[column1 column2])

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\Appendix\covidinfectionconsequencesinmen.docx", replace
		
	**Consequences of COVID in women
		collect clear 

		table (var) (covid_pos) [pweight=ipw] if gender==2, ///
		statistic (fvfrequency covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) ///
		statistic (fvpercent covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) 
		
			collect style row stack, nobinder spacer
			collect recode result   fvfrequency = column1 ///
									fvpercent   = column2 ///
									mean	    = column1 ///
									sd 		    = column2
			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move]#result[column1], nformat(%6.0fc)
			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move]#result[column2], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (covid_pos#result[column1 column2])

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\Appendix\covidinfectionconsequencesinwomen.docx", replace
		
		
		
**# Appendix: Precarity 
		collect clear 

		table (var) (gender) [pweight=ipw], ///
		statistic (fvpercent covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job) 
		
			collect style row stack, nobinder spacer
			collect style cell var[covidwb_expwrk jobsec_laidoff jobsec_newjob covid_stayhome covid_hometime covidres_stayhm ///
			isolate_maintain_job quarantine_maintain_job], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (gender)

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\WeightedTables\jobprecarity.docx", replace
		
		
			**3.1.3 Consequences of COVID in men
		collect clear 

		table (var) (covid_pos) [pweight=ipw] if gender==1 , ///
		statistic (fvpercent covidwb_losejob covidwb_wgs covidwb_food covidwb_chldcare covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) 
		
			collect style row stack, nobinder spacer


			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (covid_pos)

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\WeightedTables\covidinfectionconsequencesinmen.docx", replace
		
	**Consequences of COVID in women
		collect clear 

		table (var) (covid_pos) [pweight=ipw] if gender==2 , ///
		statistic (fvpercent covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move) 
		
			collect style row stack, nobinder spacer
			collect style cell var[covidwb_losejob covidwb_wgs covidwb_chldcare covidwb_food covidwb_rx covidwb_transp covidwb_hcacc covidwb_nodiff covidlf_move], nformat(%6.1f) sformat("%s%%")
			collect style header result, level(hide)
			collect style cell border_block, border(right, pattern(nil))
		
			collect layout (var) (covid_pos)

		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Socioeconomics\WeightedTables\covidinfectionconsequencesinwomen.docx", replace
		
		
		**Concern
			svy: tab gender covidwb_expwrk if covidwb_expwrk<6
			
			svy: tab gender covidwb_expwrk if covidwb_expwrk<6 & gender==1
			svy: tab gender covidwb_expwrk if covidwb_expwrk<6 & gender==2
			
		**Job security - layoff likely?
			svy: tab gender jobsec_laidoff if jobsec_laidoff<4, pearson
			svy: tab gender jobsec_laidoff_likely, pearson
			
		**New Job
			svy: tab gender jobsec_newjob if jobsec_newjob<4 , pearson
			
			
			
**# Appendix: OLS Wages
		collect clear
		
		collect create Wageloss

			reg covidwb_wgs i.gender i.covid_pos i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Wageloss) tag (model[Both Sexes])
			
			reg covidwb_wgs  i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if gender==1 &  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Wageloss) tag (model[Men])

			reg covidwb_wgs  i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if gender==2 &  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Wageloss) tag (model[Women])
			
			reg covidwb_wgs  i.gender##i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Wageloss) tag (model[Interaction])
		
			collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)		
			collect style cell border_block, border(right, pattern(nil))
			collect style cell, nformat(%5.2f)
			collect style row stack, nobinder spacer 
			collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")
			collect style header result, level(hide)
			collect style cell cell_type[item column-header], halign(center)
			collect style column, extraspace(1) 
			collect style row stack, spacer delimiter(" x ")
			collect layout (colname#result) (model)
			
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\wagesinfection.docx", replace

**# Appendix: Logit wages with industry classification
		
	collect clear
		collect create Wageloss
			logit covidwb_wgs i.gender i.covid_pos i.groups6 i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1  [pweight=ipw], or
			margins, dydx(*) post
			collect get _r_b _r_ci, name (Wageloss) tag (model[Both Sexes])
			
			logit covidwb_wgs  i.covid_pos i.groups6 i.incomecategory i.educat4  i.agebracket i.site if gender==1 &  primarywork==1  [pweight=ipw], or
			margins, dydx(*) post
			collect get _r_b _r_ci, name (Wageloss) tag (model[Men])
			
			logit covidwb_wgs i.covid_pos i.groups6 i.incomecategory i.educat4  i.agebracket i.site if gender==2 &  primarywork==1  [pweight=ipw], or
			margins, dydx(*) post
			collect get _r_b _r_ci, name (Wageloss) tag (model[Women])
		
			collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)		
			collect style cell border_block, border(right, pattern(nil))
			collect style cell, nformat(%5.2f)
			collect style row stack, nobinder spacer 
			collect style cell result[_r_ci], sformat("(%s)")  cidelimiter(", ")
			collect style header result, level(hide)
			collect style cell cell_type[item column-header], halign(center)
			collect style column, extraspace(1) 
			collect style row stack, spacer delimiter(" x ")
		collect layout (colname#result) (model)
		
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\wagesloss_with_industry.docx", replace	
		
		
**# Appendix: OLS Job loss stratified by gender
	collect clear
		collect create Jobloss
			reg covidwb_losejob  i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if gender==1 & primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[Men])

			reg covidwb_losejob  i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if gender==2 & primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[Women])
	
			reg covidwb_losejob  i.covid_pos i.groups6 i.incomecategory i.educat4  i.agebracket i.site if gender==1 &  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[Men])

			reg covidwb_losejob  i.covid_pos i.groups6 i.incomecategory i.educat4  i.agebracket i.site if gender==2 &  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[Women])
				
			collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
			collect style cell border_block, border(right, pattern(nil))
			collect style cell, nformat(%5.2f)
			collect style row stack, nobinder spacer 
			collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

			collect style header result, level(hide)
			collect style cell cell_type[item column-header], halign(center)
			collect style column, extraspace(1) 
			collect style row stack, spacer delimiter(" x ")			
		collect layout (colname#result) (model)
	
	collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_Jobloss_Gender_stratified.docx", replace
	
**# Appendix: OLS Job loss with HH income
collect clear
		collect create Jobloss
			reg covidwb_losejob  i.gender i.covid_pos i.incomecategory i.educat4 i.agebracket i.site if primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[1])
			
			reg covidwb_losejob  i.gender##i.covid_pos i.incomecategory i.educat4  i.agebracket i.site if primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
		
			reg covidwb_losejob   i.gender i.covid_pos i.groups6 i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[3])
			
			reg covidwb_losejob   i.gender##i.covid_pos i.groups6 i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[4])
		
			collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
			collect style cell border_block, border(right, pattern(nil))
			collect style cell, nformat(%5.2f)
			collect style row stack, nobinder spacer 
			collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

			collect style header result, level(hide)
			collect style cell cell_type[item column-header], halign(center)
			collect style column, extraspace(1) 
			collect style row stack, spacer delimiter(" x ")			
		collect layout (colname#result) (model)
		
collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_jobloss.docx", replace

**# Appendix: OLS Depvar=unemployed

		collect clear
				collect create Jobloss
					reg temporlooking  i.gender i.covid_pos i.educat4 i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])
					
					reg temporlooking  i.gender##i.covid_pos i.educat4  i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
				
					reg temporlooking  i.gender i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])
					
					reg temporlooking  i.gender##i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_unemployed.docx", replace		

		
**# Appendix OLS Robustness checks
			collect clear
				collect create Jobloss
				
				
					reg covidwb_losejob  i.covid_pos i.gender i.educat4 i.agebracket i.incomecategory i.site if primarywork==1 				[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])	
				
					reg covidwb_losejob  i.covid_pos i.gender i.groups6 i.educat4 i.agebracket i.incomecategory i.site if  primarywork==1 	[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])
					
					dsregress covidwb_losejob covid_pos if primarywork==1 , controls($uncertainbig $continuousbig $categoricalbig) selection(bic) missingok
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])	
					
					reg covidwb_losejob  i.covid_pos i.gender i.educat4 i.workcat i.agebracket i.site 								[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])	
				
					reg covidwb_losejob  i.covid_pos i.gender i.groups6 i.workcat i.educat4 i.agebracket i.site 						[pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[5])
					
					dsregress covidwb_losejob covid_pos, controls($uncertainbig $continuousbig $categoricalbig) selection(bic) missingok
					collect get _r_b _r_ci, name (Jobloss) tag (model[6])	
					
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_jobloss_robustness.docx", replace
		
		
**# Appendix: OLS depvar = temporarily laid off or unemployed and looking
		collect clear
				collect create Jobloss
					reg outofwork  i.gender i.covid_pos i.educat4 i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])
					
					reg outofwork  i.gender##i.covid_pos i.educat4  i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
				
					reg outofwork   i.gender i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])
					
					reg outofwork   i.gender##i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_=templaidofforlooking.docx", replace		
		
			
**# Appendix: OLS Job loss with entire sample

		collect clear
				collect create Jobloss
					reg covidwb_losejob  i.gender i.covid_pos i.educat4 i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])
					
					reg covidwb_losejob  i.gender##i.covid_pos i.educat4  i.agebracket i.site [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
				
					reg covidwb_losejob   i.gender i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])
					
					reg covidwb_losejob   i.gender##i.covid_pos i.groups6 i.educat4 i.agebracket i.site [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_jobloss_noHHincome_whole_sample.docx", replace

		
**# Appendix: Indirect effects on covidwb_food 

	collect clear
				collect create Jobloss
					reg covidwb_food covidwb_losejob i.covid_pos i.gender   i.educat4 i.agebracket i.site if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])
					
					reg covidwb_food covidwb_losejob  i.covid_pos##i.gender i.educat4  i.agebracket i.site if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
				
					reg covidwb_food covidwb_losejob  covid_pos i.gender  i.groups6 i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])
					
					reg covidwb_food covidwb_losejob i.covid_pos##i.gender  i.groups6 i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_mediation.docx", replace
		
		
**# Unused
**# Unused: OLS Job loss with work type *** NOTE 3/3 this doesn't need to be added anywhere because work includes things like temporarily laid off that unsurprisingly are great predictors.
collect clear
		collect create Jobloss
			reg covidwb_losejob  i.gender i.covid_pos i.work i.educat4 i.agebracket i.site if primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[1])
			
			reg covidwb_losejob  i.gender##i.covid_pos i.work i.educat4  i.agebracket i.site if primarywork==1 [pweight=ipw], robust
			collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
		
			reg covidwb_losejob   i.gender i.covid_pos i.work i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[3])
			
			reg covidwb_losejob   i.gender##i.covid_pos i.work i.incomecategory i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
			collect get _r_b _r_ci, name (Jobloss) tag (model[4])
		
			collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
			collect style cell border_block, border(right, pattern(nil))
			collect style cell, nformat(%5.2f)
			collect style row stack, nobinder spacer 
			collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

			collect style header result, level(hide)
			collect style cell cell_type[item column-header], halign(center)
			collect style column, extraspace(1) 
			collect style row stack, spacer delimiter(" x ")			
		collect layout (colname#result) (model)
		
collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_jobloss_with_work.docx", replace	

**
	collect clear
				collect create Jobloss
					reg 	housing covidwb_losejob i.covid_pos i.gender   i.educat4 i.agebracket i.site if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[1])
					
					reg 	housing covidwb_losejob  i.covid_pos##i.gender i.educat4  i.agebracket i.site if primarywork==1 [pweight=ipw], robust
					collect get _r_b _r_ci, name (Jobloss) tag (model[2])		
				
					reg 	housing covidwb_losejob  covid_pos i.gender  i.groups6 i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[3])
					
					reg 	housing covidwb_losejob i.covid_pos##i.gender  i.groups6 i.educat4 i.agebracket i.site if  primarywork==1 [pweight=ipw], r
					collect get _r_b _r_ci, name (Jobloss) tag (model[4])
				
					collect stars _r_p 0.01 "***" 0.05 "**" 0.1 "*", attach(_r_b)
					collect style cell border_block, border(right, pattern(nil))
					collect style cell, nformat(%5.2f)
					collect style row stack, nobinder spacer 
					collect style cell result[_r_ci], sformat("(%s)") cidelimiter(", ")

					collect style header result, level(hide)
					collect style cell cell_type[item column-header], halign(center)
					collect style column, extraspace(1) 
					collect style row stack, spacer delimiter(" x ")			
				collect layout (colname#result) (model)
				
		collect export "C:\Users\austin.henderson\OneDrive - Washington State University (email.wsu.edu)\Documents\CONCERTS_Employment\RegressionTables\OLS_Housing_insecurity.docx", replace