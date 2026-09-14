/*============================================================================*/
/* SAS GRAPH PROCEDURES */
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

proc sort data=demo_data out=demo_data_sorted;
    by region;
run;

proc sort data=demo_data out=demo_data_by_category;
    by category;
run;
``

/*============================================================================*/
/* ERA 1: LEGACY LINE PRINTER GRAPHICS */
/*============================================================================*/

/* PROC PLOT (simple) */
proc plot data=demo_data;
    plot sales*age;
run;


/* PROC PLOT (overlay + grouping) */
proc sort data=demo_data out=demo_data_sorted;
    by region;
run;

proc plot data=demo_data_sorted;

    plot sales*age = gender
         / overlay
           box
           vaxis=0 to 350 by 50
           haxis=10 to 70 by 10;

    by region;

run;


/* PROC PLOT (axis-heavy alternate view) */
proc plot data=demo_data;

    plot height*weight
         / box
           vaxis=80 to 120 by 10
           haxis=50 to 70 by 5;

run;

/*============================================================================*/
/* ERA 2: SAS/GRAPH CLASSIC */
/*============================================================================*/

/* SYMBOL definitions */
symbol1 value=dot height=1 interpol=none;
symbol2 value=circle height=1.5;

/* PROC GPLOT (simple) */
proc gplot data=demo_data;
    plot sales*age;
run; quit;


/* PROC GPLOT (extreme options) */
proc gplot data=demo_data_by_category gout=work.graphs;

    plot sales*age=gender
         height*weight=region
         / overlay
           frame
           haxis=axis1
           vaxis=axis2
           legend=legend1;

    by category;

    title1 "Advanced GPLOT";
    footnote1 "Demonstrating multiple options";

run; quit;


/* Axis, legend definitions */
axis1 label=("Age") order=(10 to 70 by 10);
axis2 label=(angle=90 "Sales");

legend1 label=("Gender")
        position=(top right)
        across=1;


/* PROC GCHART (simple) */
proc gchart data=demo_data;
    vbar region;
run; quit;


/* PROC GCHART (advanced) */
proc gchart data=demo_data;

    vbar region
        / group=gender
          sumvar=sales
          type=mean
          outside=sum
          subgroup=category
          width=10
          space=5
          maxis=axis1
          raxis=axis2;

    pie category
        / sumvar=sales
          value=inside
          percent=inside
          slice=arrow;

run; quit;


/* PROC G3D (3D graphics) */
proc g3d data=demo_data;
    scatter age*height=sales;
run; quit;

proc g3d data=demo_data;

    plot age*height=sales
        / tilt=45 rotate=45 grid
          zaxis=axis2;

run; quit;


/*============================================================================*/
/* ERA 3: ODS GRAPHICS REVOLUTION */
/*============================================================================*/

ods graphics on;

/* PROC SGPLOT (simple) */
proc sgplot data=demo_data;
    scatter x=age y=sales;
run;


/* PROC SGPLOT (EXTREME OPTION BLOCK) */
proc sgplot data=demo_data
           noautolegend
           sganno=work.anno;

    title "Advanced SGPLOT Example";

    scatter x=age y=sales
        / group=gender
          markerattrs=(symbol=circlefilled size=10)
          datalabel=name;

    series x=age y=sales
        / group=region
          lineattrs=(thickness=2);

    reg x=age y=sales
        / degree=2
          cli clm
          lineattrs=(pattern=dash);

    loess x=age y=sales;

    vline region / response=sales stat=mean;
refline 200 / axis=y;

    xaxis grid label="Age" values=(10 to 70 by 10);
    yaxis grid label="Sales";

    keylegend / location=inside position=topright across=1;

run;


/* PROC SGPANEL */
proc sgpanel data=demo_data;
    panelby gender;
    scatter x=age y=sales;
run;

proc sgpanel data=demo_data;

    panelby region / columns=2 rows=2;

    scatter x=age y=sales / group=gender;

    rowaxis label="Sales";
    colaxis label="Age";

run;


/* PROC SGSCATTER */
proc sgscatter data=demo_data;
    matrix age height weight sales;
run;

proc sgscatter data=demo_data;

    matrix age height weight sales
           / diagonal=(histogram kernel)
             group=gender;

run;

ods graphics off;


/*============================================================================*/
/* ERA 4: GRAPHICS EMBEDDED IN ANALYSIS */
/*============================================================================*/

ods graphics on;

/* PROC REG with plots */
proc reg data=demo_data plots=all;
    model sales = age height weight;
run; quit;

/* PROC CORR with plots */
proc corr data=demo_data plots=matrix(histogram);

    var sales height weight age;

run;

ods graphics off;


/*============================================================================*/
/* ERA 5: TEMPLATE-BASED GRAPHICS */
/*============================================================================*/

/* PROC TEMPLATE */
proc template;

    define statgraph mygraph;

        begingraph;
            layout overlay;

            scatterplot x=age y=sales;

            endlayout;
        endgraph;

    end;

run;


/* PROC SGRENDER (simple) */
proc sgrender data=demo_data template=mygraph;
run;


/* PROC SGRENDER (extended) */
proc sgrender data=demo_data template=mygraph;

    dynamic _title="Custom Graph";

run;


/*============================================================================*/
/* END */
/*============================================================================*/