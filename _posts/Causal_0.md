# Foundations of Causal Statistical Analysis: An Integrated Overview of Key Techniques

Causal inference is central to empirical research across fields like public health, economics, education, and artificial intelligence. While standard statistical models capture associations, scientific progress often hinges on estimating **causal effects**—answering "what would happen if we intervened?" This post, the first in a series, offers a comprehensive introduction to foundational causal analysis techniques, outlining assumptions, applications, advantages, limitations, and tools.


## Summary Table: Techniques for Causal Statistical Analysis

| Technique                                     | Key Assumptions                                    | Use Cases                           | Strengths                                          | Limitations                                            | Tools/Packages                                        |
| --------------------------------------------- | -------------------------------------------------- | ----------------------------------- | -------------------------------------------------- | ------------------------------------------------------ | ----------------------------------------------------- |
| Randomized Controlled Trials (RCTs)           | Random assignment ensures exchangeability          | Clinical trials, A/B testing        | Eliminates confounding                             | Often infeasible or unethical                          | `randomizr` (R), `DoWhy` (Py)                         |
| Regression Adjustment                         | No unmeasured confounders, correct model           | Policy, health outcomes             | Simple, widely used                                | Sensitive to omitted variables, model misspecification | `lm()`, `glm()` (R), `statsmodels`, `sklearn` (Py)    |
| Propensity Score Matching (PSM)               | Conditional independence given observed covariates | Observational studies               | Balances covariates, intuitive                     | Sensitive to unmeasured confounding, poor overlap      | `MatchIt`, `twang` (R), `DoWhy`, `causalml` (Py)      |
| Inverse Probability Weighting (IPW)           | Correct treatment model, positivity                | Longitudinal data                   | Handles time-varying confounding                   | Can produce unstable weights                           | `ipw`, `survey` (R), `zEpid` (Py)                     |
| Difference-in-Differences (DiD)               | Parallel trends                                    | Policy reforms, natural experiments | Controls for unobserved time-invariant confounders | Vulnerable if trends diverge                           | `fixest`, `did` (R), `linearmodels` (Py)              |
| Instrumental Variables (IV)                   | Relevance, exclusion restriction                   | Endogeneity correction              | Addresses unmeasured confounding                   | Finding valid instruments is hard                      | `ivreg`, `AER` (R), `linearmodels.iv` (Py)            |
| Regression Discontinuity (RDD)                | Sharp cutoff, local randomization                  | Education, policy thresholds        | Transparent identification                         | Limited to local effect near cutoff                    | `rdrobust`, `rddtools` (R), `rdd`, `statsmodels` (Py) |
| Causal Forests                                | Unconfoundedness, heterogeneity                    | Precision medicine, targeting       | Captures treatment heterogeneity                   | Requires large data, unmeasured confounding risk       | `grf`, `causalTree` (R), `econml`, `causalml` (Py)    |
| Bayesian Structural Time Series (BSTS)        | No unmeasured confounders post-intervention        | Time series interventions           | Handles complex time trends                        | Sensitive to model/priors                              | `CausalImpact`, `bsts` (R), `tfcausalimpact` (Py)     |
| Targeted Maximum Likelihood Estimation (TMLE) | Double robustness                                  | Epidemiology, observational data    | Robust, ML integration                             | Computationally intensive                              | `tmle`, `ltmle` (R), `zepid` (Py)                     |
| G-Computation                                 | No unmeasured confounding, correct model           | Mediation, marginal effects         | Flexible, counterfactuals                          | Model dependence                                       | `gfoRmula`, `ltmle` (R), `zepid` (Py)                 |
| Structural Equation Modeling (SEM)            | Correct structure, no unmeasured confounding       | Latent variables, mediation         | Models complex relationships                       | Requires strong assumptions                            | `lavaan` (R), `semopy`, `pysem` (Py)                  |
| Directed Acyclic Graphs (DAGs)                | Causal sufficiency, accurate knowledge             | Study design, confounder control    | Clarifies assumptions                              | Not an estimation method                               | `dagitty`, `ggdag` (R), `causalgraphicalmodels` (Py)  |


## Methodological Deep Dive with Practical Guidance

**Randomized Controlled Trials (RCTs)**
RCTs are the gold standard for causal inference. Random assignment neutralizes confounding, ensuring internal validity. However, practical, ethical, or financial constraints often limit their feasibility. When viable, they deliver the most credible causal estimates.

**Regression Adjustment**
This method models the outcome as a function of treatment and covariates. While easy to implement, it assumes no unmeasured confounding and correct model specification. It’s essential to examine covariate balance and conduct robustness checks.

**Propensity Score Matching (PSM)**
PSM aims to mimic randomization by matching units with similar probabilities of treatment. It balances covariates well but fails under unmeasured confounding. Diagnostic tools like balance plots are crucial.

**Inverse Probability Weighting (IPW)**
IPW reweights samples to simulate random assignment. It handles time-varying confounding but can produce unstable weights, requiring trimming or stabilization. It’s powerful for longitudinal and panel data.

**Difference-in-Differences (DiD)**
DiD compares treated and control units over time, assuming parallel trends. It is popular for evaluating policy interventions but sensitive to trend violations. Visualizing pre-treatment trends and using placebo tests enhance credibility.

**Instrumental Variables (IV)**
IV methods handle endogeneity by using external variables that affect treatment but not the outcome directly. The approach hinges on the strength and validity of instruments—criteria that are difficult to verify.

**Regression Discontinuity Design (RDD)**
RDD exploits sharp cutoffs for treatment assignment. It provides quasi-experimental validity but estimates only local effects near the threshold. Validity depends on smoothness and non-manipulation at the cutoff.

**Causal Forests**
Causal forests extend random forests to estimate heterogeneous treatment effects. They are ideal for personalized interventions but require large datasets and are vulnerable to omitted confounding.

**Bayesian Structural Time Series (BSTS)**
BSTS combines state-space models with Bayesian inference to estimate intervention effects in time series. It accommodates trend and seasonality but is sensitive to model misspecification and prior choices.

**Targeted Maximum Likelihood Estimation (TMLE)**
TMLE integrates machine learning into causal effect estimation. It provides double robustness and efficient inference under complex data settings but can be computationally demanding.

**G-Computation**
G-computation models potential outcomes under each treatment. It is flexible and counterfactual-based but requires accurate modeling and complete covariate adjustment.

**Structural Equation Modeling (SEM)**
SEM enables the modeling of complex causal structures, including latent constructs and mediation. Its interpretability is appealing but hinges on correct model specification and the absence of unmeasured confounding.

**Directed Acyclic Graphs (DAGs)**
DAGs are essential for clarifying causal assumptions. While not an estimation method, they guide design and analysis by identifying confounders, mediators, and colliders.



## Integrating and Combining Methods

Causal methods are often more powerful when integrated. For example:

* **Matching + DiD**: Improves balance and leverages temporal variation.
* **TMLE + Machine Learning**: Combines robustness and predictive power.
* **DAGs for Method Selection**: Informs appropriate adjustment strategies.

Sensitivity analyses (e.g., falsification tests, placebo outcomes) are essential to validate causal claims, especially when assumptions are unverifiable.





## Conclusion

Causal analysis is indispensable for understanding and acting on complex systems. A robust causal claim requires not only the right method but also a thoughtful consideration of assumptions, diagnostics, and domain knowledge. This series will delve into each method in detail, with code, diagnostics, and applied case studies to guide rigorous causal analysis.



**Suggested Reading and Resources**

1. Hernán & Robins (2020). *Causal Inference: What If*.
2. Pearl, Glymour, & Jewell (2016). *Causal Inference in Statistics: A Primer*.
3. VanderWeele (2015). *Explanation in Causal Inference*.
4. Causal AI Blog by Judea Pearl: [https://causality.cs.ucla.edu/blog/](https://causality.cs.ucla.edu/blog/)
5. Netflix Tech Blog on Causal Inference: [https://netflixtechblog.com/computational-causal-inference-at-netflix-293591691c62](https://netflixtechblog.com/computational-causal-inference-at-netflix-293591691c62)
6. Number Analytics Education Series: [https://www.numberanalytics.com/blog/](https://www.numberanalytics.com/blog/)


