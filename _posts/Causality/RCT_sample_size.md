## Causal Inference in Practice II: Sample Size, Power, and Effect Size for RCTs

In our previous post, we explored Randomized Controlled Trials (RCTs) and Regression Adjustment as foundational methods for causal inference, emphasizing their theoretical underpinnings and practical implementation. This follow-up delves into three critical aspects of RCT design and analysis: Sample Size Estimation, Power Calculations, and Effect Size Estimation. These topics are essential for ensuring RCTs are adequately designed to detect meaningful treatment effects with sufficient statistical precision. Each section includes theoretical foundations, mathematical formalism, and practical R code to guide researchers in implementing these concepts in real-world settings.

### 1. Sample Size Estimation for RCTs

#### Theoretical Foundations

Sample size estimation ensures an RCT has enough participants to estimate the Average Treatment Effect (ATE) with desired precision. The ATE is defined as:

$$
\text{ATE} = \mathbb{E}[Y(1) - Y(0)]
$$

where \$Y(1)\$ and \$Y(0)\$ are the potential outcomes under treatment and control, respectively. The sample size depends on the expected effect size, variance of the outcome, significance level (\$\alpha\$), and desired power (\$1 - \beta\$).

For a two-sample t-test comparing means, the sample size per group (\$n\$) can be approximated using:

$$
n = \frac{2 \sigma^2 (z_{1-\alpha/2} + z_{1-\beta})^2}{\delta^2}
$$

This formula assumes equal allocation, homoscedasticity, and normally distributed outcomes.

#### R Implementation

We now go beyond the simple case by incorporating uncertainty in outcome variance, unequal allocation, and a data-driven estimate of \$\sigma^2\$ using simulated pilot data.

```r
library(pwr)
library(tidyverse)

# Simulate pilot data with moderate variance and unequal group sizes
set.seed(123)
pilot_data <- tibble(
  treatment = sample(c(0, 1), 60, replace = TRUE, prob = c(0.6, 0.4)),
  outcome = 4 + 0.4 * treatment + rnorm(60, sd = 1.2)
)

# Estimate pooled standard deviation
pooled_sd <- pilot_data %>%
  group_by(treatment) %>%
  summarise(s = sd(outcome), n = n()) %>%
  summarise(
    pooled = sqrt(((n[1]-1)*s[1]^2 + (n[2]-1)*s[2]^2) / (sum(n) - 2))
  ) %>%
  pull(pooled)

# Parameters
alpha <- 0.05
power <- 0.8
effect_size <- 0.4 / pooled_sd  # Cohen's d

# Compute sample size per group assuming equal allocation
sample_size <- pwr.t.test(
  d = effect_size,
  sig.level = alpha,
  power = power,
  type = "two.sample",
  alternative = "two.sided"
)$n

cat("Required sample size per group (equal allocation):", ceiling(sample_size), "\n")
cat("Total sample size:", ceiling(2 * sample_size), "\n")
```

This realistic example incorporates empirically estimated variance and simulates a plausible imbalance in pilot data.

### 2. Power Calculations for RCTs

#### Theoretical Foundations

Statistical power is the probability of correctly rejecting the null hypothesis when the true ATE is non-zero. For the two-sample case:

$$
\text{Power} = 1 - \beta = \Phi\left( \frac{\delta \sqrt{n}}{\sqrt{2\sigma^2}} - z_{1-\alpha/2} \right)
$$

This equation illustrates how power increases with larger \$n\$, larger \$\delta\$, or smaller \$\sigma^2\$.

#### R Implementation

We now compute power across a range of effect sizes for a fixed sample size (e.g., n = 50 per group), visualizing the power curve.

```r
library(ggplot2)

n <- 50
sigma <- pooled_sd
alpha <- 0.05
effect_sizes <- seq(0.2, 0.8, by = 0.1)

powers <- sapply(effect_sizes, function(d) {
  pwr.t.test(n = n, d = d, sig.level = alpha, type = "two.sample")$power
})

power_df <- tibble(effect_size = effect_sizes, power = powers)

ggplot(power_df, aes(x = effect_size, y = power)) +
  geom_line(color = "blue", size = 1.2) +
  geom_hline(yintercept = 0.8, linetype = "dashed", color = "red") +
  labs(
    title = "Power Curve for Varying Effect Sizes",
    x = "Effect Size (Cohen's d)",
    y = "Power"
  ) +
  theme_minimal()
```

This diagnostic helps identify the minimum detectable effect (MDE) for a given sample size.

### 3. Effect Size Estimation for RCTs

#### Theoretical Foundations

The ATE is estimated as the difference in group means:

$$
\widehat{\text{ATE}} = \bar{Y}_1 - \bar{Y}_0
$$

Standardized effect sizes, such as Cohen’s \$d\$, contextualize treatment effects:

$$
d = \frac{\bar{Y}_1 - \bar{Y}_0}{s_{\text{pooled}}}
$$

#### R Implementation

We simulate an RCT, estimate the ATE and Cohen’s \$d\$, and calculate confidence intervals.

```r
# Simulate RCT data
set.seed(999)
n <- 120
rct_data <- tibble(
  treatment = rbinom(n, 1, 0.5),
  outcome = 5 + 0.6 * treatment + rnorm(n, sd = 1.1)
)

# ATE and CI
ate_result <- t.test(outcome ~ treatment, data = rct_data)

# Cohen's d with pooled SD
group_stats <- rct_data %>% group_by(treatment) %>% summarise(m = mean(outcome), s = sd(outcome), n = n())
pooled_sd <- sqrt(((group_stats$n[1] - 1)*group_stats$s[1]^2 + (group_stats$n[2] - 1)*group_stats$s[2]^2) / (n - 2))
cohens_d <- (group_stats$m[2] - group_stats$m[1]) / pooled_sd

cat("ATE:", round(ate_result$estimate[2] - ate_result$estimate[1], 3), "\n")
cat("95% CI for ATE:", round(ate_result$conf.int[1], 3), "to", round(ate_result$conf.int[2], 3), "\n")
cat("Cohen's d:", round(cohens_d, 3), "\n")
```

#### Bootstrapped Confidence Intervals for \$d\$

```r
library(boot)

# Define bootstrap function
d_boot_fn <- function(data, indices) {
  d <- data[indices, ]
  stats <- d %>% group_by(treatment) %>% summarise(m = mean(outcome), s = sd(outcome), n = n())
  pooled_sd <- sqrt(((stats$n[1] - 1)*stats$s[1]^2 + (stats$n[2] - 1)*stats$s[2]^2) / (sum(stats$n) - 2))
  (stats$m[2] - stats$m[1]) / pooled_sd
}

boot_obj <- boot(rct_data, statistic = d_boot_fn, R = 1000)
boot_ci <- boot.ci(boot_obj, type = "perc")
boot_ci
```

This yields percentile-based confidence intervals for Cohen's \$d\$, offering a nonparametric alternative under weaker assumptions.

### Conclusion

Sample size estimation, power calculations, and effect size estimation are integral to designing and interpreting RCTs. This post advanced beyond basic formulations by using realistic simulations, variance estimation from pilot data, and bootstrapped confidence intervals. These practices ensure more accurate planning and interpretation of RCTs in practice. In our next post, we will explore how to refine power analyses using covariate adjustment, and how to model treatment effect heterogeneity explicitly using interaction terms or hierarchical models.
