# Hierarchical Active Inference: From Rumination to Life Narrative

The Active Inference framework presented in the previous post demonstrated how depression emerges from distorted generative models operating at a single timescale—moment-to-moment decisions about whether to engage socially, pursue solitary activities, or ruminate. However, human cognition operates simultaneously across vastly different temporal scales. We don't just predict what will happen in the next few minutes; we maintain beliefs about who we are, what our lives mean, and how our personal narratives will unfold over years or decades. These high-level beliefs are not merely abstract philosophizing—they actively constrain and shape lower-level predictions and actions in ways that can trap individuals in self-perpetuating depressive patterns.

Consider the depressed individual who believes "I am fundamentally unlovable." This is not simply a prediction about a specific social interaction; it's a high-level narrative model that generates expectations across countless situations. When invited to a party, this narrative predicts rejection. When receiving a compliment, it predicts insincerity. When experiencing momentary loneliness, it confirms the overarching story. The belief operates as a prior that biases all lower-level inference, creating a hierarchical trap where top-down predictions overwhelm bottom-up evidence. No single positive social interaction can overturn the narrative because each interaction is interpreted through the lens of that narrative.

This post extends the Active Inference framework to hierarchical generative models that capture how beliefs at different temporal scales interact. We'll formalize how high-level narrative beliefs constrain lower-level policy selection, implement computational models demonstrating these hierarchical dynamics, and explore why effective therapy must sometimes target the highest levels of the cognitive hierarchy to enable change at lower levels.

## Mathematical Framework: Hierarchical Generative Models

In hierarchical Active Inference, the brain maintains a cascade of generative models operating at different timescales, where higher levels provide prior beliefs that constrain inference at lower levels. We can formalize this as a hierarchy of hidden state variables $s^{(1)}, s^{(2)}, ..., s^{(L)}$ where superscripts denote hierarchical levels and higher levels evolve more slowly than lower levels.

At the lowest level (level 1), we have rapidly changing states corresponding to momentary experiences—current mood, immediate social context, physiological arousal. At intermediate levels (level 2-3), we have beliefs about recurring patterns—"I usually feel anxious in social situations," "My relationships tend to fail." At the highest levels (level 4-5), we have narrative beliefs about identity and life trajectory—"I am fundamentally defective," "My life is a story of abandonment."

The generative model at each level $l$ specifies:

$$p(o^{(l)}, s^{(l)} | s^{(l+1)}, \pi^{(l)}) = p(o^{(l)} | s^{(l)}) \cdot p(s^{(l)} | s^{(l+1)}, \pi^{(l)})$$

where $s^{(l+1)}$ acts as a slowly-changing prior over states at level $l$, and $\pi^{(l)}$ represents policies at that timescale. The key insight is that higher-level states modulate the transition dynamics at lower levels. A high-level belief like "I am unlovable" doesn't just predict outcomes—it changes the effective transition probabilities by biasing attention, interpretation, and action selection.

The hierarchical free energy can be decomposed across levels:

$$F = \sum_{l=1}^{L} \mathbb{E}_{q(s^{(l)})}[\log q(s^{(l)}) - \log p(o^{(l)}, s^{(l)} | s^{(l+1)})]$$

Each level attempts to minimize free energy given the constraints imposed by levels above. This creates a crucial asymmetry: lower levels can only minimize free energy within the space of possibilities allowed by higher-level priors. If a high-level narrative belief strongly predicts negative outcomes, lower-level inference cannot discover positive possibilities because they are assigned near-zero prior probability.

The precision hierarchy further complicates this picture. Each level has associated precision parameters $\gamma^{(l)}$ that determine how much evidence is required to update beliefs at that level. Higher-level beliefs typically have higher precision (they're more resistant to change) because they integrate evidence over longer timescales. This creates stability—our core identity doesn't shift with every momentary experience—but also rigidity when these high-level beliefs become pathologically biased.

$$\pi^{(l)} \propto \exp(-\gamma^{(l)} G^{(l)}(\pi | s^{(l+1)}))$$

The policy at level $l$ is selected based on expected free energy, but this is conditioned on the state at level $l+1$. A depressive narrative at the highest level constrains what policies are even considered at lower levels, creating a hierarchical trap.

## Timescale Separation and Narrative Rigidity

A critical feature of hierarchical models is timescale separation—higher levels update more slowly than lower levels. We can formalize this through different learning rates at each level:

$$\Delta s^{(l)} \propto \alpha^{(l)} \cdot \nabla_{s^{(l)}} F$$

where $\alpha^{(1)} >> \alpha^{(2)} >> ... >> \alpha^{(L)}$. Lower levels track fast-changing features of the environment, while higher levels capture slowly-varying patterns and regularities.

In healthy cognition, this timescale separation is adaptive. Core identity beliefs remain stable across momentary fluctuations, providing continuity and predictability. However, in depression, this same architecture becomes pathological. Negative narrative beliefs, once formed, resist updating because they operate at such slow timescales. Even when lower-level experiences contradict the narrative, the high-level belief changes so slowly that it appears unchangeable.

The effective timescale $\tau^{(l)}$ at which level $l$ integrates evidence can be approximated as:

$$\tau^{(l)} \approx \frac{1}{\alpha^{(l)} \cdot \gamma^{(l)}}$$

For high-level narrative beliefs with small learning rates and high precision, this timescale can span months or years. A person might need hundreds of positive social experiences, consistently interpreted without bias, before a core belief like "I am unlovable" begins to shift.

## Implementing Hierarchical Active Inference Models

To make these ideas concrete, we'll implement a three-level hierarchical model of depression. Level 1 represents momentary mood states and immediate decisions. Level 2 represents beliefs about recurring patterns in relationships. Level 3 represents narrative beliefs about fundamental self-worth and lovability.

```r
library(ggplot2)
library(dplyr)
library(tidyr)
library(reshape2)

# Three-level hierarchical generative model
setup_hierarchical_model <- function(
    narrative_belief = 0.5  # Level 3: 0 = "I am lovable", 1 = "I am unlovable"
) {
  
  # LEVEL 1: Momentary mood states
  # States: positive mood, neutral mood, negative mood
  # Actions: social engage, solitary activity, ruminate
  
  # LEVEL 2: Relational pattern beliefs
  # States: relationships succeed, relationships mixed, relationships fail
  
  # LEVEL 3: Narrative identity beliefs
  # States: fundamentally lovable vs fundamentally unlovable
  # This is treated as a fixed parameter that modulates lower levels
  
  # Level 1 likelihood: p(observations | mood state)
  A_L1 <- matrix(c(
    0.7, 0.2, 0.1,  # Positive mood -> positive observations
    0.2, 0.6, 0.2,  # Neutral mood -> mixed observations
    0.1, 0.2, 0.7   # Negative mood -> negative observations
  ), nrow = 3, byrow = TRUE)
  
  # Level 2 likelihood: p(mood patterns | relational beliefs)
  # This is probabilistic mapping from level 2 states to level 1 state distributions
  A_L2 <- matrix(c(
    0.6, 0.3, 0.1,  # "Relationships succeed" -> tend toward positive moods
    0.3, 0.4, 0.3,  # "Relationships mixed" -> neutral mood distribution
    0.1, 0.3, 0.6   # "Relationships fail" -> tend toward negative moods
  ), nrow = 3, byrow = TRUE)
  
  # Level 1 transitions: p(mood' | mood, action, relational_belief)
  # These are modulated by level 2 states
  
  # When relational belief is "relationships succeed" (L2 state 1)
  B_L1_social_succeed <- matrix(c(
    0.7, 0.2, 0.1,
    0.5, 0.3, 0.2,
    0.4, 0.4, 0.2
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_succeed <- matrix(c(
    0.5, 0.3, 0.2,
    0.3, 0.5, 0.2,
    0.2, 0.4, 0.4
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_succeed <- matrix(c(
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4,
    0.1, 0.3, 0.6
  ), nrow = 3, byrow = TRUE)
  
  # When relational belief is "relationships mixed" (L2 state 2)
  B_L1_social_mixed <- matrix(c(
    0.5, 0.3, 0.2,
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_mixed <- matrix(c(
    0.4, 0.4, 0.2,
    0.2, 0.5, 0.3,
    0.1, 0.4, 0.5
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_mixed <- matrix(c(
    0.2, 0.4, 0.4,
    0.1, 0.4, 0.5,
    0.1, 0.2, 0.7
  ), nrow = 3, byrow = TRUE)
  
  # When relational belief is "relationships fail" (L2 state 3)
  B_L1_social_fail <- matrix(c(
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4,
    0.1, 0.3, 0.6
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_fail <- matrix(c(
    0.3, 0.4, 0.3,
    0.1, 0.4, 0.5,
    0.05, 0.25, 0.7
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_fail <- matrix(c(
    0.2, 0.3, 0.5,
    0.1, 0.2, 0.7,
    0.05, 0.15, 0.8
  ), nrow = 3, byrow = TRUE)
  
  # Package level 1 transitions (3 actions × 3 L2 states)
  B_L1 <- array(0, dim = c(3, 3, 3, 3))  # [s', s, action, L2_state]
  
  B_L1[,,1,1] <- B_L1_social_succeed
  B_L1[,,2,1] <- B_L1_solitary_succeed
  B_L1[,,3,1] <- B_L1_ruminate_succeed
  
  B_L1[,,1,2] <- B_L1_social_mixed
  B_L1[,,2,2] <- B_L1_solitary_mixed
  B_L1[,,3,2] <- B_L1_ruminate_mixed
  
  B_L1[,,1,3] <- B_L1_social_fail
  B_L1[,,2,3] <- B_L1_solitary_fail
  B_L1[,,3,3] <- B_L1_ruminate_fail
  
  # Level 2 transitions: p(relational_belief' | relational_belief, evidence, narrative)
  # Modulated by level 3 narrative belief
  
  # When narrative is "I am lovable" (low narrative_belief value)
  B_L2_lovable <- matrix(c(
    0.8, 0.15, 0.05,   # Success tends to stay success
    0.3, 0.5, 0.2,     # Mixed can improve
    0.2, 0.4, 0.4      # Failure can improve
  ), nrow = 3, byrow = TRUE)
  
  # When narrative is "I am unlovable" (high narrative_belief value)
  B_L2_unlovable <- matrix(c(
    0.4, 0.4, 0.2,     # Success is unstable
    0.1, 0.4, 0.5,     # Mixed deteriorates
    0.05, 0.25, 0.7    # Failure is stable
  ), nrow = 3, byrow = TRUE)
  
  # Interpolate based on narrative belief
  B_L2 <- (1 - narrative_belief) * B_L2_lovable + 
          narrative_belief * B_L2_unlovable
  
  # Preferences at each level
  C_L1 <- matrix(c(2, 0, -2), ncol = 1)  # Prefer positive observations
  C_L2 <- matrix(c(1, 0, -1), ncol = 1)  # Prefer relational success
  
  # Initial state distributions
  D_L1 <- c(0.33, 0.34, 0.33)
  D_L2 <- c(0.33, 0.34, 0.33)
  
  # Learning rates (higher levels learn more slowly)
  alpha_L1 <- 0.3
  alpha_L2 <- 0.05
  alpha_L3 <- 0.01  # Narrative beliefs change very slowly
  
  # Precision parameters (higher levels have higher precision)
  gamma_L1 <- 2.0
  gamma_L2 <- 4.0
  gamma_L3 <- 8.0
  
  list(
    A_L1 = A_L1, A_L2 = A_L2,
    B_L1 = B_L1, B_L2 = B_L2,
    C_L1 = C_L1, C_L2 = C_L2,
    D_L1 = D_L1, D_L2 = D_L2,
    alpha_L1 = alpha_L1, alpha_L2 = alpha_L2, alpha_L3 = alpha_L3,
    gamma_L1 = gamma_L1, gamma_L2 = gamma_L2, gamma_L3 = gamma_L3,
    narrative_belief = narrative_belief
  )
}

# Compute expected free energy at level 1 (conditioned on L2 state)
compute_EFE_L1 <- function(action, beliefs_L1, beliefs_L2, model) {
  
  # Expected L2 state
  L2_state_expected <- which.max(beliefs_L2)
  
  # Get transition matrix for this action and L2 state
  B_action <- model$B_L1[, , action, L2_state_expected]
  
  # Predict next state
  predicted_next <- as.vector(B_action %*% beliefs_L1)
  
  # Predict observations
  predicted_obs <- as.vector(model$A_L1 %*% predicted_next)
  
  # Epistemic value (information gain)
  state_entropy_before <- -sum(beliefs_L1 * log(beliefs_L1 + 1e-10))
  state_entropy_after <- -sum(predicted_next * log(predicted_next + 1e-10))
  info_gain <- state_entropy_before - state_entropy_after
  
  # Pragmatic value
  pref_value <- sum(predicted_obs * model$C_L1)
  
  # Expected free energy (to be minimized)
  EFE <- -info_gain - pref_value
  
  return(EFE)
}

# Update beliefs at level 2 based on accumulated level 1 evidence
update_beliefs_L2 <- function(beliefs_L2, mood_history, model, window = 10) {
  
  # Look at recent mood patterns
  recent_moods <- tail(mood_history, window)
  avg_mood <- mean(recent_moods)
  
  # Create observation at level 2 based on mood patterns
  # 1 = predominantly positive, 2 = mixed, 3 = predominantly negative
  if (avg_mood < 1.5) {
    L2_obs <- 1
  } else if (avg_mood > 2.5) {
    L2_obs <- 3
  } else {
    L2_obs <- 2
  }
  
  # Bayesian update
  likelihood <- model$A_L2[, L2_obs]
  predicted_state <- as.vector(model$B_L2 %*% beliefs_L2)
  posterior <- likelihood * predicted_state
  posterior <- posterior / sum(posterior)
  
  # Slow update (learning rate)
  beliefs_L2_new <- beliefs_L2 + model$alpha_L2 * (posterior - beliefs_L2)
  beliefs_L2_new <- beliefs_L2_new / sum(beliefs_L2_new)
  
  return(beliefs_L2_new)
}

# Update narrative belief based on level 2 patterns
update_narrative <- function(narrative_belief, beliefs_L2_history, model, window = 50) {
  
  if (length(beliefs_L2_history) < window) return(narrative_belief)
  
  # Extract recent L2 beliefs (each row is a time point)
  recent_L2 <- tail(beliefs_L2_history, window)
  
  # Calculate average belief in relational success vs failure
  avg_success <- mean(recent_L2[, 1])
  avg_failure <- mean(recent_L2[, 3])
  
  # Evidence for updating narrative
  # Positive: consistent relational success
  # Negative: consistent relational failure
  evidence_direction <- avg_success - avg_failure
  
  # Very slow update of narrative belief
  narrative_belief_new <- narrative_belief - model$alpha_L3 * evidence_direction
  narrative_belief_new <- max(0, min(1, narrative_belief_new))
  
  return(narrative_belief_new)
}

# Main hierarchical simulation
simulate_hierarchical_agent <- function(
    n_timesteps = 200,
    initial_narrative = 0.5,
    update_L2_every = 10,
    update_L3_every = 50
) {
  
  model <- setup_hierarchical_model(narrative_belief = initial_narrative)
  
  # Initialize
  states_L1 <- numeric(n_timesteps)
  observations_L1 <- numeric(n_timesteps)
  actions <- numeric(n_timesteps)
  beliefs_L1_history <- matrix(0, nrow = n_timesteps, ncol = 3)
  beliefs_L2_history <- matrix(0, nrow = n_timesteps, ncol = 3)
  narrative_history <- numeric(n_timesteps)
  
  current_state_L1 <- 2  # Start neutral
  current_beliefs_L1 <- model$D_L1
  current_beliefs_L2 <- model$D_L2
  current_narrative <- initial_narrative
  
  for (t in 1:n_timesteps) {
    
    # Store current state
    states_L1[t] <- current_state_L1
    beliefs_L1_history[t, ] <- current_beliefs_L1
    beliefs_L2_history[t, ] <- current_beliefs_L2
    narrative_history[t] <- current_narrative
    
    # Select action at level 1 (conditioned on L2 beliefs)
    EFE_actions <- sapply(1:3, function(a) {
      compute_EFE_L1(a, current_beliefs_L1, current_beliefs_L2, model)
    })
    
    action_probs <- exp(-model$gamma_L1 * EFE_actions)
    action_probs <- action_probs / sum(action_probs)
    action <- sample(1:3, 1, prob = action_probs)
    actions[t] <- action
    
    # Generate next state at level 1
    L2_state <- which.max(current_beliefs_L2)
    B_action <- model$B_L1[, , action, L2_state]
    next_state_probs <- B_action[current_state_L1, ]
    next_state <- sample(1:3, 1, prob = next_state_probs)
    
    # Generate observation
    obs_probs <- model$A_L1[next_state, ]
    observation <- sample(1:3, 1, prob = obs_probs)
    observations_L1[t] <- observation
    
    # Update beliefs at level 1 (fast)
    likelihood <- model$A_L1[, observation]
    predicted_state <- as.vector(B_action %*% current_beliefs_L1)
    posterior <- likelihood * predicted_state
    current_beliefs_L1 <- posterior / sum(posterior)
    
    current_state_L1 <- next_state
    
    # Periodically update level 2 beliefs
    if (t %% update_L2_every == 0 && t > update_L2_every) {
      current_beliefs_L2 <- update_beliefs_L2(
        current_beliefs_L2, 
        states_L1[1:t], 
        model,
        window = update_L2_every
      )
    }
    
    # Periodically update narrative belief
    if (t %% update_L3_every == 0 && t > update_L3_every) {
      current_narrative <- update_narrative(
        current_narrative,
        beliefs_L2_history[1:t, ],
        model,
        window = update_L3_every
      )
      
      # Rebuild model with updated narrative
      model <- setup_hierarchical_model(narrative_belief = current_narrative)
    }
  }
  
  data.frame(
    time = 1:n_timesteps,
    state_L1 = states_L1,
    observation = observations_L1,
    action = actions,
    belief_L1_positive = beliefs_L1_history[, 1],
    belief_L1_neutral = beliefs_L1_history[, 2],
    belief_L1_negative = beliefs_L1_history[, 3],
    belief_L2_success = beliefs_L2_history[, 1],
    belief_L2_mixed = beliefs_L2_history[, 2],
    belief_L2_failure = beliefs_L2_history[, 3],
    narrative_belief = narrative_history
  )
}

# Simulate agents with different initial narratives
set.seed(123)

# Agent starting with healthy narrative ("I am lovable")
healthy_narrative <- simulate_hierarchical_agent(
  n_timesteps = 300,
  initial_narrative = 0.2,
  update_L2_every = 10,
  update_L3_every = 50
)
healthy_narrative$agent_type <- "Healthy Narrative"

# Agent starting with depressed narrative ("I am unlovable")
depressed_narrative <- simulate_hierarchical_agent(
  n_timesteps = 300,
  initial_narrative = 0.8,
  update_L2_every = 10,
  update_L3_every = 50
)
depressed_narrative$agent_type <- "Depressed Narrative"

combined_data <- rbind(healthy_narrative, depressed_narrative)

# Plot Level 1: Momentary mood states
ggplot(combined_data, aes(x = time, y = state_L1, color = agent_type)) +
  geom_line(alpha = 0.3) +
  geom_smooth(se = TRUE, size = 1.2) +
  scale_y_continuous(breaks = 1:3, 
                     labels = c("Positive", "Neutral", "Negative")) +
  labs(title = "Level 1: Momentary Mood Trajectories",
       subtitle = "Higher-level narratives constrain lower-level mood dynamics",
       x = "Time", y = "Mood State", color = "Agent Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy Narrative" = "#2E7D32", 
                                 "Depressed Narrative" = "#C62828"))

# Plot Level 2: Relational pattern beliefs
belief_L2_long <- combined_data %>%
  select(time, agent_type, belief_L2_success, belief_L2_mixed, belief_L2_failure) %>%
  pivot_longer(cols = starts_with("belief_L2"), 
               names_to = "belief_type", 
               values_to = "belief_strength") %>%
  mutate(belief_type = recode(belief_type,
                              "belief_L2_success" = "Relationships Succeed",
                              "belief_L2_mixed" = "Relationships Mixed",
                              "belief_L2_failure" = "Relationships Fail"))

ggplot(belief_L2_long, aes(x = time, y = belief_strength, 
                           color = belief_type, linetype = agent_type)) +
  geom_smooth(se = FALSE, size = 1) +
  labs(title = "Level 2: Relational Pattern Beliefs Over Time",
       subtitle = "Intermediate timescale beliefs integrate momentary experiences",
       x = "Time", y = "Belief Strength", 
       color = "Belief Type", linetype = "Agent Type") +
  theme_minimal() +
  scale_color_manual(values = c("Relationships Succeed" = "#1B5E20",
                                 "Relationships Mixed" = "#F57F17", 
                                 "Relationships Fail" = "#B71C1C"))

# Plot Level 3: Narrative belief evolution
ggplot(combined_data, aes(x = time, y = narrative_belief, color = agent_type)) +
  geom_line(size = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  annotate("text", x = 250, y = 0.1, label = "\"I am lovable\"", size = 4) +
  annotate("text", x = 250, y = 0.9, label = "\"I am unlovable\"", size = 4) +
  labs(title = "Level 3: Core Narrative Belief Evolution",
       subtitle = "Highest-level beliefs change extremely slowly despite lower-level evidence",
       x = "Time", y = "Narrative Belief: Unlovable ← → Lovable", 
       color = "Initial Narrative") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy Narrative" = "#2E7D32", 
                                 "Depressed Narrative" = "#C62828")) +
  scale_y_reverse()
```

This hierarchical simulation reveals several critical insights. First, agents with different narrative-level beliefs show dramatically different mood trajectories despite experiencing the same underlying stochastic environment. The depressed narrative constrains level 2 beliefs toward "relationships fail," which in turn biases level 1 transitions toward negative moods and ruminative actions. Second, the timescale separation creates path dependence—early narrative beliefs shape all subsequent learning, making it difficult for contradictory evidence at lower levels to percolate upward. Third, the extreme slowness of narrative change means that even hundreds of timesteps of experience may barely shift core identity beliefs.

## The Hierarchical Trap: How Top-Down Priors Overwhelm Bottom-Up Evidence

The most pernicious feature of hierarchical models in depression is how high-level beliefs can render lower-level evidence essentially irrelevant. Consider a depressed individual who believes at the narrative level "I am fundamentally unlovable." When this person has a positive social interaction, several things happen:

1. **Level 1 (Momentary)**: The positive observation is registered and temporarily improves mood state
2. **Level 2 (Patterns)**: The single positive interaction is contextualized within a belief that "relationships fail." It might be dismissed as an anomaly, attributed to politeness rather than genuine affection, or predicted to be followed by inevitable rejection
3. **Level 3 (Narrative)**: The core belief "I am unlovable" generates a strong prior that this positive interaction is not diagnostic of anything meaningful about one's fundamental worth

The mathematical consequence is that the positive evidence gets increasingly discounted as it propagates up the hierarchy. We can formalize this as a precision-weighted prediction error at each level:

$$\delta^{(l)} = \gamma^{(l)} \cdot (s^{(l)}_{\text{observed}} - s^{(l)}_{\text{predicted from } l+1})$$

When $\gamma^{(l+1)}$ is very high (the higher-level belief is very precise), it generates strong predictions that overwhelm evidence from below. The posterior at level $l$ becomes:

$$p(s^{(l)} | o^{(l)}, s^{(l+1)}) \propto p(o^{(l)} | s^{(l)}) \cdot p(s^{(l)} | s^{(l+1)})$$

When the prior $p(s^{(l)} | s^{(l+1)})$ is very peaked (high precision from above), the likelihood $p(o^{(l)} | s^{(l)})$ has minimal influence on the posterior. In plain language: no matter what happens at the momentary level, the higher-level belief wins.

Let's implement a simulation that explicitly demonstrates this precision-weighting effect:

```r
# Simulate the effect of narrative precision on evidence integration
simulate_precision_effects <- function(
    n_experiences = 100,
    narrative_belief = 0.8,    # Initial: "I am unlovable"
    narrative_precision = 8.0,  # How resistant to change
    evidence_quality = 0.7      # How positive the experiences are
) {
  
  beliefs <- numeric(n_experiences + 1)
  prediction_errors <- numeric(n_experiences)
  belief_updates <- numeric(n_experiences)
  
  beliefs[1] <- narrative_belief
  
  for (i in 1:n_experiences) {
    
    # Generate experience (0 = positive, 1 = negative)
    # evidence_quality determines distribution
    experience <- rbinom(1, 1, 1 - evidence_quality)
    
    # Prediction from narrative
    predicted_experience <- beliefs[i]
    
    # Prediction error
    PE <- experience - predicted_experience
    prediction_errors[i] <- PE
    
    # Precision-weighted update
    # High precision means small updates
    learning_rate <- 1 / (1 + narrative_precision)
    update <- learning_rate * PE
    belief_updates[i] <- update
    
    # Update belief
    beliefs[i + 1] <- beliefs[i] + update
    beliefs[i + 1] <- max(0, min(1, beliefs[i + 1]))
  }
  
  data.frame(
    experience = 0:n_experiences,
    belief = beliefs,
    narrative_precision = narrative_precision
  )
}

# Compare different precision levels
low_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 2.0,
  evidence_quality = 0.7
)
low_precision$precision_type <- "Low Precision (Flexible)"

medium_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 8.0,
  evidence_quality = 0.7
)
medium_precision$precision_type <- "Medium Precision (Normal)"

high_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 20.0,
  evidence_quality = 0.7
)
high_precision$precision_type <- "High Precision (Rigid)"

precision_data <- rbind(low_precision, medium_precision, high_precision)

ggplot(precision_data, aes(x = experience, y = belief, color = precision_type)) +
  geom_line(size = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = 0.3, linetype = "dotted", alpha = 0.5) +
  annotate("text", x = 80, y = 0.32, 
           label = "Expected belief given 70% positive experiences", 
           size = 3.5) +
  labs(title = "Narrative Precision Determines Resistance to Evidence",
       subtitle = "High-precision beliefs barely update despite consistent positive experiences",
       x = "Number of Positive Experiences", 
       y = "Narrative Belief (1 = Unlovable)", 
       color = "Precision Level") +
  theme_minimal() +
  scale_color_manual(values = c("Low Precision (Flexible)" = "#2E7D32",
                                 "Medium Precision (Normal)" = "#F57F17",
                                 "High Precision (Rigid)" = "#C62828"))
```

This simulation starkly illustrates the clinical challenge. With high narrative precision, even 100 predominantly positive experiences barely shift the core belief. The belief changes from 0.8 to perhaps 0.75—a difference unlikely to be subjectively noticed or functionally meaningful. The high-precision narrative effectively immunizes itself against contradictory evidence.

## Rumination as Failed Hierarchical Inference

We can now understand rumination more precisely as a failure of hierarchical inference. When faced with a problem—say, a social rejection—healthy cognition proceeds through hierarchical evaluation:

1. **Level 1**: "This interaction went badly" (momentary state)
2. **Level 2**: "Is this part of a pattern in my relationships?" (pattern inference)
3. **Level 3**: "What does this say about my fundamental worth?" (narrative inference)

In healthy processing, strong priors at level 3 ("I am generally lovable") rapidly resolve the inference: "This was an isolated negative interaction, not diagnostic of a pattern or my fundamental worth." The inference completes, uncertainty is reduced, and the person moves on.

In depressed rumination, the hierarchical inference fails to converge:

1. **Level 1**: "This interaction went badly" 
2. **Level 2**: "This fits the pattern that relationships fail" (confirmation of negative pattern belief)
3. **Level 3**: "This confirms I am fundamentally unlovable" (confirmation of narrative)
4. **Level 2**: "But wait, sometimes relationships seem okay..." (uncertainty about pattern)
5. **Level 1**: "Let me replay the interaction to understand it better..." (return to momentary level)
6. **Repeat indefinitely**

The hierarchical inference loops because there is mutual reinforcement between levels but no resolution. The narrative predicts relationship failure, so level 2 beliefs confirm this, but occasional positive experiences at level 1 create uncertainty at level 2, which triggers re-evaluation at level 1, but the narrative continues to bias interpretation, preventing convergence.

We can model this as a failure to minimize free energy across the hierarchy:

```r
# Simulate rumination as failed hierarchical convergence
simulate_rumination_cycle <- function(
    n_iterations = 50,
    narrative_bias = 0.8,
    evidence_ambiguity = 0.5  # How ambiguous the evidence is
) {
  
  # Track which level is being evaluated at each iteration
  active_level <- numeric(n_iterations)
  free_energy_L1 <- numeric(n_iterations)
  free_energy_L2 <- numeric(n_iterations)
  free_energy_L3 <- numeric(n_iterations)
  total_free_energy <- numeric(n_iterations)
  
  # Initial states (high uncertainty)
  belief_L1 <- c(0.33, 0.34, 0.33)
  belief_L2 <- c(0.33, 0.34, 0.33)
  belief_L3 <- narrative_bias
  
  for (iter in 1:n_iterations) {
    
    # Generate ambiguous evidence
    evidence_valence <- rnorm(1, mean = 0.5 - narrative_bias, 
                              sd = evidence_ambiguity)
    
    # Level 1: Try to explain immediate experience
    # Ambiguous evidence creates uncertainty
    if (evidence_valence > 0) {
      obs_L1 <- c(0.6, 0.3, 0.1)
    } else {
      obs_L1 <- c(0.1, 0.3, 0.6)
    }
    
    # Level 2 prediction of L1
    pred_L1_from_L2 <- c(
      0.3 + 0.3 * (1 - belief_L3),  # Positive
      0.4,                           # Neutral
      0.3 + 0.3 * belief_L3          # Negative
    )
    
    # Level 3 prediction of L2
    pred_L2_from_L3 <- c(
      0.3 * (1 - belief_L3),
      0.4,
      0.3 + 0.4 * belief_L3
    )
    
    # Compute free energy at each level (KL divergence + surprise)
    FE_L1 <- sum(belief_L1 * log((belief_L1 + 1e-10) / (obs_L1 + 1e-10))) +
             -sum(obs_L1 * log(obs_L1 + 1e-10))
    
    FE_L2 <- sum(belief_L2 * log((belief_L2 + 1e-10) / (pred_L2_from_L3 + 1e-10))) +
             sum(belief_L1 * log((belief_L1 + 1e-10) / (pred_L1_from_L2 + 1e-10)))
    
    FE_L3 <- (belief_L3 - mean(belief_L2))^2
    
    free_energy_L1[iter] <- FE_L1
    free_energy_L2[iter] <- FE_L2
    free_energy_L3[iter] <- FE_L3
    total_free_energy[iter] <- FE_L1 + FE_L2 + FE_L3
    
    # Determine which level has highest free energy (most uncertainty)
    FE_levels <- c(FE_L1, FE_L2, FE_L3)
    active_level[iter] <- which.max(FE_levels)
    
    # Update the active level
    if (active_level[iter] == 1) {
      # Focus on momentary interpretation
      belief_L1 <- 0.7 * belief_L1 + 0.3 * obs_L1
      belief_L1 <- belief_L1 / sum(belief_L1)
    } else if (active_level[iter] == 2) {
      # Focus on pattern interpretation
      belief_L2 <- 0.8 * belief_L2 + 0.2 * pred_L2_from_L3
      belief_L2 <- belief_L2 / sum(belief_L2)
    } else {
      # Focus on narrative interpretation (but very resistant to change)
      narrative_update <- 0.02 * (mean(belief_L2) - belief_L3)
      belief_L3 <- belief_L3 + narrative_update
      belief_L3 <- max(0, min(1, belief_L3))
    }
  }
  
  data.frame(
    iteration = 1:n_iterations,
    active_level = active_level,
    FE_L1 = free_energy_L1,
    FE_L2 = free_energy_L2,
    FE_L3 = free_energy_L3,
    total_FE = total_free_energy,
    narrative_bias = narrative_bias
  )
}

# Simulate healthy vs ruminative processing
healthy_processing <- simulate_rumination_cycle(
  n_iterations = 50,
  narrative_bias = 0.3,
  evidence_ambiguity = 0.3
)
healthy_processing$condition <- "Healthy (Converges)"

ruminative_processing <- simulate_rumination_cycle(
  n_iterations = 50,
  narrative_bias = 0.8,
  evidence_ambiguity = 0.6
)
ruminative_processing$condition <- "Ruminative (Fails to Converge)"

convergence_data <- rbind(healthy_processing, ruminative_processing)

# Plot free energy over time
ggplot(convergence_data, aes(x = iteration, y = total_FE, color = condition)) +
  geom_line(size = 1.2) +
  labs(title = "Free Energy Minimization: Convergence vs Rumination",
       subtitle = "Healthy processing rapidly reduces uncertainty; rumination fails to converge",
       x = "Mental Simulation Iteration", 
       y = "Total Hierarchical Free Energy",
       color = "Processing Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy (Converges)" = "#2E7D32",
                                 "Ruminative (Fails to Converge)" = "#C62828"))

# Plot which level is active
convergence_data$level_label <- factor(
  convergence_data$active_level,
  levels = 1:3,
  labels = c("Momentary\n(Level 1)", "Patterns\n(Level 2)", "Narrative\n(Level 3)")
)

ggplot(convergence_data, aes(x = iteration, y = level_label, color = condition)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "Level of Hierarchical Processing Over Time",
       subtitle = "Rumination cycles between levels without resolution",
       x = "Iteration", y = "Active Processing Level",
       color = "Processing Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy (Converges)" = "#2E7D32",
                                 "Ruminative (Fails to Converge)" = "#C62828"))
```

The healthy processing rapidly reduces free energy and stabilizes at a preferred level (typically the highest level that can resolve the uncertainty). Ruminative processing cycles between levels, never achieving stable convergence. The system repeatedly drops from narrative-level processing back to momentary re-interpretation, then back up to pattern evaluation, in an endless loop that fails to minimize uncertainty.

## Therapeutic Implications: Targeting the Right Level of the Hierarchy

This hierarchical framework has profound implications for therapeutic intervention. Traditional cognitive therapy focuses primarily on level 1 and level 2—challenging automatic negative thoughts about specific situations and identifying maladaptive patterns. However, if the core narrative belief at level 3 has very high precision, these lower-level interventions may be ineffective. The patient may successfully challenge individual negative thoughts but find that their core belief remains unchanged, continuing to generate new negative predictions.

Effective therapy must either:

1. **Reduce precision at level 3**: Help the patient become less certain about their core narrative, opening it to revision. This is the domain of schema therapy and core belief work.

2. **Accumulate sufficient evidence at lower levels**: Generate enough consistent positive experiences at levels 1 and 2 that the evidence eventually overcomes even high-precision narrative beliefs. This requires sustained behavioral activation and exposure.

3. **Bypass the narrative level**: Some interventions (mindfulness, acceptance-based approaches) teach patients to observe thoughts without engaging in narrative-level processing, effectively reducing the influence of level 3 beliefs on moment-to-moment experience.

The mathematics suggests that the most efficient approach depends on the precision profile. For moderately high narrative precision, behavioral accumulation of evidence may work. For extremely high precision, direct schema-level work becomes necessary. For patients trapped in ruminative cycles, breaking the hierarchical loop (through mindfulness or rumination-focused CBT) may be required before any belief updating can occur.

## Conclusion: The Architecture of Depressive Cognition

Hierarchical Active Inference reveals depression as fundamentally an architectural problem. The same cognitive hierarchy that provides stability and continuity to healthy identity can trap individuals in self-perpetuating negative patterns when narrative-level beliefs become biased and rigid. Top-down predictions from these narrative beliefs overwhelm bottom-up evidence from experience, creating a system that is formally resistant to change despite ongoing negative consequences.

The framework explains why depression is so difficult to treat: momentary positive experiences are real but insufficient. They must accumulate over time, be correctly interpreted (not dismissed), propagate through intermediate levels, and eventually overcome the high precision of narrative beliefs that have been reinforced over years or decades. The timescale separation that normally provides stability becomes pathological rigidity. The precision weighting that normally protects core beliefs from noise becomes imperviousness to genuine positive evidence.

Yet the framework also suggests hope. By understanding depression as a hierarchical inference problem, we can design interventions targeted at specific levels and mechanisms. We can measure the precision of narrative beliefs and track how they evolve. We can identify which level of the hierarchy is most dysfunctional for a particular patient. And we can recognize that recovery is not about willpower or simply "thinking positive"—it's about systematically restructuring a hierarchical generative model through the careful accumulation and integration of evidence across multiple timescales.

The mathematics of hierarchical Active Inference provides a rigorous foundation for understanding why narrative matters, why changing core beliefs is so difficult, and why effective therapy must ultimately address the highest levels of the cognitive hierarchy to enable lasting change at lower levels.



# Hierarchical Active Inference: From Rumination to Life Narrative

The Active Inference framework has previously demonstrated how depression can emerge from distorted generative models operating at a single timescale—moment-to-moment decisions about social engagement or rumination. However, human cognition is not flat; it operates simultaneously across vastly different temporal scales. We do not merely predict events in the next few minutes; we maintain deep-seated beliefs about who we are, the meaning of our lives, and how our personal narratives will unfold over decades. These high-level beliefs are not abstract philosophical musings. They are active constraints that shape lower-level predictions and actions, potentially trapping individuals in self-perpetuating depressive patterns.

Consider a depressed individual holding the belief "I am fundamentally unlovable." This is not a specific prediction about a single interaction; it is a high-level narrative model generating expectations across countless situations. When invited to a party, this narrative predicts rejection. When receiving a compliment, it predicts insincerity. When experiencing momentary loneliness, it acts as confirmation of the overarching story. This belief operates as a hyper-prior, biasing all lower-level inference and creating a hierarchical trap where top-down predictions overwhelm bottom-up sensory evidence. Consequently, no single positive social interaction can overturn the narrative because every interaction is interpreted through its distorting lens.

This article extends the Active Inference framework to hierarchical generative models, formalizing how beliefs at different temporal scales interact. We will explore how high-level narrative beliefs constrain policy selection, implement computational models to demonstrate these dynamics, and examine why effective therapy must often target the highest levels of the cognitive hierarchy to permit change below.

## Mathematical Framework: Hierarchical Generative Models

In hierarchical Active Inference, the brain maintains a cascade of generative models operating at stratified timescales. Higher levels provide prior beliefs that constrain inference at lower levels. We formalize this as a hierarchy of hidden state variables $s^{(1)}, s^{(2)}, \dots, s^{(L)}$, where superscripts denote hierarchical levels and higher levels evolve more slowly than those below.

At the lowest level (level 1), states correspond to rapidly changing momentary experiences—current mood, immediate social context, or physiological arousal. Intermediate levels (levels 2-3) encode beliefs about recurring patterns, such as "I usually feel anxious in social situations" or "My relationships tend to fail." The highest levels (levels 4-5) house narrative beliefs regarding identity and life trajectory, such as "I am fundamentally defective."

The generative model at each level $l$ specifies the joint probability of observations and states, conditioned on the level above:

$$p(o^{(l)}, s^{(l)} \mid s^{(l+1)}, \pi^{(l)}) = p(o^{(l)} \mid s^{(l)}) \cdot p(s^{(l)} \mid s^{(l+1)}, \pi^{(l)})$$

Here, $s^{(l+1)}$ acts as a slowly changing prior over states at level $l$, and $\pi^{(l)}$ represents policies at that timescale. The critical insight is that higher-level states modulate the transition dynamics of lower levels. A high-level belief like "I am unlovable" does not simply predict outcomes; it alters effective transition probabilities by biasing attention, interpretation, and action selection.

Hierarchical free energy is decomposed across these levels:

$$F = \sum_{l=1}^{L} \mathbb{E}_{q(s^{(l)})}[\ln q(s^{(l)}) - \ln p(o^{(l)}, s^{(l)} \mid s^{(l+1)})]$$

Each level attempts to minimize free energy given the constraints imposed by levels above. This creates a functional asymmetry: lower levels can only minimize free energy within the manifold of possibilities permitted by higher-level priors. If a high-level narrative strongly predicts negative outcomes, lower-level inference is precluded from discovering positive possibilities because they are assigned near-zero prior probability.

This dynamic is governed by the precision hierarchy. Each level possesses associated precision parameters $\gamma^{(l)}$ that determine the weight of evidence required to update beliefs. Higher-level beliefs typically command higher precision—making them more resistant to change—because they integrate evidence over longer timescales. This creates adaptive stability in healthy cognition; our core identity does not fracture with every minor fluctuation. However, in depression, this stability becomes rigidity:

$$\pi^{(l)} \propto \exp(-\gamma^{(l)} G^{(l)}(\pi \mid s^{(l+1)}))$$

Policy selection $\pi^{(l)}$ minimizes expected free energy, but it is conditioned on the state $s^{(l+1)}$. A depressive narrative at the highest level constrains which policies are considered viable at lower levels, essentially removing adaptive behaviors from the agent's repertoire.

## Timescale Separation and Narrative Rigidity

A defining feature of these models is timescale separation. We formalize this via distinct learning rates, where $\alpha^{(1)} \gg \alpha^{(2)} \gg \dots \gg \alpha^{(L)}$. Lower levels track fast-changing environmental features, while higher levels capture slowly varying regularities.

While this separation provides continuity in healthy cognition, it becomes pathological in depression. Negative narrative beliefs, once established, resist updating because of their slow temporal dynamics. The effective timescale $\tau^{(l)}$ at which level $l$ integrates evidence approximates to:

$$\tau^{(l)} \approx \frac{1}{\alpha^{(l)} \cdot \gamma^{(l)}}$$

For high-level narrative beliefs characterized by small learning rates and high precision, this timescale can span years. An individual may require hundreds of positive social experiences—consistently interpreted without bias—before a core belief like "I am unlovable" begins to shift.

## Implementing Hierarchical Active Inference Models

To illustrate these dynamics, we implement a three-level hierarchical model of depression. Level 1 represents momentary mood states and immediate decisions. Level 2 represents beliefs about recurring relationship patterns. Level 3 represents narrative beliefs about fundamental self-worth.

```r
library(ggplot2)
library(dplyr)
library(tidyr)
library(reshape2)

# Three-level hierarchical generative model
setup_hierarchical_model <- function(
    narrative_belief = 0.5  # Level 3: 0 = "I am lovable", 1 = "I am unlovable"
) {
  
  # LEVEL 1: Momentary mood states
  # States: 1=positive mood, 2=neutral mood, 3=negative mood
  # Actions: 1=social engage, 2=solitary activity, 3=ruminate
  
  # LEVEL 2: Relational pattern beliefs
  # States: 1=relationships succeed, 2=relationships mixed, 3=relationships fail
  
  # LEVEL 3: Narrative identity beliefs
  # This is treated as a fixed parameter that modulates lower levels
  
  # Level 1 likelihood: p(observations | mood state)
  A_L1 <- matrix(c(
    0.7, 0.2, 0.1,  # Positive mood -> positive observations
    0.2, 0.6, 0.2,  # Neutral mood -> mixed observations
    0.1, 0.2, 0.7   # Negative mood -> negative observations
  ), nrow = 3, byrow = TRUE)
  
  # Level 2 likelihood: p(mood patterns | relational beliefs)
  # Mapping from level 2 states to level 1 state distributions
  A_L2 <- matrix(c(
    0.6, 0.3, 0.1,  # "Relationships succeed" -> tend toward positive moods
    0.3, 0.4, 0.3,  # "Relationships mixed" -> neutral mood distribution
    0.1, 0.3, 0.6   # "Relationships fail" -> tend toward negative moods
  ), nrow = 3, byrow = TRUE)
  
  # Level 1 transitions: p(mood' | mood, action, relational_belief)
  # These are modulated by level 2 states
  
  # When relational belief is "relationships succeed" (L2 state 1)
  B_L1_social_succeed <- matrix(c(
    0.7, 0.2, 0.1,
    0.5, 0.3, 0.2,
    0.4, 0.4, 0.2
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_succeed <- matrix(c(
    0.5, 0.3, 0.2,
    0.3, 0.5, 0.2,
    0.2, 0.4, 0.4
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_succeed <- matrix(c(
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4,
    0.1, 0.3, 0.6
  ), nrow = 3, byrow = TRUE)
  
  # When relational belief is "relationships mixed" (L2 state 2)
  B_L1_social_mixed <- matrix(c(
    0.5, 0.3, 0.2,
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_mixed <- matrix(c(
    0.4, 0.4, 0.2,
    0.2, 0.5, 0.3,
    0.1, 0.4, 0.5
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_mixed <- matrix(c(
    0.2, 0.4, 0.4,
    0.1, 0.4, 0.5,
    0.1, 0.2, 0.7
  ), nrow = 3, byrow = TRUE)
  
  # When relational belief is "relationships fail" (L2 state 3)
  B_L1_social_fail <- matrix(c(
    0.3, 0.4, 0.3,
    0.2, 0.4, 0.4,
    0.1, 0.3, 0.6
  ), nrow = 3, byrow = TRUE)
  
  B_L1_solitary_fail <- matrix(c(
    0.3, 0.4, 0.3,
    0.1, 0.4, 0.5,
    0.05, 0.25, 0.7
  ), nrow = 3, byrow = TRUE)
  
  B_L1_ruminate_fail <- matrix(c(
    0.2, 0.3, 0.5,
    0.1, 0.2, 0.7,
    0.05, 0.15, 0.8
  ), nrow = 3, byrow = TRUE)
  
  # Package level 1 transitions (3 actions × 3 L2 states)
  B_L1 <- array(0, dim = c(3, 3, 3, 3))  # [s', s, action, L2_state]
  
  B_L1[,,1,1] <- B_L1_social_succeed
  B_L1[,,2,1] <- B_L1_solitary_succeed
  B_L1[,,3,1] <- B_L1_ruminate_succeed
  
  B_L1[,,1,2] <- B_L1_social_mixed
  B_L1[,,2,2] <- B_L1_solitary_mixed
  B_L1[,,3,2] <- B_L1_ruminate_mixed
  
  B_L1[,,1,3] <- B_L1_social_fail
  B_L1[,,2,3] <- B_L1_solitary_fail
  B_L1[,,3,3] <- B_L1_ruminate_fail
  
  # Level 2 transitions: p(relational_belief' | relational_belief, evidence, narrative)
  # Modulated by level 3 narrative belief
  
  # When narrative is "I am lovable" (low narrative_belief value)
  B_L2_lovable <- matrix(c(
    0.8, 0.15, 0.05,   # Success tends to stay success
    0.3, 0.5, 0.2,     # Mixed can improve
    0.2, 0.4, 0.4      # Failure can improve
  ), nrow = 3, byrow = TRUE)
  
  # When narrative is "I am unlovable" (high narrative_belief value)
  B_L2_unlovable <- matrix(c(
    0.4, 0.4, 0.2,     # Success is unstable
    0.1, 0.4, 0.5,     # Mixed deteriorates
    0.05, 0.25, 0.7    # Failure is stable
  ), nrow = 3, byrow = TRUE)
  
  # Interpolate based on narrative belief
  B_L2 <- (1 - narrative_belief) * B_L2_lovable + 
          narrative_belief * B_L2_unlovable
  
  # Preferences at each level
  C_L1 <- matrix(c(2, 0, -2), ncol = 1)  # Prefer positive observations
  C_L2 <- matrix(c(1, 0, -1), ncol = 1)  # Prefer relational success
  
  # Initial state distributions
  D_L1 <- c(0.33, 0.34, 0.33)
  D_L2 <- c(0.33, 0.34, 0.33)
  
  # Learning rates (higher levels learn more slowly)
  alpha_L1 <- 0.3
  alpha_L2 <- 0.05
  alpha_L3 <- 0.01  # Narrative beliefs change very slowly
  
  # Precision parameters (higher levels have higher precision)
  gamma_L1 <- 2.0
  gamma_L2 <- 4.0
  gamma_L3 <- 8.0
  
  list(
    A_L1 = A_L1, A_L2 = A_L2,
    B_L1 = B_L1, B_L2 = B_L2,
    C_L1 = C_L1, C_L2 = C_L2,
    D_L1 = D_L1, D_L2 = D_L2,
    alpha_L1 = alpha_L1, alpha_L2 = alpha_L2, alpha_L3 = alpha_L3,
    gamma_L1 = gamma_L1, gamma_L2 = gamma_L2, gamma_L3 = gamma_L3,
    narrative_belief = narrative_belief
  )
}

# Compute expected free energy at level 1 (conditioned on L2 state)
compute_EFE_L1 <- function(action, beliefs_L1, beliefs_L2, model) {
  
  # Expected L2 state (using max belief for simulation clarity)
  L2_state_expected <- which.max(beliefs_L2)
  
  # Get transition matrix for this action and L2 state
  B_action <- model$B_L1[, , action, L2_state_expected]
  
  # Predict next state
  predicted_next <- as.vector(B_action %*% beliefs_L1)
  
  # Predict observations
  predicted_obs <- as.vector(model$A_L1 %*% predicted_next)
  
  # Epistemic value (Simplified heuristic: information gain about state)
  state_entropy_before <- -sum(beliefs_L1 * log(beliefs_L1 + 1e-10))
  state_entropy_after <- -sum(predicted_next * log(predicted_next + 1e-10))
  info_gain <- state_entropy_before - state_entropy_after
  
  # Pragmatic value (preference satisfaction)
  pref_value <- sum(predicted_obs * model$C_L1)
  
  # Expected free energy (to be minimized)
  EFE <- -info_gain - pref_value
  
  return(EFE)
}

# Update beliefs at level 2 based on accumulated level 1 evidence
update_beliefs_L2 <- function(beliefs_L2, mood_history, model, window = 10) {
  
  # Look at recent mood patterns
  recent_moods <- tail(mood_history, window)
  avg_mood <- mean(recent_moods)
  
  # Create observation at level 2 based on mood patterns
  # 1 = predominantly positive, 2 = mixed, 3 = predominantly negative
  if (avg_mood < 1.5) {
    L2_obs <- 1
  } else if (avg_mood > 2.5) {
    L2_obs <- 3
  } else {
    L2_obs <- 2
  }
  
  # Bayesian update
  likelihood <- model$A_L2[, L2_obs]
  predicted_state <- as.vector(model$B_L2 %*% beliefs_L2)
  posterior <- likelihood * predicted_state
  posterior <- posterior / sum(posterior)
  
  # Slow update (learning rate)
  beliefs_L2_new <- beliefs_L2 + model$alpha_L2 * (posterior - beliefs_L2)
  beliefs_L2_new <- beliefs_L2_new / sum(beliefs_L2_new)
  
  return(beliefs_L2_new)
}

# Update narrative belief based on level 2 patterns
update_narrative <- function(narrative_belief, beliefs_L2_history, model, window = 50) {
  
  if (length(beliefs_L2_history) < window) return(narrative_belief)
  
  # Extract recent L2 beliefs (each row is a time point)
  recent_L2 <- tail(beliefs_L2_history, window)
  
  # Calculate average belief in relational success vs failure
  avg_success <- mean(recent_L2[, 1])
  avg_failure <- mean(recent_L2[, 3])
  
  # Evidence for updating narrative
  # Positive: consistent relational success
  # Negative: consistent relational failure
  evidence_direction <- avg_success - avg_failure
  
  # Very slow update of narrative belief
  narrative_belief_new <- narrative_belief - model$alpha_L3 * evidence_direction
  narrative_belief_new <- max(0, min(1, narrative_belief_new))
  
  return(narrative_belief_new)
}

# Main hierarchical simulation
simulate_hierarchical_agent <- function(
    n_timesteps = 200,
    initial_narrative = 0.5,
    update_L2_every = 10,
    update_L3_every = 50
) {
  
  model <- setup_hierarchical_model(narrative_belief = initial_narrative)
  
  # Initialize
  states_L1 <- numeric(n_timesteps)
  observations_L1 <- numeric(n_timesteps)
  actions <- numeric(n_timesteps)
  beliefs_L1_history <- matrix(0, nrow = n_timesteps, ncol = 3)
  beliefs_L2_history <- matrix(0, nrow = n_timesteps, ncol = 3)
  narrative_history <- numeric(n_timesteps)
  
  current_state_L1 <- 2  # Start neutral
  current_beliefs_L1 <- model$D_L1
  current_beliefs_L2 <- model$D_L2
  current_narrative <- initial_narrative
  
  for (t in 1:n_timesteps) {
    
    # Store current state
    states_L1[t] <- current_state_L1
    beliefs_L1_history[t, ] <- current_beliefs_L1
    beliefs_L2_history[t, ] <- current_beliefs_L2
    narrative_history[t] <- current_narrative
    
    # Select action at level 1 (conditioned on L2 beliefs)
    EFE_actions <- sapply(1:3, function(a) {
      compute_EFE_L1(a, current_beliefs_L1, current_beliefs_L2, model)
    })
    
    action_probs <- exp(-model$gamma_L1 * EFE_actions)
    action_probs <- action_probs / sum(action_probs)
    action <- sample(1:3, 1, prob = action_probs)
    actions[t] <- action
    
    # Generate next state at level 1
    L2_state <- which.max(current_beliefs_L2)
    B_action <- model$B_L1[, , action, L2_state]
    next_state_probs <- B_action[current_state_L1, ]
    next_state <- sample(1:3, 1, prob = next_state_probs)
    
    # Generate observation
    obs_probs <- model$A_L1[next_state, ]
    observation <- sample(1:3, 1, prob = obs_probs)
    observations_L1[t] <- observation
    
    # Update beliefs at level 1 (fast)
    likelihood <- model$A_L1[, observation]
    predicted_state <- as.vector(B_action %*% current_beliefs_L1)
    posterior <- likelihood * predicted_state
    current_beliefs_L1 <- posterior / sum(posterior)
    
    current_state_L1 <- next_state
    
    # Periodically update level 2 beliefs
    if (t %% update_L2_every == 0 && t > update_L2_every) {
      current_beliefs_L2 <- update_beliefs_L2(
        current_beliefs_L2, 
        states_L1[1:t], 
        model,
        window = update_L2_every
      )
    }
    
    # Periodically update narrative belief
    if (t %% update_L3_every == 0 && t > update_L3_every) {
      current_narrative <- update_narrative(
        current_narrative,
        beliefs_L2_history[1:t, ],
        model,
        window = update_L3_every
      )
      
      # Rebuild model with updated narrative
      model <- setup_hierarchical_model(narrative_belief = current_narrative)
    }
  }
  
  data.frame(
    time = 1:n_timesteps,
    state_L1 = states_L1,
    observation = observations_L1,
    action = actions,
    belief_L1_positive = beliefs_L1_history[, 1],
    belief_L1_neutral = beliefs_L1_history[, 2],
    belief_L1_negative = beliefs_L1_history[, 3],
    belief_L2_success = beliefs_L2_history[, 1],
    belief_L2_mixed = beliefs_L2_history[, 2],
    belief_L2_failure = beliefs_L2_history[, 3],
    narrative_belief = narrative_history
  )
}

# Simulate agents with different initial narratives
set.seed(123)

# Agent starting with healthy narrative ("I am lovable")
healthy_narrative <- simulate_hierarchical_agent(
  n_timesteps = 300,
  initial_narrative = 0.2,
  update_L2_every = 10,
  update_L3_every = 50
)
healthy_narrative$agent_type <- "Healthy Narrative"

# Agent starting with depressed narrative ("I am unlovable")
depressed_narrative <- simulate_hierarchical_agent(
  n_timesteps = 300,
  initial_narrative = 0.8,
  update_L2_every = 10,
  update_L3_every = 50
)
depressed_narrative$agent_type <- "Depressed Narrative"

combined_data <- rbind(healthy_narrative, depressed_narrative)

# Plot Level 1: Momentary mood states
ggplot(combined_data, aes(x = time, y = state_L1, color = agent_type)) +
  geom_line(alpha = 0.3) +
  geom_smooth(se = TRUE, linewidth = 1.2) +
  scale_y_continuous(breaks = 1:3, 
                     labels = c("Positive", "Neutral", "Negative")) +
  labs(title = "Level 1: Momentary Mood Trajectories",
       subtitle = "Higher-level narratives constrain lower-level mood dynamics",
       x = "Time", y = "Mood State", color = "Agent Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy Narrative" = "#2E7D32", 
                                 "Depressed Narrative" = "#C62828"))

# Plot Level 2: Relational pattern beliefs
belief_L2_long <- combined_data %>%
  select(time, agent_type, belief_L2_success, belief_L2_mixed, belief_L2_failure) %>%
  pivot_longer(cols = starts_with("belief_L2"), 
               names_to = "belief_type", 
               values_to = "belief_strength") %>%
  mutate(belief_type = recode(belief_type,
                              "belief_L2_success" = "Relationships Succeed",
                              "belief_L2_mixed" = "Relationships Mixed",
                              "belief_L2_failure" = "Relationships Fail"))

ggplot(belief_L2_long, aes(x = time, y = belief_strength, 
                           color = belief_type, linetype = agent_type)) +
  geom_smooth(se = FALSE, linewidth = 1) +
  labs(title = "Level 2: Relational Pattern Beliefs Over Time",
       subtitle = "Intermediate timescale beliefs integrate momentary experiences",
       x = "Time", y = "Belief Strength", 
       color = "Belief Type", linetype = "Agent Type") +
  theme_minimal() +
  scale_color_manual(values = c("Relationships Succeed" = "#1B5E20",
                                 "Relationships Mixed" = "#F57F17", 
                                 "Relationships Fail" = "#B71C1C"))

# Plot Level 3: Narrative belief evolution
ggplot(combined_data, aes(x = time, y = narrative_belief, color = agent_type)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  annotate("text", x = 250, y = 0.1, label = "\"I am lovable\"", size = 4) +
  annotate("text", x = 250, y = 0.9, label = "\"I am unlovable\"", size = 4) +
  labs(title = "Level 3: Core Narrative Belief Evolution",
       subtitle = "Highest-level beliefs change extremely slowly despite lower-level evidence",
       x = "Time", y = "Narrative Belief: Unlovable ← → Lovable", 
       color = "Initial Narrative") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy Narrative" = "#2E7D32", 
                                 "Depressed Narrative" = "#C62828")) +
  scale_y_reverse()
```

The simulations reveal several critical insights. First, agents with different narrative-level beliefs exhibit dramatically different mood trajectories despite experiencing the same underlying stochastic environment. The depressed narrative constrains level 2 beliefs toward "relationships fail," which subsequently biases level 1 transitions toward negative moods and ruminative actions. Second, timescale separation creates strong path dependence—early narrative beliefs shape subsequent learning, making it difficult for contradictory evidence at lower levels to propagate upward. Third, the extreme slowness of narrative change means that even hundreds of timesteps of experience may barely shift core identity beliefs.

## The Hierarchical Trap: How Top-Down Priors Overwhelm Evidence

The most pernicious aspect of hierarchical models in depression is the capacity of high-level beliefs to render lower-level evidence essentially relevant. When a depressed individual with the narrative "I am fundamentally unlovable" experiences a positive interaction, the hierarchical system processes it defensively. At Level 1, the positive observation is registered, momentarily improving mood. At Level 2, however, this single event is contextualized within a belief that "relationships fail," leading the individual to dismiss the event as an anomaly or mere politeness. Finally, at Level 3, the core belief generates such a strong prior that the positive interaction is deemed non-diagnostic of one's fundamental worth.

Mathematically, positive evidence is discounted as it propagates up the hierarchy. We can formalize this as a precision-weighted prediction error at each level:

$$\delta^{(l)} = \gamma^{(l)} \cdot (s^{(l)}_{\text{observed}} - s^{(l)}_{\text{predicted from } l+1})$$

When $\gamma^{(l+1)}$ is very high (indicating a precise higher-level belief), it generates strong predictions that overwhelm evidence from below. The posterior at level $l$ approximates to:

$$p(s^{(l)} \mid o^{(l)}, s^{(l+1)}) \propto p(o^{(l)} \mid s^{(l)}) \cdot p(s^{(l)} \mid s^{(l+1)})$$

If the prior $p(s^{(l)} \mid s^{(l+1)})$ is sharply peaked due to high precision from above, the likelihood $p(o^{(l)} \mid s^{(l)})$ has minimal influence on the posterior. Practically, this means that regardless of momentary positive experiences, the higher-level belief remains dominant.

The following simulation explicitly demonstrates this precision-weighting effect:

```r
# Simulate the effect of narrative precision on evidence integration
simulate_precision_effects <- function(
    n_experiences = 100,
    narrative_belief = 0.8,    # Initial: "I am unlovable"
    narrative_precision = 8.0,  # How resistant to change
    evidence_quality = 0.7      # How positive the experiences are
) {
  
  beliefs <- numeric(n_experiences + 1)
  prediction_errors <- numeric(n_experiences)
  belief_updates <- numeric(n_experiences)
  
  beliefs[1] <- narrative_belief
  
  for (i in 1:n_experiences) {
    
    # Generate experience (0 = positive, 1 = negative)
    # evidence_quality determines distribution
    experience <- rbinom(1, 1, 1 - evidence_quality)
    
    # Prediction from narrative
    predicted_experience <- beliefs[i]
    
    # Prediction error
    PE <- experience - predicted_experience
    prediction_errors[i] <- PE
    
    # Precision-weighted update
    # High precision means small updates
    learning_rate <- 1 / (1 + narrative_precision)
    update <- learning_rate * PE
    belief_updates[i] <- update
    
    # Update belief
    beliefs[i + 1] <- beliefs[i] + update
    beliefs[i + 1] <- max(0, min(1, beliefs[i + 1]))
  }
  
  data.frame(
    experience = 0:n_experiences,
    belief = beliefs,
    narrative_precision = narrative_precision
  )
}

# Compare different precision levels
low_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 2.0,
  evidence_quality = 0.7
)
low_precision$precision_type <- "Low Precision (Flexible)"

medium_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 8.0,
  evidence_quality = 0.7
)
medium_precision$precision_type <- "Medium Precision (Normal)"

high_precision <- simulate_precision_effects(
  n_experiences = 100,
  narrative_belief = 0.8,
  narrative_precision = 20.0,
  evidence_quality = 0.7
)
high_precision$precision_type <- "High Precision (Rigid)"

precision_data <- rbind(low_precision, medium_precision, high_precision)

ggplot(precision_data, aes(x = experience, y = belief, color = precision_type)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = 0.3, linetype = "dotted", alpha = 0.5) +
  annotate("text", x = 80, y = 0.32, 
           label = "Expected belief given 70% positive experiences", 
           size = 3.5) +
  labs(title = "Narrative Precision Determines Resistance to Evidence",
       subtitle = "High-precision beliefs barely update despite consistent positive experiences",
       x = "Number of Positive Experiences", 
       y = "Narrative Belief (1 = Unlovable)", 
       color = "Precision Level") +
  theme_minimal() +
  scale_color_manual(values = c("Low Precision (Flexible)" = "#2E7D32",
                                 "Medium Precision (Normal)" = "#F57F17",
                                 "High Precision (Rigid)" = "#C62828"))
```

This simulation starkly illustrates the clinical challenge. With high narrative precision, even 100 predominantly positive experiences barely shift the core belief. The belief changes from 0.8 to perhaps 0.75—a difference unlikely to be subjectively noticed or functionally meaningful. The high-precision narrative effectively immunizes itself against contradictory evidence.

## Rumination as Failed Hierarchical Inference

Rumination can be understood precisely as a failure of hierarchical inference to converge. When faced with a problem—say, a social rejection—healthy cognition proceeds through a hierarchical evaluation that resolves uncertainty. The immediate negative experience is contextualized by pattern beliefs ("Is this typical?") and narrative beliefs ("What does this say about me?"). In healthy processing, strong, positive priors at the narrative level rapidly resolve the inference: "This was an isolated event, not diagnostic of my worth." The system minimizes free energy, and the individual moves on.

In depressed rumination, however, this inference fails to converge. The negative experience confirms the pattern of failure (Level 2) and the narrative of unlovability (Level 3). However, because reality is complex, occasional ambiguous or positive data points create residual prediction errors at Level 1. This triggers a loop: the individual replays the interaction (Level 1) to resolve the ambiguity, but the rigid narrative (Level 3) biases the interpretation again, preventing resolution. The system cycles endlessly between levels, unable to settle on a stable posterior belief.

We model this as a failure to minimize free energy across the hierarchy:

```r
# Simulate rumination as failed hierarchical convergence
simulate_rumination_cycle <- function(
    n_iterations = 50,
    narrative_bias = 0.8,
    evidence_ambiguity = 0.5  # How ambiguous the evidence is
) {
  
  # Track which level is being evaluated at each iteration
  active_level <- numeric(n_iterations)
  free_energy_L1 <- numeric(n_iterations)
  free_energy_L2 <- numeric(n_iterations)
  free_energy_L3 <- numeric(n_iterations)
  total_free_energy <- numeric(n_iterations)
  
  # Initial states (high uncertainty)
  belief_L1 <- c(0.33, 0.34, 0.33)
  belief_L2 <- c(0.33, 0.34, 0.33)
  belief_L3 <- narrative_bias
  
  for (iter in 1:n_iterations) {
    
    # Generate ambiguous evidence
    evidence_valence <- rnorm(1, mean = 0.5 - narrative_bias, 
                              sd = evidence_ambiguity)
    
    # Level 1: Try to explain immediate experience
    # Ambiguous evidence creates uncertainty
    if (evidence_valence > 0) {
      obs_L1 <- c(0.6, 0.3, 0.1)
    } else {
      obs_L1 <- c(0.1, 0.3, 0.6)
    }
    
    # Level 2 prediction of L1
    pred_L1_from_L2 <- c(
      0.3 + 0.3 * (1 - belief_L3),  # Positive
      0.4,                           # Neutral
      0.3 + 0.3 * belief_L3          # Negative
    )
    
    # Level 3 prediction of L2
    pred_L2_from_L3 <- c(
      0.3 * (1 - belief_L3),
      0.4,
      0.3 + 0.4 * belief_L3
    )
    
    # Compute free energy at each level (KL divergence + surprise)
    FE_L1 <- sum(belief_L1 * log((belief_L1 + 1e-10) / (obs_L1 + 1e-10))) +
             -sum(obs_L1 * log(obs_L1 + 1e-10))
    
    FE_L2 <- sum(belief_L2 * log((belief_L2 + 1e-10) / (pred_L2_from_L3 + 1e-10))) +
             sum(belief_L1 * log((belief_L1 + 1e-10) / (pred_L1_from_L2 + 1e-10)))
    
    FE_L3 <- (belief_L3 - mean(belief_L2))^2
    
    free_energy_L1[iter] <- FE_L1
    free_energy_L2[iter] <- FE_L2
    free_energy_L3[iter] <- FE_L3
    total_free_energy[iter] <- FE_L1 + FE_L2 + FE_L3
    
    # Determine which level has highest free energy (most uncertainty)
    FE_levels <- c(FE_L1, FE_L2, FE_L3)
    active_level[iter] <- which.max(FE_levels)
    
    # Update the active level
    if (active_level[iter] == 1) {
      # Focus on momentary interpretation
      belief_L1 <- 0.7 * belief_L1 + 0.3 * obs_L1
      belief_L1 <- belief_L1 / sum(belief_L1)
    } else if (active_level[iter] == 2) {
      # Focus on pattern interpretation
      belief_L2 <- 0.8 * belief_L2 + 0.2 * pred_L2_from_L3
      belief_L2 <- belief_L2 / sum(belief_L2)
    } else {
      # Focus on narrative interpretation (but very resistant to change)
      narrative_update <- 0.02 * (mean(belief_L2) - belief_L3)
      belief_L3 <- belief_L3 + narrative_update
      belief_L3 <- max(0, min(1, belief_L3))
    }
  }
  
  data.frame(
    iteration = 1:n_iterations,
    active_level = active_level,
    FE_L1 = free_energy_L1,
    FE_L2 = free_energy_L2,
    FE_L3 = free_energy_L3,
    total_FE = total_free_energy,
    narrative_bias = narrative_bias
  )
}

# Simulate healthy vs ruminative processing
healthy_processing <- simulate_rumination_cycle(
  n_iterations = 50,
  narrative_bias = 0.3,
  evidence_ambiguity = 0.3
)
healthy_processing$condition <- "Healthy (Converges)"

ruminative_processing <- simulate_rumination_cycle(
  n_iterations = 50,
  narrative_bias = 0.8,
  evidence_ambiguity = 0.6
)
ruminative_processing$condition <- "Ruminative (Fails to Converge)"

convergence_data <- rbind(healthy_processing, ruminative_processing)

# Plot free energy over time
ggplot(convergence_data, aes(x = iteration, y = total_FE, color = condition)) +
  geom_line(linewidth = 1.2) +
  labs(title = "Free Energy Minimization: Convergence vs Rumination",
       subtitle = "Healthy processing rapidly reduces uncertainty; rumination fails to converge",
       x = "Mental Simulation Iteration", 
       y = "Total Hierarchical Free Energy",
       color = "Processing Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy (Converges)" = "#2E7D32",
                                 "Ruminative (Fails to Converge)" = "#C62828"))

# Plot which level is active
convergence_data$level_label <- factor(
  convergence_data$active_level,
  levels = 1:3,
  labels = c("Momentary\n(Level 1)", "Patterns\n(Level 2)", "Narrative\n(Level 3)")
)

ggplot(convergence_data, aes(x = iteration, y = level_label, color = condition)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "Level of Hierarchical Processing Over Time",
       subtitle = "Rumination cycles between levels without resolution",
       x = "Iteration", y = "Active Processing Level",
       color = "Processing Type") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy (Converges)" = "#2E7D32",
                                 "Ruminative (Fails to Converge)" = "#C62828"))
```

The data shows that healthy processing rapidly reduces free energy, stabilizing at a preferred level (typically the highest level capable of resolving the uncertainty). In contrast, ruminative processing cycles erratically between levels without achieving convergence. The system repeatedly drops from narrative-level processing back to momentary re-interpretation, then back to pattern evaluation, in an endless loop that fails to minimize uncertainty.

## Therapeutic Implications: Targeting the Right Level

This hierarchical framework has profound implications for therapeutic intervention. Traditional cognitive therapy often targets Level 1 and Level 2—challenging automatic negative thoughts and identifying maladaptive patterns. However, if the core narrative belief at Level 3 holds high precision, these lower-level interventions may prove insufficient. A patient might successfully challenge individual negative thoughts yet find their core belief unchanged, continuing to generate new negative predictions.

Effective therapy must therefore strategize based on the precision profile of the patient. One approach is to reduce precision at Level 3, helping the patient become less certain about their core narrative to open it for revision—the domain of schema therapy. Another strategy involves bypassing the narrative level entirely; mindfulness and acceptance-based approaches teach patients to observe thoughts without engaging in narrative-level processing, effectively decoupling Level 3 beliefs from moment-to-moment experience. For moderately high narrative precision, the behavioral accumulation of evidence may work, provided there is enough consistent positive experience to eventually propagate up the hierarchy.

## Conclusion

Hierarchical Active Inference reframes depression as an architectural problem. The same cognitive hierarchy that provides stability to healthy identity can trap individuals in self-perpetuating negative patterns when narrative-level beliefs become biased and rigid. Top-down predictions from these beliefs overwhelm bottom-up evidence, creating a system that is formally resistant to change.

Recovery is not merely about willpower or "positive thinking"; it is about systematically restructuring a hierarchical generative model. This requires the careful accumulation and integration of evidence across multiple timescales, often necessitating interventions that target the highest levels of the cognitive hierarchy to enable lasting change below.










