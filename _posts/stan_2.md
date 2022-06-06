---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---
Logistic regression is a popular machine learning model. One application of it in an engineering context is quantifying the effectiveness of inspection technologies at detecting damage. This post describes the additional information provided by a Bayesian application of logistic regression (and how it can be implemented using the Stan probabilistic programming language). Finally, I’ve also included some recommendations for making sense of priors.

Introductions
So there are a couple of key topics discussed here: Logistic Regression, and Bayesian Statistics. Before jumping straight into the example application, I’ve provided some very brief introductions below.

Bayesian Inference

At a very high level, Bayesian models quantify (aleatory and epistemic) uncertainty, so that our predictions and decisions take into account the ways in which our knowledge is limited or imperfect. We specify a statistical model, and identify probabilistic estimates for the parameters using a family of sampling algorithms known as Markov Chain Monte Carlo (MCMC). My preferred software for writing a fitting Bayesian models is Stan. If you are not yet familiar with Bayesian statistics, then I imagine you won’t be fully satisfied with that 3 sentence summary, so I will put together a separate post on the merits and challenges of applied Bayesian inference, which will include much more detail.

Logistic Regression

Logistic regression is used to estimate the probability of a binary outcome, such as Pass or Fail (though it can be extended for > 2 outcomes). This is achieved by transforming a standard regression using the logit function, shown below. The term in the brackets may be familiar to gamblers as it is how odds are calculated from probabilities. You may see logit and log-odds used exchangeably for this reason.


Since the logit function transformed data from a probability scale, the inverse logit function transforms data to a probability scale. Therefore, as shown in the below plot, it’s values range from 0 to 1, and this feature is very useful when we are interested the probability of Pass/Fail type outcomes.

Before moving on, some terminology that you may find when reading about logistic regression elsewhere:

When a linear regression is combined with a re-scaling function such as this, it is known as a Generalised Linear Model (GLM).
The re-scaling (in this case, the logit) function is known as a link function in this context.
Logistic regression is a Bernoulli-Logit GLM.




For binary outcomes, either of the closely related logistic or probit regression models may be used. These generalized linear models vary only in the l
A logistic regression model with one predictor and an intercept is coded as follows.

```
data {
  int<lower=0> N;
  vector[N] x;
  int<lower=0,upper=1> y[N];
}
parameters {
  real alpha;
  real beta;
}
model {
  y ~ bernoulli_logit(alpha + beta * x);
}
```


The noise parameter is built into the Bernoulli formulation here rather than specified directly.

Logistic regression is a kind of generalized linear model with binary outcomes and the log odds (logit) link function, defined by
