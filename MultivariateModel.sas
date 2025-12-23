PROC IMPORT DATAFILE="/home/u26262865/data_eoldcad_subset2.0.xlsx"
            OUT=rawdata2
            DBMS=XLSX
            REPLACE;
    GETNAMES=YES;   /* Use column headers as variable names */
RUN;

DATA DataAnalysis2;
    SET rawdata2(KEEP=record_id 
                              hoursEOLDafterdnr 
                              eoldcad_r eoldcad_n eoldcad_d 
                              physicalsympsubscale_r physicalsympsubscale_n physicalsympsubscale_d 
                             
                              duration_hosdays 
                              DurationDNRbeforedeath_h 
                              relation_relative
imputated_n
imputated_r
imputated_d
imputed_ssd
imputed_ssn
imputed_ssr);
    /* Exclude rows where hoursEOLDafterdnr is missing */
    IF NOT MISSING(hoursEOLDafterdnr);
RUN;


data analysis_s2;
set DataAnalysis2;
length distvar $11;
length response 8;
length linkvar $11;
length var $20;
response = eoldcad_r;
imputed=imputated_r;
var='eoldcad';
distvar     = "Normal";
linkvar	= "IDEN";
type='r';
output;
response = eoldcad_n;
imputed=imputated_n;
var='eoldcad';
distvar     = "Normal";
linkvar	= "IDEN";
type='n';
output;
response = eoldcad_d;
imputed=imputated_d;
var='eoldcad';
distvar     = "Normal";
linkvar	= "IDEN";
type='d';
output;
response = physicalsympsubscale_r;
var='sympsubscale';
imputed=imputed_ssr;
distvar     = "Normal";
linkvar	= "IDEN";
type='r';
output;
response = physicalsympsubscale_n;
var='sympsubscale';
imputed=imputed_ssn;
distvar     = "Normal";
linkvar	= "IDEN";
type='n';
output;
response = physicalsympsubscale_d;
var='sympsubscale';
imputed=imputed_ssd;
distvar     = "Normal";
linkvar	= "IDEN";
type='d';
output;
keep 
imputed
record_id 
 hoursEOLDafterdnr  
 DurationDNRbeforedeath_h 
 duration_hosdays
relation_relative type
distvar response var linkvar;
run;


data analysis_s3;
set analysis_s2;
timelcss=hoursEOLDafterdnr;
mygroup=type;
run;


proc mixed data=analysis_s3 COVTEST;
class type record_id mygroup timelcss;
model response = type hoursEOLDafterdnr type*hoursEOLDafterdnr DurationDNRbeforedeath_h type*DurationDNRbeforedeath_h
duration_hosdays type*duration_hosdays/solution;
random  intercept /subject=record_id;
repeated mygroup /subject=record_id*hoursEOLDafterdnr type=UN r rcorr;
where var='sympsubscale';
run;


proc mixed data=analysis_s3 COVTEST;
class type record_id mygroup timelcss;
model response = type hoursEOLDafterdnr type*hoursEOLDafterdnr DurationDNRbeforedeath_h type*DurationDNRbeforedeath_h
duration_hosdays type*duration_hosdays/solution;
random  intercept /subject=record_id;
repeated mygroup /subject=record_id*hoursEOLDafterdnr type=UN r rcorr;
where var='eoldcad';
run;

