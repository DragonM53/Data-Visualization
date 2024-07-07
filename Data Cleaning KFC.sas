/*----------------------------------VARIABLE 1 TO 6-------------------------------------*/
data work.datacleanV1;
    set mydata.copykfcdataset;
    
    /* Outlier detection and handling */
	/* Let the 'M' to value 0 and 'F' to value 1 */
    if gender = "M" then gender = "0";
	if gender = "F" then gender = "1";
	
	/* Let the 'Below 20' to value 0 , Let the '20 to 29' to value 1 , ...*/
	if age = "Below 20" then age = "1";
	if age = "20 to 29" then age = "2";
	if age = "30 to 39" then age = "3";
	if age = "40 to 49" then age = "4";
	if age = "50 and above" then age = "5";
    
	/* Let the 'RM 0' to value 0 , Let the 'Below RM1500' to value 1 , ...*/
	/*
	if income = "RM0" then income = "0";
	if income = "RM 0" then income = "0";
	if income = "Below RM1500" then income = "1";
	if income = "RM1500 to RM3500" then income = "2";
	if income = "RM3500 to RM5500" then income = "3";
	if income = "RM5500 to RM7500" then income = "4";
	if income = "RM7500 and above" then income = "5";
	*/
	
	/* Dealing with typos */
	if state = "Kuala Kumpur" then state = "Kuala Lumpur";
    if lastPurchaseDate = "10/6/2023" and state = "Selangor" then income = "No Income";
	/* Handle inconsistencies in state */
    if not missing(state) then do;
        state = upcase(trim(state));
    end;
    
    /* Group the Job */
    if job in ("Admin Assistant","Admin Executive","Admin Officer","accountant") then job = "Administrative/Office Roles";
    if job in ("Doctor","architect") then job = "Professional Roles";
    if job in ("Executive","Assistant Manager","Sales Manager") then job = "Management/Leadership Roles";
    if job in ("Customer Service Representative") then job = "Service Roles";
    if job in ("Civil Servant") then job = "Civil Service";
    if job in ("Housewife") then job = "Home and Family Roles";
    if job in ("Lecturer","Secondary school teacher","Teacher") then job = "Education Roles";
    if job in ("Engineer","Junior Engineer","Maintenance Engineer") then job = "Technical Roles";
    if job in ("Real Estate Agent","Landlord") then job = "Real Estate";
    if job in ("Sales","salesman") then job = "Sales Roles";
    
    /* Group the lastPurchaseDate */
    if lastPurchaseDate = "21/8/2022"
    	then lastPurchaseDate = "Aug 2022";
    else if lastPurchaseDate = "29/10/2022"
    	then lastPurchaseDate = "Oct 2022";
    else if lastPurchaseDate = "21/11/2022"
    	then lastPurchaseDate = "Nov 2022";
    else if lastPurchaseDate in ("15/12/2022", "25/12/2022")
    	then lastPurchaseDate = "Dec 2022";
    else if lastPurchaseDate in ("15/1/2023", "31/1/2023","20/1/2023")
    	then lastPurchaseDate = "Jan 2023";
    else if lastPurchaseDate in ("03/2/2023","13/2/2023","05/2/2023") 
    	then lastPurchaseDate = "Feb 2023";
    else if lastPurchaseDate in ("01/3/2023", "06/3/2023", "1/3/2023", "13/3/2023", "29/3/2023","12/3/2023")
    	then lastPurchaseDate = "Mar 2023";
    else if lastPurchaseDate in ("01/4/2023","1/4/2023","6/4/2023","13/4/2023","30/4/2023","19/4/2023")
    	then lastPurchaseDate = "Apr 2023";
    else if lastPurchaseDate in ("01/5/2023","12/5/2023","14/5/2023","21/5/2023","22/5/2023","27/5/2023","28/5/2023","31/5/2023","05/2/2023","25/5/2023")
    	then lastPurchaseDate = "May 2023";
    else if lastPurchaseDate in ("01/6/2023","03/6/2023","08/6/2023","1/6/2023","10/6/2023","11/6/2023","12/6/2023","14/6/2023","15/6/2023","16/6/2023","17/6/2023","19/6/2023","20/6/2023","22/6/2023","23/6/2023","24/6/2023","25/6/2023","26/6/2023","27/6/2023","28/6/2023","29/6/2023","30/6/2023","7/6/2023") 
    	then lastPurchaseDate = "Jun 2023";
    else lastPurchaseDate = "Jul 2023";

run;

data work.dataclean;
merge work.dataclean datacleanV1;
run;


/*----------------------------------------END OF VARIABLE 1 TO 6---------------------------------*/








/*-----------------------------------------START FOR VARIABLE 7 TO 12----------------------------*/


/*----------------------------------------PART 1---------------------------------*/
/*4. Cleaning of frequency column*/
DATA kfcdatasetv2;
   set mydata.copykfcdataset;
   if prxmatch("/.*Seldom.*/", frequency) > 0 then frequency = 'Seldom';
run;

/*6. Cleaning of favMainFoodItem column*/
/*Separating multiple strings in a column into several columns*/
DATA splitFavMainFoodItem;
   set kfcdatasetv2;
   length var1-var7 $24;
   array var(7) $24;
   do i = 1 to dim(var); /*dim returns the number of elements in 1d array*/
      var[i]=scan(favMainFoodItem,i,',', 'M');
   end;
run;

/*Removing leading & trailing blanks & lowcasing*/
DATA splitFavMainFoodItemv2;
   set splitFavMainFoodItem (keep = var1 var2 var3 var4 var5 var6 var7);
   var1 = lowcase(strip(var1));
   var2 = lowcase(strip(var2));
   var3 = lowcase(strip(var3));
   var4 = lowcase(strip(var4));
   var5 = lowcase(strip(var5));
   var6 = lowcase(strip(var6));
   var7 = lowcase(strip(var7));
run;

/*This ensures that each new column has only 1 distinct value*/
data sortedMainFoodItem;
    set splitFavMainFoodItemv2;
    length newvar1-newvar7 $24;
    array newcolref{7} $24 newvar1-newvar7;
    array colref{7} $24 var1-var7;
	array mainFoodItems{7} $24 ('fried chicken (original)','fried chicken (spicy)','cheezy twister','crispy tenders','nuggets','zinger burger','colonel burger');
	do i = 1 to 7;
		do j = 1 to 7;
			if colref{i} = mainFoodItems{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the mainFoodItems array*/
				leave;
			end;				
		end;
	end;	
RUN;

/*See whether there are invalid values for favMainFoodItems*/
data invalidValSorted;
	set sortedMainFoodItem (keep = var1 var2 var3 var4 var5 var6 var7);
run;

/*Correcting the invalid values*/
data sortedMainFoodItemv2;
	set sortedMainFoodItem;
	if prxmatch("/.*spicy.*/", var1) > 0 then var1 = 'fried chicken (spicy)';
	if prxmatch("/.*original.*/", var1) > 0 then var1 = 'fried chicken (original)';
	if prxmatch("/.*twister.*/", var2) > 0 then var2 = 'cheezy twister';
	if prxmatch("/.*spicy.*/", var2) > 0 then var2 = 'fried chicken (spicy)';
run;

/*Processing the data again*/
data sortedMainFoodItemv3;
    set sortedMainFoodItemv2;
    length newvar1-newvar7 $24;
    array newcolref{7} $24 newvar1-newvar7;
    array colref{7} $24 var1-var7;
	array mainFoodItems{7} $24 ('fried chicken (original)','fried chicken (spicy)','cheezy twister','crispy tenders','nuggets','zinger burger','colonel burger');
	do i = 1 to 7;
		do j = 1 to 7;
			if colref{i} = mainFoodItems{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the mainFoodItems array*/
				leave;
			end;				
		end;
	end;	
RUN;


data sortedMainFoodItemv4;
	set sortedMainFoodItemv3 (keep = newvar1 newvar2 newvar3 newvar4 newvar5 newvar6 newvar7);
run;

DATA sortedMainFoodItemv5; 
  SET sortedMainFoodItemv4; 
  RENAME newvar1 = Fried_Chicken_Original 
       	 newvar2 = Fried_Chicken_Spicy  
       	 newvar3 = Cheezy_Twister  
       	 newvar4 = Crispy_Tenders 
       	 newvar5 = Nuggets 
       	 newvar6 = Zinger_Burger 
       	 newvar7 = Colonel_Burger;
run;

DATA sortedMainFoodItemv5; 
  SET sortedMainFoodItemv5;
  if missing(Fried_Chicken_Original) then Fried_Chicken_Original = 0;
  else Fried_Chicken_Original = 1;
  
  if missing(Fried_Chicken_Spicy) then Fried_Chicken_Spicy  = 0;
  else Fried_Chicken_Spicy = 1;
  
  if missing(Cheezy_Twister) then Cheezy_Twister  = 0;
  else Cheezy_Twister = 1;
  
  if missing(Crispy_Tenders) then Crispy_Tenders  = 0;
  else Crispy_Tenders  = 1;
  
  if missing(Nuggets) then Nuggets = 0;
  else Nuggets = 1;
  
  if missing(Zinger_Burger) then Zinger_Burger  = 0;
  else Zinger_Burger = 1;
  
  if missing(Colonel_Burger) then Colonel_Burger = 0;
  else Colonel_Burger = 1;
RUN;


data work.dataclean;
merge work.dataclean sortedMainFoodItemv5;
run;


data work.dataclean;
	set work.dataclean (drop = favMainFoodItem);
run;

/*-------------------------------------------END OF PART 1---------------------------------*/


/*-----------------------------------------------PART 2-------------------------------------*/
/*7. Cleaning of favSideDish column*/
/*Separating multiple strings in a column into several columns*/
DATA splitFavSideDish;
   set kfcdatasetv2;
   length var1-var9 $22;
   array var(7) $22;
   do i = 1 to dim(var); /*dim returns the number of elements in 1d array*/
      var[i]=scan(favSideDish,i,',', 'M');
   end;
run;

/*Removing leading & trailing blanks & lowcasing*/
DATA splitFavSideDishv2;
   set splitFavSideDish (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9);
   var1 = lowcase(strip(var1));
   var2 = lowcase(strip(var2));
   var3 = lowcase(strip(var3));
   var4 = lowcase(strip(var4));
   var5 = lowcase(strip(var5));
   var6 = lowcase(strip(var6));
   var7 = lowcase(strip(var7));
   var8 = lowcase(strip(var8));
   var9 = lowcase(strip(var9));
run;

/*This ensures that each new column has only 1 distinct value*/
data sortedSideDish;
    set splitFavSideDishv2;
    length newvar1-newvar9 $22;
    array newcolref{9} $22 newvar1-newvar9;
    array colref{9} $22 var1-var9;
	array sideDishes{9} $22 ('fries','banana chocolate balls','wedges','cheezy popcorn bowl','loaded potato bowl','popcorn chicken','whipped potato', 'coleslaw', 'butterscotch bun');
	do i = 1 to 9;
		do j = 1 to 9;
			if colref{i} = sideDishes{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the sideDishes array*/
				leave;
			end;				
		end;
	end;	
RUN;

/*See whether there are invalid values for favSideDish*/
data invalidValSorted;
	set sortedSideDish (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9);
run;


data sortedSideDishv2;
	set sortedSideDish (keep = newvar1 newvar2 newvar3 newvar4 newvar5 newvar6 newvar7 newvar8 newvar9);
run;

data sortedSideDishv3;
	set sortedSideDishv2;
	rename newvar1 = fries
	       newvar2 = banana_chocolate_balls
	       newvar3 = wedges
	       newvar4 = cheezy_popcorn_bowl
	       newvar5 = loaded_potato_bowl
	       newvar6 = popcorn_chicken
	       newvar7 = whipped_potato
	       newvar8 = coleslaw
	       newvar9 = butterscotch_bun;
run;	   

data sortedSideDishv3;
	set sortedSideDishv3;    
	if missing(fries) then fries = 0;
  	else fries = 1;
  	
  	if missing(banana_chocolate_balls) then banana_chocolate_balls = 0;
  	else banana_chocolate_balls = 1;
  	
  	if missing(wedges) then wedges = 0;
  	else wedges = 1;
  	
  	if missing(cheezy_popcorn_bowl) then cheezy_popcorn_bowl = 0;
  	else cheezy_popcorn_bowl = 1;
  	
  	if missing(loaded_potato_bowl) then loaded_potato_bowl = 0;
  	else loaded_potato_bowl = 1;
  	
  	if missing(popcorn_chicken) then popcorn_chicken = 0;
  	else popcorn_chicken = 1;
  	
  	if missing(whipped_potato) then whipped_potato = 0;
  	else whipped_potato = 1;
  	
  	if missing(coleslaw) then coleslaw = 0;
  	else coleslaw = 1;
  	
  	if missing(butterscotch_bun) then butterscotch_bun = 0;
  	else butterscotch_bun = 1;
run;

data work.dataclean;
merge work.dataclean sortedSideDishv3;
run;

/*9. Cleaning of occasion column*/
/*Separating multiple strings in a column into several columns*/
DATA splitOccasion;
   set kfcdatasetv2;
   length var1-var13 $21;
   array var(13) $21;
   do i = 1 to dim(var); /*dim returns the number of elements in 1d array*/
      var[i]=scan(occasion,i,',', 'M');
   end;
run;


/*Removing leading & trailing blanks & lowcasing*/
DATA splitOccasionv2;
   set splitOccasion (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13);
   var1 = lowcase(strip(var1));
   var2 = lowcase(strip(var2));
   var3 = lowcase(strip(var3));
   var4 = lowcase(strip(var4));
   var5 = lowcase(strip(var5));
   var6 = lowcase(strip(var6));
   var7 = lowcase(strip(var7));
   var8 = lowcase(strip(var8));
   var9 = lowcase(strip(var9));
   var10 = lowcase(strip(var10));
   var11 = lowcase(strip(var11));
   var12 = lowcase(strip(var12));
   var13 = lowcase(strip(var13));
run;

/*This ensures that each new column has only 1 distinct value*/
data sortedOccasion;
    set splitOccasionv2;
    length newvar1-newvar13 $21;
    array newcolref{13} $21 newvar1-newvar13;
    array colref{13} $21 var1-var13;
	array occasions{13} $21 ('birthday parties','gatherings','movie night','game night','holiday','family outing','promotional event', 'meal time', 'out shopping', 'when no other choices', 'usual dinner', 'normal meal', 'suddenly want to eat');
	do i = 1 to 13;
		do j = 1 to 13;
			if colref{i} = occasions{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the sideDishes array*/
				leave;
			end;				
		end;
	end;	
RUN;

/*See whether there are invalid values for occasion*/
data invalidValSorted;
	set sortedOccasion (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13);
run;

/*Correcting the invalid values*/
data sortedOccasionv2;
	set sortedOccasion;
	if prxmatch("/.*parties.*/", var1) > 0 then var1 = 'birthday parties';
	if prxmatch("/.*gath.*/", var1) > 0 then var1 = 'gatherings';
	if prxmatch("/.*promo.*/", var1) > 0 then var1 = 'promotional event';
	if prxmatch("/.*game.*/", var2) > 0 then var2 = 'game night';
	if prxmatch("/.*holiday.*/", var2) > 0 then var2 = 'holiday';
run;	

/*Processing the data again*/
data sortedOccasionv3;
    set sortedOccasionv2;
    length newvar1-newvar13 $21;
    array newcolref{13} $21 newvar1-newvar13;
    array colref{13} $21 var1-var13;
	array occasions{13} $21 ('birthday parties','gatherings','movie night','game night','holiday','family outing','promotional event', 'meal time', 'out shopping', 'when no other choices', 'usual dinner', 'normal meal', 'suddenly want to eat');
	do i = 1 to 13;
		do j = 1 to 13;
			if colref{i} = occasions{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the sideDishes array*/
				leave;
			end;				
		end;
	end;	
RUN;

data sortedOccasionv4;
	set sortedOccasionv3 (keep = newvar1 newvar2 newvar3 newvar4 newvar5 newvar6 newvar7 newvar8 newvar9 newvar10 newvar11 newvar12 newvar13);
run;

data sortedOccasionv5;
	set sortedOccasionv4;
	rename newvar1 = birthday_parties
	       newvar2 = gatherings
	       newvar3 = movie_night
	       newvar4 = game_night
	       newvar5 = holiday
	       newvar6 = family_outing
	       newvar7 = promotional_event
	       newvar8 = meal_time
	       newvar9 = out_shopping
	       newvar10 = when_no_other_choices
	       newvar11 = usual_dinner
	       newvar12 = normal_meal
	       newvar13 = suddenly_want_to_eat;
run;

data sortedOccasionv5;
	set sortedOccasionv5;
	if missing(birthday_parties) then birthday_parties = 0;
    else birthday_parties = 1;
    
    if missing(gatherings) then gatherings = 0;
    else gatherings = 1;
    
    if missing(movie_night) then movie_night = 0;
    else movie_night = 1;
    
    if missing(game_night) then game_night = 0;
    else game_night = 1;
    
    if missing(holiday) then holiday = 0;
    else holiday = 1;
    
    if missing(family_outing) then family_outing = 0;
    else family_outing = 1;
    
    if missing(promotional_event) then promotional_event = 0;
    else promotional_event = 1;
    
    if missing(meal_time) then meal_time = 0;
    else meal_time = 1;
    
    if missing(out_shopping) then out_shopping = 0;
    else out_shopping = 1;
    
    if missing(when_no_other_choices) then when_no_other_choices = 0;
    else when_no_other_choices = 1;
    
    if missing(usual_dinner) then usual_dinner = 0;
    else usual_dinner = 1;
    
    if missing(normal_meal) then normal_meal = 0;
    else normal_meal = 1;
    
    if missing(suddenly_want_to_eat) then suddenly_want_to_eat = 0;
    else suddenly_want_to_eat = 1;
run;
    
data work.dataclean;
merge work.dataclean sortedOccasionv5;
run;

/*10. Cleaning of factors column*/
/*Separating multiple strings in a column into several columns*/
DATA splitFactor;
   set kfcdatasetv2;
   length var1-var10 $41;
   array var(10) $41;
   do i = 1 to dim(var); /*dim returns the number of elements in 1d array*/
      var[i]=scan(factors,i,',', 'M');
   end;
run;

/*Removing leading & trailing blanks & lowcasing*/
DATA splitFactorv2;
   set splitFactor (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9 var10);
   var1 = lowcase(strip(var1));
   var2 = lowcase(strip(var2));
   var3 = lowcase(strip(var3));
   var4 = lowcase(strip(var4));
   var5 = lowcase(strip(var5));
   var6 = lowcase(strip(var6));
   var7 = lowcase(strip(var7));
   var8 = lowcase(strip(var8));
   var9 = lowcase(strip(var9));
   var10 = lowcase(strip(var10));
run;

/*This ensures that each new column has only 1 distinct value*/
data sortedFactor;
    set splitFactorv2;
    length newvar1-newvar10 $41;
    array newcolref{10} $41 newvar1-newvar10;
    array colref{10} $41 var1-var10;
	array factor{10} $41 ('delicious food','pleasant & clean environment','good service','reasonable prices','occasional introduction of new food items','promotions','free toys', 'reasonable food portion', 'reasonably fast food preparation', 'brand reputation');
	do i = 1 to 10;
		do j = 1 to 10;
			if colref{i} = factor{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the mainFoodItems array*/
				leave;
			end;				
		end;
	end;	
RUN;

/*See whether there are invalid values for factors*/
data invalidValSorted;
	set sortedFactor (keep = var1 var2 var3 var4 var5 var6 var7 var8 var9 var10);
run;

/*Correcting the invalid values*/
data sortedFactorv2;
	set sortedFactor;
	if prxmatch("/.*delicious.*/", var1) > 0 then var1 = 'delicious food';
run;	

/*Processing the data again*/
data sortedFactorv3;
    set sortedFactorv2;
    length newvar1-newvar10 $41;
    array newcolref{10} $41 newvar1-newvar10;
    array colref{10} $41 var1-var10;
	array factor{10} $41 ('delicious food','pleasant & clean environment','good service','reasonable prices','occasional introduction of new food items','promotions','free toys', 'reasonable food portion', 'reasonably fast food preparation', 'brand reputation');
	do i = 1 to 10;
		do j = 1 to 10;
			if colref{i} = factor{j} then do;
				newcolref{j} = colref{i};
				colref{i} = ' '; /*to see whether there are any values in the dataset that are not found in the mainFoodItems array*/
				leave;
			end;				
		end;
	end;	
RUN;

data sortedFactorv4;
	set sortedFactorv3 (keep = newvar1 newvar2 newvar3 newvar4 newvar5 newvar6 newvar7 newvar8 newvar9 newvar10);
run;

data sortedFactorv5;
	set sortedFactorv4;
	rename newvar1 = delicious_food
	       newvar2 = pleasant_clean_environment
	       newvar3 = good_service
	       newvar4 = reasonable_prices
	       newvar5 = occa_intro_of_new_food_items
	       newvar6 = promotions
	       newvar7 = free_toys
	       newvar8 = reasonable_food_portion
	       newvar9 = reasonably_fast_food_preparation
	       newvar10 = brand_reputation;
run;

data sortedFactorv5;
	set sortedFactorv5;
	if missing(delicious_food) then delicious_food = 0;
    else delicious_food = 1;
    
    if missing(pleasant_clean_environment) then pleasant_clean_environment = 0;
    else pleasant_clean_environment = 1;
    
    if missing(good_service) then good_service = 0;
    else good_service = 1;
    
    if missing(reasonable_prices) then reasonable_prices = 0;
    else reasonable_prices = 1;
    
    if missing(occa_intro_of_new_food_items) then occa_intro_of_new_food_items = 0;
    else occa_intro_of_new_food_items = 1;
    
    if missing(promotions) then promotions = 0;
    else promotions = 1;
    
    if missing(free_toys) then free_toys = 0;
    else free_toys = 1;
    
    if missing(reasonable_food_portion) then reasonable_food_portion = 0;
    else reasonable_food_portion = 1;
    
    if missing(reasonably_fast_food_preparation) then reasonably_fast_food_preparation = 0;
    else reasonably_fast_food_preparation = 1;
    
    if missing(brand_reputation) then brand_reputation = 0;
    else brand_reputation = 1;
run;

data work.dataclean;
merge work.dataclean sortedFactorv5;
run;


data work.dataclean;
	set work.dataclean (drop = favSideDish factors occasion);
run;

/*-----------------------------END OF PART 2---------------------------------*/






/*------------------------------------------VARIABLE 13 TO 18--------------------------------*/
/*FOR VARIABLE 13- ORDER PLACEMENT METHOD*/
data work.datacleanV2;
set mydata.copykfcdataset;

std = upcase(strip(compbl(tranwrd(orderPlacementMethod, "PICK-UP", "PICKUP"))));

method1= scan(std, 1, ',');
method2= scan(std, 2, ',');
method3= scan(std, 3, ',');
method4= scan(std, 4, ',');
method5= scan(std, 5, ',');

drop std;
drop orderPlacementMethod;
run;


/*----------------------------------------------------------*/



data work.datacleanV2;
set work.datacleanV2;

nOrder_at_counter = 0;
nDrive_thru = 0;
nOrder_via_KFC_app_delivery = 0;
nOrder_via_KFC_app_pickup = 0;
nOrder_via_third_party_apps = 0;

if findw(method1, 'ORDER AT COUNTER') or findw(method2, 'ORDER AT COUNTER') or 
findw(method3, 'ORDER AT COUNTER') or findw(method4, 'ORDER AT COUNTER') or 
findw(method5, 'ORDER AT COUNTER') then nOrder_at_counter = 1;

if findw(method1, 'DRIVE THRU') or findw(method2, 'DRIVE THRU') or 
findw(method3, 'DRIVE THRU') or findw(method4, 'DRIVE THRU')
or findw(method5, 'DRIVE THRU') then nDrive_thru = 1;

if findw(method1, 'WEBSITE FOR SELF PICK-UP') or
   findw(method2, 'WEBSITE FOR SELF PICK-UP') or 
   findw(method3, 'WEBSITE FOR SELF PICK-UP') or
   findw(method4, 'WEBSITE FOR SELF PICK-UP') or 
   findw(method5, 'WEBSITE FOR SELF PICK-UP') 
   then nOrder_via_KFC_app_pickup = 1;

if findw(method1, 'WEBSITE FOR DELIVERY') or 
findw(method2, 'WEBSITE FOR DELIVERY') or 
findw(method3, 'WEBSITE FOR DELIVERY') or
findw(method4, 'WEBSITE FOR DELIVERY') or
findw(method5, 'WEBSITE FOR DELIVERY') 
then nOrder_via_KFC_app_delivery = 1;


if findw(method1, 'THIRD PARTY APPS') or 
findw(method2, 'THIRD PARTY APPS') or 
findw(method3, 'THIRD PARTY APPS') or
findw(method4, 'THIRD PARTY APPS') or 
findw(method5, 'THIRD PARTY APPS') 
then nOrder_via_third_party_apps = 1;


drop method1 method2 method3 method4 method5;
run;

/*
data work.dataclean;
merge work.dataclean datacleanV2;
run;
*/

/*USING SET*/
data work.dataclean;
set work.datacleanV2;
set work.dataclean;
run;
/*-----------------------------------------------------------------------*/




/*FOR VARIABLE-HowCustKnowAbtKfc*/
data work.datacleanV3;
set mydata.copykfcdataset;

std2 = upcase(strip(compbl(howCustKnewAbtKfc)));

method1HC= scan(std2, 1, ',');
method2HC= scan(std2, 2, ',');
method3HC= scan(std2, 3, ',');
method4HC= scan(std2, 4, ',');


drop std2;
drop howCustKnewAbtKfc;
run;


/*-----------------------------------------------------------------------*/

data work.datacleanV3;
set work.datacleanV3;

Television = 0;
Newspaper = 0;
Online = 0;
Word_of_mouth = 0;

if findw(method1HC, 'TELEVISION') or findw(method2HC, 'TELEVISION') or 
findw(method3HC, 'TELEVISION') or findw(method4HC, 'TELEVISION') then Television = 1;

if findw(method1HC, 'NEWSPAPER') or findw(method2HC, 'NEWSPAPER') or 
findw(method3HC, 'NEWSPAPER') or findw(method4HC, 'NEWSPAPER') then Newspaper = 1;

if findw(method1HC, 'ONLINE') or findw(method2HC, 'ONLINE') or 
findw(method3HC, 'ONLINE') or findw(method4HC, 'ONLINE') then Online = 1;

if findw(method1HC, 'WORD OF MOUTH') or findw(method2HC, 'WORD OF MOUTH') or 
findw(method3HC, 'WORD OF MOUTH') or findw(method4HC, 'WORD OF MOUTH') then Word_of_mouth = 1;

drop method1HC method2HC method3HC method4HC;
run;

/*
data work.dataclean;
merge work.dataclean datacleanV3;
run;
*/

/*USING SET*/
data work.dataclean;
set work.datacleanV3;
set work.dataclean;
run;

data work.dataclean;
	set work.dataclean (drop = orderPlacementMethod howCustKnewAbtKfc);
run;



/*-----------------------------END OF VARIABLE 13 TO 18-----------------------------------*/






/*-----------------------------------VARIABLE 19 TO 23-------------------------------------*/
DATA work.datacleanV4;
    SET mydata.copykfcdataset;

    /* Check 'orderPlacementMethod' for 'Order via KFC app/ website for delivery' */
    IF INDEX(orderPlacementMethod, "Order via KFC app/ website for delivery") > 0 THEN DO;
        IF kfcDelRating = . THEN PUT "Warning: Missing kfcDelRating value for 'Order via KFC app/ website for delivery'!";
    END;
    ELSE kfcDelRating = .;

    /* Check 'orderPlacementMethod' for 'Order via KFC app/ website for self pick-up' or 'Order via KFC app/ website for delivery' */
    IF INDEX(orderPlacementMethod, "Order via KFC app/ website for self pick-up") > 0 OR INDEX(orderPlacementMethod, "Order via KFC app/ website for delivery") > 0 THEN DO;
        IF kfcOrderRating = . THEN PUT "Warning: Missing kfcOrderRating value for 'Order via KFC app/ website for self pick-up' or 'Order via KFC app/ website for delivery'!";
    END;
    ELSE kfcOrderRating = .;

    /* Display the specified columns */
    /*KEEP envRating overallRating kfcDelRating kfcOrderRating recommendKFC orderPlacementMethod;*/
RUN;

/*
data work.dataclean;
merge work.dataclean datacleanV4;
run;
*/

/*USING SET*/
data work.dataclean;
set work.datacleanV4;
set work.dataclean;
run;
/*------------------------------------------------END OF VARIABLE 19 TO 23------------------*/


/*-------------REMOVING THE VARIABLES THAT WE HAVE DONE ENCODING----------------*/

data work.dataclean;
	set work.dataclean (drop = orderPlacementMethod howCustKnewAbtKfc favSideDish factors occasion favMainFoodItem);
run;


/*-----SET AS PERMANENT DATA----*/
libname mydata "/home/u63377660";
data mydata.dckfcdataset;
set dataclean;
run;

