
## High-Level Plan

1. Encode state-action pairs into features (as before).
2. Use a **Random Forest Regressor** (`randomForest` package) to learn Q(s, a).
3. Train on the TD target:

   $$
   Q(s, a) \leftarrow r + \gamma \max_{a'} Q(s', a')
   $$
4. Use the trained model for action selection (ε-greedy).
5. Learn/update Q-function incrementally by re-fitting the model.

---

## 📦 Prerequisites

```{r}
install.packages("randomForest")  # Only once
library(randomForest)
```

---

## 🧩 Step-by-Step in Cells

### 🛠️ Step 1: Feature Encoding

```{r}
encode_features <- function(s, a, n_states, n_actions) {
  state_vec <- rep(0, n_states)
  action_vec <- rep(0, n_actions)
  state_vec[s] <- 1
  action_vec[a] <- 1
  return(c(state_vec, action_vec))
}

n_features <- n_states + n_actions
```

---

### 📦 Step 2: Setup Data Storage for Learning

```{r}
rf_data_x <- matrix(nrow = 0, ncol = n_features)
rf_data_y <- numeric(0)
rf_model <- NULL
```

---

### 🔁 Step 3: Q-Learning Loop with Random Forest Regressor

```{r}
library(randomForest)

q_learning_rf <- function(episodes = 1000, epsilon = 0.1) {
  rf_data_x <<- matrix(nrow = 0, ncol = n_features)
  rf_data_y <<- numeric(0)

  for (ep in 1:episodes) {
    s <- 1
    while (TRUE) {
      # Predict Q-values
      q_preds <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        if (!is.null(rf_model)) {
          predict(rf_model, as.data.frame(t(x)))
        } else {
          runif(1)
        }
      })

      # Epsilon-greedy action selection
      a <- if (runif(1) < epsilon) sample(1:n_actions, 1) else which.max(q_preds)

      # Step in environment
      out <- sample_env(s, a)
      s_prime <- out$s_prime
      r <- out$reward

      # Estimate TD target
      q_next <- if (s_prime == terminal_state) 0 else {
        max(sapply(1:n_actions, function(a_) {
          x_next <- encode_features(s_prime, a_, n_states, n_actions)
          if (!is.null(rf_model)) predict(rf_model, as.data.frame(t(x_next))) else 0
        }))
      }
      target <- r + gamma * q_next

      # Add training example
      x <- encode_features(s, a, n_states, n_actions)
      rf_data_x <<- rbind(rf_data_x, x)
      rf_data_y <<- c(rf_data_y, target)

      # Train or update the random forest
      if (nrow(rf_data_x) >= 50 && ep %% 10 == 0) {
        rf_model <<- randomForest(
          x = as.data.frame(rf_data_x),
          y = rf_data_y,
          ntree = 100,
          nodesize = 5
        )
      }

      if (s_prime == terminal_state) break
      s <- s_prime
    }
  }
}
```

---

### 📜 Step 4: Derive Policy from Trained Random Forest

```{r}
get_policy_from_rf <- function() {
  sapply(1:n_states, function(s) {
    q_vals <- sapply(1:n_actions, function(a) {
      x <- encode_features(s, a, n_states, n_actions)
      predict(rf_model, as.data.frame(t(x)))
    })
    which.max(q_vals)
  })
}
```

---

### ▶️ Step 5: Train and Visualize Learned Policy

```{r}
q_learning_rf(episodes = 1000)
rf_policy <- get_policy_from_rf()

barplot(rf_policy, names.arg = 1:n_states,
        col = "forestgreen", ylim = c(0, 3),
        main = "Q-Learning with Random Forest Approximation",
        ylab = "Action (1 = A1, 2 = A2)")
abline(h = 1.5, lty = 2, col = "gray")
```

---

## 🧠 Psychological Insights

* Random forests support **instance-based**, **local generalization**, echoing **episodic reinforcement**.
* Unlike tabular methods, they **scale** and **learn patterns** across similar states.
* More interpretable than neural nets (you can inspect trees!).



