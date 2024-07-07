/*---------------------------------------------HYPOTHESIS 1 TO 5--------------------------------------------*/
/*Hypothesis 1: Female customers usually go to KFC for gatherings.
*/

/*Subset the dataset for gender -> female*/

/*SUBSET THE femela for gender*/
data sel_female;
set mydata.dckfcdataset;
if gender = 1;
run;

/*REPRESENTING Gatherings variable as a numeric variable*/
data femaleH1;
   set sel_female;
   gatherings_num = input(gatherings, best32.);
run;

/*TESTING USING population proportioin, when alpha is 0.05*/
proc freq data=femaleH1;
    tables gatherings_num / binomial(p=0.07692 level=2) alpha=0.05;
run;

/*-------------------------------VISUALIZATION--------------------------------------*/
proc sgplot data=femaleH1;
    vbar  gatherings_num / datalabel;
    yaxis display=(nolabel);
    title "Is female Customers Going to KFC for Gatherings";
    run;

/*=========================END OF HYPOTHESIS NUMBER 1==============================*/



/*==========================HYPOTHESIS 2================================*/

/*---------------------------------------------------------------------------------*/

/*
Hypothesis 2: Most of the females at the age 20 to 29 prefer fried chicken (original flavour) 
than fried chicken (spicy flavour).
*/

/*Subset the female variable*/
data femaleH2;
set mydata.dckfcdataset;
if gender = 1 and age=2;
run;


/*changing the variable types of fried chicken (ori) & fried chicken (spicy)*/

/*Fried chicken (original)*/
data femaleH2;
   set femaleH2;
   friedchkori_num = input(Fried_Chicken_Original, best32.);
run;

/*Fried Chicken (Spicy)*/
data femaleH2;
   set femaleH2;
   friedchkspy_num = input(Fried_Chicken_Spicy, best32.);
run;


/*population proportion*/
proc freq data=femaleH2;
   tables friedchkori_num*friedchkspy_num / agree;
run;

/*-----------------------------VISUALIZATION-----------------------------------*/
proc sgplot data=femaleH2;
    vbar friedchkori_num / datalabel;
    yaxis display=(nolabel);
    title "IS female Customers prefer fried chicken ori";
    run;
    
    
    proc sgplot data=femaleH2;
    vbar friedchkspy_num / datalabel;
    yaxis display=(nolabel);
    title "IS female Customers prefer fried chicken spicy ?";
    run;
    
/*==============================END OF HYPOTHESIS 2================================*/




/*==================================HYPOTHESIS 3======================================*/
/*
Hypothesis 3: Males at the age of 20 to 29 are more likely to enjoy the 
signature box set than females at the age of 20 to 29.
*/

/*Subset for age*/
data ageH3;
set mydata.dckfcdataset;
if age=2;
run;


/*Multinomial Logistics Regression*/
proc logistic data=ageH3;
    class gender (param=ref ref='0'); /*reference to male as indicates as 0*/
    model favMenuItem = Gender / link=glogit; 
    run;
    


/*---------------------------------------------VISUALIZATION---------------------------------------*/
proc sgplot data=ageH3;
    vbar FavMenuItem / group = gender datalabel;
    yaxis label="Predicted Probability";
    xaxis label="Menu Item in Signature Box Set";
run;

/*1 indicate Female, 0 indicate Male*/

/*================================END OF HYPOTHESIS 3=======================================*/



/*====================================HYPOTHESIS 4=========================================*/
/*
Hypothesis 4: Males  are more likely to eat KFC on game nights than any other occasions.
*/

/*Subset the males and age below 20*/
data H4;
set mydata.dckfcdataset;
if gender = 0;
run;

/*REPRESENTING game night variable as a numeric variable*/
data maleH4;
   set H4;
   gamenight_num = input(game_night, best32.);
run;

/*population proportion*/
proc freq data=maleH4;
  tables gamenight_num / binomial(p=0.07692 level=2) alpha=0.05;
run;




/*---------------------------------------------------------------------------------------------*/

/*---------------------------------VISUALIZATION-----------------------------------*/
proc sgplot data=maleH4;
    vbar  gamenight_num / datalabel;
    yaxis display=(nolabel);
    title "IS males more likely to eat KFC when its game night occassion";
    run;
    
/*======================================END OF HYPOTHESIS 4============================================*/



/*=================================HYPOTHESIS 5==================================*/

/*
Hypothesis 5: Customers both male and female are more likely to buy KFC 
because of its good service
*/


/* population proportion using chi-square test*/
proc freq data=mydata.dckfcdataset;
tables gender * good_service / chisq;
run;


/*------------------------------------------------------------------------------------------------*/
/*-----------------------------------VISUALIZATION--------------------------------------*/

data genderH5;
   set mydata.dckfcdataset;
   gender_num = input(gender, best32.);
run;

proc sgplot data=genderH5;
    vbox gender_num / category=good_service;
run;

/*--------------------------------END OF HYPOTHESIS 1 TO 5--------------------------------------------*/







/*-----------------------------------------HYPOTHESIS 6 TO 10--------------------------------*/

/*Hypo 6 */
proc freq data=mydata.dckfcdataset;
    tables age*free_toys / chisq;
run;


data mydata.dckfcdataset;
    set mydata.dckfcdataset;
    age_bin = (age = 1);
run;

/* Performing logistic regression */
proc logistic data=mydata.dckfcdataset;
    class age_bin;
    model free_toys(event='1') = age_bin;
run;


proc sgplot data=mydata.dckfcdataset;
    styleattrs datacolors=(Pink Red);
    vbar age / group=free_toys groupdisplay=stack;
    title 'Purchases KFC because of free toy by age group';
    label age='Age Group';
run;

/* hypo 2  */
/* proc sql; */
/*     create table food_counts as */
/*     select delicious_food, count(*) as count */
/*     from mydata.dckfcdataset */
/*     group by delicious_food; */
/* quit; */
/*  */
/*  */
/*  */
/* proc gchart data=food_counts; */
/*     pie3d delicious_food / sumvar=count */
/*                          slice=outside */
/*                          percent=outside */
/*                          other=0 */
/*                          name="PieChart"; */
/*     title 'Proportion of Customers Visiting KFC for Delicious Food'; */
/* run; */
/* quit; */

/*hypo7 example*/
proc freq data=mydata.dckfcdataset;
    tables delicious_food / binomial(p=0.5);
run;

proc freq data=mydata.dckfcdataset;
    tables delicious_food / out=food_counts (rename=(COUNT=count));
run;
/* Create a pie chart using PROC GCHART */
proc gchart data=food_counts;
    pie3d delicious_food / sumvar=count
                         slice=outside
                         percent=outside
                         other=0
                         name="PieChart";
    title 'Proportion of Customers Visiting KFC for Delicious Food';
run;
quit;

/*hypo 8*/
proc freq data=mydata.dckfcdataset;
    tables promotions / binomial(p=0.5);
run;

proc freq data=mydata.dckfcdataset;
    tables promotions / out=promotion_counts (rename=(COUNT=count));
run;

/* Create a bar chart */
proc sgplot data=promotion_counts;
    vbar promotions / response=count;
    title 'Proportion of Customers Visiting KFC when KFC offers promotion';
    yaxis label='Number of Customers';
    xaxis label='Promotion';
run;

/*hypo 9*/
proc freq data=mydata.dckfcdataset;
    tables reasonable_prices / binomial(p=0.5);
run;

proc freq data=mydata.dckfcdataset;
    tables reasonable_prices / out=price_counts (rename=(COUNT=count));
run;

proc gchart data=price_counts;
    pie3d reasonable_prices / sumvar=count
                             slice=outside
                             percent=outside
                             other=0
                             name="PieChart";
    title 'Proportion of Customers Visiting KFC because of Reasonable Prices';
run;
quit;

/*Hypo 10 */
/* Perform a one-sample proportion test */
proc freq data=mydata.kfc_dataset;
    tables Online / binomial(p=0.5);
run;

/* Create a frequency table */
proc freq data=mydata.kfc_dataset;
    tables Online / out=online_counts (rename=(COUNT=count));
run;

/* Create a pie chart using PROC GCHART */
proc gchart data=online_counts;
    pie3d Online / sumvar=count
                 slice=outside
                 percent=outside
                 other=0
                 name="PieChart";
    title 'Proportion of Customers who Heard of KFC via Online Channels';
run;
quit;

/*-------------------------------------END OF HYPOTHESIS 6 TO 10------------------------------*/







/*------------------------------------HYPOTHESIS 11 TO 15-------------------------------------*/
/* Hypothesis 11 - 15 */
data HypothesisTest;
	set mydata.dckfcdataset;
	IF tasteRating IN (4, 5) THEN TasteSatisfaction = 1;
    ELSE TasteSatisfaction = 0;
    TotalOrderUsingWebsite = nOrder_via_KFC_app_delivery+nOrder_via_KFC_app_pickup;
    IF TotalOrderUsingWebsite = 2 THEN TotalOrderUsingWebsite = 1;
run;
/* Hypothesis 11 */
PROC FREQ DATA=HypothesisTest;
   	TABLES Television / BINOMIAL (P=0.05);
   	EXACT BINOMIAL;
RUN;
/* Hypothesis 12 */
PROC FREQ DATA=HypothesisTest;
   	TABLES tasteRating;

PROC FREQ DATA=HypothesisTest;
   	TABLES TasteSatisfaction / BINOMIAL (P=0.05);
RUN;
/* Hypothesis 13 */
PROC ANOVA DATA=HypothesisTest;
   CLASS tasteRating priceRating envRating;
   MODEL overallRating = tasteRating priceRating envRating;
RUN;
/* Hypothesis 14 */
PROC FREQ DATA=HypothesisTest;
   TABLES nOrder_at_counter / BINOMIAL (P=0.5) ALPHA=0.05;
RUN;
/* Hypothesis 15 */
PROC FREQ DATA=HypothesisTest;
   	TABLES TotalOrderUsingWebsite / BINOMIAL (P=0.05);
   	EXACT BINOMIAL;
RUN;

/*------------------------------------END OF HYPOTHESIS 11 TO 15------------------------------*/








/*----------------------------------------HYPOTHESIS 16 TO 20----------------------------------*/
/*H16: “Fried Chicken and Fries” is the most common combination of food ordered at KFC.*/
data work.testHypo16;
	set work.dataclean;
	if (fried_chicken_original = 1 or fried_chicken_spicy = 1) and fries = 1 then chic_fr_comb = 1;
	else chic_fr_comb = 0;
run;

proc freq data = testHypo16;
	tables chic_fr_comb / binomial (p = 0.5 level = 2) alpha = 0.05;
	exact binomial;
run;
/*H0: p <= 0.5
  H1: p > 0.5*/
/*Conclusion: The proportion of customers who ordered a combination of fried chicken and fries
is 0.3371 / 33.71%. The proportion of customers who ordered another combination is 0.6629 / 66.29%.
Since, z = -4.3088 < 1.6449, we accept H0 and conclude that “Fried Chicken and Fries” is not the most 
common combination of food ordered at KFC.*/



/*H17: “Burger and Fries” is the most common combination of food ordered at KFC.*/
data work.testHypo17;
	set work.dataclean;
	if (zinger_burger = 1 or colonel_burger = 1) and fries = 1 then burg_fr_comb = 1;
	else burg_fr_comb = 0;
run;

proc freq data = testHypo17;
	tables burg_fr_comb / binomial (p = 0.5 level = 2) alpha = 0.05;
	exact binomial;
run;
/*H0: p <= 0.5
  H1: p > 0.5*/
/*Conclusion: The proportion of customers who ordered a combination of burger and fries is
0.1257 / 12.57%. The proportion of customers who ordered another combination is 0.8743 / 87.43%.
Since z = -9.9027 < 1.6449, we accept H0 and conclude that “Burger and Fries” is not the most 
common combination of food ordered at KFC.*/


/*H18: The majority of students spent between RM20 and RM30 */ 

/*H0: p <= 0.1666667 
  H1: p  > 0.1666667*/
data work.testHypo18;
	set work.dataclean;
	if job ^= 'Student' then delete;
	if moneySpent = "Between RM20 and RM30" then match = 1;
	else match = 0;
run;

proc freq data = testHypo18;
	tables match / binomial (p = 0.1666667 level = 2) alpha = 0.05;
	exact binomial;
run;

/*Conclusion: Among KFC’s student customers, the proportion of them spending between RM20 and RM30 is 0.4236. 
Since Z = 8.2734 > 1.6449, we reject H0 and conclude that the majority of students spent between RM20 and RM30. 
Therefore, H18 is accepted. */






/*H19: People aged 29 and below are more likely to recommend KFC to their friends or family members 
than any other age group.*/
/*"Below 20" = "1";
  "20 to 29" = "2";
  "30 to 39" = "3";
  "40 to 49" = "4";
  "50 and above" = "5";*/
/*Analysis of People aged 29 and below*/
data work.testHypo19_for_29nbelow;
	set work.dataclean;
	if age = 1 or age = 2 then match = 1;
	else match = 0;
	if recommendKFC = 'Y' then recommendKFC = 1;
	else recommendKFC = 0;
run;

PROC tabulate data = work.testHypo19_for_29nbelow;
   CLASS match recommendKFC;
   TITLE "People aged 29 and below vs Recommend KFC";
   TABLE  match all, recommendKFC all;
   label recommendKFC = 'Will customer recommmend KFC?'
         match = 'People Aged 29 and Below?';
RUN;

data work.testHypo19_for_29nbelow;
	set work.testHypo19_for_29nbelow;
	if recommendKFC = 0 then delete;
run;

proc freq data = testHypo19_for_29nbelow;
	tables match / binomial (p = 0.25 level = 2) alpha = 0.05;
	exact binomial;
run;



/*Analysis of People above 29*/
data work.testHypo19_for_above29;
	set work.dataclean;
	if age < 3 then delete;
run;

PROC FREQ data = work.testHypo19_for_above29;
   TITLE "People above 29";
   TABLE  recommendKFC / NOCUM NOPERCENT;
RUN;

data twoPTestforH19;
    input ageGroup $ recommendKFC $ count;
    datalines;
Above29 Yes 28
Above29 No 4
29&below Yes 113
29&below No 30
;
run;

proc print data=twoPTestforH19;

/*
  H0: P <= 0.25
  H1: P > 0.25
*/

proc freq data=twoPTestforH19;
    weight count;
    tables ageGroup * recommendKFC / riskdiff(equal var = null);
run;
/*Conclusion: Since Z = 1.0959 < 1.6449 and the one-sided p value is 0.1366 > 0.05, 
we accept the null hypothesis and conclude that the proportion of people 29 and below who recommend KFC to 
friends or family is not significantly more than the proportion of people above 30 
who recommend KFC to friends or family.*/


/*H20: Most of the customers do not purchase banana chocolate balls.*/
data work.testHypo20;
	set work.dataclean;
	if  banana_chocolate_balls = 1 then ordered_banana_chocob = 1;
	else ordered_banana_chocob = 0;
run;
/*H0: P >= 0.1111
  H1: P < 0.1111*/
 
proc freq data = testHypo20;
	tables ordered_banana_chocob / binomial (p = 0.1111 level = 2) alpha = 0.05;
run;

/*-------------------------------------END OF HYPOTHESIS 16 TO 20--------------------------------*/
