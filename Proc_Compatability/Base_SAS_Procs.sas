/*============================================================================*/
/* BASE SAS PROCEDURES */
/*============================================================================*/


/*============================================================================*/
/* SECTION 0: DEMO DATA */
/*============================================================================*/

data demo_data;
    length id 8 name $12 gender $6 region $10 category $10;
    format date date9.;
    
    input id name $ gender $ age height weight region $ category $ date :date9. sales;
    
    datalines;
1 Alice F 13 56.5 84 North A 01JAN2024 120
2 Bob   M 14 62.3 98 South B 05JAN2024 200
3 Carol F 13 58.7 90 East  A 10JAN2024 150
4 David M 15 65.2 105 West  B 12JAN2024 300
5 Emma  F 14 60.1 95 North C 18JAN2024 250
6 Frank M 13 57.8 88 East  A 20JAN2024 175
7 Grace F 15 66.4 110 South B 25JAN2024 320
8 Henry M 14 63.0 102 West  C 28JAN2024 275
;
run;


/*============================================================================*/
/* ERA 1: FOUNDATIONAL DATA PROCESSING */
/*============================================================================*/

/*---------------------------*/
/* PROC MEANS */
/*---------------------------*/

/* SIMPLE */
proc means data=demo_data;
run;

/* FULL OPTION BLOCK */
proc means data=demo_data
           n nmiss sum mean median std var cv
           min max range q1 q3
           maxdec=3
           printalltypes
           chartype
           completetypes
           missing
           order=freq
           fw=12;

    class region category / preloadfmt exclusive;

    var sales height weight;

    weight sales;
    freq id;
    id name;

    output out=means_full
        n=n_sales n_height n_weight
        nmiss=nm_sales nm_height nm_weight
        sum=sum_sales sum_height sum_weight
        mean=mean_sales mean_height mean_weight
        median=med_sales med_height med_weight
        std=std_sales std_height std_weight
        var=var_sales var_height var_weight
        min=min_sales min_height min_weight
        max=max_sales max_height max_weight
        q1=q1_sales q1_height q1_weight
        q3=q3_sales q3_height q3_weight;

run;


/*---------------------------*/
/* PROC FREQ */
/*---------------------------*/

/* SIMPLE */
proc freq data=demo_data;
    tables region;
run;

/* FULL STATISTICS VERSION */
proc freq data=demo_data order=freq nlevels;

    tables region*category*gender /
        chisq
        expected
        deviation
        cellchi2
        measures
        nocol norow nopercent;

    weight sales;

run;

/* OUTPUT / EXACT VERSION */
proc freq data=demo_data;

    tables region*category /
        out=freq_out
        outcum;

    exact fisher;

run;


/*---------------------------*/
/* PROC SORT */
/*---------------------------*/

proc sort data=demo_data;
    by region;
run;

proc sort data=demo_data out=sorted_data
          nodupkey equals threads;
    by region descending sales;
run;


/*---------------------------*/
/* PROC PRINT */
/*---------------------------*/

proc print data=demo_data;
run;

proc print data=demo_data(obs=5 firstobs=2)
    label noobs double split='*';

    var name region sales height weight;
    sum sales height weight;
    id id;

run;


/*============================================================================*/
/* ERA 2: STRUCTURED REPORTING */
/*============================================================================*/

/*---------------------------*/
/* PROC REPORT */
/*---------------------------*/

/* SIMPLE */
proc report data=demo_data nowd;
    column region sales;
run;

/* FULL FEATURE VERSION */
proc report data=demo_data
            nowd headline headskip spacing=2
            split='*'
            missing center;

    column region category gender sales;

    define region   / group order=internal preloadfmt;
    define category / group order=data;
    define gender   / group;
    define sales    / analysis sum format=comma10.;

    break after region / summarize dol skip;
    rbreak after / summarize dol;

run;


/*---------------------------*/
/* PROC TABULATE */
/*---------------------------*/

proc tabulate data=demo_data;
    class region;
run;

proc tabulate data=demo_data missing order=freq;

    class region category;
    var sales height weight;

    table region*category,
          sales*(n mean sum)
          height*(mean)
          weight*(mean);

run;


/*---------------------------*/
/* PROC TRANSPOSE */
/*---------------------------*/

proc transpose data=demo_data out=transposed;
    var sales;
run;

proc transpose data=demo_data
               out=transposed2
               prefix=region_
               suffix=_val
               name=source
               let;

    by id;
    id region;
    var sales height weight;
    copy gender category;

run;


/*============================================================================*/
/* ERA 3: DATA ENGINEERING */
/*============================================================================*/

/*---------------------------*/
/* PROC SQL */
/*---------------------------*/

proc sql;
    select * from demo_data;
quit;

proc sql;

    create table sql_out as

    select region,
           category,
           count(*) as obs_count,
           sum(sales) as total_sales format=comma10.,
           mean(sales) as avg_sales,
           calculated total_sales / calculated obs_count as avg_calc

    from demo_data

    group by region, category

    having calculated total_sales > 200

    order by region desc;

quit;


/*---------------------------*/
/* PROC DATASETS */
/*---------------------------*/

proc datasets lib=work;
run;

proc datasets lib=work nolist nodetails;

    contents data=demo_data;

    modify demo_data;
        rename sales = total_sales;
        label total_sales = "Updated Sales Value";
        format total_sales comma10.;
    quit;

    copy in=work out=work;
        select demo_data;
    run;

run;
quit;


/*---------------------------*/
/* PROC APPEND */
/*---------------------------*/

data append_base;
    input id value;
    datalines;
1 10
2 20
;
run;

data append_new;
    input id value;
    datalines;
3 30
4 40
;
run;

proc append base=append_base data=append_new;
run;

proc append base=append_base data=append_new force;
run;


/*============================================================================*/
/* ERA 4: METADATA & STORAGE */
/*============================================================================*/

/* PROC FORMAT */
proc format library=work;

    value sales_fmt
        low-<150='Low'
        150-<300='Medium'
        300-high='High';

    value $region_fmt
        'North'='North Region'
        'South'='South Region'
        other='Other';

run;


/* PROC CPORT / CIMPORT */
proc cport data=demo_data file="demo.xpt";
run;

proc cimport data=demo_data file="demo.xpt";
run;


/*============================================================================*/
/* ERA 5: MODERN ACCESS */
/*============================================================================*/

/* PROC JSON */
proc json out="demo.json";
    export demo_data;
run;

proc json out="demo.json" pretty nosastags;
    export demo_data;
run;


/* PROC HTTP */
proc http url="https://example.com"
          method="GET"
          out=response;
run;

proc http url="https://example.com"
          method="GET"
          out=response
          ct="application/json";
run;


/* PROC FEDSQL */
proc fedsql;
    select * from demo_data;
quit;

proc fedsql;

    create table fedsql_out as
    select region, count(*) as n
    from demo_data
    group by region;

quit;


/*============================================================================*/
/* ERA 6: LEGACY ARTIFACTS */
/*============================================================================*/

proc plot data=demo_data; plot sales*age; run;
proc chart data=demo_data; vbar region; run;
proc fsedit data=demo_data; run;


/*============================================================================*/
/* END */
/*============================================================================*/