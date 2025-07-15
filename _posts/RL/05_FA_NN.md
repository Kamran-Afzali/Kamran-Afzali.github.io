Great — now we're moving into **nonlinear function approximation** using **machine learning models** (e.g., neural networks, decision trees) to estimate $Q(s, a; \theta)$.

This is more powerful than linear approximators, allowing:

* **Feature interactions**
* **Nonlinear effects**
* More realistic modeling of psychological generalization

We’ll use **`nnet`** (a small neural network) to approximate Q-values for `(state, action)` pairs.

---

## 🔄 Overview of Approach

1. **Feature construction**: State-action pairs as input features.
2. **ML model**: Train a **neural net** to predict Q-values.
3. **Epsilon-greedy** policy based on predicted Q-values.
4. **Train via stochastic updates** using TD-error.

---

## 📦 Requirements

We'll use base R + `nnet`:

```{r}
install.packages("nnet")  # Only once
library(nnet)
```

---

## 🧩 Step-by-Step in Cells

### 🛠️ Step 1: Feature Encoding (with interaction potential)

Use one-hot encoding for state and action — nonlinear models can learn interactions implicitly.

```{r}
# One-hot encode state and action
encode_features <- function(s, a, n_states, n_actions) {
  state_vec <- rep(0, n_states)
  action_vec <- rep(0, n_actions)
  state_vec[s] <- 1
  action_vec[a] <- 1
  return(c(state_vec, action_vec))
}

n_features <- n_states + n_actions  # input size for neural net
```

---

### 🧠 Step 2: Neural Network Q-function Approximator

We train a small neural net to approximate Q-values.

```{r}
# Initialize training data
q_data <- data.frame()
q_data_x <- NULL
q_data_y <- NULL

# Placeholder model (retrained each time)
q_model <- NULL
```

---

### 🔁 Step 3: Q-Learning Loop with Online Neural Network Updates

```{r}
library(nnet)

q_learning_nn <- function(episodes = 1000, alpha = 0.01, epsilon = 0.1) {
  q_data_x <<- matrix(nrow = 0, ncol = n_features)
  q_data_y <<- numeric(0)

  for (ep in 1:episodes) {
    s <- 1
    while (TRUE) {
      # Predict Q-values for all actions
      q_preds <- sapply(1:n_actions, function(a) {
        x <- encode_features(s, a, n_states, n_actions)
        if (!is.null(q_model)) {
          predict(q_model, as.data.frame(t(x)))
        } else {
          runif(1)
        }
      })

      # Epsilon-greedy action selection
      a <- if (runif(1) < epsilon) sample(1:n_actions, 1) else which.max(q_preds)
      
      out <- sample_env(s, a)
      s_prime <- out$s_prime
      r <- out$reward

      # Estimate target: r + gamma * max Q(s', a')
      q_next <- if (s_prime == terminal_state) 0 else {
        max(sapply(1:n_actions, function(a_) {
          x_next <- encode_features(s_prime, a_, n_states, n_actions)
          if (!is.null(q_model)) predict(q_model, as.data.frame(t(x_next))) else 0
        }))
      }
      target <- r + gamma * q_next
      
      # Store training data (s, a) → target
      x <- encode_features(s, a, n_states, n_actions)
      q_data_x <<- rbind(q_data_x, x)
      q_data_y <<- c(q_data_y, target)
      
      # Train/update neural net
      if (nrow(q_data_x) >= 50 && ep %% 10 == 0) {
        q_model <<- nnet(
          x = q_data_x,
          y = q_data_y,
          size = 10, linout = TRUE, maxit = 50, trace = FALSE
        )
      }

      if (s_prime == terminal_state) break
      s <- s_prime
    }
  }
}
```

---

### 📜 Step 4: Derive Policy from Trained Model

```{r}
# Derive greedy policy from trained model
get_policy_from_nn <- function() {
  sapply(1:n_states, function(s) {
    q_vals <- sapply(1:n_actions, function(a) {
      x <- encode_features(s, a, n_states, n_actions)
      predict(q_model, as.data.frame(t(x)))
    })
    which.max(q_vals)
  })
}
```

---

### ▶️ Step 5: Run and Visualize

```{r}
q_learning_nn(episodes = 1000)
nn_policy <- get_policy_from_nn()

barplot(nn_policy, names.arg = 1:n_states,
        col = "lightcoral", ylim = c(0, 3),
        main = "Q-Learning with Neural Net Function Approximation",
        ylab = "Action (1 = A1, 2 = A2)")
abline(h = 1.5, lty = 2, col = "gray")
```

---

## ✅ Summary

| Approach                      | Model          | Learns Interactions? | Generalizes? | Scales Well? |
| ----------------------------- | -------------- | -------------------- | ------------ | ------------ |
| Tabular Q-learning            | Lookup table   | ❌ No                 | ❌ No         | ❌ No         |
| Linear function approximation | Linear weights | ❌ No                 | ✅ Yes        | ✅ Yes        |
| **Nonlinear approx (NN)**     | Neural Network | ✅ Yes                | ✅ Yes        | ✅ Yes        |

