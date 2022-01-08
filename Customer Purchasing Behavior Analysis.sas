libname cy 'D:\project\SAS datasets';

PROC IMPORT OUT= CY.CUS_BEHA_origin 
            DATAFILE= "D:\project\Customer Purchasing Behaviours.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
     GUESSINGROWS=100; 
RUN;

proc print data=CY.CUS_BEHA_origin(obs =100);
run;


proc contents data=CY.CUS_BEHA_origin;
run;

proc contents data=CY.CUS_BEHA_origin  varnum short;
run;

*PURCHASE ACCTNUM CUSTDATE DAYS_BECUS JOBNAME JOB MARITAL NTITLE SEX 
AGE RACE EDLEVEL NUMKIDS NUMKID_BIN NUMCARS COUNTRY STATENAME REGION 
COUNTYNUM COUNTY STATECOD INCOME HOMEVAL DINING TRAVTIME HEAT FREQUENT 
AMOUNT RECENCY RETURN TELIND TMKTORD VALRATIO PROMO7 PROMO13 APRTMNT 
MOBILE DOMESTIC APPAREL LEISURE KITCHEN LUXURY MENSWARE FLATWARE 
DISHES HOMEACC LAMPS LINENS BLANKETS TOWELS OUTDOOR COATS WCOAT WAPPAR 
HHAPPAR JEWELRY ;

proc means data=CY.CUS_BEHA_origin n nmiss mean median max min std;
run;

proc freq data=CY.CUS_BEHA_origin;
table PURCHASE ACCTNUM CUSTDATE DAYS_BECUS JOB MARITAL NTITLE SEX AGE 
RACE EDLEVEL NUMKIDS NUMKID_BIN NUMCARS COUNTRY STATENAME REGION 
COUNTYNUM COUNTY STATECOD INCOME HOMEVAL DINING TRAVTIME HEAT 
FREQUENT AMOUNT RECENCY RETURN TELIND TMKTORD VALRATIO PROMO7 
PROMO13 APRTMNT MOBILE DOMESTIC APPAREL LEISURE KITCHEN LUXURY 
MENSWARE FLATWARE DISHES HOMEACC LAMPS LINENS BLANKETS TOWELS 
OUTDOOR COATS WCOAT WAPPAR HHAPPAR JEWELRY/missing;
run;

proc contents data=CY.CUS_BEHA_origin out=cy.cus_vars;
run;

data  cy.cus_behaviors(drop=COUNTRY);
set cy.cus_beha_origin;
run; 

proc contents data=cy.CUS_BEHAVIORS;
run;


***********************************************************;
*Data Profiling;
***********************************************************;
*For Numeric Variables;
%MACRO DP_NUMERIC (DSN = );
PROC CONTENTS DATA = cy.&DSN. OUT= cy.&DSN._VARS;RUN;
PROC SQL;
SELECT NAME INTO : NUM_ONLY SEPARATED BY " "
FROM cy.&DSN._VARS
WHERE TYPE EQ 1
;
QUIT;
%LET N = %SYSFUNC(COUNTW(&NUM_ONLY));
%DO I = 1 %TO &N;
	%LET X = %SCAN(&NUM_ONLY,&I);
ODS PDF FILE = "D:\script\dataprofiling numeric\DATA_PROFILING_&X._&SYSDATE9..PDF";
TITLE "DISTRIBUTION OF NUMERIC VARIABLE : &X.";
PROC MEANS DATA = cy.&DSN N NMISS MIN MEDIAN MEAN MAX STD MAXDEC=2;
 VAR &X.;
RUN;
TITLE "GRAPHIC DISTRIBUTION OF NUMERIC VARAIBLE : &X.";
PROC SGPLOT DATA = cy.&DSN.;
 HISTOGRAM &X.;
 DENSITY &X./TYPE = KERNEL;
KEYLEGEND / LOCATION=INSIDE POSITION=TOPRIGHT ACROSS=1 NOBORDER;
RUN;
QUIT;

TITLE "GRAPHIC DISTRIBUTION (VERTICAL BAR) OF NUMERIC VARAIBLE : &X.";
PROC SGPLOT DATA = cy.&DSN.;
 VBOX &X.;
 yaxis grid;
 xaxis display=(nolabel);
RUN;
QUIT;
ODS PDF CLOSE;
%END;
%MEND;

%dp_numeric (DSN = Cus_Behaviors);

*For categorical variables;
%MACRO DP_CHAR (DSN = );
PROC SQL;
SELECT NAME INTO : CHAR_ONLY SEPARATED BY " "
FROM cy.&DSN._VARS
WHERE TYPE EQ 2
;
QUIT;
%LET N = %SYSFUNC(COUNTW(&CHAR_ONLY));
%DO I = 1 %TO &N;
	%LET X = %SCAN(&CHAR_ONLY,&I);
ODS PDF FILE = "D:\script\dataprofiling categorical\DATA_PROFILING_&X._&SYSDATE9..PDF";
TITLE "DISTRIBUTION OF CATEGORICAL VARIABLE : &X.";
PROC freq DATA = cy.&DSN order=freq;
TABLE &X./MISSING;
RUN;

TITLE "GRAPHIC DISTRIBUTION (VERTICAL BAR) OF CATEGORICAL VARAIBLE : &X.";
PROC SGPLOT DATA = cy.&DSN.;
 VBAR &X.;
 STYLEATTRS 
    BACKCOLOR=lightblue 
    WALLCOLOR=lightyellow;
RUN;
QUIT;
ODS PDF CLOSE;
%END;
%MEND;


%dp_CHAR (DSN = Cus_Behaviors);

**************************************************************;
*EDA;
**************************************************************;

*Univariate Analysis;
*Change some numeric variables into categorical variables;
proc contents data=CY.cus_behaviors;
run;

data cy.cus_eda(drop=APPAREL BLANKETS COATS 
DINING DISHES DOMESTIC  FLATWARE HHAPPAR HOMEACC JEWELRY
KITCHEN LAMPS LEISURE LINENS MENSWARE OUTDOOR TOWELS WAPPAR 
WCOAT ACCTNUM TELIND TMKTORD MARITAL APRTMNT MOBILE RACE 
HEAT NUMCARS NUMKIDS EDLEVEL JOB LUXURY COUNTY COUNTYNUM 
CUSTDATE STATECOD STATENAME NUMKIDS PURCHASE);
set cy.cus_behaviors;

TELIND_CATE=put(TELIND,$4.);
TMKTORD_CATE=put(TMKTORD,$4.);
MARITAL_CATE=put(MARITAL,$4.);
APRTMNT_CATE=put(APRTMNT,$4.);
MOBILE_CATE=put(MOBILE,$4.);
RACE_CATE=put(RACE,$4.);
NUMCARS_CATE=put(NUMCARS,$4.);
NUMKIDS_CATE=put(NUMKIDS,$4.);
LUXURY_CATE=put(LUXURY,$4.);
PURCHASE_CATE=put(PURCHASE,$4.);

APPAREL_CATE=put(APPAREL,$4.);
BLANKETS_CATE=PUT(BLANKETS,$4.);
COATS_CATE=PUT(COATS,$4.);
DINING_CATE=PUT(DINING,$4.);
DISHES_CATE=PUT(DISHES,$4.);
DOMESTIC_CATE=PUT(DOMESTIC,$4.);
FLATWARE_CATE=PUT(FLATWARE,$4.);
HHAPPAR_CATE=PUT(HHAPPAR,$4.);
HOMEACC_CATE=PUT(HOMEACC,$4.);
JEWELRY_CATE=PUT(JEWELRY,$4.);
KITCHEN_CATE=PUT(KITCHEN,$4.);
LAMPS_CATE=PUT(LAMPS,$4.);
LEISURE_CATE=PUT(LEISURE,$4.);
LINENS_CATE=PUT(LINENS,$4.);
MENSWARE_CATE=PUT(MENSWARE,$4.);
OUTDOOR_CATE=PUT(OUTDOOR,$4.);
TOWELS_CATE=PUT(TOWELS,$4.);
WAPPAR_CATE=PUT(WAPPAR,$4.);
WCOAT_CATE=PUT(WCOAT,$4.);
RETURN_CATE=PUT(RETURN,$4.);
run;


proc contents data=cy.cus_eda;
run;



%macro univ(DSN= );
PROC CONTENTS DATA = cy.&DSN. OUT= cy.&DSN._PROJECT_VARS;RUN;
PROC SQL;
SELECT NAME INTO : NUM_ONLY SEPARATED BY " "
FROM cy.&DSN._PROJECT_VARS
WHERE TYPE EQ 1
;
SELECT NAME INTO : CHAR_ONLY SEPARATED BY " "
FROM cy.&DSN._PROJECT_VARS
WHERE TYPE EQ 2
;
QUIT;

%LET M = %SYSFUNC(COUNTW(&CHAR_ONLY));
%DO J = 1 %TO &M.;
	%LET X = %SCAN(&CHAR_ONLY,&J.);

ODS PDF FILE = "D:\script\EDA Univariate Analysis\CATEGORICAL\UNIV_&X._&SYSDATE9..PDF";

TITLE "COUNT BY &X.";
PROC FREQ DATA = cy.&DSN. ; 
TABLE &X./missing; 
RUN;
TITLE "COUNT BY &X.";
PROC SGPLOT DATA = cy.&DSN.; 
VBAR &X./categoryorder=respDESC barwidth=0.6 fillattrs=graphdata4 
dataskin=pressed
         baselineattrs=(thickness=0); 
xaxis display=(nolabel);
RUN;
QUIT;

PROC TEMPLATE; 
DEFINE STATGRAPH PIE;  
BEGINGRAPH;    
ENTRYTITLE "COUNT BY &X.";  
LAYOUT REGION;      
PIECHART CATEGORY=&X. / DATALABELLOCATION=OUTSIDE DATASKIN = CRISP  
DATALABELCONTENT = ALL CATEGORYDIRECTION = CLOCKWISE START = 180 NAME = 'pie' ; 
DISCRETELEGEND 'pie'; 
ENDLAYOUT;  
ENDGRAPH; 
END; 
RUN; 
PROC SGRENDER DATA =  cy.&DSN.
TEMPLATE = PIE;
RUN;
title;
quit;
ODS PDF CLOSE;
%END;
%LET N = %SYSFUNC(COUNTW(&NUM_ONLY));
%DO I = 1 %TO &N.;
	%LET Y = %SCAN(&NUM_ONLY,&I.);
ODS PDF FILE = "D:\script\EDA Univariate Analysis\NUMERIC\UNIV_&Y._&SYSDATE9..PDF";
TITLE "THIS IS HISTOGRAM FOR &Y.";
PROC SGPLOT DATA=cy.&DSN.;
  HISTOGRAM &Y.;
  DENSITY &Y.;
  DENSITY &Y./type=kernel ;
    STYLEATTRS 
    BACKCOLOR=LIGHTBLUE 
    WALLCOLOR=LIGHTYELLOW
     ;
  keylegend / location=inside position=topright;
 RUN;
 QUIT;
 TITLE "THIS IS HORIZONTAL BOXPLOT FOR &Y.";
 PROC SGPLOT DATA=cy.&DSN.;
  HBOX &Y.;
    STYLEATTRS 
    BACKCOLOR=lightblue 
    WALLCOLOR=lightyellow
     ;
 RUN;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &Y. IN cy.&DSN.";
proc means data=cy.&DSN. n nmiss mean median min max lclm uclm std qrange maxdec=2;
var &Y.;
run;
title;
quit;
ODS PDF CLOSE;
%END;
%mend;

%univ(DSN=cus_eda);


*********************************************
* Binning;
proc sql;
SELECT NAME 
FROM cy.cus_eda_PROJECT_VARS
WHERE TYPE EQ 1;
run;
quit;


*AGE 
AMOUNT 
DAYS_BECUS 
FREQUENT 
HOMEVAL 
INCOME 
PROMO7 
PROMO13 
RECENCY 
RETURN 
TRAVTIME 
VALRATIO 
; 

proc print DATA = cy.cus_eda(obs=10);
run;

PROC HPBIN DATA = cy.cus_eda  OUTPUT=cy.cus_eda_BIN PSEUDO_QUANTILE;
INPUT AMOUNT /NUMBIN=5;
INPUT DAYS_BECUS /NUMBIN=3;
INPUT FREQUENT /NUMBIN=5;
INPUT HOMEVAL /NUMBIN=5;
INPUT INCOME /NUMBIN=5;
INPUT PROMO7 /NUMBIN=3;
INPUT PROMO13 /NUMBIN=3;
INPUT RECENCY /NUMBIN=5;
INPUT TRAVTIME /NUMBIN=3;
INPUT VALRATIO /NUMBIN=3;
INPUT AGE /NUMBIN=5;

RUN;
proc print data=cy.cus_eda_bin;
run;


*CUT POINTS;
/*DAYS_BECUS*/
/**/
/*BIN_DAYS_BECUS*/
/*DAYS_BECUS < 523.0046 655 0.33316378 */
/*523.0046 <= DAYS_BECUS < 578.0218 656 0.33367243 */
/*578.0218 <= DAYS_BECUS 655 0.33316378 */
/**/
/*INCOME*/
/**/
/*BIN_INCOME*/
/*INCOME < 22705.65 400 0.20345880 */
/*22705.65 <= INCOME < 27007.2 389 0.19786368 */
/*27007.2 <= INCOME < 31809.69 397 0.20193286 */
/*31809.69 <= INCOME < 39007.98 388 0.19735504 */
/*39007.98 <= INCOME 392 0.19938962 */

/*HOMEVAL*/
/*BIN_HOMEVAL*/
/*HOMEVAL < 40440 393 0.19989827 */
/*40440 <= HOMEVAL < 54360 397 0.20193286 */
/*54360 <= HOMEVAL < 69120 390 0.19837233 */
/*69120 <= HOMEVAL < 111240 394 0.20040692 */
/*111240 <= HOMEVAL 392 0.19938962 */
/**/

/*TRAVTIME*/
/*BIN_TRAVTIME*/
/*TRAVTIME < 17.001 769 0.39114954 */
/*17.001 <= TRAVTIME < 21.006 550 0.27975585 */
/*21.006 <= TRAVTIME 647 0.32909461 */
/**/
/*FREQUENT*/
/*BIN_FREQUENT*/
/*FREQUENT < 1.08231 395 0.20091556 */
/*1.08231 <= FREQUENT < 1.74044 396 0.20142421 */
/*1.74044 <= FREQUENT < 2.60317 390 0.19837233 */
/*2.60317 <= FREQUENT < 4.37296 392 0.19938962 */
/*4.37296 <= FREQUENT 393 0.19989827 */

/*AMOUNT*/
/*BIN_AMOUNT*/
/*AMOUNT < 45.169 425 0.21617497 */
/*45.169 <= AMOUNT < 148.792 365 0.18565615 */
/*148.792 <= AMOUNT < 324.154 393 0.19989827 */
/*324.154 <= AMOUNT < 697.4625 391 0.19888098 */
/*697.4625 <= AMOUNT 392 0.19938962 */
/**/
/*RECENCY*/
/*BIN_RECENCY*/
/*RECENCY < 26.0491 395 0.20091556 */
/*26.0491 <= RECENCY < 78.008 395 0.20091556 */
/*78.008 <= RECENCY < 182.0651 396 0.20142421 */
/*182.0651 <= RECENCY < 316.0717 389 0.19786368 */
/*316.0717 <= RECENCY 391 0.19888098 */


/*VALRATIO*/
/*BIN_VALRATIO*/
/*VALRATIO < 2.3667 657 0.33418108 */
/*2.3667 <= VALRATIO < 8.7465 655 0.33316378 */
/*8.7465 <= VALRATIO 654 0.33265514 */

/*PROMO7*/
/*BIN_PROMO7*/
/*PROMO7 < 23.0102 678 0.34486267 */
/*23.0102 <= PROMO7 < 44.0016 644 0.32756867 */
/*44.0016 <= PROMO7 644 0.32756867 */

/*PROMO13*/
/*BIN_PROMO13*/
/*PROMO13 < 10.0048 672 0.34181078 */
/*10.0048 <= PROMO13 < 30.007 648 0.32960326 */
/*30.007 <= PROMO13 646 0.32858596 */
/**/

/*AGE*/
/*BIN_AGE*/
/*AGE < 26.0005 477 0.24262462 */
/*26.0005 <= AGE < 29.0042 388 0.19735504 */
/*29.0042 <= AGE < 32.003 389 0.19786368 */
/*32.003 <= AGE < 36.0014 356 0.18107833 */
/*36.0014 <= AGE */


********************************************************;
*MAKE SOME VARIABLES GROUPS;
***********************************************************;
proc contents data=cy.cus_behaviors;
RUN;




data cy.cus_eda_group ;
set cy.cus_behaviors;

if missing(RETURN) then RETURN_GROUP="No Return                           ";
else if RETURN eq 0 then RETURN_GROUP="Return 0 Item";
else if 1=<RETURN=<3 then RETURN_GROUP="Return 1-3 Items";
else RETURN_GROUP="Return more than 3 Items";

if DAYS_BECUS<=520 then DAYS_BECUS_GROUP="Less than 520 days                           ";
else if 520<DAYS_BECUS<580 then DAYS_BECUS_GROUP="520-580 days";
else DAYS_BECUS_GROUP="More than 580 days";

if INCOME<22700 then INCOME_GROUP="Less than 22700                          ";
else if 22700<=INCOME<27000 then INCOME_GROUP="22700-27000";
else if 27000<=INCOME<31800 then INCOME_GROUP="27000-31800";
else if 31800<=INCOME<39000 then INCOME_GROUP="31800-39000";
else INCOME_GROUP="More than 39000";

if HOMEVAL<40440 then HOMEVAL_GROUP="Less than 40440                          ";
else if 40440<=HOMEVAL<54360 then HOMEVAL_GROUP="40440-54360";
else if 54360<=HOMEVAL<69120 then HOMEVAL_GROUP="54360-69120";
else if 69120<=HOMEVAL<111240 then HOMEVAL_GROUP="69120-111240";
else HOMEVAL_GROUP="More than 111240";

if TRAVTIME<=17 then TRAVTIME_GROUP="Less than 17 days                           ";
else if 17<TRAVTIME<21 then TRAVTIME_GROUP="17-21 days";
else TRAVTIME_GROUP="More than 21 days";

if FREQUENT<1.08 then FREQUENT_SCORE="1                          ";
else if 1.08<=FREQUENT<1.74 then FREQUENT_SCORE="2";
else if 1.74<=FREQUENT<2.60 then FREQUENT_SCORE="3";
else if 2.60<=FREQUENT<4.37 then FREQUENT_SCORE="4";
else FREQUENT_SCORE="5";

if AMOUNT<45.17 then AMOUNT_SCORE="1                          ";
else if 45.17<=AMOUNT<148.79 then AMOUNT_SCORE="2";
else if 148.79<=AMOUNT<324.15 then AMOUNT_SCORE="3";
else if 324.15<=AMOUNT<697.46 then AMOUNT_SCORE="4";
else AMOUNT_SCORE="5";

if RECENCY<26 then RECENCY_SCORE="5                             ";
else if 26<=RECENCY<78 then RECENCY_SCORE="4";
else if 78<=RECENCY<182 then RECENCY_SCORE="3";
else if 182<=RECENCY<316 then RECENCY_SCORE="2";
else RECENCY_SCORE="1";

if VALRATIO<=2.36 then VALRATIO_GROUP="Less than 2.36                           ";
else if 2.36<VALRATIO<8.75 then VALRATIO_GROUP="2.36-8.75";
else VALRATIO_GROUP="More than 8.75";

if AGE<26 then AGE_GROUP="Less than 26 years old                          ";
else if 26<=AGE<29 then AGE_GROUP="26-29 years old";
else if 29<=AGE<32 then AGE_GROUP="29-32 years old";
else if 32<=AGE<36 then AGE_GROUP="32-36 years old";
else AGE_GROUP="More than 36 years old";

if PROMO7<23 then PROMO7_GROUP="Low level                          ";
else if 23<=PROMO7<44 then PROMO7_GROUP="Middle level";
else PROMO7_GROUP="High level";

if PROMO13<10 then PROMO13_GROUP="Low level                          ";
else if 10<=PROMO13<30 then PROMO13_GROUP="Middle level";
else PROMO13_GROUP="High level";

if APPAREL EQ 0 then APPAREL_GROUP="No orders                          ";
else if 1<=APPAREL<=2 then APPAREL_GROUP="1-2 orders";
else APPAREL_GROUP="3+ orders";

if BLANKETS EQ 0 then BLANKETS_GROUP="No orders                          ";
else if 1<=BLANKETS<=2 then BLANKETS_GROUP="1-2 orders";
else BLANKETS_GROUP="3+ orders";

if COATS EQ 0 then COATS_GROUP="No orders                          ";
else if 1<=COATS<=2 then COATS_GROUP="1-2 orders";
else COATS_GROUP="3+ orders";

if DINING EQ 0 then DINING_GROUP="No orders                          ";
else if 1<=DINING<=2 then DINING_GROUP="1-2 orders";
else DINING_GROUP="3+ orders";

if DISHES EQ 0 then DISHES_GROUP="No orders                          ";
else if 1<=DISHES<2 then DISHES_GROUP="one orders";
else DISHES_GROUP="2+ orders";

if DOMESTIC EQ 0 then DOMESTIC_GROUP="No orders                          ";
else if 1<=DOMESTIC<=2 then DOMESTIC_GROUP="1-2 orders";
else DOMESTIC_GROUP="3+ orders";

if FLATWARE EQ 0 then FLATWARE_GROUP="No orders                          ";
else if 1<=FLATWARE<2 then FLATWARE_GROUP="one orders";
else FLATWARE_GROUP="2+ orders";

if HHAPPAR EQ 0 then HHAPPAR_GROUP="No orders                          ";
else if 1<=HHAPPAR<=2 then HHAPPAR_GROUP="1-2 orders";
else HHAPPAR_GROUP="3+ orders";

if HOMEACC EQ 0 then HOMEACC_GROUP="No orders                          ";
else if 1<=HOMEACC<2 then HOMEACC_GROUP="one orders";
else HOMEACC_GROUP="2+ orders";

if JEWELRY EQ 0 then JEWELRY_GROUP="No orders                          ";
else if 1<=JEWELRY<2 then JEWELRY_GROUP="one orders";
else JEWELRY_GROUP="2+ orders";

if KITCHEN EQ 0 then KITCHEN_GROUP="No orders                          ";
else if 1<=KITCHEN<2 then KITCHEN_GROUP="one orders";
else KITCHEN_GROUP="2+ orders";

if LAMPS EQ 0 then LAMPS_GROUP="No orders                          ";
else if 1<=LAMPS<2 then LAMPS_GROUP="one orders";
else LAMPS_GROUP="2+ orders";

if LEISURE EQ 0 then LEISURE_GROUP="No orders                          ";
else if 1<=LEISURE<2 then LEISURE_GROUP="one orders";
else LEISURE_GROUP="2+ orders";

if LINENS EQ 0 then LINENS_GROUP="No orders                          ";
else if 1<=LINENS<2 then LINENS_GROUP="one orders";
else LINENS_GROUP="2+ orders";

if MENSWARE EQ 0 then MENSWARE_GROUP="No orders                          ";
else if 1<=MENSWARE<2 then MENSWARE_GROUP="one orders";
else MENSWARE_GROUP="2+ orders";

if OUTDOOR EQ 0 then OUTDOOR_GROUP="No orders                          ";
else if 1<=OUTDOOR<2 then OUTDOOR_GROUP="one orders";
else OUTDOOR_GROUP="2+ orders";

if TOWELS EQ 0 then TOWELS_GROUP="No orders                          ";
else if 1<=TOWELS<=2 then TOWELS_GROUP="1-2 orders";
else TOWELS_GROUP="3+ orders";

if WAPPAR EQ 0 then WAPPAR_GROUP="No orders                          ";
else if 1<=WAPPAR<=2 then WAPPAR_GROUP="1-2 orders";
else WAPPAR_GROUP="3+ orders";

if WCOAT EQ 0 then WCOAT_GROUP="No orders                          ";
else if 1<=WCOAT<=2 then WCOAT_GROUP="1-2 orders";
else WCOAT_GROUP="3+ orders";

run;


proc contents data=cy.cus_eda_group;
RUN;

data cy.cus_eda_BIVA;
set cy.cus_eda_group;

TELIND_CATE=put(TELIND,$4.);
TMKTORD_CATE=put(TMKTORD,$4.);
MARITAL_CATE=put(MARITAL,$4.);
APRTMNT_CATE=put(APRTMNT,$4.);
MOBILE_CATE=put(MOBILE,$4.);
RACE_CATE=put(RACE,$4.);
NUMCARS_CATE=put(NUMCARS,$4.);
NUMKIDS_CATE=put(NUMKIDS,$4.);
LUXURY_CATE=put(LUXURY,$4.);
RUN;

proc contents data=cy.cus_eda_BIVA;
RUN;

*target: Purchase;


*cate(Y) vs cate(X);
%macro biva(DSN= ,Y= );
PROC CONTENTS DATA = &DSN. OUT= &DSN._VARS;RUN;
PROC SQL;
SELECT NAME INTO : CHAR SEPARATED BY " "
FROM &DSN._VARS
WHERE TYPE EQ 2  
AND NAME NOT IN ("&Y.") ;
QUIT;

%LET M = %SYSFUNC(COUNTW(&CHAR));
%DO J = 1 %TO &M.;
	%LET X = %SCAN(&CHAR,&J.);

ODS PDF FILE = "D:\script\EDA Bivariate Analysis\BIVA_&X._&SYSDATE9..PDF";

Title "Relationship between &X. and &Y.";
proc freq data=&DSN.;
table &X.* &Y./chisq missing nopercent NOCOL;
run;

Title "Stacked Bar Chart:Relationship between &X. and &Y.";
proc sgplot data=&DSN.;
styleattrs datacolors=(gold olive);
vbar &X./group=&Y. barwidth=0.6
 dataskin=pressed
         baselineattrs=(thickness=0);;
run;
quit;
title;

Title "Group Bar Chart:Relationship between &X. and &Y.";
proc sgplot data=&DSN.;
vbar &X./group=&Y. GROUPDISPLAY = CLUSTER barwidth=0.6
         dataskin=pressed
         baselineattrs=(thickness=0);
run;
quit;
title;
ODS PDF CLOSE;
%end;
%mend;


%biva(DSN=cy.cus_eda_BIVA,Y= PURCHASE);


*****************************************************;
* Handling Missing Values;
*****************************************************;
*there are missing values in county and return, droping the column of county;
* group the column of return, and group missing values as "No return"group";






*****************************************************;
*Handling Outliers;
*********************************************************;
proc contents data=cy.cus_eda_group;
RUN;

*outlier macro;

%let DSN=cy.cus_behaviors;

data Numeric_outliers;
input Id Name $12.;
datalines;
1 AGE
2 AMOUNT
3 DAYS_BECUS 
4 FREQUENT
5 HOMEVAL
6 INCOME
7 RECENCY
8 VALRATIO
;
run;


%macro outlier(DSN= );

PROC SQL;
SELECT NAME INTO : NUM_NAME SEPARATED BY " "
FROM Numeric_outliers
;
QUIT;

%LET N = %SYSFUNC(COUNTW(&NUM_NAME));
%DO I = 1 %TO &N.;
	%LET X = %SCAN(&NUM_NAME,&I.);
proc means data=&DSN. n q1 q3 qrange;
var &X. ;
output out=temp q1=Q1 q3=Q3 qrange=IQR;
run;

PROC PRINT DATA = TEMP;RUN;

DATA TEMP1;
SET TEMP;
LOWER_LIMIT =  Q1 - (3*IQR);
UPPER_LIMIT = Q3 +(3*IQR);
RUN;

*CARTESIAN JOINS;
PROC SQL;
CREATE TABLE TEMP2 AS
SELECT A.*,B.LOWER_LIMIT,B.UPPER_LIMIT
FROM &DSN. AS A , TEMP1 AS B
;
QUIT;

DATA &DSN.2;
 SET TEMP2;
 IF &X. LE LOWER_LIMIT THEN &X._RAGNE = "BELOW LOWER LIMIT";
 ELSE  IF &X. GE UPPER_LIMIT THEN &X._RAGNE = "ABOVE LOWER LIMIT";
 ELSE &X._RAGNE = "WITHIN RANGE";
RUN;

PROC SQL;
 CREATE TABLE &DSN.3 AS
 SELECT *
 FROM &DSN.2
 WHERE &X._RAGNE EQ "WITHIN RANGE";
 QUIT;
 %end;
 %mend;

 %outlier(DSN= cy.cus_eda_group);


 proc print data=cy.cus_eda_group3(obs=10);
 run;


 proc contents data=cy.cus_eda_group3;
 run;

 PROC MEANS data=cy.cus_eda_group3 N NMISS;
 RUN;
 
*******************************************************;
*K-mean Clustering;
********************************************************;
DATA CY.CUS_CLUS;
 SET cy.cus_eda_group3;
 IDNUM = _N_;
 KEEP IDNUM PURCHASE AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO promo13 promo7;
RUN;

PROC CONTENTS DATA=CY.CUS_CLUS;
RUN;

PROC PRINT DATA=CY.CUS_CLUS;
RUN;

PROC STANDARD DATA=CY.CUS_CLUS OUT=CLUSTVAR MEAN=0 STD=1; 
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO promo13 promo7; 
RUN; 

ODS GRAPHICS ON;
%MACRO KMEAN(K);
PROC FASTCLUS DATA=CLUSTVAR OUT=OUTDATA_&K. OUTSTAT=CLUSTSTAT_&K. MAXCLUSTERS= &K.
MAXITER=300;
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO;
RUN;
%MEND;

%kmean(1);
%kmean(2);
%kmean(3);
%kmean(4);
%kmean(5);
%kmean(6);
%kmean(7);
%kmean(8);
%kmean(9);


* extract r-square values from each cluster solution and then merge them to plot elbow curve;
%MACRO EXT_RSQ(C);
data clus&C.;
set cluststat_&C.;
nclust=&C.;
if _type_='RSQ';
keep nclust over_all;
run;
%MEND;
%EXT_RSQ (1);
%EXT_RSQ (2);
%EXT_RSQ (3);
%EXT_RSQ (4);
%EXT_RSQ (5);
%EXT_RSQ (6);
%EXT_RSQ (7);
%EXT_RSQ (8);
%EXT_RSQ (9);

DATA CLUSTER_RSQ;
 SET CLUS1 CLUS2 CLUS3 CLUS4 CLUS5 CLUS6 CLUS7 CLUS8 CLUS9;
RUN;

** plot elbow curve using r-square values;
symbol1 color=blue interpol=join;
proc gplot data=CLUSTER_RSQ;
 plot over_all*nclust;
 run;


* PLOT CLUSTERS FOR 3 CLUSTER SOLUTION;
PROC CANDISC DATA=OUTDATA_3 OUT=CLUSTCAN_3;
CLASS CLUSTER;
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO;
RUN;

title "PLOT CLUSTERS FOR 3 CLUSTER SOLUTION";
PROC SGPLOT DATA=CLUSTCAN_3;
SCATTER Y=CAN2 X=CAN1 / GROUP=CLUSTER;
RUN;


* PLOT CLUSTERS FOR 4 CLUSTER SOLUTION;
PROC CANDISC DATA=OUTDATA_4 OUT=CLUSTCAN_4;
CLASS CLUSTER;
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO;
RUN;


PROC SGPLOT DATA=CLUSTCAN_4;
SCATTER Y=CAN2 X=CAN1 / GROUP=CLUSTER;
RUN;


PROC CANDISC DATA=OUTDATA_6 OUT=CLUSTCAN_6;
CLASS CLUSTER;
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO;
RUN;


PROC SGPLOT DATA=CLUSTCAN_6;
SCATTER Y=CAN2 X=CAN1 / GROUP=CLUSTER;
RUN;

*FOR 8 CLUSTERS;

PROC CANDISC DATA=OUTDATA_8 OUT=CLUSTCAN_8;
CLASS CLUSTER;
VAR AGE AMOUNT DAYS_BECUS RECENCY FREQUENT HOMEVAL INCOME VALRATIO;
RUN;


PROC SGPLOT DATA=CLUSTCAN_8;
SCATTER Y=CAN2 X=CAN1 / GROUP=CLUSTER;
RUN;
* CLUSTER 3 IS THE BEST;


DATA CUS_DATA;
SET CY.CUS_CLUS;
KEEP IDNUM PURCHASE;
RUN;

PROC SORT DATA=OUTDATA_3;
BY IDNUM;
RUN;

PROC SORT DATA=CUS_DATA;
BY IDNUM;
RUN;

DATA MERGED;
MERGE OUTDATA_3 CUS_DATA;
BY IDNUM;
RUN;


proc export data = work.MERGED
outfile = "D:\script\DATASETS\CUS_CLUS_&SYSDATE9..CSV"
dbms = csv;
delimiter = '09'x;
run;

PROC SORT DATA=MERGED;
BY CLUSTER;
RUN;


PROC freq DATA=MERGED;
table PURCHASE/chisq;
BY CLUSTER;
RUN;

Title "Group Bar Chart:Relationship between Purchase and Cluster";
proc sgplot data=MERGED;
styleattrs datacolors=(gold olive);
vbar CLUSTER/group=PURCHASE GROUPDISPLAY = CLUSTER barwidth=0.6
         dataskin=pressed
         baselineattrs=(thickness=0);
run;
quit;
title;




*******************************************************;
*RMF analysis;
*********************************************************;
PROC SQL;
 CREATE TABLE R_F_M AS
 SELECT PURCHASE, ACCTNUM, DAYS_BECUS, JOB, MARITAL, SEX, AGE, 
        RACE, EDLEVEL, NUMKIDS, NUMCARS, STATENAME, REGION, STATENAME,
        INCOME, HOMEVAL,APRTMNT, TELIND, TMKTORD,VALRATIO_GROUP,VALRATIO,
		PROMO7_GROUP, PROMO13_GROUP,
        INPUT(FREQUENT_SCORE,BEST.)AS FREQUENCY_SCORE ,
        INPUT(RECENCY_SCORE,BEST.) AS RECENCY_SCORE, 
        INPUT(AMOUNT_SCORE,BEST.) AS MONETARY_SCORE
 FROM cy.cus_eda_group 
 ;
 QUIT;


*CALCULATE AVERAGE R_F_M SCORES;
 DATA R_F_M01;
  SET R_F_M;
  RFM_SCORE = ROUND(MEAN(RECENCY_SCORE,FREQUENCY_SCORE,MONETARY_SCORE),.01);
RUN;


PROC SORT DATA = R_F_M01 OUT=R_F_M02;
 BY DESCENDING RFM_SCORE;
RUN;
PROC PRINT DATA = R_F_M02;
RUN;


*SEGMENTATION USING R AND F;

PROC SORT DATA = R_F_M01 OUT=R_F_M02;
 BY DESCENDING RECENCY_SCORE DESCENDING FREQUENCY_SCORE;
RUN;
PROC PRINT DATA = R_F_M02;
RUN;

*creating a heat map;
TITLE "The Heat Map of R_F_M"; 
PROC SGPLOT DATA = R_F_M02 noautolegend;
 HEATMAPparm X = RECENCY_SCORE Y=FREQUENCY_SCORE 
 colorRESPONSE=RFM_SCORE/ outline attrid=SortOrder ;
 KEYLEGEND;
RUN;
title;

TITLE "The Heat Map of R_F_M"; 
PROC SGPLOT DATA = R_F_M02;
styleattrs datacolors=(blue lightred lightgreen lightpurple lightorange );
 HEATMAPparm X = RECENCY_SCORE Y=FREQUENCY_SCORE
  colorgroup=MONETARY_SCORE/outline attrid=SortOrder
  ;
 KEYLEGEND;
RUN;
title;

title 'Monetary by Frequency and Recency';
proc sgplot data=R_F_M02 noborder;
  vbar  RECENCY_SCORE/ response=MONETARY_SCORE stat=mean
          group=FREQUENCY_SCORE groupdisplay=cluster
         dataskin=pressed
         baselineattrs=(thickness=0);
  xaxis display=(noline noticks);
  yaxis display=(noline) grid;
run;


proc export data = work.R_F_M02
outfile = "D:\script\DATASETS\R_F_M_&SYSDATE9..CSV"
dbms = csv;
delimiter = '09'x;
run;


**********************************************************;
*Logistic Regression Modeling
**********************************************************;
DATA CY.CUS_FOR_LOG_MODEL(DROP=ACCTNUM CUSTDATE JOB NUMKIDS 
                  STATENAME COUNTYNUM COUNTY STATECOD DINING
                  FREQUENT AMOUNT RECENCY DOMESTIC RETURN APPAREL LEISURE KITCHEN 
                  LUXURY MENSWARE FLATWARE DISHES HOMEACC LAMPS LINENS
                  BLANKETS TOWELS OUTDOOR COATS WCOAT WAPPAR HHAPPAR JEWELRY);
SET CY.CUS_EDA_GROUP;
RUN;


PROC SURVEYSELECT DATA =cy.CUS_FOR_LOG_MODEL  OUT=CUS_SAMP  RATE = .7 OUTALL;
RUN;
PROC FREQ DATA = CUS_SAMP;
 TABLE SELECTED;
RUN;

DATA TRAINING TESTING;
 SET CUS_SAMP;
 IF SELECTED EQ 1 THEN OUTPUT TRAINING;
 ELSE IF SELECTED EQ 0 THEN OUTPUT TESTING;
RUN;

PROC FREQ DATA = TRAINING;
TABLE DAYS_BECUS JOBNAME MARITAL SEX 
      AGE RACE EDLEVEL NUMKID_BIN REGION INCOME HOMEVAL 
      TELIND TMKTORD VALRATIO APRTMNT 
      RETURN_GROUP FREQUENT_SCORE AMOUNT_SCORE RECENCY_SCORE 
      PROMO7_GROUP PROMO13_GROUP;
run;

PROC CONTENTS DATA=TRAINING VARNUM SHORT ;
RUN;

/*Selected PURCHASE DAYS_BECUS JOBNAME MARITAL NTITLE SEX 
AGE RACE EDLEVEL NUMKID_BIN NUMCARS REGION INCOME HOMEVAL 
TRAVTIME HEAT TELIND TMKTORD VALRATIO PROMO7 PROMO13 APRTMNT 
MOBILE RETURN_GROUP DAYS_BECUS_GROUP INCOME_GROUP HOMEVAL_GROUP 
TRAVTIME_GROUP FREQUENT_SCORE AMOUNT_SCORE RECENCY_SCORE VALRATIO_GROUP 
AGE_GROUP PROMO7_GROUP PROMO13_GROUP APPAREL_GROUP BLANKETS_GROUP COATS_GROUP 
DINING_GROUP DISHES_GROUP DOMESTIC_GROUP FLATWARE_GROUP HHAPPAR_GROUP 
HOMEACC_GROUP JEWELRY_GROUP KITCHEN_GROUP LAMPS_GROUP LEISURE_GROUP LINENS_GROUP 
MENSWARE_GROUP OUTDOOR_GROUP TOWELS_GROUP WAPPAR_GROUP WCOAT_GROUP JOB_GROUP*/


ODS GRAPHICS ON;
TITLE "USING A COMBINATION OF CONTINUOUS AND CATEGORICAL VARIABLES";
PROC LOGISTIC DATA = TRAINING plots(only) =(roc oddsratio);
     CLASS AMOUNT_SCORE(PARAM =REF REF ="5")
           FREQUENT_SCORE (PARAM=REF REF ="5")
           RECENCY_SCORE (PARAM=REF REF ="5")
		   TELIND(PARAM=REF REF ="1")
           PROMO7_GROUP(PARAM=REF REF ="High level")
		   PROMO13_GROUP(PARAM=REF REF ="High level")
		   RETURN_GROUP(PARAM=REF REF ="No Return")
		   VALRATIO_GROUP(PARAM=REF REF ="More than 8.75")
		   RACE(PARAM=REF REF ="5")
           NUMKID_BIN(PARAM=REF REF ="3+")
		   MARITAL(PARAM=REF REF ="0")
           SEX(PARAM=REF REF ="female")
		   APRTMNT(PARAM=REF REF ="0")
          ;
      MODEL PURCHASE (EVENT="1") = DAYS_BECUS MARITAL SEX 
                                   AGE RACE  NUMKID_BIN INCOME HOMEVAL 
                                   TELIND VALRATIO APRTMNT 
                                   RETURN_GROUP FREQUENT_SCORE AMOUNT_SCORE RECENCY_SCORE 
                                   PROMO7_GROUP PROMO13_GROUP/CLODDS =PL;
	  UNITS INCOME=1 VALRATIO=1 DAYS_BECUS=1 HOMEVAL=1 AGE=1; 

RUN;
QUIT;
TITLE;