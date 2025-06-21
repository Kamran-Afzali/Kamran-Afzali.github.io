# Modeling Affective Dynamics in Reinforcement Learning: A Comparative Study of Healthy and Depressed Agents

## Introduction

Reinforcement learning (RL) has emerged as a powerful framework for modeling decision-making processes in both artificial agents and biological organisms. By learning from interactions with their environment, agents can adapt their behavior to maximize cumulative rewards. However, traditional RL models often overlook the influence of affective states, such as mood, on decision-making. Recent advancements have sought to integrate emotional dynamics into RL frameworks, providing a more comprehensive understanding of behavior, particularly in the context of psychological disorders like depression.

Depression is characterized by persistent negative mood, anhedonia, and cognitive biases that affect decision-making. Computational psychiatry has leveraged RL models to dissect the cognitive mechanisms underlying depression, offering insights into how affective states modulate learning and choice behavior. In this blog post, we explore two R-based simulation frameworks that incorporate mood dynamics into RL models to compare the behavior of "healthy" and "depressed" agents. The first framework introduces between-person variability and exogenous environmental events, while the second incorporates meta-cognitive mechanisms to model affective decision-making.

## Part 1: Mood-Modulated Bayesian Reinforcement Learning with Between-Person Variability

### Overview

The first simulation framework extends a mood-modulated Bayesian RL model by introducing individual differences and external environmental events. In a 5-armed bandit task, each of 20 simulated agents is endowed with parameters governing pessimism, self-defeating bias, mood decay, and mood influence. Notably, the pessimistic prior mean and self-defeating bias are sampled from a correlated bivariate normal distribution, introducing realistic covariance in affective traits. The environment is punctuated by external events—negative at trials 50 and 180, positive at 120—which directly perturb the agent’s mood.

### Simulation Details

The environment consists of five arms with varying reward probabilities and values:

```r
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)
reward_vals  <- c(1, 1, -1, -1, -2)
self_defeating_arms <- 3:5
```

External events are introduced at specific trials to simulate environmental perturbations:

```r
external_events <- rep(0, episodes)
external_events[c(50, 120, 180)] <- c(-2, 1, -1)
```

Individual differences are modeled by sampling parameters from specified distributions:

```r
mean_vec <- c(0, 0)
cov_mat <- matrix(c(0.25, 0.15,
                    0.15, 1.0), nrow = 2, byrow = TRUE)
correlated_params <- MASS::mvrnorm(N_agents, mu = mean_vec, Sigma = cov_mat)
colnames(correlated_params) <- c("pessimistic_prior_mean", "self_defeat_bias")
mood_decay <- runif(N_agents, 0.85, 0.98)
mood_influence <- rnorm(N_agents, 2, 0.5)
```

Each agent selects actions using Thompson sampling, with mood dynamically modulating the variance of the sampled Q-values to shift the exploration–exploitation balance. The mood is updated as an exponentially smoothed function of prior rewards and is directly perturbed by external events.

### Results

The simulation captures action choice, reward received, and mood trajectory for each agent across 200 episodes. The mood trajectories, visualized via a multi-agent time series plot, reveal heterogeneity in affective dynamics and illustrate how internal traits interact with external perturbations. Agents with higher pessimism and self-defeating bias exhibit more negative mood trajectories and are more susceptible to external negative events.

## Part 2: Meta-Cognitive Mechanisms in Affective Decision-Making

### Overview

The second simulation framework incorporates meta-cognitive mechanisms to model affective decision-making in "depressed" and "non-depressed" agents. Each agent interacts with a 5-armed bandit environment over 200 trials, with distinct probabilities and magnitudes of rewards. The agents implement Bayesian Q-learning, where mood modulates exploration through variance scaling, and updates to beliefs depend on a learned helplessness factor that reduces learning following repeated punishments.

### Simulation Details

The environment setup is similar to the first framework:

```r
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)
reward_vals  <- c(1, 1, -1, -1, -2)
self_defeating_arms <- 3:5
```

The agent function incorporates meta-cognitive variables:

```r
bayesian_agent_meta <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0,
    mood_decay = 0.9,
    mood_influence = 1.5,
    learned_helplessness_threshold = 5,
    learned_helplessness_factor = 0.5,
    rumination_weight_success = 0.3,
    rumination_weight_failure = 0.7
) {
    # Function body
}
```

Two groups are defined by parameter sets that reflect psychological differences:

```r
params_non_depressed <- list(
  pessimistic_prior_mean = 0,
  self_defeat_bias = 0,
  mood_decay = 0.95,
  mood_influence = 1.0,
  learned_helplessness_threshold = 10,
  learned_helplessness_factor = 0.8,
  rumination_weight_success = 0.5,
  rumination_weight_failure = 0.5
)

params_depressed <- list(
  pessimistic_prior_mean = -0.5,
  self_defeat_bias = 2,
  mood_decay = 0.9,
  mood_influence = 2.0,
  learned_helplessness_threshold = 3,
  learned_helplessness_factor = 0.3,
  rumination_weight_success = 0.2,
  rumination_weight_failure = 0.8
)
```

Thirty agents per group are simulated, and the output is summarized across trials to estimate average cumulative reward and mood.

### Results

Visualizations reveal significant group differences, with depressed agents accumulating fewer rewards and displaying more negative mood trajectories. The depressed agents exhibit greater pessimism, stronger self-defeating bias, faster mood decay, and heightened susceptibility to negative feedback through lower helplessness thresholds and biased rumination. These findings highlight the behavioral and emotional consequences of maladaptive cognitive-affective dynamics.

## Discussion

The integration of mood dynamics into RL models provides a nuanced understanding of decision-making processes, particularly in the context of depression. The first framework demonstrates how individual differences and environmental events interact to shape affective trajectories, while the second framework elucidates the role of meta-cognitive mechanisms in modulating learning and behavior.([Computational Psychiatry][1])

These models align with empirical findings in computational psychiatry, which suggest that depression is associated with impairments in reinforcement learning, including diminished reward sensitivity and increased punishment sensitivity . Moreover, the incorporation of learned helplessness and rumination into the models reflects key features of depressive cognition .([ScienceDirect][2], [Wikipedia][3])

By simulating both "healthy" and "depressed" agents, these frameworks offer valuable insights into the cognitive and affective processes underlying depression. They also provide a platform for testing interventions aimed at modifying maladaptive learning patterns and improving decision-making in individuals with depression.

## Conclusion

The integration of affective dynamics into reinforcement learning models represents a significant advancement in our understanding of decision-making processes. By simulating individual differences and meta-cognitive mechanisms, these models capture the complexity of human behavior and offer a computational framework for studying psychological disorders like depression. Future research should continue to refine these models and explore their applications in clinical settings, with the goal of developing targeted interventions to improve mental health outcomes.


## References

Beck, A. T., Rush, A. J., Shaw, B. F., & Emery, G. (1979). *Cognitive therapy of depression*. Guilford Press. [https://www.guilford.com/books/Cognitive-Therapy-of-Depression/Beck-Rush-Shaw-Emery/9780898629194](https://www.guilford.com/books/Cognitive-Therapy-of-Depression/Beck-Rush-Shaw-Emery/9780898629194)

Dayan, P., & Huys, Q. J. M. (2008). Serotonin, inhibition, and negative mood. *PLoS Computational Biology, 4*(2), e4. [https://doi.org/10.1371/journal.pcbi.0040004](https://doi.org/10.1371/journal.pcbi.0040004)

Eshel, N., & Roiser, J. P. (2010). Reward and punishment processing in depression. *Biological Psychiatry, 68*(2), 118–124. [https://doi.org/10.1016/j.biopsych.2010.01.027](https://doi.org/10.1016/j.biopsych.2010.01.027)

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience, 38*, 1–23. [https://doi.org/10.1146/annurev-neuro-071714-033928](https://doi.org/10.1146/annurev-neuro-071714-033928)

Maia, T. V., & Frank, M. J. (2011). From reinforcement learning models to psychiatric and neurological disorders. *Nature Neuroscience, 14*(2), 154–162. [https://doi.org/10.1038/nn.2723](https://doi.org/10.1038/nn.2723)

Montague, P. R., Dolan, R. J., Friston, K. J., & Dayan, P. (2012). Computational psychiatry. *Trends in Cognitive Sciences, 16*(1), 72–80. [https://doi.org/10.1016/j.tics.2011.11.018](https://doi.org/10.1016/j.tics.2011.11.018)

Pittig, A., Treanor, M., LeBeau, R. T., & Craske, M. G. (2018). The role of associative learning in anxiety disorders: A reassessment. *Behaviour Research and Therapy, 112*, 1–17. [https://doi.org/10.1016/j.brat.2018.10.011](https://doi.org/10.1016/j.brat.2018.10.011)

Rottenberg, J., & Hindash, A. C. (2015). Emerging evidence for emotion context insensitivity in depression. *Current Opinion in Psychology, 4*, 72–77. [https://doi.org/10.1016/j.copsyc.2015.03.020](https://doi.org/10.1016/j.copsyc.2015.03.020)

Sutton, R. S., & Barto, A. G. (2018). *Reinforcement learning: An introduction* (2nd ed.). MIT Press. [http://incompleteideas.net/book/the-book-2nd.html](http://incompleteideas.net/book/the-book-2nd.html)

Treadway, M. T., & Zald, D. H. (2013). Parsing anhedonia: Translational models of reward-processing deficits in psychopathology. *Current Directions in Psychological Science, 22*(3), 244–249. [https://doi.org/10.1177/0963721412474460](https://doi.org/10.1177/0963721412474460)

Wikipedia contributors. (2023, September 26). *Behavioral theories of depression*. Wikipedia. [https://en.wikipedia.org/wiki/Behavioral\_theories\_of\_depression](https://en.wikipedia.org/wiki/Behavioral_theories_of_depression)

Whitton, A. E., Treadway, M. T., & Pizzagalli, D. A. (2015). Reward processing dysfunction in major depression, bipolar disorder and schizophrenia. *Current Opinion in Psychiatry, 28*(1), 7–12. [https://doi.org/10.1097/YCO.0000000000000122](https://doi.org/10.1097/YCO.0000000000000122)






## Code

This R script extends a mood-modulated Bayesian reinforcement learning framework by introducing between-person variability and exogenous environmental events. In a 5-armed bandit task, each of 20 simulated agents is endowed with individual-level parameters governing pessimism, self-defeating bias, mood decay, and mood influence. Notably, pessimistic prior mean and self-defeating bias are sampled from a correlated bivariate normal distribution, introducing realistic covariance in affective traits. The environment is punctuated by external events—negative at trials 50 and 180, positive at 120—which directly perturb the agent’s mood, operationalized as an exponentially smoothed function of prior rewards. Each agent selects actions using Thompson sampling, with mood dynamically modulating the variance of the sampled Q-values to shift the exploration–exploitation balance. The resulting dataset captures action choice, reward received, and mood trajectory for each agent across 200 episodes. The mood trajectories, visualized via a multi-agent time series plot, reveal heterogeneity in affective dynamics and illustrate how internal traits interact with external perturbations.






```
set.seed(123)
library(ggplot2)
library(reshape2)

# Environment
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)
reward_vals  <- c(1, 1, -1, -1, -2)
self_defeating_arms <- 3:5
episodes <- 200
N_agents <- 20

# External events (e.g., negative at 50, positive at 120, negative at 180)
external_events <- rep(0, episodes)
external_events[c(50, 120, 180)] <- c(-2, 1, -1)


mean_vec <- c(0, 0)
cov_mat <- matrix(c(0.25, 0.15,
                    0.15, 1.0), nrow = 2, byrow = TRUE)

# Generate correlated samples
correlated_params <- MASS::mvrnorm(N_agents, mu = mean_vec, Sigma = cov_mat)
colnames(correlated_params) <- c("pessimistic_prior_mean", "self_defeat_bias")

# Generate other independent parameters
mood_decay <- runif(N_agents, 0.85, 0.98)
mood_influence <- rnorm(N_agents, 2, 0.5)

# Combine into a data frame
agents <- data.frame(
  mood_decay = mood_decay,
  mood_influence = mood_influence,
  pessimistic_prior_mean = correlated_params[, "pessimistic_prior_mean"],
  self_defeat_bias = correlated_params[, "self_defeat_bias"]
)



run_agent <- function(params) {
  K <- length(reward_probs)
  mu <- rep(params$pessimistic_prior_mean, K)
  tau <- rep(1/10, K)
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0
  mood_hist <- numeric(episodes)
  for (i in 1:episodes) {
    mood_clamped <- min(max(mood, -1), 1)
    mood_sigma_scale <- exp(-params$mood_influence * mood_clamped)
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + params$self_defeat_bias
    action <- which.max(sampled_Q)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
    mood <- params$mood_decay * mood + (1 - params$mood_decay) * reward
    mood <- mood + external_events[i]
    mood_hist[i] <- mood
  }
  data.frame(trial = 1:episodes, action = actions, reward = rewards, mood = mood_hist)
}

# Simulate all agents
results <- lapply(1:N_agents, function(i) {
  df <- run_agent(agents[i, ])
  df$agent <- i
  df
})
results_df <- do.call(rbind, results)

# Visualize mood trajectories for all agents
ggplot(results_df, aes(x = trial, y = mood, group = agent, color = factor(agent))) +
  geom_line() +
  labs(title = "Mood Trajectories with Between-Person Differences and External Events",
       x = "Trial", y = "Mood", color = "Agent") +
  theme_minimal()
```




 This R script simulates a reinforcement learning framework that incorporates meta-cognitive mechanisms to model affective decision-making in “depressed” and “non-depressed” agents. Each agent interacts with a 5-armed bandit environment over 200 trials, with distinct probabilities and magnitudes of rewards. The agents implement Bayesian Q-learning, where mood modulates exploration through variance scaling, and updates to beliefs depend on a learned helplessness factor that reduces learning following repeated punishments. Two groups are defined by parameter sets that reflect psychological differences: the depressed group exhibits greater pessimism, stronger self-defeating bias, faster mood decay, and heightened susceptibility to negative feedback through lower helplessness thresholds and biased rumination (favoring negative outcomes). Thirty agents per group are simulated, and the output is summarized across trials to estimate average cumulative reward and mood. Visualizations reveal significant group differences, with depressed agents accumulating fewer rewards and displaying more negative mood trajectories, highlighting the behavioral and emotional consequences of maladaptive cognitive-affective dynamics.




```
set.seed(123)
library(ggplot2)
library(reshape2)
library(dplyr)

# Environment
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)
reward_vals  <- c(1, 1, -1, -1, -2)
self_defeating_arms <- 3:5
episodes <- 200
n_agents <- 30

# Agent function with meta-cognitive variables
bayesian_agent_meta <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0,
    mood_decay = 0.9,
    mood_influence = 1.5,
    learned_helplessness_threshold = 5,
    learned_helplessness_factor = 0.5,
    rumination_weight_success = 0.3,
    rumination_weight_failure = 0.7
) {
  K <- length(reward_probs)
  mu <- rep(pessimistic_prior_mean, K)
  tau <- rep(1/prior_var, K)
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0
  mood_hist <- numeric(episodes)
  consecutive_punishments <- 0
  alpha_base <- 1.0
  
  for (i in 1:episodes) {
    mood_clamped <- min(max(mood, -1), 1)
    mood_sigma_scale <- exp(-mood_influence * mood_clamped)
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    action <- which.max(sampled_Q)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Learned helplessness
    if (reward < 0) {
      consecutive_punishments <- consecutive_punishments + 1
    } else {
      consecutive_punishments <- 0
    }
    if (consecutive_punishments >= learned_helplessness_threshold) {
      alpha <- alpha_base * learned_helplessness_factor
    } else {
      alpha <- alpha_base
    }
    
    # Bayesian update
    tau[action] <- tau[action] + alpha
    mu[action] <- (mu[action] * (tau[action] - alpha) + alpha * reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
    
    # Rumination
    if (reward > 0) {
      mood_update <- rumination_weight_success * reward
    } else if (reward < 0) {
      mood_update <- rumination_weight_failure * reward
    } else {
      mood_update <- 0
    }
    mood <- mood_decay * mood + (1 - mood_decay) * mood_update
    mood_hist[i] <- mood
  }
  list(actions = actions, rewards = rewards, mood = mood_hist)
}

# Parameter sets for groups
params_non_depressed <- list(
  pessimistic_prior_mean = 0,
  self_defeat_bias = 0,
  mood_decay = 0.95,
  mood_influence = 1.0,
  learned_helplessness_threshold = 10,
  learned_helplessness_factor = 0.8,
  rumination_weight_success = 0.5,
  rumination_weight_failure = 0.5
)

params_depressed <- list(
  pessimistic_prior_mean = -0.5,
  self_defeat_bias = 2,
  mood_decay = 0.9,
  mood_influence = 2.0,
  learned_helplessness_threshold = 3,
  learned_helplessness_factor = 0.3,
  rumination_weight_success = 0.2,
  rumination_weight_failure = 0.8
)

# Run simulations
sim_results <- lapply(1:n_agents, function(i) {
  # Non-depressed
  nd <- do.call(bayesian_agent_meta, c(list(episodes = episodes, prior_var = 10), params_non_depressed))
  # Depressed
  d <- do.call(bayesian_agent_meta, c(list(episodes = episodes, prior_var = 10), params_depressed))
  data.frame(
    Trial = rep(1:episodes, 2),
    CumulativeReward = c(cumsum(nd$rewards), cumsum(d$rewards)),
    Mood = c(nd$mood, d$mood),
    Agent = rep(i, 2 * episodes),
    Group = rep(c("Non-Depressed", "Depressed"), each = episodes)
  )
})
sim_df <- bind_rows(sim_results)

# Summarize across agents
summary_df <- sim_df %>%
  group_by(Group, Trial) %>%
  summarize(
    MeanCumulativeReward = mean(CumulativeReward),
    SEMCumulativeReward = sd(CumulativeReward) / sqrt(n()),
    MeanMood = mean(Mood),
    SEMMood = sd(Mood) / sqrt(n())
  )

# Plot average cumulative reward
p1 <- ggplot(summary_df, aes(x = Trial, y = MeanCumulativeReward, color = Group)) +
  geom_line(size = 1) +
  geom_ribbon(aes(ymin = MeanCumulativeReward - SEMCumulativeReward, ymax = MeanCumulativeReward + SEMCumulativeReward, fill = Group), alpha = 0.2, color = NA) +
  labs(title = "Average Cumulative Reward", x = "Trial", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Non-Depressed" = "#00bfc4", "Depressed" = "#f8766d")) +
  scale_fill_manual(values = c("Non-Depressed" = "#00bfc4", "Depressed" = "#f8766d"))

# Plot average mood
p2 <- ggplot(summary_df, aes(x = Trial, y = MeanMood, color = Group)) +
  geom_line(size = 1) +
  geom_ribbon(aes(ymin = MeanMood - SEMMood, ymax = MeanMood + SEMMood, fill = Group), alpha = 0.2, color = NA) +
  labs(title = "Average Mood", x = "Trial", y = "Mood") +
  theme_minimal() +
  scale_color_manual(values = c("Non-Depressed" = "#00bfc4", "Depressed" = "#f8766d")) +
  scale_fill_manual(values = c("Non-Depressed" = "#00bfc4", "Depressed" = "#f8766d"))

print(p1)
print(p2)
```

