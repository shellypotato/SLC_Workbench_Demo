/*============================================================================*/
/* SAS IML PROCEDURES */
/*============================================================================*/


/*============================================================================*/
/* SECTION 0: DEMO DATASET */
/*============================================================================*/

data demo_data;
    length id 8 name $12 gender $6 region $10 category $10;
    format date date9.;
    
    input id name $ gender $ age height weight region $ category $ date :date9. sales;
    
    datalines;
1 Alice   F 13 56.5 84  North A 01JAN2024 120
2 Bob     M 14 62.3 98  South B 05JAN2024 200
3 Carol   F 13 58.7 90  East  A 10JAN2024 150
4 David   M 15 65.2 105 West  B 12JAN2024 300
5 Emma    F 14 60.1 95  North C 18JAN2024 250
6 Frank   M 13 57.8 88  East  A 20JAN2024 175
7 Grace   F 15 66.4 110 South B 25JAN2024 320
8 Henry   M 14 63.0 102 West  C 28JAN2024 275
;
run;


/*============================================================================*/
/* ERA 1: MATRIX FUNDAMENTALS (1980s–1990s) */
/*============================================================================*/
/* SAS gains matrix programming capability */

/* Basic matrix creation and operations */
proc iml;
    A = {1 2 3,
         4 5 6};

    B = {1 0 1,
         0 1 0};

    C = A + B;
    print A B C;
quit;


/*============================================================================*/
/* ERA 2: LINEAR ALGEBRA & STATISTICS */
/*============================================================================*/

/* Matrix multiplication & transpose */
proc iml;
    X = {1 2,
         3 4,
         5 6};

    XtX = X` * X;
    print X XtX;

    invXtX = inv(XtX);
    print invXtX;
quit;


/* Compute mean manually using matrices */
proc iml;
    use demo_data;
    read all var {sales} into y;

    mean_y = y[:,];   /* column mean */
    print mean_y;
quit;


/*============================================================================*/
/* ERA 3: CUSTOM MODELING */
/*============================================================================*/
/* Building regression manually using matrix algebra */

proc iml;
    use demo_data;
    read all var {age height weight} into X;
    read all var {sales} into y;

    /* Add intercept */
    X = j(nrow(X),1,1) || X;

    /* Beta = (X'X)^(-1) X'y */
    beta = inv(X` * X) * X` * y;

    print beta;
quit;


/*============================================================================*/
/* ERA 4: SIMULATION */
/*============================================================================*/
/* Monte Carlo simulation */

proc iml;
    call randseed(123);

    n = 1000;
    x = j(n, 1);
    
    call randgen(x, "Normal", 0, 1);

    mean_x = x[:,];
    std_x = std(x);

    print mean_x std_x;
quit;


/*============================================================================*/
/* ERA 5: ADVANCED PROGRAMMING */
/*============================================================================*/
/* Write reusable modules (functions) */

/* Define a function */
proc iml;

    start meanFunc(v);
        return( v[:,] );
    finish;

    use demo_data;
    read all var {sales} into y;

    result = meanFunc(y);
    print result;

quit;


/* Matrix eigenvalues (advanced linear algebra) */
proc iml;

    A = {4 1,
         1 3};

    eigval = eigval(A);
    print eigval;

quit;


/*============================================================================*/
/* END */
/*============================================================================*/