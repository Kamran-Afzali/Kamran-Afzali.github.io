---
editor_options: 
  markdown: 
    wrap: 72
---

# Deep Function Approximation: Q-Learning with Neural Networks in R

## Introduction

Our exploration of function approximation in reinforcement learning has progressed from linear models to ensemble methods, each offering increasing sophistication in capturing complex relationships between states, actions, and their values. Neural networks represent the natural next step in this evolution, providing the theoretical foundation for modern deep reinforcement learning while maintaining practical implementability in R.

Neural network function approximation transcends the limitations of both linear models and tree-based methods by learning hierarchical feature representations automatically. Where linear models assume additive relationships and Random Forests rely on axis-aligned splits, neural networks can discover arbitrary non-linear transformations of the input space. This capability proves particularly valuable in reinforcement learning, where the optimal action-value function often exhibits complex dependencies that resist simple parametric forms.

This post demonstrates Q-Learning with neural network function approximation using R's `nnet` package, continuing our 10-state environment while examining how artificial neural networks learn Q-value approximations. We explore the theoretical foundations, implementation challenges, and practical considerations that distinguish neural network approaches from their predecessors.

## Theoretical Foundation

Neural network function approximation replaces our previous parameterizations with a multi-layered composition of non-linear transformations. The action-value function becomes:

$$
Q(s, a; \theta) = f_L(W_L f_{L-1}(W_{L-1} \cdots f_1(W_1 \phi(s, a) + b_1) \cdots + b_{L-1}) + b_L)
$$

where $f_i$ represents the activation function at layer $i$, $W_i$ and $b_i$ are weight matrices and bias vectors, and $\theta = \{W_1, b_1, \ldots, W_L, b_L\}$ encompasses all trainable parameters. This hierarchical structure enables the network to learn increasingly abstract representations of the state-action space.

### Universal Approximation and Expressivity

The theoretical appeal of neural networks stems from universal approximation theorems, which guarantee that feedforward networks with sufficient hidden units can approximate any continuous function to arbitrary precision. In the context of Q-Learning, this suggests that neural networks can, in principle, represent any action-value function arising from a Markov decision process.

For our implementation, we employ a single hidden layer architecture with sigmoid activation functions:

$$
Q(s, a; \theta) = W_2 \sigma(W_1 \phi(s, a) + b_1) + b_2
$$

where $\sigma(z) = \frac{1}{1 + e^{-z}}$ is the sigmoid function, providing the non-linearity necessary for complex function approximation.

### Gradient-Based Learning

Neural network training relies on backpropagation to compute gradients of the temporal difference error with respect to all network parameters. The loss function for a single transition becomes:

$$
L(\theta) = \frac{1}{2}(y - Q(s, a; \theta))^2
$$

where $y = r + \gamma \max_{a'} Q(s', a'; \theta)$ is the TD target. The gradient with respect to parameters $\theta$ follows the chain rule:

$$
\nabla_\theta L(\theta) = (Q(s, a; \theta) - y) \nabla_\theta Q(s, a; \theta)
$$

This gradient guides parameter updates through standard optimization algorithms, though the non-convex nature of neural network loss surfaces introduces challenges absent in linear approximation.

### Comparison with Previous Approaches

Neural networks offer several theoretical advantages over linear and tree-based methods. Unlike linear approximation, they can learn feature interactions without explicit engineering. Unlike Random Forests, they provide smooth function approximations suitable for gradient-based optimization. However, this flexibility comes with increased computational complexity and potential instability during training.

| **Characteristic** | **Linear Approximation** | **Random Forest** | **Neural Network** |
|------------------|-------------------------|-------------------|-------------------|
| **Function Class** | Linear combinations | Piecewise constant | Universal approximators |
| **Feature Learning** | None | Implicit via splits | Explicit representation learning |
| **Optimization** | Convex (guaranteed convergence) | Non-parametric | Non-convex (local minima) |
| **Interpretability** | High (weight inspection) | Moderate (tree visualization) | Low (distributed representations) |
| **Sample Efficiency** | High | Moderate | Variable (depends on architecture) |

## R Implementation

Our neural network implementation builds upon the established environment while introducing the complexities of gradient-based optimization and network training. The `nnet` package provides a lightweight implementation suitable for demonstrating core concepts without the overhead of deep learning frameworks.

```r
# Load required libraries
library(nnet)
library(ggplot2)

# Environment setup (consistent with previous implementations)
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

# Feature encoding for neural network input
encode_features <- function(s, a, n_states, n_actions) {
  state_vec <- rep(0, n_states)
  action_vec <- rep(0, n_actions)
  state_vec[s] <- 1
  action_vec[a] <- 1
  return(c(state_vec, action_vec))
}

n_features <- n_states + n_actions

# Q-Learning with neural network function approximation
q_learning_nn <- function(episodes = 1000, epsilon = 0.1, hidden_size = 10, 
                          retrain_freq = 10, min_samples = 50) {
  # Initialize training data storage
  q_data_x <- matrix(nrow = 0, ncol = n_features)
  q_data_y <- numeric(0)
  q_model <- NULL
  rewards <- numeric(episodes)
  training_losses <- numeric()
  
  for (ep in 1:episodes) {
    s <- sample(1:(n_states - 1), 1)  # Start from non-terminal state
    episode_reward <- 0
    
    while (TRUE) {
      # Predict Q-values for all actions
      q_preds <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        if (!is.null(q_model)) {
          as.numeric(predict(q_model, as.data.frame(t(x))))
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
          if (!is.null(q_model)) {
            as.numeric(predict(q_model, as.data.frame(t(x_next))))
          } else {
            0
          }
        }))
      }
      
      target <- r + gamma * q_next
      
      # Store training example
      x <- encode_features(s, a, n_states, n_actions)
      q_data_x <- rbind(q_data_x, x)
      q_data_y <- c(q_data_y, target)
      
      # Train neural network periodically
      if (nrow(q_data_x) >= min_samples && ep %% retrain_freq == 0) {
        # Suppress nnet output for cleaner execution
        capture.output({
          q_model <- nnet(
            x = q_data_x,
            y = q_data_y,
            size = hidden_size,
            linout = TRUE,
            maxit = 100,
            decay = 0.01,
            trace = FALSE
          )
        })
        
        # Track training loss
        if (!is.null(q_model)) {
          predictions <- predict(q_model, as.data.frame(q_data_x))
          mse <- mean((predictions - q_data_y)^2)
          training_losses <- c(training_losses, mse)
        }
      }
      
      if (s_prime == terminal_state) break
      s <- s_prime
    }
    
    rewards[ep] <- episode_reward
  }
  
  # Derive final policy
  policy <- sapply(1:(n_states-1), function(s) {
    if (!is.null(q_model)) {
      q_vals <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        as.numeric(predict(q_model, as.data.frame(t(x))))
      })
      which.max(q_vals)
    } else {
      1  # Default action
    }
  })
  
  list(model = q_model, policy = c(policy, NA), rewards = rewards,
       training_losses = training_losses,
       training_data = list(x = q_data_x, y = q_data_y))
}

# Run Q-Learning with neural network approximation
set.seed(42)
nn_result <- q_learning_nn(episodes = 1000, epsilon = 0.1, hidden_size = 10)
nn_policy <- nn_result$policy
nn_rewards <- nn_result$rewards

# Visualize learned policy
policy_df <- data.frame(
  State = 1:n_states,
  Policy = nn_policy,
  Algorithm = "Q-Learning NN"
)

policy_plot_nn <- ggplot(policy_df[1:(n_states-1), ], aes(x = State, y = Policy)) +
  geom_point(size = 4, color = "coral") +
  geom_line(color = "coral", linewidth = 1) +
  theme_minimal() +
  labs(
    title = "Policy from Q-Learning with Neural Network Approximation",
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

# Learning curve with smoothing
rewards_smooth <- numeric(length(nn_rewards))
window_size <- 50
for (i in 1:length(nn_rewards)) {
  start_idx <- max(1, i - window_size + 1)
  rewards_smooth[i] <- mean(nn_rewards[start_idx:i])
}

reward_df_nn <- data.frame(
  Episode = 1:1000,
  Reward = rewards_smooth,
  Algorithm = "Q-Learning NN"
)

reward_plot_nn <- ggplot(reward_df_nn, aes(x = Episode, y = Reward)) +
  geom_line(color = "coral", linewidth = 1) +
  theme_minimal() +
  labs(
    title = "Learning Curve: Q-Learning with Neural Network (50-episode moving average)",
    x = "Episode",
    y = "Average Reward"
  ) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10)
  )

# Training loss evolution
if (length(nn_result$training_losses) > 0) {
  loss_df <- data.frame(
    Update = 1:length(nn_result$training_losses),
    Loss = nn_result$training_losses
  )
  
  loss_plot <- ggplot(loss_df, aes(x = Update, y = Loss)) +
    geom_line(color = "darkred", linewidth = 1) +
    theme_minimal() +
    labs(
      title = "Neural Network Training Loss Evolution",
      x = "Training Update",
      y = "Mean Squared Error"
    ) +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10)
    )
  
  print(loss_plot)
}

# Display main plots
print(policy_plot_nn)
print(reward_plot_nn)

# Model diagnostics and analysis
if (!is.null(nn_result$model)) {
  cat("Neural Network Model Summary:\n")
  cat("Architecture: Input(", n_features, ") -> Hidden(", nn_result$model$n[2], ") -> Output(1)\n")
  cat("Total parameters:", length(nn_result$model$wts), "\n")
  cat("Training examples:", nrow(nn_result$training_data$x), "\n")
  cat("Final training loss:", tail(nn_result$training_losses, 1), "\n")
  
  # Weight analysis
  weights <- nn_result$model$wts
  cat("Weight statistics:\n")
  cat("Mean:", round(mean(weights), 4), "\n")
  cat("Standard deviation:", round(sd(weights), 4), "\n")
  cat("Range: [", round(min(weights), 4), ",", round(max(weights), 4), "]\n")
}
```

## Analysis and Interpretation

### Learning Dynamics

Neural network function approximation introduces several unique characteristics compared to linear and tree-based methods. The non-convex optimization landscape means that training can exhibit complex dynamics, including periods of rapid improvement followed by plateaus. The learning curve often shows more volatility than linear methods due to the continuous parameter updates and potential for local minima.

### Function Representation

Unlike Random Forests that learn piecewise constant approximations, neural networks produce smooth function approximations. This continuity can be advantageous for policy learning, as small changes in state typically result in small changes in Q-values. The hidden layer learns intermediate representations that capture relevant features for action-value estimation.

### Generalization Properties

Neural networks excel at discovering relevant patterns in the state-action space without explicit feature engineering. The hidden units automatically learn combinations of input features that prove useful for Q-value prediction. This automatic feature discovery becomes increasingly valuable as problem complexity grows.

### Training Stability

The batch retraining approach helps stabilize learning compared to online neural network updates, which can suffer from catastrophic forgetting. However, the periodic retraining introduces discontinuities in the learned function that can temporarily disrupt policy performance.

## Practical Considerations

### Architecture Selection

The choice of network architecture significantly impacts performance. Too few hidden units may underfit the true Q-function, while too many can lead to overfitting with limited training data. Our single hidden layer with 10 units provides a reasonable balance for the 10-state environment.

### Training Frequency

The retraining frequency presents a trade-off between computational efficiency and learning responsiveness. More frequent retraining provides better adaptation to new experience but increases computational cost. The optimal frequency depends on the environment complexity and available computational resources.

### Regularization

Neural networks benefit from regularization techniques to prevent overfitting. Our implementation includes weight decay (L2 regularization) to encourage smaller weights and improve generalization. Other techniques like dropout or early stopping could further enhance performance.

### Initialization and Convergence

Neural network training depends critically on weight initialization and optimization parameters. Poor initialization can trap the network in suboptimal local minima, while inappropriate learning rates can cause divergence or slow convergence.

## Comparison Across Function Approximation Methods

Our progression from tabular to linear to ensemble to neural network methods illustrates the evolution of function approximation in reinforcement learning. Each method offers distinct advantages for different problem characteristics.

Tabular methods provide exact representation but fail to scale. Linear methods offer guaranteed convergence and interpretability but assume additive relationships. Random Forests handle non-linearities while maintaining interpretability but produce discontinuous approximations. Neural networks provide universal approximation capabilities and smooth functions but introduce optimization challenges and reduced interpretability.

The choice among methods depends on problem requirements, available data, computational constraints, and interpretability needs. Neural networks shine when function complexity exceeds simpler methods' capabilities and sufficient training data is available.

## Future Directions

This exploration establishes the foundation for more advanced neural network approaches in reinforcement learning. Extensions could include deeper architectures, convolutional networks for spatial problems, recurrent networks for partially observable environments, or modern techniques like attention mechanisms.

The theoretical framework developed here scales naturally to these more complex architectures, with the core principles of temporal difference learning and gradient-based optimization remaining constant while the function approximation capabilities expand dramatically.

## Conclusion

Neural network function approximation represents a significant step toward the sophisticated methods underlying modern deep reinforcement learning. While maintaining the theoretical foundations of Q-Learning, neural networks provide the flexibility to tackle complex environments that challenge simpler approximation methods.

The implementation demonstrates how classical reinforcement learning principles extend naturally to neural network settings, preserving core algorithmic structure while enhancing representational power. This foundation enables practitioners to understand and implement more advanced methods building on these fundamental concepts.

The journey through different function approximation approaches reveals the rich landscape of reinforcement learning methods, each contributing unique insights and capabilities. Neural networks, as universal approximators, provide the theoretical and practical foundation for tackling increasingly complex decision-making problems across diverse domains.
