
Bayesian modeling using Stan offers a powerful framework for handling ordered categorical and multinomial outcomes in a variety of contexts. When dealing with ordered categorical outcomes, such as survey responses or Likert scale ratings, Bayesian methods can be applied to fit ordinal logistic regression models. In this approach, the cumulative probabilities of each ordinal category are modeled relative to the predictor variables. Stan allows for the specification of complex hierarchical models, enabling researchers to capture the nuances of the relationships between predictors and the ordered outcome. By incorporating prior information about these relationships, Bayesian ordinal logistic regression provides a flexible and robust approach for modeling ordered categorical outcomes.

Similarly, Bayesian modeling with Stan can also be applied to multinomial outcomes, where the outcome variable has more than two categories. Multinomial logistic regression models can be fitted using Stan, wherein the probabilities of each category relative to a reference category are modeled as a function of the predictor variables. This approach is particularly useful in settings where the outcome variable represents multiple mutually exclusive categories, such as different types of diseases or customer preferences. With Stan, researchers can specify complex multinomial logistic regression models that account for uncertainty in the parameter estimates and incorporate prior beliefs about the relationships between predictors and the outcome categories.

Bayesian methods allow for the incorporation of uncertainty quantification and model comparison techniques. Uncertainty quantification is essential in Bayesian modeling as it provides estimates of uncertainty in model parameters, allowing researchers to make more informed decisions and interpretations. Stan facilitates the calculation of credible intervals for model parameters, providing insights into the range of plausible values. Additionally, model comparison techniques such as Bayesian Information Criterion (BIC) or leave-one-out cross-validation (LOO-CV) can be used to compare the fit of different models and aid in model selection. This enables researchers to identify the most appropriate model for their data, considering both goodness-of-fit and model complexity.

Here we present an example of Stan code defines a multinomial logistic regression model, where the predictor matrix `x` is used to predict the categorical outcome variable `y`. The model estimates a matrix of coefficients `beta`, and the likelihood function relates the predictor variables to the outcome categories.

```stan
data {
  int K;
  int N;
  int D;
  int y[N];
  matrix[N, D] x;
}
parameters {
  matrix[D, K] beta;
}
model {
  matrix[N, K] x_beta = x * beta;

  to_vector(beta) ~ normal(0, 5);

  for (n in 1:N)
    y[n] ~ categorical_logit(x_beta[n]');
}
```

### Data Block:
```stan
data {
  int K;            // Number of categories or classes
  int N;            // Number of observations
  int D;            // Number of predictors or features
  int y[N];         // Outcome variable, an array of length N containing the category indices
  matrix[N, D] x;   // Predictor matrix, containing the predictor values for each observation
}
```
In the data block, we declare the variables used in the model and specify their dimensions and types. Here, `K` represents the number of categories or classes, `N` is the number of observations, `D` is the number of predictors, `y` is an array of length `N` containing the category indices (each entry corresponds to the category of the respective observation), and `x` is a matrix of size `N`-by-`D` containing the predictor values for each observation.

### Parameters Block:
```stan
parameters {
  matrix[D, K] beta;   // Coefficient matrix, where each column represents the coefficients for one category
}
```
In the parameters block, we declare the parameters to be estimated in the model. Here, `beta` is a matrix of size `D`-by-`K`, where each column represents the coefficients for one category. The elements of this matrix will be estimated during the modeling process.

### Model Block:
```stan
model {
  matrix[N, K] x_beta = x * beta;   // Matrix multiplication to obtain linear predictors

  to_vector(beta) ~ normal(0, 5);    // Prior distribution for the coefficients

  for (n in 1:N)
    y[n] ~ categorical_logit(x_beta[n]');   // Likelihood function for the categorical outcome
}
```
In the model block, we define the statistical model. 

1. **Matrix Multiplication**: We perform matrix multiplication between the predictor matrix `x` and the coefficient matrix `beta` to obtain the linear predictors for each category, stored in `x_beta`.

2. **Prior Distribution**: We specify a prior distribution for the coefficients `beta`. Here, we assume a normal prior distribution with mean 0 and standard deviation 5 for all elements of `beta`.

3. **Likelihood Function**: We define the likelihood function for the categorical outcome variable `y`. In this case, we use the `categorical_logit` distribution, which models the outcome as a categorical variable with probabilities proportional to the exponential of the linear predictors `x_beta`. The loop iterates over each observation `n` and assigns the corresponding likelihood of observing the category specified by `y[n]`.


```stan
stan_program <- "
data {
    int n;
    int k;
    int response[n];
}
parameters {
    ordered[k] cutpoints;
}
model {
    for (i in 1:n) {
        response[i] ~ ordered_logistic(0, cutpoints);
    }
    cutpoints ~ normal(0, 15);
}
"
```


The provided Stan program defines an ordered logistic regression model. Let's break down the code:

### Data Block:
```stan
data {
    int n;                 // Number of observations
    int k;                 // Number of categories (levels) for the ordered outcome variable
    int response[n];       // Array of length n containing the ordered outcome variable
}
```
In the data block, we declare the variables used in the model. `n` represents the number of observations, `k` represents the number of categories for the ordered outcome variable, and `response` is an array of length `n` containing the ordered outcome variable.

### Parameters Block:
```stan
parameters {
    ordered[k] cutpoints;   // Ordered cutpoints separating the categories
}
```
In the parameters block, we declare the parameter to be estimated in the model. `cutpoints` is an ordered array of length `k`, representing the cutpoints that separate the categories of the ordered outcome variable.

### Model Block:
```stan
model {
    for (i in 1:n) {
        response[i] ~ ordered_logistic(0, cutpoints);   // Likelihood function
    }
    cutpoints ~ normal(0, 15);   // Prior distribution for the cutpoints
}
```
In the model block, we define the statistical model.

1. **Likelihood Function**: We specify the likelihood function for the ordered outcome variable `response`. The `ordered_logistic` distribution models the outcome as an ordered categorical variable with ordered cutpoints specified by `cutpoints`. For each observation `i`, we model the probability of observing the category specified by `response[i]` given the cutpoints.

2. **Prior Distribution**: We specify a prior distribution for the cutpoints. Here, we assume a normal prior distribution with mean 0 and standard deviation 15 for the cutpoints.

Overall, this Stan program defines an ordered logistic regression model where the goal is to estimate the cutpoints that separate the ordered categories of the outcome variable based on the predictor variables.




The Dirichlet distribution is a family of continuous multivariate probability distributions, parameterized by a vector α of positive real numbers. It is commonly used as a prior distribution for categorical or multinomial variables in Bayesian statistics. The Dirichlet distribution can characterize the random variability of a multinomial distribution and is particularly useful for modeling actual measurements due to its ability to generate a wide variety of shapes based on the parameters α. In the context of dice manufacturing, the Dirichlet distribution can be used to model the random variability in the probabilities of different outcomes, allowing for the creation of fair or loaded dice based on specific parameter values. Dirichlet distribution offers a versatile tool for modeling categorical data in various applications. One key use case involves multinomial models, where Stan provides a categorical family specifically designed to address multinomial or categorical outcomes. This feature enables the fitting of Bayesian models with multinomial responses, facilitating the automatic generation of categorical contrasts. By incorporating the Dirichlet distribution in these models, researchers can effectively analyze and interpret data with multiple categories or levels, making it a valuable resource for statistical inference. By utilizing the Dirichlet distribution as a prior distribution for categorical or multinomial variables in Bayesian regression, researchers can introduce prior knowledge or beliefs about the distribution of categorical data into their modeling process. This approach provides a flexible framework for modeling ordered categorical responses while incorporating informative priors based on existing knowledge. Bayesian regression models leveraging the Dirichlet distribution offer a robust methodology for analyzing relationships between predictors and ordered categorical outcomes, allowing for nuanced interpretations and inference based on the underlying data structure.



### References

- https://mc-stan.org/docs/2_20/stan-users-guide/multi-logit-section.html
- https://vincentarelbundock.github.io/rethinking2/12.html
- https://builtin.com/data-science/dirichlet-distribution
- https://distribution-explorer.github.io/multivariate_continuous/dirichlet.html
- https://www.statisticshowto.com/dirichlet-distribution/
- https://www.andrewheiss.com/blog/2023/09/18/understanding-dirichlet-beta-intuition/

