/*============================================================================*/
/* SAS OR PROCEDURES */
/*============================================================================*/


/*============================================================================*/
/* SECTION 0: DEMO DATASETS */
/*============================================================================*/

/* Network / flow dataset */
data net_data;
    input from $ to $ capacity cost;
    datalines;
A B 10 2
A C 15 4
B D 10 1
C D 10 3
;
run;

/* Assignment problem dataset */
data assign_data;
    input worker $ task $ cost;
    datalines;
W1 T1 10
W1 T2 15
W1 T3 20
W2 T1 12
W2 T2 18
W2 T3 25
W3 T1 14
W3 T2 16
W3 T3 19
;
run;

/* Transportation dataset */
data trans_data;
    input source $ dest $ supply demand cost;
    datalines;
S1 D1 20 . 4
S1 D2 20 . 6
S2 D1 30 . 5
S2 D2 30 . 2
;
run;

/* Project scheduling dataset */
data cpm_data;
    input task $ duration predecessor $;
    datalines;
A 5 .
B 3 A
C 4 A
D 2 B
E 6 C
;
run;


/*============================================================================*/
/* ERA 1: LEGACY LINEAR PROGRAMMING (PROC LP) */
/*============================================================================*/

/************************************************************************/
/* Original SAS Code                                                    */
/* Compatibility Issue: Unsupported PROC LP syntax                      */
/************************************************************************/
proc lp;

    max profit = 3*x1 + 5*x2;

    x1 + 2*x2 <= 10;
    3*x1 + x2 <= 12;

    bounds
        x1 >= 0,
        x2 >= 0;

run;

/************************************************************************/
/* SLC-Compatible PROC LP Example                                       */
/************************************************************************/

/* Define LP problem as coefficient matrix */

data lpdata;
    input _ROW_ $ x1 x2 _TYPE_ $ _RHS_;
    datalines;
profit 3 5 MAX .
c1     1 2 LE  10
c2     3 1 LE  12
;
run;

/* Solve LP */

proc lp data=lpdata
        primalout=lp_solution
        print;
run;

/* View Solution */

proc print data=lp_solution;
run;



/*============================================================================*/
/* ERA 2: CLASSIC OR MODELS */
/*============================================================================*/

/* PROC NETFLOW */
proc netflow data=net_data;
    tail from;
    head to;
    capacity capacity;
    cost cost;
run;


/* PROC ASSIGN */
proc assign data=assign_data;
    cost cost;
    id worker task;
run;


/* PROC TRANS (Transportation Model) */
proc trans data=trans_data;
    supply supply;
    demand demand;
    cost cost;
    id source dest;
run;


/* PROC CPM */
proc cpm data=cpm_data;
    activity task;
    duration duration;
    predecessor predecessor;
run;


/*============================================================================*/
/* ERA 3: MODERN OPTIMIZATION LANGUAGE */
/*============================================================================*/

proc optmodel;

    var x1 >= 0;
    var x2 >= 0;

    max profit = 3*x1 + 5*x2;

    con c1: x1 + 2*x2 <= 10;
    con c2: 3*x1 + x2 <= 12;

    solve;

    print x1 x2 profit;

quit;


/*============================================================================*/
/* ERA 4: SPECIALIZED OPT PROCEDURES */
/*============================================================================*/

/* PROC OPTLP */
proc optlp;
    /* Example linear program */
    var x1 >= 0;
    var x2 >= 0;

    max z = 3*x1 + 5*x2;

    con c1: x1 + 2*x2 <= 10;
    con c2: 3*x1 + x2 <= 12;

run;


/* PROC OPTMILP */
proc optmilp;
    var x1 integer >= 0;
    var x2 integer >= 0;

    max z = 3*x1 + 5*x2;

    con c1: x1 + 2*x2 <= 10;
    con c2: 3*x1 + x2 <= 12;

run;


/* PROC OPTQP */
proc optqp;

    var x1 >= 0;
    var x2 >= 0;

    min obj = x1*x1 + x2*x2;

    con c1: x1 + x2 >= 5;

run;


/* PROC OPTLSO */
proc optlso;
    /* Local search (heuristics) placeholder */
run;


/*============================================================================*/
/* ERA 5: NETWORK / GRAPH OPTIMIZATION (MODERN) */
/*============================================================================*/

/* PROC OPTNETWORK */
proc optnetwork data=net_data;
    links = (from to);
    weight cost;
run;


/* PROC OPTGRAPH */
proc optgraph data=net_data;
    nodes = (from to);
run;


/*============================================================================*/
/* ERA 6: ADVANCED OPTMODEL USAGE */
/*============================================================================*/

/* Integer programming */
proc optmodel;

    var x1 integer >= 0;
    var x2 integer >= 0;

    max profit = 3*x1 + 5*x2;

    con c1: x1 + 2*x2 <= 10;
    con c2: 3*x1 + x2 <= 12;

    solve;

    print x1 x2 profit;

quit;


/* Nonlinear example */
proc optmodel;

    var x >= 0;
    var y >= 0;

    max z = x + y;

    con nonlinear: x*y <= 25;

    solve;

    print x y z;

quit;


/*============================================================================*/
/* END */
/*============================================================================*/