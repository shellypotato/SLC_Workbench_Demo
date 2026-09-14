/*============================================================================*/
/* SAS STAT PROCEDURES */
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
/* ERA 1: CLASSICAL STATISTICS */
/*============================================================================*/

/*---------------------------*/
/* PROC TTEST */
/*---------------------------*/

proc ttest data=demo_data;
    class gender;
    var sales;
run;

proc ttest data=demo_data
          sides=2 alpha=0.05 h0=0
          plots=all;

    class gender;
    var sales height weight;

    ods select statistics ttests equality;

run;


/*---------------------------*/
/* PROC ANOVA */
/*---------------------------*/

proc anova data=demo_data;
    class region;
    model sales = region;
run;
quit;

proc anova data=demo_data;

    class region category;

    model sales = region category;

    means region category / tukey cldiff;

    ods output OverallANOVA=anova_out;

run;
quit;


/*---------------------------*/
/* PROC CORR */
/*---------------------------*/

proc corr data=demo_data;
    var sales height;
run;

proc corr data=demo_data
          pearson spearman kendall
          plots=matrix(histogram);

    var sales height weight age;

    ods output PearsonCorr=corr_out;

run;


/*============================================================================*/
/* ERA 2: LINEAR MODELING */
/*============================================================================*/

/*---------------------------*/
/* PROC REG */
/*---------------------------*/

proc reg data=demo_data;
    model sales = age;
run;
quit;

proc reg data=demo_data
          plots(unpack)=all;

    model sales = age height weight
        / vif tol stb clb spec dw;

    output out=reg_out
        p=predicted
        r=residual
        student=student_resid
        cookd=cookd;

    ods output ParameterEstimates=reg_params;

run;
quit;


/*---------------------------*/
/* PROC GLM */
/*---------------------------*/

proc glm data=demo_data;
    class region;
    model sales = region;
run;
quit;

proc glm data=demo_data plots=all;

    class region category gender;

    model sales = region category gender;

    lsmeans region category / pdiff adjust=tukey;

    contrast 'North vs South' region 1 -1 0 0;

    estimate 'Custom Effect' region 1 -1 0 0;

    ods output LSMeans=glm_lsmeans;

run;
quit;


/*---------------------------*/
/* PROC GLMSELECT */
/*---------------------------*/

proc glmselect data=demo_data;
    model sales = age height weight;
run;

proc glmselect data=demo_data plots=all;

    model sales = age height weight
        / selection=stepwise(select=aic stop=aic)
          stats=all;

    partition fraction(test=0.3);

run;


/*============================================================================*/
/* ERA 3: ADVANCED MODELING */
/*============================================================================*/

/*---------------------------*/
/* PROC MIXED */
/*---------------------------*/

proc mixed data=demo_data;
    class region;
    model sales = region;
run;

proc mixed data=demo_data
           method=REML
           plots=all;

    class region category;

    model sales = region category
        / solution cl chisq;

    random region;

    repeated / subject=region type=cs;

    ods output SolutionF=mixed_fixed;

run;


/*---------------------------*/
/* PROC LOGISTIC */
/*---------------------------*/

proc logistic data=demo_data;
    class gender;
    model category(event='B') = age;
run;

proc logistic data=demo_data
              plots(only)=roc(id=prob)
              descending;

    class gender region / param=ref;

    model category(event='B') =
        age height weight region gender
        / clodds=wald rsquare lackfit;

    output out=log_out
        p=prob
        xbeta=logit;

    ods output OddsRatios=log_odds;

run;


/*---------------------------*/
/* PROC GENMOD */
/*---------------------------*/

proc genmod data=demo_data;
    class region;
    model sales = region;
run;

proc genmod data=demo_data;

    class region category;

    model sales = age height weight
        / dist=normal link=identity type3;

    repeated subject=region / type=cs;

    ods output ParameterEstimates=genmod_out;

run;


/*============================================================================*/
/* ERA 4: SPECIALIZED METHODS */
/*============================================================================*/

/*---------------------------*/
/* PROC NPAR1WAY */
/*---------------------------*/

proc npar1way data=demo_data;
    class region;
    var sales;
run;

proc npar1way data=demo_data wilcoxon median edf;

    class category;
    var sales;

    exact wilcoxon;

run;


/*---------------------------*/
/* PROC LIFETEST */
/*---------------------------*/

data survival_data;
    set demo_data;
    time = sales;
    censor = (sales < 200);
run;

proc lifetest data=survival_data;
    time time*censor(1);
run;

proc lifetest data=survival_data plots=survival;

    time time*censor(1);

    strata region;

    ods output Quartiles=life_out;

run;


/*---------------------------*/
/* PROC PHREG */
/*---------------------------*/

proc phreg data=survival_data;
    model time*censor(1) = age;
run;

proc phreg data=survival_data;

    class region;

    model time*censor(1) =
        age region
        / ties=efron risklimits;

    hazardratio region;

    baseline out=phreg_out survival=surv;

run;


/*============================================================================*/
/* ERA 5: MODERN / BAYESIAN */
/*============================================================================*/

/*---------------------------*/
/* PROC MCMC */
/*---------------------------*/

proc mcmc data=demo_data outpost=postout nmc=1000 seed=123;
    parms beta0 0 beta1 0;
    prior beta: ~ normal(0, var=100);

    model sales ~ normal(beta0 + beta1*age, var=1);
run;

proc mcmc data=demo_data
          outpost=postout
          nmc=5000
          thin=5
          seed=123;

    parms beta0 0 beta1 0;

    prior beta: ~ normal(0, var=1000);

    model sales ~ normal(beta0 + beta1*age, var=1);

    monitor=(beta0 beta1);

run;


/*============================================================================*/
/* END */
/*============================================================================*/