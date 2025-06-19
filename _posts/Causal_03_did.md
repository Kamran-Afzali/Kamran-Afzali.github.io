
## **Causal Inference in Practice III: Difference-in-Differences and Instrumental Variables**

In observational settings where treatment assignment is neither random nor fully ignorable, quasi-experimental methods offer a principled framework to recover causal effects under weaker assumptions than standard regression. This installment introduces two such techniques: **Difference-in-Differences (DiD)** and **Instrumental Variables (IV)**. We examine their identification conditions, derive formal estimators, and demonstrate implementations in R using simulated data. These methods are especially valuable when panel data or natural experiments are available.

### **Difference-in-Differences (DiD)**

#### **Motivation and Identification**

Difference-in-Differences (DiD) is a powerful tool when units are observed before and after treatment, and some units remain untreated. The key idea is to estimate the causal effect by comparing the **change** in outcomes over time between treated and untreated groups. Formally, let:

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

#### **Motivation and Identification**

When unmeasured confounding invalidates ignorability, Instrumental Variables (IV) estimation allows recovery of causal effects using an external source of variation in treatment—an **instrument**—that satisfies three key conditions:

1. **Relevance**: The instrument $Z$ is correlated with treatment $D$:

   $$
   \text{Cov}(Z, D) \neq 0
   $$
2. **Exclusion**: The instrument affects outcome $Y$ only through treatment $D$, not directly.
3. **Independence**: The instrument is as good as randomly assigned, i.e., independent of potential outcomes:

   $$
   Z \perp \{Y(1), Y(0)\}
   $$

Under these assumptions, IV identifies the **Local Average Treatment Effect (LATE)**—the average effect among **compliers**, those whose treatment status is affected by the instrument.

#### **Formal Estimator**

The **Wald estimator** for binary $Z$ and $D$ is:

$$
\widehat{\text{LATE}} = \frac{\mathbb{E}[Y \mid Z = 1] - \mathbb{E}[Y \mid Z = 0]}{\mathbb{E}[D \mid Z = 1] - \mathbb{E}[D \mid Z = 0]}
$$

More generally, IV can be estimated by **two-stage least squares (2SLS)**:

1. First stage: regress treatment on instrument

   $$
   D_i = \pi_0 + \pi_1 Z_i + \pi_2 X_i + \nu_i
   $$
2. Second stage: regress outcome on predicted treatment

   $$
   Y_i = \alpha_0 + \alpha_1 \hat{D}_i + \alpha_2 X_i + \varepsilon_i
   $$

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

