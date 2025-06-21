set.seed(123)
N <- 100  # number of observations
D <- 2    # number of predictors
K <- 3    # number of categories
x <- matrix(rnorm(N * D), ncol = D)  # predictor matrix
beta_true <- matrix(rnorm(D * K), ncol = K)  # true regression coefficients
alpha_true <- rep(1, K)  # Dirichlet prior parameters

# Simulate outcome variable
eta <- x %*% beta_true
prob <- apply(eta, 1, function(x) exp(x - max(x)) / sum(exp(x - max(x))))
y <- apply(prob, 2, function(p) sample(1:K, 1, prob = p))

stan_data <- list(
  K = K,
  N = N,
  D = D,
  y = y,
  x = x
)

# Compile the Stan model
stan_model <- stan_model(model_code = stan_code)


library(rstan)

# Define the Stan model code
stan_code <- "
data {
  int<lower=2> K; // number of categories
  int<lower=0> N; // number of observations
  int<lower=1> D; // number of predictors
  int<lower=1, upper=K> y[N]; // outcome variable
  matrix[N, D] x; // predictor matrix
}
parameters {
  matrix[D, K] beta; // regression coefficients
  vector<lower=0>[K] alpha; // Dirichlet prior parameters
}
model {
  // Dirichlet prior for the probabilities of categories
  alpha ~ gamma(1, 1);
  
  // Multinomial logit model
  for (n in 1:N) {
    real log_probs[K];
    for (k in 1:K) {
      log_probs[k] = x[n] * beta[, k];
    }
    target += log_sum_exp(log_probs);
    y[n] ~ categorical_logit(log_probs);
  }
}
"




# Fit the model using Stan
stan_model <- stan_model(model_code = stan_code)
fit <- sampling(stan_model, data = stan_data)

# Print the summary of the model
print(fit)

library(diffpriv) 
f <- function(X) c(mean(X), sd(X))
f <- function(X) {X+1}
n <- 100
mechanism <- DPMechLaplace(target = f, sensitivity = 1/n, dims = 1) 
D <- runif(n, min = 0, max = 1) 
pparams <- DPParamsEps(epsilon = 1) 
r <- releaseResponse(mechanism, privacyParams = pparams, X = D)

r$target()

cat("Private response r$response:", r$response, "\nNon-private response f(D): ", f(D))



D <- rnorm(500, mean=3, sd=2) lower.bound <--3 # 3 standard deviations below mean upper.bound <- 9 # 3 standard deviations above mean



library(diffpriv)

# Example data
data <- c(10, 20, 30, 40, 50)

# Define the privacy budget (epsilon)
epsilon <- 1.0

# Define the sensitivity of the query
sensitivity <- 1

# Create a differentially private sum function
dp_sum <- function(x) {
  dp_mechanism <- DPMechLaplace(epsilon = epsilon, sensitivity = sensitivity)
  dp_release <- releaseResponse(dp_mechanism, x)
  return(dp_release$response)
}

# Compute the differentially private sum
dp_result <- dp_sum(data)

print(paste("Differentially Private Sum:", dp_result))



library(randomNames) ## a package that generates representative random names 
oracle <- function(n) randomNames(n) 
D <- c("Michael Jordan", "Andrew Ng", "Andrew Zisserman","Christopher Manning", "Jitendra Malik", "Geoffrey Hinton", "Scott Shenker", "Bernhard Scholkopf", "Jon Kleinberg", "Judea Pearl") 
n <- length(D) 
f <- function(X) { function(r) sum(r == unlist(base::strsplit(X, ""))) } 
rSet <- as.list(letters) ## the response set, letters a--z, must be a list
mechanism <- DPMechExponential(target = f, responseSet = rSet)
mechanism <- sensitivitySampler(mechanism, oracle = oracle, n = n, gamma = 0.1) 
pparams <- DPParamsEps(epsilon = 1)
r <- releaseResponse(mechanism, privacyParams = pparams, X = D) 
cat("Private response r$response: ", r$response, "\nNon-private f(D) maximizer: ", letters[which.max(sapply(rSet, f(D)))])

vignette("diffpriv")


install.packages("DPpack")

library("DPpack")


D <- rnorm(500, mean=3, sd=2) 
lower.bound =-3 # 3 standard deviations below mean 
upper.bound = 9 # 3 standard deviations above mean


private.mean <- meanDP(D, 1, lower.bound, upper.bound) 
cat("Privacy preserving mean: ", private.mean, "\nTrue mean: ", mean(D)) 

 private.var <- varDP(D, 0.5, lower.bound, upper.bound, which.sensitivity = "unbounded", mechanism = "Gaussian", delta = 0.01) 
 cat("Privacy preserving variance: ", private.var, "\nTrue variance: ", var(D)) 
 
private.sd <- sdDP(D, 0.5, lower.bound, upper.bound, mechanism="Gaussian", delta=0.01, type.DP="pDP") 
cat("Privacy preserving standard deviation: ", private.sd, "\nTrue standard deviation: ", sd(D)) 




D1 <- sort(rnorm(500, mean=3, sd=2))
D2 <- sort(rnorm(500, mean=-1, sd=0.5)) 
lb1 <--3 
# 3 std devs below mean 
lb2 <--2.5 
# 3 std devs below mean
ub1 <- 9 
# 3 std devs above mean 
ub2 <- .5 
# 3 std devs above mean


private.cov <- covDP(D1, D2, 1, lb1, ub1, lb2, ub2) 

cat("Privacy preserving covariance: ", private.cov, "\nTrue covariance: ", cov(D1, D2))


D3 <- sort(rnorm(200, mean=3, sd=2)) 
D4 <- sort(rnorm(200, mean=-1, sd=0.5)) 
M1 <- matrix(c(D1, D2), ncol=2) 
M2 <- matrix(c(D3, D4), ncol=2)


private.pooled.cov <- pooledCovDP(M1, M2, eps = 1, lower.bound1 = lb1, lower.bound2 = lb2, upper.bound1 = ub1, upper.bound2 = ub2)




n <- 100 
c0 <- 5 
c1 <- 10 
D <- runif(n, c0, c1) 
f <- function(D) c(mean(D), var(D)) 
sensitivities <- c((c1-c0)/n, (c1-c0)^2/n)
epsilon <- 1
private.vals <- LaplaceMechanism(f(D), epsilon, sensitivities) 
cat("Privacy preserving values: ", private.vals, "\nTrue values: ", f(D))


# Here, privacy budget is split so that 25% is given to the mean and 75% is given to the variance 
private.vals <- LaplaceMechanism(f(D), epsilon, sensitivities, alloc.proportions = c(0.25, 0.75)) 
cat("Privacy preserving values: ", private.vals, "\nTrue values: ", f(D))



library(smotefamily)
data_example = sample_generator(10000,ratio = 0.80)
genData = SMOTE(data_example[,-3],data_example[,3])
genData_2 = SMOTE(data_example[,-3],data_example[,3],K=7)
genData$syn_data
genData_2$syn_data




# Build example dataset
n <- 500
X <- data.frame(X1=rnorm(n, mean=0, sd=0.3),X2=rnorm(n, mean=0, sd=0.3),X3=rnorm(n, mean=0, sd=0.3))
true.theta <- c(-.3,.5,.8,.2) # First element is bias term
p <- length(true.theta)
y <- true.theta[1] + as.matrix(X)%*%true.theta[2:p] + stats::rnorm(n=n,sd=.1)
summary(y)
# Construct object for linear regression
regularizer <- 'l2' # Alternatively, function(coeff) coeff%*%coeff/2
eps <- 10
delta <- 0 # Indicates to use pure eps-DP
gamma <- 0
regularizer.gr <- function(coeff) coeff

lrdp <- LinearRegressionDP$new('l2', eps, delta, gamma, regularizer.gr)

# Fit with data
# We must assume y is a matrix with values between -p and p (-2 and 2
#   for this example)
upper.bounds <- c(1,1,1, 2) # Bounds for X and y
lower.bounds <- c(-1,-1,-1,-2) # Bounds for X and y
lrdp$fit(X, y, upper.bounds, lower.bounds, add.bias=TRUE)
lrdp$coeff # Gets private coefficients

# Predict new data points
# Build a test dataset
Xtest <- data.frame(X=c(-.5, -.25, .1, .4))
predicted.y <- lrdp$predict(Xtest, add.bias=TRUE)



# Set seed for reproducibility
set.seed(0)

# Create 9 predictor variables
predictors <- matrix(rnorm(900), nrow = 100, ncol = 9)
colnames(predictors) <- paste0("Predictor_", 1:9)

# Create coefficients for the linear relationship
coefficients <- runif(9)

# Generate the outcome variable with some added noise
outcome <- predictors %*% coefficients + rnorm(100, sd = 0.5)

# Combine predictors and outcome into a single dataframe
data <- data.frame(predictors, Outcome = outcome)

# View the first few rows of the dataframe
head(data)

summary(data)

# Fit linear regression model
model <- lm(Outcome ~ ., data = data)

# View model summary
summary(model)

# Get coefficients and intercept
coef(model)



summary(model)
regularizer <- 'l1' # Alternatively, function(coeff) coeff%*%coeff/2
eps <- 1
delta <- 0 # Indicates to use pure eps-DP
gamma <- 1
regularizer.gr <- function(coeff) coeff

lrdp <- LinearRegressionDP$new('l2', eps, delta, gamma, regularizer.gr)

# Fit with data
# We must assume y is a matrix with values between -p and p (-2 and 2
#   for this example)
upper.bounds <- c(rep(3,9),5 ) # Bounds for X and y
lower.bounds <- c(rep(-3,9),-5) # Bounds for X and y
lrdp$fit(as.data.frame(predictors), as.data.frame(outcome), upper.bounds, lower.bounds, add.bias=T)
lrdp$coeff # Gets private coefficients
coef(model)






set.seed(0)

predictors <- matrix(rnorm(900), nrow = 100, ncol = 9)
colnames(predictors) <- paste0("Predictor_", 1:9)

coefficients <- runif(9)

outcome <- predictors %*% coefficients + rnorm(100, sd = 0.5)

data <- data.frame(predictors, Outcome = outcome)
summary(data)


model <- lm(Outcome ~ ., data = data)
summary(model)
 
eps <- 100
delta <- 0 
gamma <- 0
regularizer.gr <- function(coeff) coeff

lrdp <- LinearRegressionDP$new('l2', eps, delta, gamma, regularizer.gr)


upper.bounds <- c(rep(5,9),5 ) 
lower.bounds <- c(rep(-5,9),-5) 
lrdp$fit(as.data.frame(predictors), as.data.frame(outcome), upper.bounds, lower.bounds, add.bias=T)
lrdp$coeff # Gets private coefficients
coef(model)


D1 <- sort(rnorm(500, mean=3, sd=2))
D2 <- sort(rnorm(500, mean=-1, sd=0.5)) 
lb1 <--3 
# 3 std devs below mean 
lb2 <--2.5 
# 3 std devs below mean
ub1 <- 9 
# 3 std devs above mean 
ub2 <- .5 
# 3 std devs above mean
cov(D1, D2)

private.cov <- covDP(D1, D2, 1, lb1, ub1, lb2, ub2) 

cat("Privacy preserving covariance: ", private.cov, "\nTrue covariance: ", cov(D1, D2))


D3 <- sort(rnorm(200, mean=3, sd=2)) 
D4 <- sort(rnorm(200, mean=-1, sd=0.5)) 
M1 <- matrix(c(D1, D2), ncol=2) 
M2 <- matrix(c(D3, D4), ncol=2)
private.pooled.cov <- pooledCovDP(M1, M2, eps = 1, lower.bound1 = lb1, lower.bound2 = lb2, upper.bound1 = ub1, upper.bound2 = ub2)

private.pooled.cov






library(gtools)
alpha <- c(2, 3, 5)
n=1000
samples <- rdirichlet(n, alpha)
print(samples)
round(10*(colSums(samples)/n),3)




library(LaplacesDemon)

# Define a probability vector and alpha parameters
prob_vector <- c(0.1, 0.3, 0.6)
alpha <- c(1, 1, 1)

# Calculate the density
density <- ddirichlet(prob_vector, alpha)
print(density)


alpha <- c(2, 3, 5)
samples <- rdirichlet(10000, alpha)
library(ggtern)
data <- as.data.frame(samples)
colnames(data) <- c("X1", "X2", "X3")
ggtern(data = data, aes(x = X1, y = X2, z = X3)) +
  geom_point(alpha = 0.1) +
  labs(title = "Dirichlet Distribution Visualization")




stan_model <-'data {
  int<lower=1> K; // Number of categories
  vector<lower=0>[K] alpha; // Dirichlet parameters
}

parameters {
  simplex[K] theta; // Probability vector
}

model {
  theta ~ dirichlet(alpha); // Dirichlet prior
}'
library(rstan)

# Define the data
K <- 3
alpha <- c(2, 3, 5) # Dirichlet parameters
data_list <- list(K = K, alpha = alpha)

# Fit the model
fit <- stan(model_code=stan_model, data = data_list, iter = 2000, chains = 4)

# Print the results
print(fit)





library(rstan)
library(ggplot2)

dirichlet_model_code <- "
data {
  int<lower=1> K;            // Number of categories
  int<lower=0> N;            // Number of observations
  int<lower=1, upper=K> y[N]; // Observations (categorical data)
  vector<lower=0>[K] alpha;  // Dirichlet prior parameters
}
parameters {
  simplex[K] theta;          // Probabilities for each category
}
model {
  theta ~ dirichlet(alpha);  // Dirichlet prior
  y ~ categorical(theta);    // Likelihood
}
generated quantities {
  vector[K] p_hat;           // Posterior mean of theta
  p_hat = theta;
}
"
# Number of categories
K <- 3

# Observed data (e.g., 1, 2, 3 corresponds to categories)
y <- c(rep(1,20),rep(2,30),rep(3,50))

# Number of observations
N <- length(y)

# Dirichlet prior parameters (e.g., prior beliefs about category probabilities)
alpha <- c(2, 2, 2)

# Data list to pass to Stan
data_list <- list(K = K, N = N, y = y, alpha = alpha)
# Compile the model
dirichlet_model <- stan_model(model_code = dirichlet_model_code)

# Fit the model with the data
fit <- sampling(dirichlet_model, data = data_list, iter = 2000, chains = 4, seed = 123)

# Print a summary of the results
print(fit)



posterior_samples <- extract(fit)

# Summary statistics of the posterior mean (p_hat)
posterior_mean <- apply(posterior_samples$p_hat, 2, mean)
print(posterior_mean)

# Plot the posterior distributions of theta
theta_samples <- as.data.frame(posterior_samples$theta)
colnames(theta_samples) <- paste0("theta_", 1:K)

# Use ggplot2 to visualize the posterior distributions
ggplot(theta_samples, aes(x = theta_1)) +
  geom_density(fill = "blue", alpha = 0.3) +
  labs(title = "Posterior Distribution of theta_1", x = "theta_1", y = "Density")

ggplot(theta_samples, aes(x = theta_2)) +
  geom_density(fill = "green", alpha = 0.3) +
  labs(title = "Posterior Distribution of theta_2", x = "theta_2", y = "Density")

ggplot(theta_samples, aes(x = theta_3)) +
  geom_density(fill = "red", alpha = 0.3) +
  labs(title = "Posterior Distribution of theta_3", x = "theta_3", y = "Density")



library(dplyr)
library(ggplot2)
library(ggthemes)
library(MASS)
library(rstan)

#first cluster
mu1=c(0,0,0,0)
sigma1=matrix(c(0.2,0,0,0,0,0.2,0,0,0,0,0.1,0,0,0,0,0.1),ncol=4,nrow=4, byrow=TRUE)
norm1=mvrnorm(30, mu1, sigma1)

#second cluster
mu2=c(10,10,10,10)
sigma2=sigma1
norm2=mvrnorm(30, mu2, sigma2)

#third cluster
mu3=c(4,4,4,4)
sigma3=sigma1
norm3=mvrnorm(30, mu3, sigma3)

norms=rbind(norm1,norm2,norm3) #combine the 3 mixtures together
N=90 #total number of data points 
Dim=4 #number of dimensions
y=array(as.vector(norms), dim=c(N,Dim))
mixture_data=list(N=N, D=4, K=3, y=y)

as.data.frame(norms)  %>%
  pivot_longer(colnames(as.data.frame(norms)), names_to = "var", values_to = "value")%>%
  ggplot( aes(x=value, color=var)) + geom_density() +
  ggtitle("Three clusters on four variables")


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
 ps[k] = log(theta[k])+multi_normal_cholesky_lpdf(y[n] | mu[k], L[k]); 
 }
 target += log_sum_exp(ps);
 }

}'




fit=stan(model_code=mixture_model, data=mixture_data, iter=3000, warmup=1000, chains=1)
print(fit)
params=extract(fit)
#density plots of the posteriors of the mixture means
par(mfrow=c(1,3))
plot(density(params$mu[,1,1]), ylab='', xlab='mu[1]', main='')
lines(density(params$mu[,1,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,1,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,1,4]), col=rgb(0,0,0,0.1))
abline(v=c(4), lty='dotted', col='red',lwd=2)

plot(density(params$mu[,2,1]), ylab='', xlab='mu[2]', main='')
lines(density(params$mu[,2,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,2,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,2,4]), col=rgb(0,0,0,0.1))
abline(v=c(10), lty='dotted', col='red',lwd=2)

plot(density(params$mu[,3,1]), ylab='', xlab='mu[3]', main='')
lines(density(params$mu[,3,2]), col=rgb(0,0,0,0.7))
lines(density(params$mu[,3,3]), col=rgb(0,0,0,0.4))
lines(density(params$mu[,3,4]), col=rgb(0,0,0,0.1))
abline(v=c(0), lty='dotted', col='red',lwd=2)












# Load necessary packages
library(rstan)
library(ggplot2)

# Simulate some data
set.seed(123)
n <- 100
x <- seq(0, 10, length.out = n)
y <- sin(x) + rnorm(n, sd = 0.2)
df <- data.frame(x = x, y = y)

# Prepare data for Stan model
stan_data <- list(
  n = nrow(df),
  p = 1,  # We have only one predictor variable (x)
  X = as.matrix(df$x),
  y = df$y,
  tau = 0.5  # Quantile of interest (e.g., 0.5 for median)
)

# Specify Stan model code
stan_model_code <- "
data {
  int<lower=1> n;
  int<lower=1> p;
  matrix[n,p] X;
  vector[n] y;
  real tau;
}
parameters {
  vector[p] beta;
}
transformed parameters {
  vector[n] mu;
  for (i in 1:n) {
    mu[i] = X[i] * beta;
  }
}
model {
  beta ~ normal(0, 10);
  for (i in 1:n) {
    target += log_sum_exp({
      normal_lpdf(y[i] | mu[i], 1),
      normal_lccdf(y[i] | mu[i], 1) - log(1 - tau),
      normal_lcdf(y[i] | mu[i], 1) - log(tau)
    });
  }
}
"

# Compile Stan model
gqr_stan_model <- stan_model(model_code = stan_model_code)

# Fit Bayesian quantile regression model using Stan
gqr_fit <- sampling(gqr_stan_model, data = stan_data)

# Extract the posterior samples and summarize the results
posterior_samples <- extract(gqr_fit)
summary(gqr_fit)


samples <- extract(gqr_fit)

# Summary of the posterior distribution
summary(samples$beta)




n <- 200
x <- runif(n = n, min = 0, max = 10)
y <- 1 + 2 * x + rnorm(n = n, mean = 0, sd = 0.6*x)
dat <- data.frame(x, y)
# fit the 20%-quantile
fit <- brm(bf(y ~ x, quantile = 0.2), data = dat, family = asym_laplace())
summary(fit)
fit$model




library(rstan)
library(ggplot2)

# Generate simulated data
set.seed(123)
x <- seq(0, 10, length = 50)
y <- sin(x) + rnorm(50, 0, 0.2)
df <- data.frame(x = x, y = y)

# Specify Stan model code
stan_model_code <- "
functions {
  vector gp_pred_rng(array[] real x2,
                     vector y1,
                     array[] real x1,
                     real sigma_f,
                     real lengthscale_f,
                     real sigma,
                     real jitter) {
    int N1 = rows(y1);
    int N2 = size(x2);
    vector[N2] f2;
    {
      matrix[N1, N1] L_K;
      vector[N1] K_div_y1;
      matrix[N1, N2] k_x1_x2;
      matrix[N1, N2] v_pred;
      vector[N2] f2_mu;
      matrix[N2, N2] cov_f2;
      matrix[N1, N1] K;
      K = gp_exp_quad_cov(x1, sigma_f, lengthscale_f);
      for (n in 1:N1)
        K[n, n] = K[n,n] + square(sigma);
      L_K = cholesky_decompose(K);
      K_div_y1 = mdivide_left_tri_low(L_K, y1);
      K_div_y1 = mdivide_right_tri_low(K_div_y1', L_K)';
      k_x1_x2 = gp_exp_quad_cov(x1, x2, sigma_f, lengthscale_f);
      f2_mu = (k_x1_x2' * K_div_y1);
      v_pred = mdivide_left_tri_low(L_K, k_x1_x2);
      cov_f2 = gp_exp_quad_cov(x2, sigma_f, lengthscale_f) - v_pred' * v_pred;

      f2 = multi_normal_rng(f2_mu, add_diag(cov_f2, rep_vector(jitter, N2)));
    }
    return f2;
  }
}
data {
  int<lower=1> N;      // number of observations
  vector[N] x;         // univariate covariate
  vector[N] y;         // target variable
  int<lower=1> N2;     // number of test points
  vector[N2] x2;       // univariate test points
}
transformed data {
  // Normalize data
  real xmean = mean(x);
  real ymean = mean(y);
  real xsd = sd(x);
  real ysd = sd(y);
  array[N] real xn = to_array_1d((x - xmean)/xsd);
  array[N2] real x2n = to_array_1d((x2 - xmean)/xsd);
  vector[N] yn = (y - ymean)/ysd;
  real sigma_intercept = 1;
  vector[N] zeros = rep_vector(0, N);
}
parameters {
  real<lower=0> lengthscale_f; // lengthscale of f
  real<lower=0> sigma_f;       // scale of f
  real<lower=0> sigman;         // noise sigma
}
model {
  // covariances and Cholesky decompositions
  matrix[N, N] K_f = gp_exp_quad_cov(xn, sigma_f, lengthscale_f)+
                     sigma_intercept^2;
  matrix[N, N] L_f = cholesky_decompose(add_diag(K_f, sigman^2));
  // priors
  lengthscale_f ~ normal(0, 1);
  sigma_f ~ normal(0, 1);
  sigman ~ normal(0, 1);
  // model
  yn ~ multi_normal_cholesky(zeros, L_f);
}
generated quantities {
  // function scaled back to the original scale
  vector[N2] f = gp_pred_rng(x2n, yn, xn, sigma_f, lengthscale_f, sigman, 1e-9)*ysd + ymean;
  real sigma = sigman*ysd;
}
"

# Compile Stan model
gpr_stan_model <- stan_model(model_code = stan_model_code)

# Prepare data for Stan model
stan_data <- list(x=df$x,
                  x2=df$x,
                  y=df$y,
                  N=length(df$x),
                  N2=length(df$x))

# Fit Bayesian GPR model using Stan
gpr_fit <- sampling(gpr_stan_model, data = stan_data)


f_samples <- extract(gpr_fit, "f")$f
sigma_samples <- extract(gpr_fit, "sigma")$sigma


df %>%
  mutate(Ef=colMeans(f_samples),
         sigma=mean(sigma_samples)) %>%  
  ggplot(aes(x=x,y=y))+
  geom_point()+
  labs(x="Time (ms)", y="Acceleration (g)")+
  geom_line(aes(y=Ef), color='red')+
  geom_line(aes(y=Ef-2*sigma), color='red',linetype="dashed")+
  geom_line(aes(y=Ef+2*sigma), color='red',linetype="dashed")



