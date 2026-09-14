/*============================================================================*/
/* SAS STAT PROCEDURES */
/*============================================================================*/


/*============================================================================*/
/* SECTION 0: DEMO DATA */
/*============================================================================*/

data demo_data;

    length
        name $12
        gender $1
        region $10
        category $10;

    format date date9.;

    call streaminit(12345);

    do id = 1 to 20;

        name = cats('P',put(id,z2.));

        gender =
            ifc(mod(id,2)=0,'M','F');

        region =
            scan('North South East West',
                 mod(id-1,4)+1);

        category =
            scan('A B C',
                 mod(id-1,3)+1);

        do visit = 1 to 4;

            age = 13 + mod(id,4);

            height =
                55 +
                id +
                rand('normal',0,2);

            weight =
                85 +
                id +
                visit*2 +
                rand('normal',0,3);

            sales =
                100 +
                (age*8) +
                (visit*10) +
                (id*4) +
                rand('normal',0,25);

            date =
                '01JAN2024'd +
                (visit-1)*30;

            output;

        end;
    end;

run;

data demo_data;
    set demo_data;

    high_sales =
        (sales >= 220);

run;



/*============================================================================*/
/* ERA 1: CLASSICAL STATISTICS */
/*============================================================================*/

/*
    Classical statistics represents the foundation of inferential analysis.

    Fundamental questions:

        • Are two groups different?
        • Are multiple groups different?
        • Are variables related?
        • What if distributional assumptions are not valid?

    These procedures form the historical core of SAS/STAT and were among
    the earliest methods widely used in scientific research.
*/


/*---------------------------*/
/* PROC TTEST */
/*---------------------------*/

/*
    Statistical Theory:

    The t-test evaluates whether the means of two populations are
    significantly different.

    H0 (Null Hypothesis):
        Mean(Group1) = Mean(Group2)

    HA (Alternative Hypothesis):
        Mean(Group1) ≠ Mean(Group2)

    The procedure compares:
        Difference in means
        ------------------------------------
        Estimated standard error

    producing a t-statistic and p-value.

    Common applications:
        • Clinical trials
        • A/B testing
        • Experimental research

    Historical significance:

    One of the most widely used inferential procedures in statistics and
    typically the first formal hypothesis test taught in statistical
    methodology.
*/

/* SIMPLE */
proc ttest data=demo_data;

    class gender;

    var sales;

run;


/*
    Advanced version demonstrates:
        • Multiple response variables
        • Hypothesis controls
        • Confidence levels
        • ODS outputs
        • Diagnostic graphics
*/

/* FULL OPTION BLOCK */
proc ttest data=demo_data
           alpha=0.05
           h0=0
           sides=2
           plots=all;

    class gender;

    var sales
        height
        weight;

    ods output
        Statistics=ttest_stats
        TTests=ttest_tests
        Equality=ttest_equal;

run;


/*---------------------------*/
/* PROC ANOVA */
/*---------------------------*/

/*
    Statistical Theory:

    Analysis of Variance (ANOVA) extends the t-test to multiple groups.

    Fundamental question:

        Is the variability BETWEEN groups larger than the
        variability WITHIN groups?

    ANOVA partitions total variation into:

        Total Variation
            =
        Between-Group Variation
            +
        Within-Group Variation

    The resulting F-statistic evaluates whether group means are
    significantly different.

    Historical significance:

    ANOVA is one of the foundational methods of experimental design and
    agricultural statistics, forming much of the basis of modern
    statistical inference.
*/

/* SIMPLE */
proc anova data=demo_data;

    class region;

    model sales = region;

run;
quit;


/*
    Advanced version demonstrates:
        • Multiple classification variables
        • Post-hoc comparisons
        • Multiple comparison corrections
        • ODS output capture
*/

/* FULL OPTION BLOCK */
proc anova data=demo_data;

    class region
          category;

    model sales =
          region
          category;

    means region
          category
          / tukey
            bon
            scheffe
            cldiff;

    ods output
        OverallANOVA=anova_out
        ModelANOVA=model_anova_out;

run;
quit;


/*---------------------------*/
/* PROC CORR */
/*---------------------------*/

/*
    Statistical Theory:

    Correlation analysis measures association between variables.

    Pearson Correlation:
        Measures linear relationships.

    Spearman Correlation:
        Measures monotonic relationships using ranks.

    Kendall Correlation:
        Measures ordinal agreement.

    Correlation coefficient range:

        -1  Perfect negative relationship
         0  No relationship
        +1  Perfect positive relationship

    Historical significance:

    Correlation analysis became one of the earliest and most important
    exploratory techniques in statistical science.
*/

/* SIMPLE */
proc corr data=demo_data;

    var sales
        height;

run;


/*
    Advanced version demonstrates:
        • Multiple correlation methods
        • Matrix visualization
        • ODS output datasets
*/

/* FULL OPTION BLOCK */
proc corr data=demo_data
          pearson
          spearman
          kendall
          plots=matrix(histogram)
          nosimple;

    var sales
        age
        height
        weight;

    ods output
        PearsonCorr=pearson_out
        SpearmanCorr=spearman_out
        KendallCorr=kendall_out;

run;


/*---------------------------*/
/* PROC NPAR1WAY */
/*---------------------------*/

/*
    Statistical Theory:

    Nonparametric methods relax assumptions required by parametric tests.

    Parametric procedures often assume:

        • Normal distributions
        • Equal variances
        • Interval-scaled data

    PROC NPAR1WAY replaces raw values with ranks and evaluates whether
    distributions differ between groups.

    Common methods:

        Wilcoxon:
            Rank-based alternative to the t-test

        Median Test:
            Comparison of population medians

        EDF Tests:
            Empirical distribution function comparisons

    Historical significance:

    Nonparametric procedures became important when researchers needed
    valid inferential results without strict distributional assumptions.
*/

/* SIMPLE */
proc npar1way data=demo_data;

    class region;

    var sales;

run;


/*
    Advanced version demonstrates:
        • Multiple nonparametric test families
        • Exact inference methods
        • Distribution-free testing
*/

/* FULL OPTION BLOCK */
proc npar1way data=demo_data
              wilcoxon
              median
              edf;

    class category;

    var sales;

    exact wilcoxon;

run;

/*============================================================================*/
/* ERA 2: LINEAR MODELS */
/*============================================================================*/

/*
    The evolution of statistical modeling begins with regression.

    Fundamental question:

        Can one or more predictor variables explain or predict
        the behavior of a response variable?

    The procedures in this era represent the development of:

        • Linear Regression
        • General Linear Models
        • Automated Model Selection
        • Nonlinear Regression

    This marks the transition from:

        "Are groups different?"

    to

        "What mathematical relationship exists between variables?"

    Historically, this era forms the backbone of predictive analytics.
*/


/*---------------------------*/
/* PROC REG */
/*---------------------------*/

/*
    Statistical Theory:

    Ordinary Least Squares (OLS) Regression.

    PROC REG estimates a linear relationship between
    a dependent variable (Y) and one or more independent
    variables (X).

    Basic Model:

        Y = β0 + β1X1 + β2X2 + ... + ε

    where:

        β0 = Intercept
        βn = Regression coefficients
        ε  = Random error

    The procedure minimizes:

        Sum of Squared Errors (SSE)

    by finding coefficient estimates that produce the
    smallest overall prediction error.

    Statistical concepts demonstrated:

        • Parameter estimation
        • Goodness of fit
        • R-squared
        • Residual analysis
        • Multicollinearity diagnostics

    Historical significance:

    Regression is one of the most important procedures ever developed in
    statistics and serves as the foundation for many modern predictive
    modeling techniques.
*/

/* SIMPLE */
proc reg data=demo_data;

    model sales = age;

run;
quit;


/*
    Advanced version demonstrates:

        • Multiple predictors
        • Variance Inflation Factors (VIF)
        • Tolerance diagnostics
        • Standardized coefficients
        • Confidence limits
        • Specification testing
        • Durbin-Watson autocorrelation testing
        • Output datasets
        • ODS integration
        • Regression diagnostics
*/

/* FULL OPTION BLOCK */
proc reg data=demo_data
          plots(unpack)=all;

    model sales =
          age
          height
          weight

          / vif
            tol
            stb
            clb
            spec
            dw;

    output out=reg_out
        p=predicted
        r=residual
        student=student_resid
        cookd=cookd;

    ods output
        ParameterEstimates=reg_params;

run;
quit;


/*---------------------------*/
/* PROC GLM */
/*---------------------------*/

/*
    Statistical Theory:

    General Linear Models (GLM).

    PROC GLM extends regression by allowing both:

        • Continuous predictors
        • Categorical predictors

    Example:

        sales = region + category + gender

    Unlike PROC REG, GLM automatically creates design matrices for
    classification variables through indicator (dummy) coding.

    Statistical concepts demonstrated:

        • ANOVA
        • ANCOVA
        • Factor effects
        • Least Squares Means
        • Contrasts
        • Parameter estimation

    Historical significance:

    PROC GLM became one of the primary analytical procedures in SAS,
    unifying regression and analysis of variance into a common
    mathematical framework.
*/

/* SIMPLE */
proc glm data=demo_data;

    class region;

    model sales = region;

run;
quit;


/*
    Advanced version demonstrates:

        • Multiple categorical factors
        • Least-squares means
        • Pairwise comparisons
        • Multiple-comparison adjustment
        • Custom contrasts
        • Effect estimation
        • ODS output datasets
*/

/* FULL OPTION BLOCK */
proc glm data=demo_data
         plots=all;

    class region
          category
          gender;

    model sales =
          region
          category
          gender;

    lsmeans region
            category
            / pdiff
              adjust=tukey;

    contrast 'North vs South'
             region 1 -1 0 0;

    estimate 'Custom Effect'
             region 1 -1 0 0;

    ods output
        LSMeans=glm_lsmeans;

run;
quit;


/*---------------------------*/
/* PROC GLMSELECT */
/*---------------------------*/

/*
    Statistical Theory:

    Model Selection and Variable Selection.

    Real-world datasets often contain many potential predictors.

    Fundamental question:

        Which variables should remain in the model?

    PROC GLMSELECT automates model-building strategies.

    Common approaches:

        Forward Selection:
            Start small and add variables

        Backward Elimination:
            Start large and remove variables

        Stepwise Selection:
            Add and remove variables iteratively

    Model selection often relies on information criteria:

        • AIC
        • SBC/BIC
        • Validation performance

    Historical significance:

    Represents SAS's transition from classical statistical modeling
    toward machine-learning-inspired automated model construction.
*/

/* SIMPLE */
proc glmselect data=demo_data;

    model sales =
          age
          height
          weight;

run;


/*
    Advanced version demonstrates:

        • Automatic variable selection
        • Information criteria
        • Training / testing partitioning
        • Model assessment statistics
        • Selection diagnostics
        • Graphical output
*/

/* FULL OPTION BLOCK */
proc glmselect data=demo_data
               plots=all;

    partition fraction(test=0.30);

    model sales =
          age
          height
          weight

          / selection=stepwise(
                select=aic
                stop=aic)
            stats=all;

run;


/*---------------------------*/
/* PROC NLIN */
/*---------------------------*/

/*
    Statistical Theory:

    Nonlinear Regression.

    Not all relationships are linear.

    Many scientific phenomena are better represented by:

        Growth curves
        Exponential decay
        Biological response models
        Physical process equations

    PROC NLIN estimates parameters in models where predictors enter
    the equation nonlinearly.

    Example:

        Y = a + b*X^2

    or

        Y = a*exp(bX)

    Estimation is performed through iterative numerical optimization.

    Common algorithms include:

        • Gauss-Newton
        • Marquardt
        • Gradient-based methods

    Historical significance:

    PROC NLIN introduced numerical optimization techniques into
    mainstream statistical modeling and laid groundwork for more
    advanced likelihood-based procedures.
*/

/* SIMPLE */
proc nlin data=demo_data;

    parms a=100
          b=5
          c=1;

    model sales =
          a + b*age + c*(visit*visit);

run;


/*
    Advanced version demonstrates:

        • Explicit starting values
        • Iterative optimization
        • Marquardt estimation
        • Predicted values
        • Residual output
        • Model diagnostics
*/

/* FULL OPTION BLOCK */
proc nlin data=demo_data
          method=marquardt;

    parms a=100
          b=5;

    model sales =
          a + b*age;

    output out=nlin_out
        predicted=pred
        residual=resid;

run;

/*============================================================================*/
/* ERA 3: GENERALIZED & MIXED MODELS */
/*============================================================================*/

/*
    Classical linear models assume:

        • Normally distributed errors
        • Independent observations
        • Constant variance

    Real-world data frequently violates these assumptions.

    This era represents the evolution of statistical modeling beyond
    ordinary least squares.

    Questions addressed:

        • What if the response is categorical?
        • What if observations are correlated?
        • What if random effects exist?
        • What if we need generalized distributions?
        • What if the model is both nonlinear and mixed?

    These procedures form the bridge between traditional statistical
    modeling and modern predictive analytics.
*/


/*---------------------------*/
/* PROC MIXED */
/*---------------------------*/

/*
    Statistical Theory:

    Mixed Models extend the General Linear Model by introducing
    random effects.

    Traditional models contain:

        Fixed Effects

    Mixed models contain:

        Fixed Effects
        +
        Random Effects

    Examples:

        Students within schools
        Patients within hospitals
        Measurements within subjects

    Mixed models account for correlation structures and hierarchical
    data that violate ordinary regression assumptions.

    Historical significance:

    PROC MIXED became one of the most important advances in SAS/STAT,
    enabling repeated measures analysis and hierarchical modeling.
*/

/* SIMPLE */
proc mixed data=demo_data;

    class region;

    model sales = region;

run;


/*
    Advanced version demonstrates:

        • REML estimation
        • Fixed-effect solutions
        • Random effects
        • Repeated measures
        • Covariance structures
        • Confidence intervals
        • ODS output
        • Diagnostic graphics
*/

/* FULL OPTION BLOCK */
proc mixed data=demo_data
           method=reml
           plots=all;
           
class id region category visit;

model sales =
      region
      category
      visit
      / solution cl;

random intercept / subject=id;

repeated visit
    / subject=id
      type=cs;

    ods output
        SolutionF=mixed_fixed;

run;


/*---------------------------*/
/* PROC LOGISTIC */
/*---------------------------*/

/*
    Statistical Theory:

    Logistic Regression models probabilities rather than continuous
    response values.

    Ordinary regression predicts:

        Any real number

    Logistic regression predicts:

        Probabilities between 0 and 1

    The model estimates:

                        P
        Logit(P) = ln(-----)
                      1-P

    Common applications:

        Disease prediction
        Customer churn
        Credit risk
        Classification problems

    Historical significance:

    Logistic regression became one of the foundational procedures for
    predictive modeling and classification.
*/

/* SIMPLE */
proc logistic data=demo_data;

    class gender;

    model high_sales(event='1') =
          age;

run;


/*
    Advanced version demonstrates:

        • Reference coding
        • Odds ratios
        • ROC analysis
        • Classification diagnostics
        • Predicted probabilities
        • Model fit assessment
        • ODS outputs
*/

/* FULL OPTION BLOCK */
proc logistic data=demo_data
              descending
              plots(only)=roc(id=prob);

    class gender
          region
          / param=ref;

    model high_sales(event='1') =
          age
          height
          weight
          region
          gender

          / clodds=wald
            rsquare
            lackfit;

    output out=log_out
        p=prob
        xbeta=logit;

    ods output
        OddsRatios=log_odds;

run;


/*---------------------------*/
/* PROC GENMOD */
/*---------------------------*/

/*
    Statistical Theory:

    Generalized Linear Models (GLMs).

    Classical linear models assume:

        Response ~ Normal Distribution

    PROC GENMOD extends modeling to alternative distributions:

        Normal
        Binomial
        Poisson
        Gamma
        Negative Binomial

    The model consists of:

        Random Component
        Link Function
        Linear Predictor

    Common examples:

        Counts
        Rates
        Proportions
        Event data

    Historical significance:

    PROC GENMOD unified a large family of statistical models into a
    single framework.
*/

/* SIMPLE */
proc genmod data=demo_data;

    class region;

    model sales = region;

run;


/*
    Advanced version demonstrates:

        • Distribution specification
        • Link functions
        • Type III tests
        • Repeated structures
        • Correlated observations
        • Parameter output
*/

/* FULL OPTION BLOCK */
proc genmod data=demo_data;

    class region
          category;

    model sales =
          age
          height
          weight

          / dist=normal
            link=identity
            type3;

    repeated
        subject=id
        / type=cs;

    ods output
        ParameterEstimates=genmod_out;

run;


/*---------------------------*/
/* PROC GLIMMIX */
/*---------------------------*/

/*
    Statistical Theory:

    Generalized Linear Mixed Models.

    PROC GLIMMIX combines ideas from:

        PROC MIXED
            +
        PROC GENMOD

    allowing:

        • Non-normal responses
        • Random effects
        • Correlated observations

    This procedure is frequently used when:

        Data are clustered
        Responses are categorical
        Random variation exists

    Examples:

        Educational studies
        Medical studies
        Longitudinal research

    Historical significance:

    PROC GLIMMIX became the natural successor to many MIXED and
    GENMOD workflows.
*/

/* SIMPLE */
proc glimmix data=demo_data;

    class region;

    model sales = region;

run;


/*
    Advanced version demonstrates:

        • Mixed-model estimation
        • Random effects
        • Least-squares means
        • Multiple comparisons
        • Solution estimates
        • Graphics
*/

/* FULL OPTION BLOCK */
proc glimmix data=demo_data
             plots=all;

    class region
          category;

    model sales =
          region
          category
          / solution;

random intercept / subject=id;

    lsmeans region
            / adjust=tukey;

    ods output
        LSMeans=glimmix_lsmeans
        SolutionF=glimmix_solution;

run;


/*---------------------------*/
/* PROC NLMIXED */
/*---------------------------*/

/*
    Statistical Theory:

    Nonlinear Mixed Models.

    PROC NLMIXED combines ideas from:

        Nonlinear Regression
            +
        Mixed Models

    The procedure allows user-defined likelihood functions and highly
    flexible model structures.

    Components:

        • Nonlinear mean structure
        • Random effects
        • Maximum likelihood estimation
        • Numerical integration

    Unlike PROC MIXED and GLIMMIX, PROC NLMIXED allows the analyst
    to directly specify the likelihood function while simultaneously
    incorporating random effects.

    Common applications:

        • Pharmacokinetics
        • Growth curve analysis
        • Longitudinal studies
        • Biological systems
        • Engineering models

    Historical significance:

    PROC NLMIXED is one of SAS/STAT's most flexible procedures,
    providing direct access to nonlinear mixed-effects likelihood
    modeling and numerical integration methods.
*/

/* SIMPLE */
proc nlmixed data=demo_data;

    parms beta0=100
          beta1=5
          sigma=25;

    model sales ~ normal(beta0 + beta1*age, sigma);

run;


/*
    Advanced version demonstrates:

        • User-defined likelihoods
        • Random effects
        • Subject-level variation
        • Adaptive Gaussian quadrature
        • Numerical integration
        • Prediction output
        • Mixed-effects estimation

    This example introduces a subject-specific random effect that
    allows each observational unit to deviate from the population
    average regression relationship.
*/

/* FULL OPTION BLOCK */
proc nlmixed data=demo_data
             qpoints=5;

    parms beta0=100
          beta1=5
          sigma=25
          s2u=10;

    random u ~ normal(0,s2u)
        subject=id;

    model sales ~ normal(beta0 + beta1*age + u,
                         sigma);

    predict beta0 + beta1*age + u
        out=nlmixed_out;

run;


