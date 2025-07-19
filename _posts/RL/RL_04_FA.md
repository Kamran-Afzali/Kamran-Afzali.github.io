
# Function Approximation in Reinforcement Learning: Q-Learning with Linear Models in R

## Introduction

In reinforcement learning (RL), tabular methods like SARSA and
Q-Learning store a separate Q-value for each state-action pair, which
becomes infeasible in large or continuous state spaces. Function
approximation addresses this by representing the action-value function
$Q(s, a)$ as a parameterized function $Q(s, a; \theta)$, enabling
generalization across states and scalability. This post explores
Q-Learning with linear function approximation, using a 10-state,
2-action environment to demonstrate how it learns policies compared to
tabular methods. We provide mathematical formulations, R code, and
comparisons with tabular Q-Learning, focusing on generalization,
scalability, and practical implications.

## Theoretical Background

Function approximation in RL aims to estimate the action-value function:

$$
Q^\pi(s, a) = \mathbb{E}_\pi \left[ \sum_{t=0}^\infty \gamma^t R_{t+1} \mid S_0 = s, A_0 = a \right]
$$

where $\gamma \in [0,1]$ is the discount factor, and $R_{t+1}$ is the
reward at time $t+1$. Instead of storing $Q(s, a)$ in a table, we
approximate it as:

$$
Q(s, a; \theta) = \phi(s, a)^T \theta
$$

where $\phi(s, a)$ is a feature vector for state-action pair $(s, a)$,
and $\theta$ is a parameter vector learned via optimization, typically
stochastic gradient descent (SGD).

### Q-Learning with Function Approximation

Q-Learning with function approximation is an off-policy method that
learns the optimal policy by updating $\theta$ to minimize the temporal
difference (TD) error. The update rule is:

$$
\theta \leftarrow \theta + \alpha \delta \nabla_\theta Q(s, a; \theta)
$$

where $\alpha$ is the learning rate, and the TD error $\delta$ is:

$$
\delta = r + \gamma \max_{a'} Q(s', a'; \theta) - Q(s, a; \theta)
$$

Here, $r$ is the reward, $s'$ is the next state, and
$\max_{a'} Q(s', a'; \theta)$ estimates the value of the next state
assuming the optimal action. For linear function approximation, the
gradient is:

$$
\nabla_\theta Q(s, a; \theta) = \phi(s, a)
$$

Thus, the update becomes:

$$
\theta \leftarrow \theta + \alpha \left( r + \gamma \max_{a'} Q(s', a'; \theta) - Q(s, a; \theta) \right) \phi(s, a)
$$

In our 10-state environment, we use one-hot encoding for $\phi(s, a)$,
mimicking tabular Q-Learning for simplicity but demonstrating the
framework’s potential for generalization with more complex features.

### Comparison with Tabular Q-Learning

Tabular Q-Learning updates a table of Q-values directly:

$$
Q(s, a) \leftarrow Q(s, a) + \alpha \left( r + \gamma \max_{a'} Q(s', a') - Q(s, a) \right)
$$

Function approximation generalizes across states via $\phi(s, a)$,
reducing memory requirements and enabling learning in large or
continuous spaces. However, it introduces approximation errors and
requires careful feature design to ensure convergence.

| **Aspect** | **Tabular Q-Learning** | **Q-Learning with Function Approximation** |
|------------------|-------------------------|------------------------------|
| **Representation** | Table of $Q(s, a)$ values | $Q(s, a; \theta) = \phi(s, a)^T \theta$ |
| **Memory** | $O(|\mathcal{S}| \cdot |\mathcal{A}|)$ | $O(|\theta|)$, depends on feature size |
| **Generalization** | None; state-action specific | Yes; depends on feature design |
| **Scalability** | Poor for large/continuous spaces | Good for large/continuous spaces with proper features |
| **Update Rule** | Direct Q-value update | Parameter update via gradient descent |
| **Convergence** | Guaranteed to optimal $Q^*$ under conditions | Converges to approximation of $Q^*$; depends on features |

## R Implementation

We implement Q-Learning with linear function approximation in a
10-state, 2-action environment, using one-hot encoding for $\phi(s, a)$.
The environment mirrors the previous post, with action 1 yielding a 1.0
reward at the terminal state (state 10) and action 2 yielding 0.5.


```r
# Common settings
n_states <- 10
n_actions <- 2
gamma <- 0.9
terminal_state <- n_states

# Environment: transition and reward models
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

# Create one-hot features for (state, action) pairs
create_features <- function(s, a, n_states, n_actions) {
  vec <- rep(0, n_states * n_actions)
  index <- (a - 1) * n_states + s
  vec[index] <- 1
  return(vec)
}

# Initialize weights
n_features <- n_states * n_actions
theta <- rep(0, n_features)

# Q-value approximation function
q_hat <- function(s, a, theta) {
  x <- create_features(s, a, n_states, n_actions)
  return(sum(x * theta))
}

# Q-Learning with function approximation
q_learning_fa <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1) {
  theta <- rep(0, n_features)
  rewards <- numeric(episodes)
  
  for (ep in 1:episodes) {
    s <- sample(1:(n_states - 1), 1)
    episode_reward <- 0
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
      episode_reward <- episode_reward + r
      
      # Compute TD target and error
      q_current <- q_hat(s, a, theta)
      q_next <- if (s_prime == terminal_state) 0 else max(sapply(1:n_actions, function(a_) q_hat(s_prime, a_, theta)))
      target <- r + gamma * q_next
      error <- target - q_current
      
      # Gradient update
      x <- create_features(s, a, n_states, n_actions)
      theta <- theta + alpha * error * x
      
      if (s_prime == terminal_state) break
      s <- s_prime
    }
    rewards[ep] <- episode_reward
  }
  
  # Derive policy
  policy <- sapply(1:n_states, function(s) {
    if (s == terminal_state) NA else which.max(sapply(1:n_actions, function(a) q_hat(s, a, theta)))
  })
  
  list(theta = theta, policy = policy, rewards = rewards)
}

# Run Q-Learning with function approximation
set.seed(42)
fa_result <- q_learning_fa(episodes = 1000, alpha = 0.1, epsilon = 0.1)
fa_policy <- fa_result$policy
fa_rewards <- fa_result$rewards

# Visualize policy
library(ggplot2)
policy_df <- data.frame(
  State = 1:n_states,
  Policy = fa_policy,
  Algorithm = "Q-Learning FA"
)
policy_df$Policy[n_states] <- NA  # Terminal state

policy_plot <- ggplot(policy_df, aes(x = State, y = Policy)) +
  geom_point(size = 3, color = "deepskyblue") +
  geom_line(na.rm = TRUE, color = "deepskyblue") +
  theme_minimal() +
  labs(title = "Policy from Q-Learning with Function Approximation", x = "State", y = "Action") +
  scale_x_continuous(breaks = 1:n_states) +
  scale_y_continuous(breaks = 1:n_actions, labels = c("Action 1", "Action 2")) +
  theme(legend.position = "none")

# Visualize cumulative rewards
reward_df <- data.frame(
  Episode = 1:1000,
  Reward = cumsum(fa_rewards),
  Algorithm = "Q-Learning FA"
)

policy_plot
```  
  
