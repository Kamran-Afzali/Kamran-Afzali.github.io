
## Causal Inference in Practice II: Propensity Scores, Doubly Robust Estimators, and Inverse Probability Weighting
The previous post investigated the foundations of Randomized Controlled Trials and Regression Adjustment. In real-world observational data, achieving balance on covariates is challenging, and simple regression models rely heavily on conditional independence and correct model specification. Propensity score–based methods, including matching, Inverse Probability Weighting (IPW), and doubly robust estimation, offer suitable alternatives. These methods alleviate some assumptions but introduce others such as positivity and model correctness. In this essay, we articulate their theoretical motivations, derive formal estimators, and demonstrate implementation in R.

### Propensity Score Methods

Propensity score methods serve to emulate a randomized trial by balancing observed confounders across treatment groups. The **propensity score** $e(x) = P(D=1 \mid X=x)$ compresses multivariate covariate information into a single scalar. Under the assumption of **conditional ignorability** ($Y(1),Y(0) \perp D \mid X$) and **overlap** ($0 < e(x) < 1$), adjusting for $e(x)$ suffices to remove bias due to observed covariates.

Formally, denote the **propensity score–adjusted estimator**:

$$
\widehat{\text{ATE}} = \frac{1}{n} \sum_{i=1}^n \left( \frac{D_i Y_i}{\hat e(X_i)} - \frac{(1-D_i)Y_i}{1 - \hat e(X_i)} \right).
$$

In practice, one normally models $e(x)$ with logistic regression:

```r
# Estimate propensity score
ps_model <- glm(treatment ~ covariate, family = binomial(), data = data_obs)
data_obs$pscore <- predict(ps_model, type = "response")

# Visual check of overlap
ggplot(data_obs, aes(x = pscore, fill = factor(treatment))) +
  geom_density(alpha = 0.5) +
  labs(title = "Propensity Score Distribution by Treatment")
```

To estimate ATE by matching:

```r
library(MatchIt)
match_out <- matchit(treatment ~ covariate, data = data_obs, method = "nearest", ratio = 1)
matched <- match.data(match_out)
lm_matched <- lm(outcome ~ treatment, data = matched)
summary(lm_matched)
```

Here, `coefficients()` for treatment gives the ATE among matched units, interpretable under the assumption of balance on $X$. Diagnostics should include covariate balance checks after matching (e.g., `plot(match_out, type="jitter")`).



### Inverse Probability Weighting (IPW)

IPW uses **propensity score–based weighting** to reweight the sample, such that the weighted treated and control groups become exchangeable. Each subject is weighted as:

$$
w_i = \frac{D_i}{\hat e(X_i)} + \frac{1-D_i}{1-\hat e(X_i)}.
$$

Then,

$$
\widehat{\text{ATE}}_{\text{IPW}} = \frac{\sum_i w_i Y_i}{\sum_i w_i}.
$$

IPW estimates the ATE without explicit modeling of $E[Y \mid D, X]$, but hinge critically on correctly specified propensity scores and stable overlap.

```r
library(survey)
data_obs$wt <- with(data_obs, ifelse(treatment == 1, 1/pscore, 1/(1-pscore)))
design <- svydesign(ids = ~1, weights = ~wt, data = data_obs)
ipw_mod <- svyglm(outcome ~ treatment, design = design)
summary(ipw_mod)
```

The coefficient on **treatment** gives the IPW-estimated ATE. One must check for **extreme weights** using summaries (`summary(data_obs$wt)`) and consider trimming.



### Doubly Robust Estimators

Doubly robust estimators combine outcome modeling and propensity weighting so that estimation remains consistent if **either** model is correctly specified. The canonical form is:

$$
 \widehat{\text{ATE}}_{\text{DR}} &= \frac{1}{n} \sum_i \Bigg\{ \left( \frac{D_i}{\hat e(X_i)} - \frac{1-D_i}{1-\hat e(X_i)}\right)\left[Y_i - \hat m(D_i, X_i)\right] \\
&\quad\quad + \hat m(1, X_i) - \hat m(0, X_i) \Bigg\},
 $$

where $\hat m(D, X)$ is an estimated regression of outcome on treatment and covariates.

```r
# Outcome model
om_mod <- lm(outcome ~ treatment + covariate, data = data_obs)
data_obs$mu1_hat <- predict(om_mod, newdata = transform(data_obs, treatment = 1))
data_obs$mu0_hat <- predict(om_mod, newdata = transform(data_obs, treatment = 0))

# Doubly robust ATE
dr_ate <- with(data_obs, mean((treatment/pscore - (1-treatment)/(1-pscore))*(outcome - (treatment*mu1_hat + (1-treatment)*mu0_hat)) + mu1_hat - mu0_hat))
dr_ate
```

This `dr_ate` estimate is **doubly robust**: consistent if either propensity or outcome model is correct. Practical use involves bootstrapping for variance.



### Integrative Interpretation

Propensity scores adjust for observed confounders in a manner motivated by design, yielding a pseudo-randomized experiment. IPW pushes this further by weighting, creating a synthetic population. Doubly robust methods guard against misspecification of either the weighting model or the outcome model—ensuring valid ATE estimation under broader conditions.

However, each method remains anchored in core assumptions: **ignorability**, **overlap**, and **model correctness**. Diagnostics—such as balance checks after matching/IPW, weight summaries, and residual/outcome-model validation—are essential before causal claims are made.



### Summary Table

| Method                              | Model Requirement                         | Consistency If                   | Estimator Formula                                      | Primary Strength                        |
| ----------------------------------- | ----------------------------------------- | -------------------------------- | ------------------------------------------------------ | --------------------------------------- |
| Propensity Score Matching           | Logistic for $e(x)$                       | Propensity correctly estimated   | Difference in means after matching                     | Balances covariates; design mimicry     |
| Inverse Probability Weighting (IPW) | Logistic for $e(x)$                       | Propensity correctly estimated   | Weighted regression or weighted mean difference        | Creates reweighted, exchangeable sample |
| Doubly Robust Estimator             | Logistic for $e(x)$ *or* outcome $m(D,X)$ | Either model correctly specified | ATE combining weighted residuals and conditional means | Robust to misspecification, efficient   |



### Conclusion

This post has advanced our series by exploring methods that bridge the gap between randomization and modeling. Propensity scores, IPW, and doubly robust estimators offer complementary strategies for tackling confounding, each accompanied by unique trade‑offs in terms of assumptions, stability, and interpretability. The next installment will explore Matching, Difference-in-Differences, and Instrumental Variables, offering further depth and methods for complex real-world data.

### References  
Rosenbaum, P. R., & Rubin, D. B. (1983). The central role of the propensity score in observational studies for causal effects. Biometrika, 70(1), 41–55.

Robins, J. M., & Rotnitzky, A. (1995). Semiparametric efficiency in multivariate regression models with missing data. Journal of the American Statistical Association, 90(429), 122–129.

Bang, H., & Robins, J. M. (2005). Doubly robust estimation in missing data and causal inference models. Biometrics, 61(4), 962–973.

Hernán, M. A., & Robins, J. M. (2020). Causal Inference: What If. Chapman & Hall/CRC.
