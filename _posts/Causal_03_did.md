
## **Causal Inference in Practice III: Difference-in-Differences and Instrumental Variables**

In observational settings where treatment assignment is neither random nor fully ignorable, quasi-experimental methods offer a principled framework to recover causal effects under weaker assumptions than standard regression. This installment introduces two such techniques: **Difference-in-Differences (DiD)** and **Instrumental Variables (IV)**. We examine their identification conditions, derive formal estimators, and demonstrate implementations in R using simulated data. These methods are especially valuable when panel data or natural experiments are available.

### **Difference-in-Differences (DiD)**


Difference-in-Differences (DiD) is a tool when units are observed before and after treatment, and some units remain untreated. The key idea is to estimate the causal effect by comparing the **change** in outcomes over time between treated and untreated groups. Formally, let:

* $Y_{it}$: Outcome for unit $i$ at time $t \in \{0, 1\}$
* $D_i \in \{0,1\}$: Indicator for treated group
* $Y_{i1}(1), Y_{i1}(0)$: Potential outcomes at time 1 under treatment and control

The **DiD estimator** is:

$$
\widehat{\text{DiD}} = \left( \bar{Y}_{1, \text{treated}} - \bar{Y}_{0, \text{treated}} \right) - \left( \bar{Y}_{1, \text{control}} - \bar{Y}_{0, \text{control}} \right)
$$

This relies on the **parallel trends assumption**: in the absence of treatment, treated and control groups would have experienced the same average change in outcomes. Formally,

$$
\mathbb{E}[Y_{1}(0) - Y_{0}(0) \mid D = 1] = \mathbb{E}[Y_{1}(0) - Y_{0}(0) \mid D = 0]
$$

Following ractical considerations should be highlighted:  DiD requires panel or repeated cross-sectional data with observations for both groups before and after the treatment; Covariates including control variables (e.g., via regression) can improve precision and account for potential confounders, as long as they are unaffected by the treatment.



#### **Simulation and Implementation in R**

We simulate a setting with 1000 units and two time points. Treatment is assigned post-$t = 0$ only to some units.

```r
set.seed(123)

# Parameters
n_units <- 100  # 50 treated, 50 control
time_periods <- 2  # Pre (t=0) and Post (t=1)
treatment_effect <- 5  # True treatment effect

# Create data
data <- data.frame(
  unit = rep(1:n_units, each = time_periods),
  time = rep(0:1, times = n_units),
  treated = rep(rep(c(0, 1), each = time_periods), times = n_units/2)
)

# Generate outcome variable Y
# Y = baseline + group_effect + time_effect + treatment_effect + noise
data$Y <- 10 +                      # Baseline
  2 * data$treated +                # Group effect (treated units slightly higher)
  3 * data$time +                   # Time trend (both groups increase over time)
  treatment_effect * data$treated * data$time +  # Treatment effect (only for treated in t=1)
  rnorm(n = nrow(data), mean = 0, sd = 1)  # Random noise

# Preview data
head(data)


library(ggplot2)

# Calculate group means by time
means <- aggregate(Y ~ time + treated, data = data, mean)

# Plot
ggplot(means, aes(x = time, y = Y, color = factor(treated), group = treated)) +
  geom_line() +
  geom_point() +
  labs(title = "Parallel Trends Check", x = "Time", y = "Outcome (Y)",
       color = "Group") +
  scale_color_manual(values = c("blue", "red"), labels = c("Control", "Treated")) +
  theme_minimal()

# Run DiD regression
did_model <- lm(Y ~ treated + time + treated:time, data = data)

# Summary of results
summary(did_model)


# Calculate means for each group and time
means_table <- aggregate(Y ~ treated + time, data = data, mean)

# Extract means
y0_control <- means_table$Y[means_table$treated == 0 & means_table$time == 0]
y1_control <- means_table$Y[means_table$treated == 0 & means_table$time == 1]
y0_treated <- means_table$Y[means_table$treated == 1 & means_table$time == 0]
y1_treated <- means_table$Y[means_table$treated == 1 & means_table$time == 1]

# Compute DiD
did_estimate <- (y1_treated - y0_treated) - (y1_control - y0_control)
cat("DiD Estimate:", did_estimate, "\n")
```

### **Instrumental Variables (IV)**

### Instrumental Variables (IV) Estimation

#### Motivation and Identification

Instrumental Variables (IV) methods offer a strategy for causal inference in the presence of **unmeasured confounding**, a situation where the standard assumption of conditional ignorability fails. That is, when potential outcomes $Y(1), Y(0)$ are not conditionally independent of treatment $D$ given observed covariates $X$, alternative identification strategies are required. IV methods achieve this by exploiting exogenous variation in treatment induced by an external variable, known as an **instrument** $Z$, which must satisfy a set of well-defined assumptions.

The validity of an instrumental variable relies on the following three core conditions:

1. **Relevance**: The instrument must have a non-zero correlation with the treatment variable. Formally,

   $$
   \operatorname{Cov}(Z, D) \neq 0,
   $$

   which ensures that the instrument induces variation in the treatment.

2. **Exclusion Restriction**: The instrument must affect the outcome $Y$ only through its effect on the treatment $D$. That is, conditional on the treatment and covariates, the instrument has no direct effect on the outcome:

   $$
   Y = f(D, X, \varepsilon), \quad \text{with } Z \notin f.
   $$

3. **Independence (or Exogeneity)**: The instrument must be independent of the unobserved determinants of the outcome, i.e., the instrument is as good as randomly assigned:

   $$
   Z \perp \{Y(1), Y(0)\} \mid X.
   $$

When these conditions are met, the IV approach identifies the **Local Average Treatment Effect (LATE)**—the average treatment effect for the subpopulation of **compliers**, individuals whose treatment status is influenced by the instrument. It is important to emphasize that LATE may differ from the Average Treatment Effect (ATE), as it pertains only to a specific subpopulation determined by the instrument’s influence.

#### Theoretical Estimation Framework

In the case of binary instruments and binary treatments, the IV estimand can be expressed via the **Wald estimator**, given by:

$$
\widehat{\text{LATE}} = \frac{\mathbb{E}[Y \mid Z = 1] - \mathbb{E}[Y \mid Z = 0]}{\mathbb{E}[D \mid Z = 1] - \mathbb{E}[D \mid Z = 0]}.
$$

This ratio captures the causal effect among compliers by scaling the change in outcomes induced by the instrument by the change in treatment uptake.

In more general settings, particularly with continuous instruments or treatments and with covariates $X$, the causal effect is commonly estimated via **two-stage least squares (2SLS)**. The procedure consists of two sequential regressions:

* **First stage**: Estimate the predicted treatment value $\hat{D}_i$ using the instrument:

  $$
  D_i = \pi_0 + \pi_1 Z_i + \pi_2^\top X_i + \nu_i.
  $$

* **Second stage**: Regress the outcome $Y_i$ on the predicted treatment:

  $$
  Y_i = \alpha_0 + \alpha_1 \hat{D}_i + \alpha_2^\top X_i + \varepsilon_i.
  $$

The coefficient $\alpha_1$ from the second stage provides a consistent estimate of the causal effect under the IV assumptions. Importantly, this estimator remains consistent even in the presence of omitted variable bias, provided the instrument is valid.

#### Comparison to Other Causal Methods

Instrumental Variables (IV) estimation differs substantially from other causal inference strategies, such as **propensity score methods** and **Difference-in-Differences (DiD)**, both in terms of identifying assumptions and target estimands.

Propensity score matching and related methods (e.g., inverse probability weighting, doubly robust estimators) rely on the **conditional ignorability assumption**, i.e., $Y(1), Y(0) \perp D \mid X$, which requires that all confounders influencing both treatment and outcome are observed and properly adjusted for. These approaches target the **Average Treatment Effect (ATE)** or the **Average Treatment effect on the Treated (ATT)** across the full population or a matched subpopulation. In contrast, IV methods do not require all confounders to be measured but instead depend on the presence of a valid instrument and identify LATE, a more restricted estimand.

Difference-in-Differences (DiD) methods exploit temporal variation in treatment exposure across groups and require the **parallel trends assumption**: that, in the absence of treatment, the difference in outcomes between treated and control groups would have remained constant over time. DiD can accommodate some unobserved confounding, provided it is time-invariant. However, DiD assumes the absence of differential trends, an assumption that cannot be tested directly. Unlike IV, DiD does not rely on an instrument but on quasi-experimental variation in timing or assignment. IV estimation offers a powerful alternative when unmeasured confounding invalidates conditional ignorability, but it comes with its own limitations, such as the difficulty of finding valid instruments and the interpretation of effects limited to compliers. While DiD and propensity score methods may estimate broader effects under stronger assumptions, IV provides robustness to hidden bias at the cost of narrower causal generalizability.


#### **Simulation and R Implementation**

We now simulate a valid instrument that affects treatment but not the outcome directly:

```r
set.seed(456)
n <- 2000
z <- rbinom(n, 1, 0.5)  # Instrument
x <- rnorm(n)
d <- rbinom(n, 1, plogis(0.4 * z + 0.5 * x))  # Treatment influenced by Z
y <- 1 + 2 * d + 1.5 * x + rnorm(n)  # Outcome depends on D and X

iv_data <- data.frame(y, d, z, x)

# First stage: check relevance
summary(lm(d ~ z + x, data = iv_data))

# 2SLS using AER package
library(AER)
iv_mod <- ivreg(y ~ d + x | z + x, data = iv_data)
summary(iv_mod)
```

The coefficient on `d` is the IV estimate of the treatment effect. Note that `z + x` in the second part of the formula specifies instruments (`z`) and exogenous controls (`x`).

#### **Diagnostics**

Key diagnostics include:

* **First-stage F-statistic** (should exceed 10): tests instrument strength.
* **Overidentification tests**: e.g., Hansen J-test, for models with multiple instruments.
* **Placebo or falsification checks**: assess exclusion by testing instrument association with outcomes that should not be affected.


### **Summary Table**

| Method                    | Key Assumption                                                   | Target Estimand                | R Implementation       | Common Use Cases                          |
| ------------------------- | ---------------------------------------------------------------- | ------------------------------ | ---------------------- | ----------------------------------------- |
| Difference-in-Differences | Parallel trends (untreated units represent counterfactual trend) | ATE (under strong assumptions) | `lm(y ~ treat*time)`   | Policy evaluation, natural experiments    |
| Instrumental Variables    | Exclusion restriction, relevance, independence                   | LATE (compliers only)          | `ivreg()` from **AER** | Endogenous treatment, natural experiments |

---

### **Conclusion**

DiD leverages temporal structure and repeated observations, assuming that, in the absence of treatment, both groups would follow the same trajectory. Its simplicity and intuitive interpretation make it a workhorse in policy evaluation. Instrumental Variables, in contrast, leverage variation from external sources—policy rules, natural experiments, or genetic variants (in Mendelian randomization)—to identify causal effects when ignorability fails. Both methods complement regression and propensity score approaches, extending the causal inference toolkit to more complex observational settings. This post expanded the causal inference framework to cover quasi-experimental methods—Difference-in-Differences and Instrumental Variables. These tools relax the strict ignorability assumptions of regression and propensity-based estimators by incorporating external or structural information. Each requires careful consideration of identification assumptions and diagnostics, particularly the plausibility of parallel trends (for DiD) and the exclusion restriction (for IV). In the next installment, we will consider Regression Discontinuity Designs and Synthetic Control methods, which further extend causal analysis in observational research.


### **References**

* Angrist, J. D., & Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
* Abadie, A. (2005). Semiparametric difference-in-differences estimators. *Review of Economic Studies*, 72(1), 1–19.
* Imbens, G. W., & Lemieux, T. (2008). Regression discontinuity designs: A guide to practice. *Journal of Econometrics*, 142(2), 615–635.
* Hernán, M. A., & Robins, J. M. (2020). *Causal Inference: What If*. Chapman & Hall/CRC.
* Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data*. MIT Press.

