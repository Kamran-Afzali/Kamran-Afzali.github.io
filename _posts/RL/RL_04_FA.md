


## 🎯 Goal

Instead of learning a separate Q-value for each state-action pair (which doesn’t scale well), we will:

* Represent Q-values as a function:

  $$
  Q(s, a; \theta) = \phi(s, a)^T \cdot \theta
  $$
* Learn the parameters $\theta$ using stochastic gradient descent.
* Use **feature vectors** $\phi(s, a)$, which can be simple (e.g., one-hot encodings).



## 🧩 Step-by-Step in Cells

### Step 1: Defining the Environment in R

We use a 10-state, 2-action environment with stochastic transitions and rewards, as in previous work:

```r
# Common settings
n_states <- 10
n_actions <- 2
gamma <- 0.9
terminal_state <- n_states

# Environment: transition + reward models
set.seed(42)
transition_model <- array(0, dim = c(n_states, n_actions, n_states))
reward_model <- array(0, dim = c(n_states, n_actions, n_states))

for (s in 1:(n_states - 1)) {
  transition_model[s, 1, s + 1] <- 0.9
  transition_model[s, 1, sample(1:n_states, 1)] <- 0.1

  transition_model[s, 2, sample(1:n_states, 1)] <- 0.8
  transition_model[s, 2, sample(1:n_states, 1)] <- 0.2

  for (s_prime in 1:n_states) {
    reward_model[s, 1, s_prime] <- ifelse(s_prime == n_states, 1.0, 0.1 * runif(1))
    reward_model[s, 2, s_prime] <- ifelse(s_prime == n_states, 0.5, 0.05 * runif(1))
  }
}

transition_model[n_states, , ] <- 0
reward_model[n_states, , ] <- 0

# Sampling function
sample_env <- function(s, a) {
  probs <- transition_model[s, a, ]
  s_prime <- sample(1:n_states, 1, prob = probs)
  reward <- reward_model[s, a, s_prime]
  list(s_prime = s_prime, reward = reward)
}
```



### 🔧 Step 2: Define Features

We'll use simple **one-hot state encoding** concatenated with action indicator.

```{r}
# Create one-hot features for (state, action) pairs
create_features <- function(s, a, n_states, n_actions) {
  vec <- rep(0, n_states * n_actions)
  index <- (a - 1) * n_states + s
  vec[index] <- 1
  return(vec)
}
```



### 📦 Step 3: Initialize Function Approximator

We initialize weights $\theta$ randomly.

```{r}
# Initialize weights
n_features <- n_states * n_actions
theta <- rep(0, n_features)

# Q-value approximation function
q_hat <- function(s, a, theta) {
  x <- create_features(s, a, n_states, n_actions)
  return(sum(x * theta))
}
```



### 🧠 Step 4: Q-Learning with Function Approximation

We’ll use the same environment as before and update $\theta$ using the Q-learning rule.

```{r}
q_learning_fa <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1) {
  theta <- rep(0, n_features)
  
  for (ep in 1:episodes) {
    s <- 1
    while (TRUE) {
      # Epsilon-greedy action selection
      a <- if (runif(1) < epsilon) {
        sample(1:n_actions, 1)
      } else {
        q_vals <- sapply(1:n_actions, function(a_) q_hat(s, a_, theta))
        which.max(q_vals)
      }
      
      out <- sample_env(s, a)
      s_prime <- out$s_prime
      r <- out$reward
      
      # Compute TD target and error
      q_current <- q_hat(s, a, theta)
      q_next <- if (s_prime == terminal_state) 0 else max(sapply(1:n_actions, function(a_) q_hat(s_prime, a_, theta)))
      target <- r + gamma * q_next
      error <- target - q_current
      
      # Gradient update: θ ← θ + α * δ * ∇θ Q(s,a)
      x <- create_features(s, a, n_states, n_actions)
      theta <- theta + alpha * error * x
      
      if (s_prime == terminal_state) break
      s <- s_prime
    }
  }
  
  # Derive policy
  policy <- sapply(1:n_states, function(s) {
    q_vals <- sapply(1:n_actions, function(a) q_hat(s, a, theta))
    which.max(q_vals)
  })
  
  list(theta = theta, policy = policy)
}

fa_result <- q_learning_fa()
fa_policy <- fa_result$policy
```



### 📊 Step 5: Visualize Policy from Function Approximation

```{r}
barplot(fa_policy, names.arg = 1:n_states,
        col = "deepskyblue", ylim = c(0, 3),
        main = "Policy from Q-Learning with Function Approximation",
        ylab = "Action (1 = A1, 2 = A2)")
abline(h = 1.5, lty = 2, col = "gray")
```



## ✅ Summary

| Method                       | Representation    | Generalization | Scalable? | Psychological Mapping           |
| - | -- | -- |  | - |
| Tabular Q-learning           | Table of Q(s, a)  | ❌ No           | ❌ No      | Habitual, state-specific        |
| Q-learning + Function Approx | Linear Q(s, a; θ) | ✅ Yes          | ✅ Yes     | Habitual, schema-based learning |
