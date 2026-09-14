/************************************************************************/
/* Hub Resource Monitoring Demo                                         */
/************************************************************************/

options fullstimer;

/* Create 5 million rows */

data work.big_data;
    do id = 1 to 25000000;

        x = ranuni(12345);
        y = ranuni(54321);

        value1 = x * 1000;
        value2 = y * 1000;

        output;
    end;
run;

/* Force CPU-intensive calculations */

data work.big_calc;
    set work.big_data;

    result =
        sqrt(value1) *
        log(value2 + 1) *
        exp(mod(value1,10)/10);

run;

/* Sort a large dataset */

proc sort
    data=work.big_calc
    out=work.big_sorted;
    by descending result;
run;

/* Statistical analysis */

proc means
    data=work.big_sorted
    n
    mean
    median
    min
    max
    std;
    var result;
run;