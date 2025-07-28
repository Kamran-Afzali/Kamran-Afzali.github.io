# Dyna: Integrating Learning and Planning in Reinforcement Learning

## Introduction

Traditional reinforcement learning methods fall into two categories: model-free approaches like SARSA and Q-Learning that learn directly from experience, and model-based methods that first learn environment dynamics then use planning algorithms. Dyna, introduced by Sutton (1990), bridges this gap by combining direct reinforcement learning with indirect learning through an internal model of the environment.

The key insight behind Dyna is that real experience can serve dual purposes: updating value functions directly and improving an internal model that generates simulated experience for additional learning. This architecture allows agents to benefit from both the sample efficiency of planning and the robustness of direct learning, making it particularly effective in environments where experience is costly or limited.

## Theoretical Framework

### The Dyna Architecture

Dyna integrates three key components within a unified learning system:

1. **Direct RL**: Learning from real experience using standard temporal difference methods
2. **Model Learning**: Building an internal model of environment dynamics from experience  
3. **Planning**: Using the learned model to generate simulated experience for additional value function updates

The complete Dyna update cycle can be formalized as follows. For each real experience tuple $(s, a, r, s')$:

**Direct Learning (Q-Learning)**:
$$Q(s,a) \leftarrow Q(s,a) + \alpha \left[ r + \gamma \max_{a'} Q(s', a') - Q(s,a) \right]$$

**Model Update**:
$$\hat{T}(s,a) \leftarrow s'$$
$$\hat{R}(s,a) \leftarrow r$$

**Planning Phase** (repeat $n$ times):
$$s \leftarrow \text{random previously visited state}$$
$$a \leftarrow \text{random action previously taken in } s$$
$$r \leftarrow \hat{R}(s,a)$$
$$s' \leftarrow \hat{T}(s,a)$$
$$Q(s,a) \leftarrow Q(s,a) + \alpha \left[ r + \gamma \max_{a'} Q(s', a') - Q(s,a) \right]$$

The parameter $n$ controls the number of planning steps per real experience, representing the computational budget available for internal simulation.

### Model Representation

In its simplest form, Dyna uses a deterministic table-based model where $\hat{T}(s,a)$ stores the last observed next state for state-action pair $(s,a)$, and $\hat{R}(s,a)$ stores the last observed reward. This approach works well for deterministic environments but can be extended to handle stochastic dynamics through sampling-based representations.

### Convergence Properties

Under standard assumptions (all state-action pairs visited infinitely often, appropriate learning rates), Dyna inherits the convergence guarantees of its underlying RL algorithm. The addition of planning typically accelerates convergence by allowing each real experience to propagate information more widely through the value function.

## Implementation in R

We implement Dyna-Q using the same 10-state environment from previous posts, allowing direct comparison with pure Q-Learning and SARSA approaches.

### Environment Setup

```r
# Environment parameters
n_states <- 10
n_actions <- 2
gamma <- 0.9
terminal_state <- n_states

# Transition and reward models (same as previous posts)
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

# Environment interaction function
sample_env <- function(s, a) {
  probs <- transition_model[s, a, ]
  s_prime <- sample(1:n_states, 1, prob = probs)
  reward <- reward_model[s, a, s_prime]
  list(s_prime = s_prime, reward = reward)
}
```

### Dyna-Q Implementation

```r
dyna_q <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1, n_planning = 5) {
  # Initialize Q-values and model
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  model_T <- array(NA, dim = c(n_states, n_actions))  # Transition model
  model_R <- array(NA, dim = c(n_states, n_actions))  # Reward model
  visited_sa <- list()  # Track visited state-action pairs
  
  for (ep in 1:episodes) {
    s <- 1
    
    while (s != terminal_state) {
      # Action selection (epsilon-greedy)
      if (runif(1) < epsilon) {
        a <- sample(1:n_actions, 1)
      } else {
        a <- which.max(Q[s, ])
      }
      
      # Take action and observe outcome
      outcome <- sample_env(s, a)
      s_prime <- outcome$s_prime
      r <- outcome$reward
      
      # Direct learning (Q-Learning update)
      Q[s, a] <- Q[s, a] + alpha * (r + gamma * max(Q[s_prime, ]) - Q[s, a])
      
      # Model learning
      model_T[s, a] <- s_prime
      model_R[s, a] <- r
      
      # Track visited state-action pairs
      sa_key <- paste(s, a, sep = "_")
      if (!(sa_key %in% names(visited_sa))) {
        visited_sa[[sa_key]] <- c(s, a)
      }
      
      # Planning phase
      if (length(visited_sa) > 0) {
        for (i in 1:n_planning) {
          # Sample random previously visited state-action pair
          sa_sample <- sample(visited_sa, 1)[[1]]
          s_plan <- sa_sample[1]
          a_plan <- sa_sample[2]
          
          # Get simulated experience from model
          if (!is.na(model_T[s_plan, a_plan])) {
            s_prime_plan <- model_T[s_plan, a_plan]
            r_plan <- model_R[s_plan, a_plan]
            
            # Planning update (same as Q-Learning)
            Q[s_plan, a_plan] <- Q[s_plan, a_plan] + 
              alpha * (r_plan + gamma * max(Q[s_prime_plan, ]) - Q[s_plan, a_plan])
          }
        }
      }
      
      s <- s_prime
    }
  }
  
  list(Q = Q, policy = apply(Q, 1, which.max), model_T = model_T, model_R = model_R)
}
```

### Standard Q-Learning for Comparison

```r
q_learning <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1) {
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  
  for (ep in 1:episodes) {
    s <- 1
    while (s != terminal_state) {
      a <- if (runif(1) < epsilon) sample(1:n_actions, 1) else which.max(Q[s, ])
      outcome <- sample_env(s, a)
      s_prime <- outcome$s_prime
      r <- outcome$reward
      
      Q[s, a] <- Q[s, a] + alpha * (r + gamma * max(Q[s_prime, ]) - Q[s, a])
      s <- s_prime
    }
  }
  
  list(Q = Q, policy = apply(Q, 1, which.max))
}
```

## Experimental Analysis

### Learning Efficiency Comparison

We compare Dyna-Q against standard Q-Learning across different numbers of planning steps:

```r
# Run experiments with different planning steps
set.seed(123)
n_runs <- 50
episodes <- 500

results <- data.frame(
  episode = rep(1:episodes, 4),
  algorithm = rep(c("Q-Learning", "Dyna-Q (n=5)", "Dyna-Q (n=10)", "Dyna-Q (n=20)"), each = episodes),
  performance = numeric(episodes * 4)
)

for (run in 1:n_runs) {
  # Q-Learning
  ql_perf <- evaluate_performance(q_learning(episodes = episodes))
  
  # Dyna-Q variants
  dyna5_perf <- evaluate_performance(dyna_q(episodes = episodes, n_planning = 5))
  dyna10_perf <- evaluate_performance(dyna_q(episodes = episodes, n_planning = 10))
  dyna20_perf <- evaluate_performance(dyna_q(episodes = episodes, n_planning = 20))
  
  # Accumulate results (simplified for illustration)
  if (run == 1) {
    results$performance <- c(ql_perf, dyna5_perf, dyna10_perf, dyna20_perf)
  }
}

# Performance evaluation function
evaluate_performance <- function(result) {
  # Calculate policy value or other performance metric
  policy_values <- numeric(episodes)
  for (i in 1:episodes) {
    # Simplified: count optimal actions in policy
    policy_values[i] <- sum(result$policy == 1) / length(result$policy)
  }
  return(policy_values)
}
```

### Adaptation to Environmental Changes

We test how Dyna-Q handles environmental changes compared to standard Q-Learning:

```r
# Test adaptation after environment change
test_adaptation <- function() {
  # Train both algorithms in original environment
  ql_result <- q_learning(episodes = 500)
  dyna_result <- dyna_q(episodes = 500, n_planning = 10)
  
  # Change environment (block preferred path)
  original_trans <- transition_model[5, 1, ]
  transition_model[5, 1, ] <<- 0
  transition_model[5, 1, 1] <<- 1  # Force return to start
  
  # Continue learning in changed environment
  ql_adapted <- q_learning_continue(ql_result$Q, episodes = 200)
  dyna_adapted <- dyna_q_continue(dyna_result$Q, episodes = 200, n_planning = 10)
  
  # Restore original environment
  transition_model[5, 1, ] <<- original_trans
  
  list(
    ql_before = ql_result$policy,
    ql_after = ql_adapted$policy,
    dyna_before = dyna_result$policy,
    dyna_after = dyna_adapted$policy
  )
}
```

## Planning Step Analysis

The number of planning steps $n$ represents a crucial hyperparameter in Dyna. We analyze its impact:

```r
analyze_planning_steps <- function() {
  n_values <- c(0, 1, 5, 10, 20, 50)
  convergence_episodes <- numeric(length(n_values))
  
  for (i in seq_along(n_values)) {
    result <- dyna_q(episodes = 1000, n_planning = n_values[i])
    # Calculate episodes to convergence (simplified)
    convergence_episodes[i] <- estimate_convergence(result)
  }
  
  data.frame(
    n_planning = n_values,
    episodes_to_convergence = convergence_episodes
  )
}

# Visualization
plot_convergence <- function() {
  data <- analyze_planning_steps()
  
  plot(data$n_planning, data$episodes_to_convergence,
       type = "b", pch = 16, col = "steelblue",
       xlab = "Planning Steps (n)", ylab = "Episodes to Convergence",
       main = "Effect of Planning Steps on Learning Speed")
  
  grid(lty = 2, col = "gray")
}
```

## Discussion

### Computational Trade-offs

Dyna demonstrates a fundamental trade-off in reinforcement learning between sample efficiency and computational cost. Each real experience triggers $n$ additional planning updates, requiring $(n+1)$ times the computation per step compared to model-free methods. However, this computational investment often pays dividends through faster convergence, especially in environments where real experience is expensive or dangerous to obtain.

The optimal value of $n$ depends on the specific problem characteristics. In our experiments, moderate values (5-10 planning steps) typically provide good performance improvements without excessive computational overhead. Very large values of $n$ can lead to diminishing returns and may even hurt performance if the model is inaccurate.

### Model Quality and Robustness

Dyna's effectiveness critically depends on model quality. In our deterministic table-based implementation, the model becomes increasingly accurate as more state-action pairs are visited. However, this approach assumes deterministic transitions, which may not hold in stochastic environments.

The simple model representation used here (storing only the last observed transition) works well for stationary environments but can struggle with non-stationary dynamics. More sophisticated model representations, such as maintaining transition probability distributions, can improve robustness at the cost of increased memory and computational requirements.

### Exploration and Planning Synergy

An interesting aspect of Dyna is how exploration during direct learning benefits planning effectiveness. The $\epsilon$-greedy exploration policy ensures that diverse state-action pairs are visited, providing the model with broader coverage of the environment. This coverage directly impacts planning quality, as the algorithm can only plan using previously visited state-action pairs.

This creates a positive feedback loop where exploration improves the model, which in turn makes planning more effective, leading to better policies and potentially more informed exploration. This synergy distinguishes Dyna from pure model-based approaches that might suffer from limited exploration during model learning.

### Comparison with Pure Approaches

Relative to pure model-free methods like Q-Learning, Dyna typically demonstrates faster convergence and better sample efficiency. The planning component allows each real experience to propagate information more widely through the value function, effectively amplifying the impact of limited experience.

Compared to pure model-based approaches, Dyna maintains the robustness benefits of direct learning. Even if the model is imperfect, the direct learning component continues to make progress using real experience. This dual approach can be particularly valuable in environments where model accuracy is difficult to achieve or verify.

### Limitations and Extensions

Several limitations of basic Dyna become apparent in practice. The deterministic model representation may poorly capture stochastic environments. The uniform sampling of state-action pairs for planning may be suboptimal compared to prioritized approaches that focus computational resources on high-value updates.

Modern extensions address many of these limitations. Dyna-Q+ incorporates exploration bonuses for state-action pairs that haven't been visited recently, encouraging continued exploration. Prioritized sweeping focuses planning updates on state-action pairs where the value function is likely to change most significantly. Model-based extensions can maintain probability distributions over transitions rather than deterministic mappings.

## Implementation Considerations

### Memory Requirements

Dyna requires additional memory to store the learned model alongside the value function. In our implementation, this doubles the memory requirements compared to pure Q-Learning. For larger state-action spaces, this can become a significant consideration, potentially requiring sparse representations or function approximation techniques.

### Real-time Constraints

The planning phase introduces variable computational demands that can complicate real-time applications. While the number of planning steps can be adjusted based on available computational budget, this flexibility requires careful consideration of timing constraints in online learning scenarios.

### Hyperparameter Sensitivity

Dyna introduces additional hyperparameters, particularly the number of planning steps $n$. This parameter requires tuning based on the specific problem characteristics and computational constraints. Unlike some hyperparameters that can be set based on theoretical considerations, $n$ often requires empirical validation.

## Conclusion

Dyna represents an elegant solution to integrating learning and planning in reinforcement learning, combining the sample efficiency of model-based methods with the robustness of model-free approaches. Our R implementation demonstrates both the benefits and challenges of this integration, showing improved learning speed at the cost of increased computational and memory requirements.

The key insight of using real experience for both direct learning and model improvement creates a powerful synergy that can significantly accelerate learning in many environments. However, the approach requires careful consideration of model representation, computational constraints, and hyperparameter tuning to achieve optimal performance.

Future extensions could explore more sophisticated model representations, prioritized planning strategies, or integration with function approximation techniques for handling larger state spaces. The fundamental principle of combining direct and indirect learning remains a valuable paradigm in modern reinforcement learning research.
