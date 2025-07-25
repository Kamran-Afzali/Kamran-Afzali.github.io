

# Beyond Linear Models: Q-Learning with Random Forest Function Approximation in R

## Introduction

While linear function approximation provides a solid foundation for scaling reinforcement learning beyond tabular methods, it assumes a linear relationship between features and Q-values. Real-world problems often exhibit complex, non-linear patterns that linear models cannot capture effectively. This post extends our previous exploration by implementing Q-Learning with Random Forest function approximation, demonstrating how ensemble methods can learn intricate state-action value relationships while maintaining interpretability and robust generalization.

Random Forests offer several advantages over linear approximation: they handle non-linear relationships naturally, provide built-in feature importance measures, resist overfitting through ensemble averaging, and require minimal hyperparameter tuning. We'll implement this approach using the same 10-state, 2-action environment, comparing the learned policies and examining the unique characteristics of tree-based function approximation.

## Theoretical Background

Random Forest function approximation replaces the linear parameterization with an ensemble of decision trees. Instead of:

$$
Q(s, a; \theta) = \phi(s, a)^T \theta
$$

we now approximate the action-value function as:

$$
Q(s, a) = \frac{1}{B} \sum_{b=1}^{B} T_b(\phi(s, a))
$$

where $T_b$ represents the $b$-th tree in the ensemble, $B$ is the number of trees, and $\phi(s, a)$ is our feature representation. Each tree $T_b$ is trained on a bootstrap sample of the data with random feature subsets at each split, providing natural regularization and variance reduction.

### Q-Learning with Random Forest Approximation

The Q-Learning update process with Random Forest approximation involves:

1. **Experience Collection**: Gather state-action-reward-next state tuples $(s, a, r, s')$
2. **Target Computation**: Calculate TD targets $y = r + \gamma \max_{a'} Q(s', a')$
3. **Model Training**: Fit Random Forest regressor to predict $Q(s, a)$ from features $\phi(s, a)$
4. **Policy Update**: Use updated model for epsilon-greedy action selection

Unlike linear methods with continuous parameter updates, Random Forest approximation requires periodic model retraining on accumulated experience. This batch-like approach trades computational efficiency for modeling flexibility.

### Feature Engineering for Tree-Based Models

For our implementation, we use a simple concatenation of one-hot encoded state and action vectors:

$$
\phi(s, a) = [e_s^{(state)} \; || \; e_a^{(action)}]
$$

where $e_s^{(state)}$ is a one-hot vector for state $s$ and $e_a^{(action)}$ is a one-hot vector for action $a$. This encoding allows trees to learn complex interactions between states and actions while maintaining interpretability.

### Comparison with Previous Methods

| **Aspect** | **Tabular Q-Learning** | **Linear Function Approximation** | **Random Forest Function Approximation** |
|------------|------------------------|-----------------------------------|------------------------------------------|
| **Model Complexity** | None; direct storage | Linear combinations | Non-linear ensemble |
| **Feature Interactions** | Implicit | None (unless engineered) | Automatic discovery |
| **Interpretability** | Full | Moderate (weights) | High (tree structures) |
| **Training** | Online updates | Gradient descent | Batch retraining |
| **Overfitting Risk** | None | Low | Low (ensemble averaging) |
| **Computational Cost** | $O(1)$ lookup | $O(d)$ linear algebra | $O(B \cdot \log n)$ prediction |

## R Implementation

Our implementation builds upon the previous environment while introducing Random Forest-based Q-value approximation. The key innovation lies in accumulating training examples and periodically retraining the forest to incorporate new experience.

```r
# Load required libraries
library(randomForest)
library(ggplot2)

# Environment setup (same as previous implementation)
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

# Feature encoding for Random Forest
encode_features <- function(s, a, n_states, n_actions) {
  state_vec <- rep(0, n_states)
  action_vec <- rep(0, n_actions)
  state_vec[s] <- 1
  action_vec[a] <- 1
  return(c(state_vec, action_vec))
}

n_features <- n_states + n_actions

# Q-Learning with Random Forest function approximation
q_learning_rf <- function(episodes = 1000, epsilon = 0.1, retrain_freq = 10, min_samples = 50) {
  # Initialize training data storage
  rf_data_x <- matrix(nrow = 0, ncol = n_features)
  rf_data_y <- numeric(0)
  rf_model <- NULL
  rewards <- numeric(episodes)
  
  for (ep in 1:episodes) {
    s <- sample(1:(n_states - 1), 1)  # Start from non-terminal state
    episode_reward <- 0
    
    while (TRUE) {
      # Predict Q-values for all actions
      q_preds <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        if (!is.null(rf_model)) {
          predict(rf_model, as.data.frame(t(x)))
        } else {
          runif(1)  # Random initialization
        }
      })
      
      # Epsilon-greedy action selection
      a <- if (runif(1) < epsilon) {
        sample(1:n_actions, 1)
      } else {
        which.max(q_preds)
      }
      
      # Take action and observe outcome
      out <- sample_env(s, a)
      s_prime <- out$s_prime
      r <- out$reward
      episode_reward <- episode_reward + r
      
      # Compute TD target
      q_next <- if (s_prime == terminal_state) {
        0
      } else {
        max(sapply(1:n_actions, function(a_) {
          x_next <- encode_features(s_prime, a_, n_states, n_actions)
          if (!is.null(rf_model)) {
            predict(rf_model, as.data.frame(t(x_next)))
          } else {
            0
          }
        }))
      }
      
      target <- r + gamma * q_next
      
      # Store training example
      x <- encode_features(s, a, n_states, n_actions)
      rf_data_x <- rbind(rf_data_x, x)
      rf_data_y <- c(rf_data_y, target)
      
      # Retrain Random Forest periodically
      if (nrow(rf_data_x) >= min_samples && ep %% retrain_freq == 0) {
        rf_model <- randomForest(
          x = as.data.frame(rf_data_x),
          y = rf_data_y,
          ntree = 100,
          nodesize = 5,
          mtry = max(1, floor(n_features / 3))
        )
      }
      
      if (s_prime == terminal_state) break
      s <- s_prime
    }
    
    rewards[ep] <- episode_reward
  }
  
  # Derive final policy
  policy <- sapply(1:(n_states-1), function(s) {
    if (!is.null(rf_model)) {
      q_vals <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        predict(rf_model, as.data.frame(t(x)))
      })
      which.max(q_vals)
    } else {
      1  # Default action
    }
  })
  
  list(model = rf_model, policy = c(policy, NA), rewards = rewards, 
       training_data = list(x = rf_data_x, y = rf_data_y))
}

# Run Q-Learning with Random Forest approximation
set.seed(42)
rf_result <- q_learning_rf(episodes = 1000, epsilon = 0.1, retrain_freq = 10)
rf_policy <- rf_result$policy
rf_rewards <- rf_result$rewards

# Create policy visualization
policy_df <- data.frame(
  State = 1:n_states,
  Policy = rf_policy,
  Algorithm = "Q-Learning RF"
)

policy_plot_rf <- ggplot(policy_df[1:(n_states-1), ], aes(x = State, y = Policy)) +
  geom_point(size = 4, color = "forestgreen") +
  geom_line(color = "forestgreen", linewidth = 1) +
  theme_minimal() +
  labs(
    title = "Policy from Q-Learning with Random Forest Approximation",
    x = "State", 
    y = "Action"
  ) +
  scale_x_continuous(breaks = 1:n_states) +
  scale_y_continuous(breaks = 1:n_actions, labels = c("Action 1", "Action 2"), limits = c(0.5, 2.5)) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

# Compare cumulative rewards with moving average
rewards_smooth <- numeric(length(rf_rewards))
window_size <- 50
for (i in 1:length(rf_rewards)) {
  start_idx <- max(1, i - window_size + 1)
  rewards_smooth[i] <- mean(rf_rewards[start_idx:i])
}

reward_df_rf <- data.frame(
  Episode = 1:1000,
  Reward = rewards_smooth,
  Algorithm = "Q-Learning RF"
)

reward_plot_rf <- ggplot(reward_df_rf, aes(x = Episode, y = Reward)) +
  geom_line(color = "forestgreen", linewidth = 1) +
  theme_minimal() +
  labs(
    title = "Learning Curve: Q-Learning with Random Forest (50-episode moving average)",
    x = "Episode",
    y = "Average Reward"
  ) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

# Display plots
print(policy_plot_rf)
print(reward_plot_rf)

# Feature importance analysis
if (!is.null(rf_result$model)) {
  importance_df <- data.frame(
    Feature = c(paste("State", 1:n_states), paste("Action", 1:n_actions)),
    Importance = importance(rf_result$model)[, 1]
  )
  
  importance_plot <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_col(fill = "forestgreen", alpha = 0.7) +
    coord_flip() +
    theme_minimal() +
    labs(
      title = "Feature Importance in Random Forest Q-Function",
      x = "Feature",
      y = "Importance (Mean Decrease in MSE)"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  print(importance_plot)
}

# Model diagnostics
cat("Random Forest Model Summary:\n")
cat("Number of trees:", rf_result$model$ntree, "\n")
cat("Training examples:", nrow(rf_result$training_data$x), "\n")
cat("Final OOB error:", tail(rf_result$model$mse, 1), "\n")
```

## Analysis and Insights

### Policy Learning Characteristics

Random Forest function approximation exhibits several characteristics that distinguish it from linear methods. Trees can capture non-linear decision boundaries, enabling the model to learn state-action relationships that linear approaches cannot represent. The random feature sampling at each split performs automatic feature selection, focusing computational resources on the most informative variables. Ensemble averaging across multiple trees reduces overfitting and provides stable predictions across different training samples. Individual trees maintain interpretable decision paths that show how Q-values are estimated for specific state-action pairs.

### Computational Considerations

The batch retraining approach creates distinct computational trade-offs that affect implementation decisions. Training frequency must balance responsiveness against computational cost, as more frequent updates improve adaptation but require additional processing time. Trees need sufficient data to learn meaningful patterns, which can slow initial learning compared to methods that update continuously. Memory requirements increase over time as training examples accumulate, requiring careful management of historical data.

### Feature Importance Insights

Random Forest methods naturally generate feature importance measures that reveal which states and actions most influence Q-value predictions. This interpretability provides diagnostic capabilities for understanding learning issues and analyzing policy decisions. The feature ranking can guide state representation choices and help identify redundant or irrelevant variables in the problem formulation.

### Practical Implications

Random Forest function approximation occupies a position between simple linear models and neural networks in terms of complexity and capability. The method handles larger state spaces more effectively than tabular approaches while remaining computationally tractable. It captures non-linear patterns without requiring extensive feature engineering or domain expertise. The approach shows less sensitivity to hyperparameter choices compared to neural networks while maintaining stability across different problem instances. The inherent interpretability provides insights into the decision-making process that can be valuable for debugging and analysis.

## Comparison with Linear Approximation

Random Forest methods demonstrate several advantages and trade-offs when compared to linear function approximation. The tree-based approach excels at pattern recognition, learning state-action relationships that linear models cannot capture due to their representational limitations. However, initial learning proceeds more slowly as trees require sufficient data to construct meaningful decision boundaries. Computational costs are higher due to periodic retraining requirements, contrasting with the continuous gradient updates used in linear methods. Generalization performance tends to be superior, as ensemble averaging provides natural regularization that reduces overfitting tendencies.

## Conclusion

Random Forest function approximation extends linear methods by offering enhanced modeling flexibility while preserving interpretability characteristics. The approach performs particularly well in environments with non-linear state-action relationships and provides regularization through ensemble averaging.

Several key observations emerge from this analysis. Non-linear function approximation can capture patterns that linear models miss, enabling better policy learning in complex environments. Batch learning approaches require careful consideration of training frequency and sample requirements to balance performance with computational efficiency. Feature importance analysis provides insights into learned policies that can guide problem formulation and debugging efforts. Tree-based methods offer an interpretable alternative to neural network approaches while maintaining theoretical foundations.

This exploration demonstrates how ensemble methods can enhance reinforcement learning without abandoning the established principles of Q-Learning. Future work could investigate online tree learning algorithms that avoid batch retraining requirements, adaptive schedules that optimize training frequency based on performance metrics, or hybrid approaches that combine strengths from different function approximation methods.
