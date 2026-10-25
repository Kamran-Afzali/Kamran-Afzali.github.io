# Model Comparison in Bayesian Analysis, Part 2: Predictive Accuracy with WAIC and LOO-CV

*Series: Bayesian model comparison and selection. Part 2 of 3. Part 1 introduced the running example and posterior predictive checks; Part 3 covers Bayes factors.*

## Introduction

Posterior predictive checks tell us whether a model is adequate, but they do not rank models. If the goal is prediction, we need a quantity that measures how well a model would do on data it has not seen, and that accounts for the fact that a flexible model can look good on the data used to fit it. WAIC and leave-one-out cross-validation (LOO-CV) are the two standard Bayesian answers. This post defines the target they estimate, derives each estimator, explains the Pareto $k$ diagnostic that makes PSIS-LOO usable in practice, and applies everything to the running example from Part 1. It ends with stacking, which replaces "pick one model" with "weight the models by predictive performance."

## The target: expected log predictive density

Suppose the true data-generating distribution is $p_t(\tilde{y})$. For a new observation $\tilde{y}_i$, the log score of a fitted model $M$ is $\log p(\tilde{y}_i\mid y)$, and the quantity we would like to know is the expected log predictive density for new data,

$$
\text{elpd} = \sum_{i=1}^{n} \int p_t(\tilde{y}_i)\,\log p(\tilde{y}_i\mid y)\,d\tilde{y}_i .
$$

Maximizing elpd is equivalent to minimizing the Kullback–Leibler divergence from $p_t$ to the model's predictive distribution, since the entropy of $p_t$ is the same for every candidate. The log score is a proper scoring rule, which is one reason it is the default choice, although other scores (e.g., CRPS or a decision-specific loss) may suit particular applications better (Gneiting & Raftery, 2007).

We never observe $p_t$, so elpd must be estimated. The naive estimate is the log pointwise predictive density evaluated on the observed data,

$$
\text{lppd} = \sum_{i=1}^{n}\log\!\left(\frac{1}{S}\sum_{s=1}^{S} p(y_i\mid\theta^{(s)})\right),
$$

but it uses the data twice and is therefore optimistic. WAIC and LOO each correct that optimism in a different way.

## WAIC

Watanabe (2010) showed that the optimism can be estimated from the posterior variance of the pointwise log likelihood. The effective number of parameters is

$$
p_{\text{WAIC}} = \sum_{i=1}^{n} \operatorname{Var}_{s}\!\big[\log p(y_i\mid\theta^{(s)})\big],
$$

and the bias-corrected estimate of elpd is

$$
\widehat{\text{elpd}}_{\text{WAIC}} = \text{lppd} - p_{\text{WAIC}} .
$$

On the deviance scale, $\text{WAIC} = -2\,\widehat{\text{elpd}}_{\text{WAIC}}$. The two scales differ only by the factor $-2$, but the direction flips: higher elpd is better, lower WAIC is better. The `loo` package reports elpd by default, so it is easy to misread the sign when moving between sources.

Unlike AIC or BIC, $p_{\text{WAIC}}$ is not a parameter count. It reflects how much the posterior actually adapts to each observation, so it can be fractional and can shrink under strong priors or partial pooling. WAIC is asymptotically equivalent to leave-one-out cross-validation (Watanabe, 2010), but that is an asymptotic statement. In finite samples with weak priors or influential observations the approximation can be poor, and WAIC offers no built-in diagnostic to tell you when (Vehtari et al., 2017).

## LOO-CV and PSIS

The leave-one-out predictive density for observation $i$ conditions on all other data $y_{-i}$:

$$
p(y_i\mid y_{-i}) = \int p(y_i\mid\theta)\,p(\theta\mid y_{-i})\,d\theta,
\qquad
\widehat{\text{elpd}}_{\text{LOO}} = \sum_{i=1}^{n}\log p(y_i\mid y_{-i}).
$$

Refitting the model $n$ times is expensive. Importance sampling avoids it by reusing the full-data posterior draws with weights proportional to

$$
r_i^{(s)} = \frac{p(\theta^{(s)}\mid y_{-i})}{p(\theta^{(s)}\mid y)} \propto \frac{1}{p(y_i\mid\theta^{(s)})},
$$

which gives

$$
p(y_i\mid y_{-i}) \approx \frac{\sum_{s} r_i^{(s)}\,p(y_i\mid\theta^{(s)})}{\sum_{s} r_i^{(s)}}
= \left(\frac{1}{S}\sum_{s}\frac{1}{p(y_i\mid\theta^{(s)})}\right)^{-1}\!\!\!\text{(raw IS)}.
$$

Raw importance weights can have infinite variance, because the weight is large precisely where observation $i$ is poorly predicted. Pareto-smoothed importance sampling (PSIS) fits a generalized Pareto distribution to the largest weights and replaces them with smoothed values, which stabilizes the estimate and yields a diagnostic: the estimated shape parameter $\hat{k}$ of that Pareto fit (Vehtari et al., 2017; Vehtari et al., 2024).

### Reading the Pareto $\hat{k}$ diagnostic

The interpretation of $\hat{k}$ has been revised, and many tutorials still carry the older version. Earlier guidance used fixed cutoffs of 0.5 and 0.7. Current `loo` documentation uses a sample-size-dependent threshold, $\min\!\big(1 - 1/\log_{10}(S),\,0.7\big)$ for $S$ posterior draws, which equals 0.7 when $S$ exceeds roughly 2200 (Vehtari et al., 2024). In the common 4-chain, 1000-draw setting ($S = 4000$), the practical threshold is therefore 0.7. Values above the threshold indicate that the importance sampling estimate for that observation is unreliable, which can mean a highly influential point, a misspecified model, or a data error.

When $\hat{k}$ is high, there are three escalating options: moment matching (`loo_moment_match()`), a mixture or other improved approximation, or exact refitting for the flagged observations (or K-fold CV). Do not simply ignore the warning; the estimate of the sum can be dominated by exactly those observations.

## Comparing models

Given two models $A$ and $B$, the quantity of interest is the pointwise difference $d_i = \log p_A(y_i\mid y_{-i}) - \log p_B(y_i\mid y_{-i})$. The total difference is $\sum_i d_i$, with standard error

$$
\operatorname{SE}_{\Delta} = \sqrt{n \cdot \widehat{\operatorname{Var}}(d_i)} .
$$

A common rule of thumb treats differences smaller than about 4 in elpd as small, and compares the difference to its standard error (Sivula et al., 2020). Two cautions apply. The normal approximation behind the SE is unreliable for small $n$ or when models are very similar, and the SE can understate uncertainty when many models are compared, since selecting the maximum among many noisy estimates is itself biased (Piironen & Vehtari, 2017). Think of an elpd difference of 2 with an SE of 4 as "no meaningful difference," not "model A is slightly better."

## Implementation

The Stan programs from Part 1 already compute `log_lik`. We extract it and pass it to `loo`, supplying relative effective sample sizes so that the PSIS estimate accounts for MCMC autocorrelation.

``` r
# Assumes fit_pois, fit_nb, y, stan_data from Part 1
ll_pois <- fit_pois$draws("log_lik", format = "matrix")
ll_nb   <- fit_nb$draws("log_lik",   format = "matrix")

r_eff_pois <- relative_eff(exp(ll_pois),
                           chain_id = rep(1:4, each = nrow(ll_pois) / 4))
r_eff_nb   <- relative_eff(exp(ll_nb),
                           chain_id = rep(1:4, each = nrow(ll_nb) / 4))

loo_pois <- loo(ll_pois, r_eff = r_eff_pois)
loo_nb   <- loo(ll_nb,   r_eff = r_eff_nb)
waic_pois <- waic(ll_pois)
waic_nb   <- waic(ll_nb)

print(loo_pois); print(loo_nb)
loo_compare(loo_pois, loo_nb)       # best model first; elpd_diff <= 0
loo_compare(waic_pois, waic_nb)
```

In `loo_compare()` output, the top row is the model with the highest elpd, and the other rows show `elpd_diff` (negative, relative to the best) and `se_diff`. For this dataset one would expect the negative binomial model to be preferred by a margin large relative to its SE, since the Poisson model misses the overdispersion, but the numbers come from your run and should be reported, not assumed.

Inspect the diagnostics:

``` r
print(loo_pois)                      # Pareto k table
plot(loo_pois, label_points = TRUE)  # which observations are influential?
pareto_k_table(loo_nb)

# Pointwise differences
d <- loo_nb$pointwise[, "elpd_loo"] - loo_pois$pointwise[, "elpd_loo"]
qplot(seq_along(d), d) + geom_hline(yintercept = 0, linetype = 2)
```

Plotting the pointwise differences is worth the extra line. It shows whether the gain comes from a few observations (often the high counts the Poisson model cannot accommodate) or is spread evenly.

### The same comparison with rstanarm

``` r
library(rstanarm)
dat <- data.frame(x = x, y = y)
rs_pois <- stan_glm(y ~ x, family = poisson(), data = dat, refresh = 0, seed = 1)
rs_nb   <- stan_glm(y ~ x, family = neg_binomial_2(), data = dat, refresh = 0, seed = 1)

loo_rs_pois <- loo(rs_pois)
loo_rs_nb   <- loo(rs_nb)
loo_compare(loo_rs_pois, loo_rs_nb)
```

For `rstanarm` and `brms`, `loo()` extracts the log likelihood automatically; no `generated quantities` block is needed.

## Why PSIS-LOO is usually preferred to WAIC

Vehtari et al. (2017) compared the two on several examples and found that PSIS-LOO is more robust in the finite-sample, weak-prior, influential-observation regime, and that it provides diagnostics ($\hat{k}$) that WAIC lacks. In well-behaved cases with many observations, the two give nearly identical answers. The practical recommendation is to default to PSIS-LOO and treat WAIC as a secondary check, mainly of historical and pedagogical interest. Reporting both is harmless; reporting WAIC alone is harder to defend.

## When LOO is the wrong question

LOO answers "how well would the model predict a new observation drawn like the others?" That is not always the prediction task.

In hierarchical models, a new observation from an *existing* group differs from a new observation from a *new* group. Leave-one-observation-out measures the former. If the scientific target is generalization to new groups (new subjects, new sites), you need leave-one-group-out cross-validation, which usually requires refitting. Likewise, for time series, leave-one-out leaks future information and leave-future-out schemes are more appropriate (Bürkner et al., 2020). Finally, for variable selection among many predictors, selecting on elpd can overfit the selection itself, and projection predictive approaches (e.g., the `projpred` package) are designed for that setting (Piironen & Vehtari, 2017).

## Stacking and predictive model averaging

If no model clearly dominates, picking one discards information. Bayesian model averaging (BMA) weights models by posterior model probability, which depends on marginal likelihoods (Part 3) and tends to collapse onto one model as $n$ grows. Stacking instead chooses weights $w$ on the simplex to maximize the LOO predictive score of the combined predictive distribution,

$$
\max_{w\in\Delta^{K-1}}\ \sum_{i=1}^{n}\log\sum_{k=1}^{K} w_k\,p(y_i\mid y_{-i},M_k),
$$

and is designed for the M-open setting where none of the models is true (Yao et al., 2018).

``` r
lpd_point <- cbind(loo_pois$pointwise[, "elpd_loo"],
                   loo_nb$pointwise[,   "elpd_loo"])
loo_model_weights(list(Poisson = loo_pois, NegBin = loo_nb), method = "stacking")
loo_model_weights(list(Poisson = loo_pois, NegBin = loo_nb), method = "pseudobma",
                  BB = TRUE)
```

With only one adequate model among two, the stacking weight should be close to 1 for it, and the exercise is mainly useful as a template. Stacking pays off when models capture different aspects of the data, such as a parametric and a flexible alternative that each win in different regions of the covariate space.

## Limitations to keep in mind

Elpd differences are estimates with noise, and the noise is hard to quantify when $n$ is small or the models are similar. Cross-validation estimates can be optimistic for the selected model when many models are compared. Both WAIC and LOO depend on the prior through the posterior, so they are not prior-free; the more accurate statement is that they are less sensitive to diffuse priors than marginal likelihoods, as Part 3 will show. And a model with higher elpd is not necessarily the more interpretable or scientifically useful one.

## References

Bürkner, P.-C., Gabry, J., & Vehtari, A. (2020). Approximate leave-future-out cross-validation for Bayesian time series models. *Journal of Statistical Computation and Simulation, 90*(14), 2499–2523.

Gneiting, T., & Raftery, A. E. (2007). Strictly proper scoring rules, prediction, and estimation. *Journal of the American Statistical Association, 102*(477), 359–378.

Piironen, J., & Vehtari, A. (2017). Comparison of Bayesian predictive methods for model selection. *Statistics and Computing, 27*(3), 711–735.

Sivula, T., Magnusson, M., Matamoros, A. A., & Vehtari, A. (2020). Uncertainty in Bayesian leave-one-out cross-validation based model comparison. *arXiv:2008.10296*.

Vehtari, A., Gelman, A., & Gabry, J. (2017). Practical Bayesian model evaluation using leave-one-out cross-validation and WAIC. *Statistics and Computing, 27*(5), 1413–1432.

Vehtari, A., Simpson, D., Gelman, A., Yao, Y., & Gabry, J. (2024). Pareto smoothed importance sampling. *Journal of Machine Learning Research, 25*(72), 1–58.

Watanabe, S. (2010). Asymptotic equivalence of Bayes cross validation and widely applicable information criterion in singular learning theory. *Journal of Machine Learning Research, 11*, 3571–3594.

Yao, Y., Vehtari, A., Simpson, D., & Gelman, A. (2018). Using stacking to average Bayesian predictive distributions. *Bayesian Analysis, 13*(3), 917–1007.
