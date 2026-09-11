/************************************************************************/
/* Demo: Create sample dataset in SAS                                   */
/************************************************************************/

data work.score;
    length Name $20;

    input Name $ Age Score;

    datalines;
Jon 40 89
Reid 36 87
Sandy 43 91
Amy 44 89
Clay 38 93
;
run;

/* View dataset */
proc print data=work.score;
    title "Demo Score Dataset";
run;

/* Summary statistics */
proc means data=work.score mean min max;
    var Score Age;
run;

/* Export to CSV for Python and R */
proc export
    data=work.score
    outfile="C:\Users\z0059emp\Documents\Workbench Workspaces\Demo_Workspace\score.csv"
    dbms=csv
    replace;
run;

%put NOTE: CSV file successfully created.;