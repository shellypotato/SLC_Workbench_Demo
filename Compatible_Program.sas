/************************************************************************/
/* Databricks Demo                                                      */
/* Connect to Databricks, analyze data, export results                  */
/************************************************************************/

/*Connect to Databricks*/

libname dbricks odbc
    dsn=DBRIX_DEMO
    user='token'
    password="&dbrix_token";



/*SQL*/

proc sql;
  connect to odbc
  (
    dsn=DBRIX_DEMO
    uid=token
    pwd="&dbrix_token"
  );

  create table work.sales_transactions as
  select *
  from connection to odbc
  (
    select *
    from samples.bakehouse.sales_transactions
  );

  disconnect from odbc;
quit;


/*Proc Contents*/
proc contents data=work.sales_transactions varnum;
run;

/*Statistical Summary*/


ods output Summary=work.summary_stats;

proc means
    data=work.sales_transactions
    n
    mean
    min
    max
    median
    std;
    class product;
    var totalPrice;
run;

/*Export CSV*/
proc export
    data=work.summary_stats
    outfile="C:\Users\z0059emp\Documents\Workbench Workspaces\Demo_Workspace/summary_stats.csv"
    dbms=csv
    replace;
run;