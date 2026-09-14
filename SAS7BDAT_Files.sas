/*Option to ignore missing formats*/
options nofmterr;

/* Point to folder containing the SAS7BDAT files */

libname demo
    "C:\Users\z0059emp\Documents\Workbench Workspaces\Demo_Workspace\SAS7BDAT_Files";

/* Copy analytic.sas7bdat into WORK */

data work.analytic;
    set demo.analytic;
run;

/* Browse structure */

proc contents data=work.analytic;
run;

/* View records */

proc print data=work.analytic(obs=10);
run;