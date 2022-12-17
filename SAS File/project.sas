/*read Computer-Assisted Personal Interview Data*/
data capi;
set hph559.capi;
*keep SP_ID PAQ050Q PAQ280Q PAQ400Q PAQ460Q;
keep SP_ID PAQ020 PAQ326 PAQ206 PAQ440; 
run;

/*read physcial examination data*/
data exam;
set hph559.exam;
keep SP_ID BMXBMI;
run;

/*read spfile data*/
data spfile;
set hph559.spfile; 
keep SP_ID agegroup race_eth riagendr;
run; 

/*sort data by SP_ID*/
proc sort; 
by SP_ID; 
run;

/*merge 3 data sets*/
data append; 
merge capi exam spfile;
by SP_ID;
run; 

/*remove missing value*/
data appendnew; 
set append; 
if PAQ050Q =. then delete; 
if PAQ280Q =. then delete; 
if PAQ400Q =. then delete; 
if PAQ460Q =. then delete; 
run;  *349 observations and 9 variables; 

/*remove missing value*/
data appendtest; 
set append; 
if PAQ020 =3 then delete; 
if PAQ326 =3 then delete; 
if PAQ206 =3 then delete; 
if PAQ440 =3 then delete; 
run;  *1972 observations and 9 variables; 

/*Check for other out of range values*/
proc freq;
table BMXBMI PAQ020 PAQ326 PAQ206 PAQ440 agegroup race_eth riagendr;
run; *don't see any other out of range values.;

/*influential outliers*/
proc reg;
model BMXBMI = PAQ050Q PAQ280Q PAQ400Q PAQ460Q agegroup race_eth riagendr / influence vif;
plot cookd.*obs.;
run; 
quit;

/*remove influential outliers*/
proc reg;
model BMXBMI = PAQ050Q PAQ280Q PAQ400Q PAQ460Q agegroup race_eth riagendr / influence vif;

output out = outliers    
     cookd = cooksd;

run;
quit; 

data remove;
set outliers;
if cooksd > 0.6 then delete;

run; *2 ouliers removed;

/*rerun model without outliers*/ 
proc reg;
model BMXBMI = PAQ050Q PAQ280Q PAQ400Q PAQ460Q agegroup race_eth riagendr / influence vif;
plot cookd.*obs.;
run; 
quit;

proc reg data=appendtest;
model BMXBMI = PAQ020 PAQ326 PAQ206 PAQ440 agegroup race_eth riagendr / influence vif;
plot cookd.*obs.;
run; 
quit;

/*remove influential outliers*/
proc reg;
model BMXBMI = PAQ020 PAQ326 PAQ206 PAQ440 agegroup race_eth riagendr / influence vif;

output out = outliers    
     cookd = cooksd;

run;
quit; 

data remove;
set outliers;
if cooksd > 0.015 then delete;

run; *2 ouliers removed;

proc reg data=remove;
model BMXBMI = PAQ020 PAQ326 PAQ206 PAQ440 agegroup race_eth riagendr / influence vif;
plot cookd.*obs.;
run; 
quit;

*/scatterplot to check non-linearity/*;
proc reg;
model BMXBMI = PAQ050Q PAQ280Q PAQ400Q PAQ460Q agegroup race_eth riagendr / influence vif;
plot BMXBMI*PAQ050Q; 
plot BMXBMI*PAQ280Q;
plot BMXBMI*PAQ400Q;
plot BMXBMI*PAQ460Q;
run; 
quit;

*/residual plot/*;
proc reg;
model BMXBMI = PAQ050Q PAQ280Q PAQ400Q PAQ460Q agegroup race_eth riagendr / influence vif stb;	
plot residual.*predicted.; 
run; 
quit;

/*run multiple linear regression model*/
*the number of times participants walked or bicycled over the past 30 days;
proc reg;
model BMXBMI = PAQ020    agegroup race_eth riagendr;
run;
quit; 
*the number of times participants did moderate activities over the past 30 days;
proc reg;
model BMXBMI = PAQ326 agegroup race_eth riagendr;
run;
quit; 
*the number of times participants did vigorous activities over the past 30 days; 
proc reg;
model BMXBMI = PAQ206  agegroup race_eth riagendr;
run;
quit; 
*the number of times participants did strengthening activities over the past 30 days;
proc reg;
model BMXBMI = PAQ440 agegroup race_eth riagendr;
run;
quit;
