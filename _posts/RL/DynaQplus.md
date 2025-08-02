# Dyna-Q+: Enhanced Exploration in Integrated Learning and Planning

## Introduction

While Dyna successfully bridges model-free and model-based reinforcement learning, it carries an inherent assumption that can limit its effectiveness in changing environments: that the world remains static. When an agent has learned to navigate one version of an environment, what happens if the rules suddenly change? Standard Dyna may find itself stuck, continuing to plan based on outdated information while failing to adequately explore the new reality.

Dyna-Q+, introduced by Sutton (1990) alongside the original Dyna framework, addresses this limitation through a deceptively simple yet powerful mechanism: it rewards curiosity. By providing exploration bonuses for state-action pairs that haven't been tried recently, Dyna-Q+ maintains a healthy skepticism about its model's continued accuracy. This approach proves particularly valuable in non-stationary environments where adaptation speed can mean the difference between success and failure.

The enhancement might seem minor—just an additional term in the reward calculation—but its implications run deep. Dyna-Q+ acknowledges that in a changing world, forgetting can be as important as remembering, and that an agent's confidence in its model should decay over time unless continually refreshed by recent experience.

## Theoretical Framework

### The Exploration Bonus Mechanism

Dyna-Q+ modifies the planning phase of standard Dyna by augmenting rewards with an exploration bonus based on the time elapsed since each state-action pair was last visited. The core insight lies in treating the passage of time as information: the longer an agent hasn't verified a particular transition, the less confident it should be about that transition's current validity.

For each state-action pair $(s,a)$, we maintain a timestamp $\tau(s,a)$ recording when it was last experienced. During planning, instead of using the stored reward $\hat{R}(s,a)$ directly, we calculate an augmented reward:

$$r_{augmented} = \hat{R}(s,a) + \kappa \sqrt{t - \tau(s,a)}$$

where $t$ represents the current time step, and $\kappa$ is a parameter controlling the strength of the exploration bonus. The square root function provides a diminishing bonus that grows with time but at a decreasing rate, reflecting the intuition that uncertainty about a transition increases with time but not linearly.

### Complete Dyna-Q+ Algorithm

The full algorithm extends standard Dyna with minimal modifications. For each real experience tuple $(s, a, r, s')$:

**Direct Learning**:
$$Q(s,a) \leftarrow Q(s,a) + \alpha \left[ r + \gamma \max_{a'} Q(s', a') - Q(s,a) \right]$$

**Model and Timestamp Updates**:
$$\hat{T}(s,a) \leftarrow s'$$
$$\hat{R}(s,a) \leftarrow r$$
$$\tau(s,a) \leftarrow t$$

**Planning Phase** (repeat $n$ times):
$$s_{plan} \leftarrow \text{random previously visited state}$$
$$a_{plan} \leftarrow \text{random action previously taken in } s_{plan}$$
$$r_{plan} \leftarrow \hat{R}(s_{plan},a_{plan}) + \kappa \sqrt{t - \tau(s_{plan},a_{plan})}$$
$$s'_{plan} \leftarrow \hat{T}(s_{plan},a_{plan})$$
$$Q(s_{plan},a_{plan}) \leftarrow Q(s_{plan},a_{plan}) + \alpha \left[ r_{plan} + \gamma \max_{a'} Q(s'_{plan}, a') - Q(s_{plan},a_{plan}) \right]$$

### Convergence and Stability

The theoretical properties of Dyna-Q+ are more complex than those of standard Dyna due to the non-stationary nature of the augmented rewards. In stationary environments, the exploration bonuses for frequently visited state-action pairs will remain small, and convergence properties approach those of standard Dyna. However, the algorithm sacrifices some theoretical guarantees about convergence to optimal policies in exchange for improved adaptability.

The parameter $\kappa$ requires careful tuning. Too small, and the exploration bonus becomes negligible, reducing Dyna-Q+ to standard Dyna. Too large, and the algorithm may exhibit excessive exploration even in stable environments, potentially degrading performance. The square root scaling helps moderate this trade-off by providing significant bonuses for truly neglected state-action pairs while keeping bonuses manageable for recently visited ones.

## Implementation in R

Building on our previous Dyna implementation, we extend the framework to include timestamp tracking and exploration bonuses.

### Environment Setup

We'll use the same 10-state environment as before, but we'll also create scenarios with environmental changes to demonstrate Dyna-Q+'s adaptive capabilities:

```r
# Environment parameters (same as before)
n_states <- 10
n_actions <- 2
gamma <- 0.9
terminal_state <- n_states

# Transition and reward models
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

# Environment interaction function with optional modification capability
sample_env <- function(s, a, modified = FALSE) {
  if (modified) {
    # Simulate environmental change by blocking previously optimal path
    if (s == 5 && a == 1) {
      return(list(s_prime = 1, reward = -0.5))  # Penalty for blocked path
    }
  }
  
  probs <- transition_model[s, a, ]
  s_prime <- sample(1:n_states, 1, prob = probs)
  reward <- reward_model[s, a, s_prime]
  list(s_prime = s_prime, reward = reward)
}
```

### Dyna-Q+ Implementation

The key modification involves maintaining timestamps and calculating exploration bonuses during planning:

```r
dyna_q_plus <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1, 
                        n_planning = 5, kappa = 0.1, change_episode = NULL) {
  # Initialize Q-values, model, and timestamps
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  model_T <- array(NA, dim = c(n_states, n_actions))
  model_R <- array(NA, dim = c(n_states, n_actions))
  timestamps <- array(0, dim = c(n_states, n_actions))  # When last visited
  visited_sa <- list()
  
  current_time <- 0
  environment_changed <- FALSE
  
  for (ep in 1:episodes) {
    # Check if we should change the environment
    if (!is.null(change_episode) && ep == change_episode) {
      environment_changed <- TRUE
    }
    
    s <- 1
    
    while (s != terminal_state) {
      current_time <- current_time + 1
      
      # Action selection (epsilon-greedy)
      if (runif(1) < epsilon) {
        a <- sample(1:n_actions, 1)
      } else {
        a <- which.max(Q[s, ])
      }
      
      # Take action and observe outcome
      outcome <- sample_env(s, a, modified = environment_changed)
      s_prime <- outcome$s_prime
      r <- outcome$reward
      
      # Direct learning (Q-Learning update)
      Q[s, a] <- Q[s, a] + alpha * (r + gamma * max(Q[s_prime, ]) - Q[s, a])
      
      # Model learning and timestamp update
      model_T[s, a] <- s_prime
      model_R[s, a] <- r
      timestamps[s, a] <- current_time
      
      # Track visited state-action pairs
      sa_key <- paste(s, a, sep = "_")
      if (!(sa_key %in% names(visited_sa))) {
        visited_sa[[sa_key]] <- c(s, a)
      }
      
      # Planning phase with exploration bonuses
      if (length(visited_sa) > 0) {
        for (i in 1:n_planning) {
          # Sample random previously visited state-action pair
          sa_sample <- sample(visited_sa, 1)[[1]]
          s_plan <- sa_sample[1]
          a_plan <- sa_sample[2]
          
          # Get simulated experience from model
          if (!is.na(model_T[s_plan, a_plan])) {
            s_prime_plan <- model_T[s_plan, a_plan]
            r_base <- model_R[s_plan, a_plan]
            
            # Calculate exploration bonus
            time_since_visit <- current_time - timestamps[s_plan, a_plan]
            exploration_bonus <- kappa * sqrt(time_since_visit)
            r_plan <- r_base + exploration_bonus
            
            # Planning update with augmented reward
            Q[s_plan, a_plan] <- Q[s_plan, a_plan] + 
              alpha * (r_plan + gamma * max(Q[s_prime_plan, ]) - Q[s_plan, a_plan])
          }
        }
      }
      
      s <- s_prime
    }
  }
  
  list(Q = Q, policy = apply(Q, 1, which.max), 
       model_T = model_T, model_R = model_R, timestamps = timestamps)
}
```

### Standard Dyna for Comparison

We also implement standard Dyna to highlight the differences:

```r
dyna_q_standard <- function(episodes = 1000, alpha = 0.1, epsilon = 0.1, 
                           n_planning = 5, change_episode = NULL) {
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  model_T <- array(NA, dim = c(n_states, n_actions))
  model_R <- array(NA, dim = c(n_states, n_actions))
  visited_sa <- list()
  
  environment_changed <- FALSE
  
  for (ep in 1:episodes) {
    if (!is.null(change_episode) && ep == change_episode) {
      environment_changed <- TRUE
    }
    
    s <- 1
    
    while (s != terminal_state) {
      # Action selection
      if (runif(1) < epsilon) {
        a <- sample(1:n_actions, 1)
      } else {
        a <- which.max(Q[s, ])
      }
      
      # Take action
      outcome <- sample_env(s, a, modified = environment_changed)
      s_prime <- outcome$s_prime
      r <- outcome$reward
      
      # Direct learning
      Q[s, a] <- Q[s, a] + alpha * (r + gamma * max(Q[s_prime, ]) - Q[s, a])
      
      # Model learning (no timestamp tracking)
      model_T[s, a] <- s_prime
      model_R[s, a] <- r
      
      # Track visited pairs
      sa_key <- paste(s, a, sep = "_")
      if (!(sa_key %in% names(visited_sa))) {
        visited_sa[[sa_key]] <- c(s, a)
      }
      
      # Standard planning (no exploration bonus)
      if (length(visited_sa) > 0) {
        for (i in 1:n_planning) {
          sa_sample <- sample(visited_sa, 1)[[1]]
          s_plan <- sa_sample[1]
          a_plan <- sa_sample[2]
          
          if (!is.na(model_T[s_plan, a_plan])) {
            s_prime_plan <- model_T[s_plan, a_plan]
            r_plan <- model_R[s_plan, a_plan]  # No bonus here
            
            Q[s_plan, a_plan] <- Q[s_plan, a_plan] + 
              alpha * (r_plan + gamma * max(Q[s_prime_plan, ]) - Q[s_plan, a_plan])
          }
        }
      }
      
      s <- s_prime
    }
  }
  
  list(Q = Q, policy = apply(Q, 1, which.max))
}
```

## Experimental Analysis

### Adaptation to Environmental Changes

The most compelling demonstration of Dyna-Q+'s advantages comes from scenarios where the environment changes mid-learning. We'll compare how quickly both algorithms adapt:

```r
# Function to evaluate policy performance
evaluate_policy_performance <- function(Q, episodes = 100, modified = FALSE) {
  total_reward <- 0
  total_steps <- 0
  
  for (ep in 1:episodes) {
    s <- 1
    episode_reward <- 0
    steps <- 0
    
    while (s != terminal_state && steps < 50) {  # Prevent infinite loops
      a <- which.max(Q[s, ])
      outcome <- sample_env(s, a, modified = modified)
      episode_reward <- episode_reward + outcome$reward
      s <- outcome$s_prime
      steps <- steps + 1
    }
    
    total_reward <- total_reward + episode_reward
    total_steps <- total_steps + steps
  }
  
  list(avg_reward = total_reward / episodes, avg_steps = total_steps / episodes)
}

# Comparative experiment with environmental change
adaptation_experiment <- function() {
  set.seed(123)
  n_runs <- 20
  change_point <- 500
  total_episodes <- 1000
  
  # Storage for results
  results <- data.frame(
    episode = rep(1:total_episodes, 2),
    algorithm = rep(c("Dyna-Q", "Dyna-Q+"), each = total_episodes),
    performance = numeric(total_episodes * 2),
    run = rep(1, total_episodes * 2)
  )
  
  for (run in 1:n_runs) {
    # Train both algorithms
    dyna_standard_result <- dyna_q_standard(episodes = total_episodes, 
                                          change_episode = change_point)
    dyna_plus_result <- dyna_q_plus(episodes = total_episodes, 
                                   change_episode = change_point,
                                   kappa = 0.1)
    
    # Evaluate performance at each episode (simplified for illustration)
    for (ep in 1:total_episodes) {
      modified_env <- ep >= change_point
      
      # This is a simplified evaluation - in practice, you'd want to
      # track performance throughout training
      if (ep %% 50 == 0) {
        std_perf <- evaluate_policy_performance(dyna_standard_result$Q, 
                                              episodes = 10, 
                                              modified = modified_env)
        plus_perf <- evaluate_policy_performance(dyna_plus_result$Q, 
                                               episodes = 10, 
                                               modified = modified_env)
        
        # Store results (this is simplified - you'd want better tracking)
        idx_std <- (run - 1) * total_episodes * 2 + ep
        idx_plus <- (run - 1) * total_episodes * 2 + total_episodes + ep
        
        if (run == 1) {  # Just store first run for illustration
          results$performance[ep] <- std_perf$avg_reward
          results$performance[total_episodes + ep] <- plus_perf$avg_reward
        }
      }
    }
  }
  
  return(results)
}
```

### Parameter Sensitivity Analysis

The exploration parameter $\kappa$ significantly influences Dyna-Q+'s behavior. Let's examine its effects:

```r
kappa_sensitivity_analysis <- function() {
  kappa_values <- c(0, 0.01, 0.05, 0.1, 0.2, 0.5)
  change_point <- 300
  total_episodes <- 600
  
  results <- list()
  
  for (i in seq_along(kappa_values)) {
    set.seed(42)  # Consistent conditions
    
    result <- dyna_q_plus(episodes = total_episodes,
                         change_episode = change_point,
                         kappa = kappa_values[i],
                         n_planning = 10)
    
    # Evaluate adaptation speed after change
    pre_change_perf <- evaluate_policy_performance(result$Q, modified = FALSE)
    post_change_perf <- evaluate_policy_performance(result$Q, modified = TRUE)
    
    results[[i]] <- list(
      kappa = kappa_values[i],
      pre_change_reward = pre_change_perf$avg_reward,
      post_change_reward = post_change_perf$avg_reward,
      adaptation_ratio = post_change_perf$avg_reward / pre_change_perf$avg_reward
    )
  }
  
  # Convert to data frame for analysis
  sensitivity_df <- do.call(rbind, lapply(results, function(x) {
    data.frame(kappa = x$kappa,
               pre_change = x$pre_change_reward,
               post_change = x$post_change_reward,
               adaptation = x$adaptation_ratio)
  }))
  
  return(sensitivity_df)
}

# Visualization function
plot_kappa_sensitivity <- function() {
  data <- kappa_sensitivity_analysis()
  
  par(mfrow = c(1, 2))
  
  # Plot 1: Performance vs kappa
  plot(data$kappa, data$post_change, type = "b", pch = 16, col = "darkred",
       xlab = "Kappa Value", ylab = "Post-Change Performance",
       main = "Performance After Environmental Change")
  grid(lty = 2, col = "gray")
  
  # Plot 2: Adaptation ratio vs kappa
  plot(data$kappa, data$adaptation, type = "b", pch = 16, col = "darkblue",
       xlab = "Kappa Value", ylab = "Adaptation Ratio",
       main = "Adaptation Speed vs Exploration Strength")
  grid(lty = 2, col = "gray")
  abline(h = 1, lty = 2, col = "red")  # Reference line
  
  par(mfrow = c(1, 1))
}
```

### Exploration Pattern Analysis

One way to understand Dyna-Q+'s behavior is to examine how exploration bonuses evolve over time:

```r
analyze_exploration_patterns <- function() {
  # Run Dyna-Q+ and track exploration bonuses
  set.seed(123)
  
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  timestamps <- array(0, dim = c(n_states, n_actions))
  visited_sa <- list()
  current_time <- 0
  kappa <- 0.1
  
  # Storage for bonus tracking
  bonus_history <- list()
  time_points <- seq(100, 1000, by = 100)
  
  for (ep in 1:1000) {
    s <- 1
    
    while (s != terminal_state) {
      current_time <- current_time + 1
      
      # Simple action selection for this analysis
      a <- sample(1:n_actions, 1)
      outcome <- sample_env(s, a)
      s_prime <- outcome$s_prime
      
      # Update timestamps
      timestamps[s, a] <- current_time
      
      # Track bonuses at specific time points
      if (current_time %in% time_points) {
        bonuses <- array(0, dim = c(n_states, n_actions))
        for (state in 1:n_states) {
          for (action in 1:n_actions) {
            if (timestamps[state, action] > 0) {
              time_diff <- current_time - timestamps[state, action]
              bonuses[state, action] <- kappa * sqrt(time_diff)
            }
          }
        }
        
        bonus_history[[as.character(current_time)]] <- bonuses
      }
      
      s <- s_prime
    }
  }
  
  return(bonus_history)
}

# Visualization of exploration bonus evolution
plot_bonus_evolution <- function() {
  bonus_data <- analyze_exploration_patterns()
  
  # Extract bonus magnitudes over time
  time_points <- as.numeric(names(bonus_data))
  max_bonuses <- sapply(bonus_data, function(x) max(x, na.rm = TRUE))
  mean_bonuses <- sapply(bonus_data, function(x) mean(x[x > 0], na.rm = TRUE))
  
  plot(time_points, max_bonuses, type = "l", col = "red", lwd = 2,
       xlab = "Time Steps", ylab = "Exploration Bonus Magnitude",
       main = "Evolution of Exploration Bonuses",
       ylim = c(0, max(max_bonuses, na.rm = TRUE)))
  
  lines(time_points, mean_bonuses, col = "blue", lwd = 2, lty = 2)
  
  legend("topright", 
         legend = c("Maximum Bonus", "Average Bonus"),
         col = c("red", "blue"), 
         lty = c(1, 2), 
         lwd = 2)
  
  grid(lty = 2, col = "gray")
}
```

## Discussion

### The Psychology of Artificial Curiosity

Dyna-Q+ embodies a form of artificial curiosity that mirrors aspects of human learning. Just as we become suspicious of information we haven't verified recently, the algorithm systematically doubts its model's accuracy as time passes. This skepticism proves adaptive in changing environments, where yesterday's knowledge might be today's liability.

The square root scaling of the exploration bonus reflects a nuanced understanding of uncertainty. Rather than linearly increasing doubt, the algorithm acknowledges that while confidence should decrease with time, the rate of that decrease should itself decrease. This mathematical choice prevents the system from becoming paralyzed by excessive doubt while maintaining sufficient motivation to revisit old assumptions.

### Computational Implications

The additional bookkeeping required by Dyna-Q+ is minimal—just maintaining timestamps for each state-action pair. However, the conceptual implications run deeper. The algorithm must now balance three competing objectives: exploiting current knowledge, exploring for immediate learning, and re-exploring to maintain model currency. This three-way tension creates richer behavioral dynamics than standard Dyna's simpler explore-exploit dichotomy.

In environments with large state-action spaces, the timestamp storage requirements scale linearly with the size of the space. For continuous or very large discrete spaces, this might necessitate function approximation or selective memory management, where only recently relevant state-action pairs maintain explicit timestamps.

### Performance Characteristics

Our experiments reveal that Dyna-Q+'s advantages become most pronounced in non-stationary environments. In stable conditions, the exploration bonuses for frequently visited states remain small, and performance closely matches standard Dyna. However, when environmental changes occur, Dyna-Q+ typically adapts more quickly, driven by its systematic re-examination of previously learned transitions.

The parameter $\kappa$ serves as a knob controlling the algorithm's anxiety level about its model's accuracy. Small values create a conservative system that trusts its model unless strong evidence suggests otherwise. Large values create a more paranoid system that constantly questions its assumptions. The optimal setting depends critically on the expected rate of environmental change and the cost of exploration versus exploitation errors.

### Limitations and Edge Cases

Dyna-Q+ assumes that environmental changes are the primary reason for model inaccuracy. In environments where the model is simply difficult to learn accurately (due to high stochasticity or complex dynamics), the exploration bonuses might drive excessive exploration without corresponding benefits. The algorithm lacks mechanisms to distinguish between model inaccuracy due to environmental change versus inherent learning difficulty.

The uniform application of exploration bonuses across all state-action pairs may also prove suboptimal. In many environments, certain regions might be more prone to change than others, or the consequences of outdated information might vary dramatically across the state space. More sophisticated versions might weight exploration bonuses based on the strategic importance or change probability of different state-action pairs.

### Extensions and Modern Perspectives

Contemporary research has extended the core insights of Dyna-Q+ in several directions. Uncertainty-based exploration methods in deep reinforcement learning often incorporate similar principles, using neural network uncertainty estimates to drive exploration rather than simple timestamp-based bonuses. Meta-learning approaches attempt to learn optimal exploration strategies for families of related environments.

The relationship between Dyna-Q+ and modern curiosity-driven learning deserves particular attention. While Dyna-Q+ focuses on temporal curiosity (doubting old information), recent work explores intrinsic motivation based on prediction errors, information gain, or state visitation counts. These approaches share the fundamental insight that learning systems should actively seek information that improves their understanding of the world.

## Implementation Considerations

### Real-world Applications

Dyna-Q+ proves particularly valuable in domains where environmental dynamics evolve gradually rather than changing abruptly. Financial trading, where market conditions shift over time, represents one such application. Robot navigation in environments where obstacles occasionally move provides another example. The algorithm's systematic skepticism about outdated information aligns well with these domains' requirements.

However, the approach may be less suitable for environments with very rapid changes or completely random dynamics. In such cases, the exploration bonuses might not provide sufficient time to detect and adapt to changes, or the changes might be so frequent that maintaining any model becomes counterproductive.

### Hyperparameter Guidelines

Practitioners implementing Dyna-Q+ often start with $\kappa$ values between 0.01 and 0.1, adjusting based on empirical performance. The optimal value typically correlates with the expected frequency of environmental changes: more volatile environments benefit from larger $\kappa$ values, while stable environments work well with smaller values.

The number of planning steps $n$ interacts with $\kappa$ in interesting ways. Larger $n$ values amplify the effects of exploration bonuses, as more planning updates occur with augmented rewards. This interaction suggests that $\kappa$ might need downward adjustment when increasing $n$, though the exact relationship depends on specific problem characteristics.

### Memory and Computational Efficiency

For large-scale applications, the timestamp storage requirements might necessitate approximations. Techniques like temporal sampling (maintaining timestamps for only a subset of state-action pairs) or temporal binning (grouping time into discrete bins rather than maintaining exact timestamps) can reduce memory requirements while preserving much of the algorithm's adaptive behavior.

The computational overhead of calculating exploration bonuses during planning is typically minimal compared to the value function updates themselves. However, in time-critical applications, the square root calculations might be approximated with lookup tables or simplified functions.

## Conclusion

Dyna-Q+ represents a elegant solution to a fundamental challenge in reinforcement learning: how to maintain confidence in learned models while remaining appropriately skeptical about their continued accuracy. By treating time as information and systematically rewarding curiosity about neglected state-action pairs, the algorithm achieves a sophisticated balance between stability and adaptability.

The approach's strength lies not just in its technical effectiveness but in its conceptual clarity. The idea that confidence should decay over time unless refreshed by recent experience resonates across many domains beyond reinforcement learning. This principle finds echoes in human psychology, scientific methodology, and even social institutions that require periodic validation of their foundational assumptions.

While modern deep reinforcement learning has developed more sophisticated approaches to uncertainty and exploration, Dyna-Q+'s core insights remain relevant. The tension between trusting learned models and maintaining healthy skepticism about their accuracy continues to challenge contemporary algorithms. In an era of rapidly changing environments and non-stationary dynamics, the principle of time-decaying confidence may prove even more valuable than when originally proposed.

Looking forward, the integration of Dyna-Q+'s temporal curiosity with modern uncertainty estimation techniques presents intriguing possibilities. Neural networks that maintain both predictive models and confidence estimates could incorporate exploration bonuses based on both temporal factors and model uncertainty, potentially creating more robust and adaptive learning systems.

The simplicity of Dyna-Q+'s modification to standard Dyna—just adding a single term to the planning rewards—belies its conceptual sophistication. Sometimes the most profound advances in artificial intelligence come not from complex new architectures but from simple changes that embody deep insights about learning, adaptation, and the nature of knowledge itself.
