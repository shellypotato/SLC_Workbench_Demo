/*============================================================================*/
/* SAS ETS PROCEDURES */
/*============================================================================*/


/*============================================================================*/
/* SECTION 0: TIME SERIES DATASET */
/*============================================================================*/

/* Create a simple time series dataset */
data time_data;
    format date date9.;
    
    do i = 1 to 12;
        date = intnx('month', '01JAN2024'd, i-1);
        value = 100 + i*10 + rannor(123)*5;
        output;
    end;
    
    drop i;
run;


/*============================================================================*/
/* ERA 1: EARLY TIME SERIES HANDLING */
/*============================================================================*/

/* PROC EXPAND */
/* Used for time series transformation and interpolation */
proc expand data=time_data out=expanded_data;
    id date;
    convert value = value_ma / transformout=(movave 3);
run;


/*============================================================================*/
/* ERA 2: CLASSICAL FORECASTING */
/*============================================================================*/

/* PROC FORECAST */
/* Simple time series forecasting */
proc forecast data=time_data interval=month lead=3 out=forecast_out;
    id date;
    var value;
run;


/* PROC ARIMA */
/* Autoregressive Integrated Moving Average models */
proc arima data=time_data;
    identify var=value;
    estimate p=1 q=1;
    forecast lead=3 out=arima_out;
run;
quit;


/*============================================================================*/
/* ERA 3: STRUCTURED TIME SERIES PROCESSING */
/*============================================================================*/

/* PROC TIMESERIES */
/* Modern time indexing and aggregation */
proc timeseries data=time_data out=ts_out;
    id date interval=month;
    var value;
run;


/*============================================================================*/
/* ERA 4: ADVANCED ECONOMETRICS */
/*============================================================================*/

/* PROC AUTOREG */
/* Regression models with autocorrelation */
proc autoreg data=time_data;
    model value = / nlag=1;
run;

proc autoreg data=time_data;
    model value = / nlag=(1 2);
run;


/*============================================================================*/
/* ERA 5: MODERN FORECASTING EXTENSIONS */
/*============================================================================*/

/* PROC ESM */
/* Exponential smoothing models */
proc esm data=time_data lead=3 outfor=esm_out;
    id date interval=month;
    forecast value / model=winters;
run;


/* PROC UCM */
/* Unobserved Components Model */
proc ucm data=time_data;
    id date interval=month;
    model value;
    level;
    slope;
run;


/*============================================================================*/
/* END */
/*============================================================================*/