
## **Causal Inference in Practice III: Difference-in-Differences and Instrumental Variables**

In observational settings where treatment assignment is neither random nor fully ignorable, quasi-experimental methods offer a principled framework to recover causal effects under weaker assumptions than standard regression. This installment introduces two such techniques: **Difference-in-Differences (DiD)** and **Instrumental Variables (IV)**. We examine their identification conditions, derive formal estimators, and demonstrate implementations in R using simulated data. These methods are especially valuable when panel data or natural experiments are available.

---

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

#### **Simulation and Implementation in R**

We simulate a setting with 1000 units and two time points. Treatment is assigned post-$t = 0$ only to some units.

```r
set.seed(123)
n <- 1000
id <- 1:n
time <- rep(c(0, 1), each = n)
unit <- rep(id, times = 2)

# Covariates and group assignment
x <- rnorm(n)
treat <- ifelse(x > 0.2, 1, 0)
treat_rep <- rep(treat, times = 2)

# Outcome model
baseline <- 2 + 1.5 * x
trend <- 1.2
treatment_effect <- 2

# Generate potential outcomes
y0 <- baseline + trend * (time == 1)
y1 <- y0 + treatment_effect * (treat_rep == 1 & time == 1)

# Observed outcome
y <- ifelse(treat_rep == 1 & time == 1, y1, y0)

data <- data.frame(id = unit, time = time, treat = treat_rep, y = y)

library(dplyr)

# Calculate DiD manually
did_data <- data %>%
  group_by(treat, time) %>%
  summarise(mean_y = mean(y), .groups = "drop") %>%
  pivot_wider(names_from = time, values_from = mean_y, names_prefix = "time_")

did_estimate <- (did_data$time_1[2] - did_data$time_0[2]) - 
                (did_data$time_1[1] - did_data$time_0[1])
did_estimate
```

We can also estimate DiD via linear regression with interaction:

```r
model <- lm(y ~ treat * time, data = data)
summary(model)
```

The coefficient on `treat:time` estimates the DiD effect. Its consistency depends crucially on **parallel trends**, which should be diagnosed using pre-treatment periods if available (e.g., event study plots).

---

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

---

### **Integrative Discussion**

Difference-in-Differences and Instrumental Variables represent distinct responses to unobserved confounding. DiD leverages temporal structure and repeated observations, assuming that, in the absence of treatment, both groups would follow the same trajectory. Its simplicity and intuitive interpretation make it a workhorse in policy evaluation.

Instrumental Variables, in contrast, leverage variation from external sources—policy rules, natural experiments, or genetic variants (in Mendelian randomization)—to identify causal effects when ignorability fails. However, IV identifies LATE, not ATE, and the exclusion restriction is often unverifiable and fragile.

Both methods complement regression and propensity score approaches, extending the causal inference toolkit to more complex observational settings.

---

### **Summary Table**

| Method                    | Key Assumption                                                   | Target Estimand                | R Implementation       | Common Use Cases                          |
| ------------------------- | ---------------------------------------------------------------- | ------------------------------ | ---------------------- | ----------------------------------------- |
| Difference-in-Differences | Parallel trends (untreated units represent counterfactual trend) | ATE (under strong assumptions) | `lm(y ~ treat*time)`   | Policy evaluation, natural experiments    |
| Instrumental Variables    | Exclusion restriction, relevance, independence                   | LATE (compliers only)          | `ivreg()` from **AER** | Endogenous treatment, natural experiments |

---

### **Conclusion**

This post expanded the causal inference framework to cover quasi-experimental methods—Difference-in-Differences and Instrumental Variables. These tools relax the strict ignorability assumptions of regression and propensity-based estimators by incorporating external or structural information. Each requires careful consideration of identification assumptions and diagnostics, particularly the plausibility of parallel trends (for DiD) and the exclusion restriction (for IV). In the next installment, we will consider Regression Discontinuity Designs and Synthetic Control methods, which further extend causal analysis in observational research.

---

### **References**

* Angrist, J. D., & Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
* Abadie, A. (2005). Semiparametric difference-in-differences estimators. *Review of Economic Studies*, 72(1), 1–19.
* Imbens, G. W., & Lemieux, T. (2008). Regression discontinuity designs: A guide to practice. *Journal of Econometrics*, 142(2), 615–635.
* Hernán, M. A., & Robins, J. M. (2020). *Causal Inference: What If*. Chapman & Hall/CRC.
* Wooldridge, J. M. (2010). *Econometric Analysis of Cross Section and Panel Data*. MIT Press.

