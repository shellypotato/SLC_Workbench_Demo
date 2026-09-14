%let sf_pwd=%sysget(snowflaketok);

libname sf snowflake
    server="ivpvnqt-fsc10930.snowflakecomputing.com"
    user="dbadmin"
    password="&sf_pwd"
    database=fcg_demo_db
    schema=aml;
    
    proc options option=autoexec;
run;

data _null_;
   put "Main program running";
run;