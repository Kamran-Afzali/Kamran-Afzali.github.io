### Introduction

Mixture modeling is a powerful technique for integrating multiple data generating processes into a single model. Unfortunately when those data data generating processes are degenerate the resulting mixture model suffers from inherent combinatorial non-identifiabilities that frustrate accurate computation. Consequently, in order to utilize mixture models reliably in practice we need strong and principled prior information to ameliorate these frustrations. 

Bayesian mixture models can be implemented in Stan, a probabilistic programming language. Mixture models assume that a given measurement can be drawn from one of K data generating processes, each with their own set of parameters. Stan allows for the fitting of Bayesian mixture models using its Hamiltonian Monte Carlo sampler. The models can be parameterized in several ways and used directly for modeling data with multimodal distributions or as priors for other parameters. The implementation of mixture models in Stan involves defining the model, specifying the priors, and marginalizing out the discrete parameters. Several resources provide examples and tutorials on fitting Bayesian mixture models in Stan, demonstrating the practical implementation of these models.

In this post I will first introduce how mixture models are implemented in Bayesian inference. It is noteworthy to take into consideration non-identifiability inherent these models how the non-identifiability can be tempered with principled prior information. [Michael Betancourt](https://maggielieu.com/2017/03/21/multivariate-gaussian-mixture-model-done-properly/) has a blogpost describing the problems often encountered with gaussian mixture models, specifically the estimation of parameters of a mixture model and identifiability i.e. the problem with labelling [mixtures](http://mc-stan.org/documentation/case-studies/identifying_mixture_models.html). Also there has been suggestions that GMM’s can’t be easily done in Stan. 

```
library(dplyr); library(ggplot2); library(ggthemes)

# Number of data points
N <- 400

# Let's make three states
mu <- c(3, 6, 9)
sigma <- c(2, 4, 3)

# with probability
Theta <- c(.5, .2, .3)

# Draw which model each belongs to
z <- sample(1:3, size = N, prob = Theta, replace = T)

# Some white noise
epsilon <- rnorm(N)

# Simulate the data using the fact that y ~ normal(mu, sigma) can be 
# expressed as y = mu + sigma*epsilon for epsilon ~ normal(0, 1)
y <- mu[z] + sigma[z]*epsilon

data_frame(y, z = as.factor(z)) %>% 
  ggplot(aes(x = y, fill = z)) +
  geom_density(alpha = 0.3) +
  theme_economist() +
  ggtitle("Three data generating processes")
```


```
mixture_model<-'

// saved as finite_mixture_linear_regression.stan
data {
  int N;
  vector[N] y;
  int n_groups;
}
parameters {
  vector[n_groups] mu;
  vector<lower = 0>[n_groups] sigma;
  simplex[n_groups] Theta;
}
model {
  vector[n_groups] contributions;
  // priors
  mu ~ normal(0, 10);
  sigma ~ cauchy(0, 2);
  Theta ~ dirichlet(rep_vector(2.0, n_groups));
  
  
  // likelihood
  for(i in 1:N) {
    for(k in 1:n_groups) {
      contributions[k] = log(Theta[k]) + normal_lpdf(y[i] | mu[k], sigma[k]);
    }
    target += log_sum_exp(contributions);
  }
}'
```

```
library(rstan)
options(mc.cores = parallel::detectCores())

compiled_model <- stan_model("finite_mixture_linear_regression.stan")

estimated_model <- sampling(compiled_model, data = list(N= N, y = y, n_groups = 3), iter = 600)
```

```
vector[n_groups] mu;
ordered[n_groups] mu;
```



```
#first cluster
mu1=c(0,0,0,0)
sigma1=matrix(c(0.1,0,0,0,0,0.1,0,0,0,0,0.1,0,0,0,0,0.1),ncol=4,nrow=4, byrow=TRUE)
norm1=mvrnorm(30, mu1, sigma1)

#second cluster
mu2=c(7,7,7,7)
sigma2=sigma1
norm2=mvrnorm(30, mu2, sigma2)

#third cluster
mu3=c(3,3,3,3)
sigma3=sigma1
norm3=mvrnorm(30, mu3, sigma3)

norms=rbind(norm1,norm2,norm3) #combine the 3 mixtures together
N=90 #total number of data points 
Dim=4 #number of dimensions
y=array(as.vector(norms), dim=c(N,Dim))
mixture_data=list(N=N, D=4, K=3, y=y)
```

```
mixture_model<-'
data {
 int D; //number of dimensions
 int K; //number of gaussians
 int N; //number of data
 vector[D] y[N]; //data
}

parameters {
 simplex[K] theta; //mixing proportions
 ordered[D] mu[K]; //mixture component means
 cholesky_factor_corr[D] L[K]; //cholesky factor of covariance
}

model {
 real ps[K];
 
 for(k in 1:K){
 mu[k] ~ normal(0,3);
 L[k] ~ lkj_corr_cholesky(4);
 }
 

 for (n in 1:N){
 for (k in 1:K){
 ps[k] = log(theta[k])+multi_normal_cholesky_lpdf(y[n] | mu[k], L[k]); //increment log probability of the gaussian
 }
 target += log_sum_exp(ps);
 }

}'
```



```
fit=stan(model_code=mixture_model, data=mixture_data, iter=11000, warmup=1000, chains=1)
print(fit)
params=extract(fit)
#density plots of the posteriors of the mixture means
par(mfrow=c(2,2))
plot(density(params$mu[,1,1]), ylab='', xlab='mu[1]', main='')
lines(density(params$mu[,1,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,1,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,1,4]), col=rgb(0,0,0,0.1))
abline(v=c(0), lty='dotted', col='red',lwd=2)

plot(density(params$mu[,2,1]), ylab='', xlab='mu[2]', main='')
lines(density(params$mu[,2,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,2,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,2,4]), col=rgb(0,0,0,0.1))
abline(v=c(7), lty='dotted', col='red',lwd=2)

plot(density(params$mu[,3,1]), ylab='', xlab='mu[3]', main='')
lines(density(params$mu[,3,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,3,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,3,4]), col=rgb(0,0,0,0.1))
abline(v=c(3), lty='dotted', col='red',lwd=2)
```

### Advantages and Limitations 

Bayesian mixture models offer several advantages in statistical modeling. Their inherent flexibility makes them well-suited for diverse tasks such as clustering, data compression, outlier detection, and generative classification. The Bayesian framework's ability to incorporate prior knowledge enhances model accuracy, especially when informative prior information is available. Moreover, these models effectively handle unobserved heterogeneity by integrating multiple data generating processes, proving valuable when data alone may not fully identify underlying patterns. The stability provided by Bayesian estimation ensures reliable posterior distributions, reducing sensitivity to issues like singularities, over-fitting, and violated identification criteria. Bayesian mixture models also facilitate the examination of the posterior distribution of the number of classes, offering insights into the underlying class structure of the data.

However, the use of Bayesian mixture models comes with certain limitations. Applying these models demands a high level of statistical expertise to appropriately specify priors and ensure correct model formulation, presenting a challenge for practitioners lacking a strong background in Bayesian statistics. The complexity of posterior inference is compounded by label switching, a phenomenon that complicates the interpretation of results. Bayesian nonparametric mixture models, in particular, may suffer from inconsistency in estimating the number of clusters, impacting their performance in clustering applications. Additionally, model fitting challenges arise, and careful evaluation of inaccuracies in predictions and comparison with alternative models are essential to address potential shortcomings.

###  Conclusion 

In this post, we learned to fit mixture models using Stan. We saw how to evaluate model fit using the usual prior and posterior predictive checks, and to investigate parameter recovery. Such mixture models are notoriously difficult to fit, but they have a lot of potential in cognitive science applications, especially in developing computational models of different kinds of cognitive processes. The reader interested in a deeper understanding of potential chllanges in the process can refer to Betancourt discussion of identification problems in Bayesian mixture models in a [case study](https://mc-stan.org/users/documentation/case-studies/identifying_mixture_models.html). 



### References

- [Finite mixture models in Stan](https://modernstatisticalworkflow.blogspot.com/2016/10/finite-mixture-models-in-stan.html) 
- [Multivariate Gaussian Mixture Model done properly ](https://maggielieu.com/2017/03/21/multivariate-gaussian-mixture-model-done-properly/)
- [Finite Mixtures](https://mc-stan.org/docs/stan-users-guide/mixture-modeling.html) 
- [Identifying Bayesian Mixture Models](https://mc-stan.org/users/documentation/case-studies/identifying_mixture_models.html) 
- [Mixture models](https://vasishth.github.io/bayescogsci/book/ch-mixture.html) 
- [Bayesian Density Estimation (Finite Mixture Model) ](https://rpubs.com/kaz_yos/fmm2)
- [Bayesian mixture models (in)consistency for the number of clusters](https://hal.science/hal-03866434/document)
- [Advantages of a Bayesian Approach for Examining Class Structure in Finite Mixture Models](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6459682/) 



