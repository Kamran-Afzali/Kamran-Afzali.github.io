---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

https://agabrioblog.onrender.com/tutorial/simple-linear-regression-stan/simple-linear-regression-stan/


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.6     ✓ dplyr   1.0.7
## ✓ tidyr   1.1.4     ✓ stringr 1.4.0
## ✓ readr   1.4.0     ✓ forcats 0.5.0
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(kableExtra)
```

```
## 
## Attaching package: 'kableExtra'
```

```
## The following object is masked from 'package:dplyr':
## 
##     group_rows
```

```r
set.seed(123)
n <- 1000
a <- 40  #intercept
b <- c(-2, 3, 4, 1 , 0.25) #slopes
sigma2 <- 25  #residual variance (sd=5)
x <- matrix(rnorm(5000),1000,5)
eps <- rnorm(n, mean = 0, sd = sqrt(sigma2))  #residuals
y <- a +x%*%b+ eps  #response variable
data <- data.frame(y, x)  #dataset
head(data)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> y </th>
   <th style="text-align:right;"> X1 </th>
   <th style="text-align:right;"> X2 </th>
   <th style="text-align:right;"> X3 </th>
   <th style="text-align:right;"> X4 </th>
   <th style="text-align:right;"> X5 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 33.51510 </td>
   <td style="text-align:right;"> -0.5604756 </td>
   <td style="text-align:right;"> -0.9957987 </td>
   <td style="text-align:right;"> -0.5116037 </td>
   <td style="text-align:right;"> -0.1503075 </td>
   <td style="text-align:right;"> 0.1965498 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 43.76098 </td>
   <td style="text-align:right;"> -0.2301775 </td>
   <td style="text-align:right;"> -1.0399550 </td>
   <td style="text-align:right;"> 0.2369379 </td>
   <td style="text-align:right;"> -0.3277571 </td>
   <td style="text-align:right;"> 0.6501132 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 27.64712 </td>
   <td style="text-align:right;"> 1.5587083 </td>
   <td style="text-align:right;"> -0.0179802 </td>
   <td style="text-align:right;"> -0.5415892 </td>
   <td style="text-align:right;"> -1.4481653 </td>
   <td style="text-align:right;"> 0.6710042 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 50.72614 </td>
   <td style="text-align:right;"> 0.0705084 </td>
   <td style="text-align:right;"> -0.1321751 </td>
   <td style="text-align:right;"> 1.2192276 </td>
   <td style="text-align:right;"> -0.6972846 </td>
   <td style="text-align:right;"> -1.2841578 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 39.46286 </td>
   <td style="text-align:right;"> 0.1292877 </td>
   <td style="text-align:right;"> -2.5493428 </td>
   <td style="text-align:right;"> 0.1741359 </td>
   <td style="text-align:right;"> 2.5984902 </td>
   <td style="text-align:right;"> -2.0261096 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 39.42009 </td>
   <td style="text-align:right;"> 1.7150650 </td>
   <td style="text-align:right;"> 1.0405735 </td>
   <td style="text-align:right;"> -0.6152683 </td>
   <td style="text-align:right;"> -0.0374150 </td>
   <td style="text-align:right;"> 2.2053261 </td>
  </tr>
</tbody>
</table>




```r
   model_stan = "
   data {
     // declare the input data / parameters
   }
   transformed data {
     // optional - for transforming/scaling input data
   }
   parameters {
     // define model parameters
   }
   transformed parameters {
     // optional - for deriving additional non-model parameters
     //            note however, as they are part of the sampling chain
     //            transformed parameters slow sampling down.
   }
   model {
     // specifying priors and likelihood as well as the linear predictor
   }
   generated quantities {
     // optional - derivatives (posteriors) of the samples
   }
   "
   cat(model_stan)
```

```
## 
##    data {
##      // declare the input data / parameters
##    }
##    transformed data {
##      // optional - for transforming/scaling input data
##    }
##    parameters {
##      // define model parameters
##    }
##    transformed parameters {
##      // optional - for deriving additional non-model parameters
##      //            note however, as they are part of the sampling chain
##      //            transformed parameters slow sampling down.
##    }
##    model {
##      // specifying priors and likelihood as well as the linear predictor
##    }
##    generated quantities {
##      // optional - derivatives (posteriors) of the samples
##    }
## 
```




```r
stan_mod = "data {
  int<lower=0> N;   // number of observations
  int<lower=0> K;   // number of predictors
  matrix[N, K] X;   // predictor matrix
  vector[N] y;      // outcome vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for predictors
  real<lower=0> sigma;  // error scale
}
model {
  y ~ normal(alpha + X * beta, sigma);  // target density
}"

writeLines(stan_mod, con = "stan_mod.stan")

cat(stan_mod)
```

```
## data {
##   int<lower=0> N;   // number of observations
##   int<lower=0> K;   // number of predictors
##   matrix[N, K] X;   // predictor matrix
##   vector[N] y;      // outcome vector
## }
## parameters {
##   real alpha;           // intercept
##   vector[K] beta;       // coefficients for predictors
##   real<lower=0> sigma;  // error scale
## }
## model {
##   y ~ normal(alpha + X * beta, sigma);  // target density
## }
```




```r
library(tidyverse)
predictors <- data %>%
  select(-y)

stan_data <- list(
  N = 1000,
  K = 5,
  X = predictors,
  y = data$y
)
```




```r
fit_rstan <- rstan::stan(
  file = "stan_mod.stan",
  data = stan_data
)
```

```
## Trying to compile a simple C file
```

```
## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
## clang -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:88:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
## namespace Eigen {
## ^
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
## namespace Eigen {
##                ^
##                ;
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
## #include <complex>
##          ^~~~~~~~~
## 3 errors generated.
## make: *** [foo.o] Error 1
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 0.000101 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 1.01 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.267 seconds (Warm-up)
## Chain 1:                0.202 seconds (Sampling)
## Chain 1:                0.469 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 4.2e-05 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.42 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.271 seconds (Warm-up)
## Chain 2:                0.227 seconds (Sampling)
## Chain 2:                0.498 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 4.3e-05 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.43 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.242 seconds (Warm-up)
## Chain 3:                0.212 seconds (Sampling)
## Chain 3:                0.454 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 4.3e-05 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.43 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.267 seconds (Warm-up)
## Chain 4:                0.208 seconds (Sampling)
## Chain 4:                0.475 seconds (Total)
## Chain 4:
```

```r
fit_rstan
```

```
## Inference for Stan model: anon_model.
## 4 chains, each with iter=2000; warmup=1000; thin=1; 
## post-warmup draws per chain=1000, total post-warmup draws=4000.
## 
##             mean se_mean   sd     2.5%      25%      50%      75%    97.5%
## alpha      40.19    0.00 0.15    39.89    40.08    40.19    40.29    40.48
## beta[1]    -2.07    0.00 0.16    -2.39    -2.18    -2.07    -1.97    -1.76
## beta[2]     2.73    0.00 0.16     2.42     2.62     2.73     2.84     3.04
## beta[3]     3.83    0.00 0.16     3.51     3.72     3.83     3.93     4.13
## beta[4]     1.23    0.00 0.16     0.92     1.11     1.23     1.34     1.54
## beta[5]     0.34    0.00 0.16     0.04     0.23     0.34     0.45     0.65
## sigma       4.96    0.00 0.11     4.74     4.88     4.95     5.03     5.17
## lp__    -2098.32    0.04 1.88 -2102.75 -2099.39 -2097.99 -2096.92 -2095.67
##         n_eff Rhat
## alpha    5280    1
## beta[1]  5552    1
## beta[2]  6251    1
## beta[3]  5988    1
## beta[4]  6172    1
## beta[5]  6343    1
## sigma    5687    1
## lp__     1916    1
## 
## Samples were drawn using NUTS(diag_e) at Wed May  4 13:23:35 2022.
## For each parameter, n_eff is a crude measure of effective sample size,
## and Rhat is the potential scale reduction factor on split chains (at 
## convergence, Rhat=1).
```



```r
library(bayesplot)
```

```
## This is bayesplot version 1.9.0
```

```
## - Online documentation and vignettes at mc-stan.org/bayesplot
```

```
## - bayesplot theme set to bayesplot::theme_default()
```

```
##    * Does _not_ affect other ggplot2 plots
```

```
##    * See ?bayesplot_theme_set for details on theme setting
```

```r
fit_rstan %>%
  mcmc_trace()
```

![](stan_files/figure-html/bayesplots-1.png)<!-- -->




```r
fit_rstan %>%
  rhat() %>%
  mcmc_rhat() +
  yaxis_text()
```

![](stan_files/figure-html/rhat-1.png)<!-- -->

