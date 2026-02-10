

# Modeling Healthy vs. Depressed Decision-Making with Q-Learning

Reinforcement learning (RL) models have become a powerful framework for understanding how people learn from feedback and make decisions.  In computational psychiatry, such models have been applied to characterize the cognitive and affective disturbances in disorders like depression.  Major Depressive Disorder (MDD) is marked by symptoms such as anhedonia (reduced enjoyment of rewarding activities), pervasive pessimism, and indecisiveness – difficulties that closely implicate the brain’s reward-learning circuits.  In fact, behavioral studies report that depressed individuals are slower to learn rewarding associations and make fewer optimal choices than healthy controls.  This suggests that formal RL algorithms can capture key aspects of depressive cognition.  Indeed, recent work uses Q-learning and Bayesian learning models to simulate “healthy” versus “depressed” agents performing tasks like multi-armed bandits (choosing among options with probabilistic rewards) and finds systematic differences in their parameters and behavior. In this post, we review how a simple Q-learning model can illustrate differences between healthy and depressed decision-makers.  We begin with an overview of Q-learning and its parameters (learning rate and value sensitivity), then show R code for simulating agents on a 5-armed bandit task.  We compare “healthy” versus “depressed” agents by varying their Q-learning parameters and examine the resulting choice patterns.  Next, we introduce a Bayesian learning agent (with Beta–Bernoulli updates) and show how altering prior beliefs can encode pessimism or self-sabotaging biases.  We also discuss extensions where an internal “mood” variable modulates exploration.  Throughout, we interpret the simulated behaviors in cognitive and affective terms.  Finally, we reflect on what these models offer computational psychiatry, their limitations, and future directions.

## Q-Learning Fundamentals

At its core, reinforcement learning describes how agents learn to map situations to actions in order to maximize cumulative reward.  In a simple bandit task, an agent repeatedly chooses among several options (arms), each of which delivers a stochastic reward (e.g. win or loss) with some unknown probability.  Over time, the agent must learn which arms are most rewarding.  A canonical model-free algorithm for this task is **Q-learning**, in which the agent maintains an expected value $Q(a)$ for each action $a$.  After each choice and observed reward $r$, the chosen action’s Q-value is updated by a prediction error:

$$
Q(a) \leftarrow Q(a) + \alpha \bigl(r - Q(a)\bigr).
$$

Here $\alpha$ (0≤α≤1) is the *learning rate*, controlling how much new outcomes influence the learned value.  A high $\alpha$ means the agent gives strong weight to recent feedback (rapid learning), whereas a low $\alpha$ yields gradual updating.  The agent then uses its Q-values to guide choice, often via a softmax (Boltzmann) rule: it selects action $a$ with probability

$$
P(a) = \frac{\exp[\beta\,Q(a)]}{\sum_{b}\exp[\beta\,Q(b)]},
$$

where $\beta$ is an *inverse temperature* parameter.  A larger $\beta$ makes the agent more deterministic in choosing the current best option, while a smaller $\beta$ leads to more random (exploratory) choice.  In effect, $\alpha$ captures sensitivity to prediction errors, and $\beta$ captures how strongly value differences influence choice.  Empirically, these parameters often differ between populations: meta-analyses have found that depressed or anxious patients tend to have **lower** learning rates and lower $\beta$ than controls, indicating sluggish updating and more stochastic choices.

To make these ideas concrete, consider an R implementation of a Q-learning agent in a 5-armed bandit.  We define a constructor `q_learning_agent(alpha, beta, n_arms)` that initializes the agent’s parameters and a vector of Q-values.  The function `simulate_agent` then runs the agent through a fixed number of trials on a specified bandit environment.  In each trial, the agent samples an action probabilistically via softmax and observes a binary reward (drawn from the chosen arm’s true probability).  We then update the Q-value of the chosen arm using the standard Q-learning rule.  For simplicity, we show just the core logic without extensive bookkeeping or state representation:

```r
q_learning_agent <- function(alpha, beta, n_arms) {
  Q <- rep(0, n_arms)               # Initialize Q-values for each arm
  list(alpha = alpha, beta = beta, Q = Q)
}

simulate_agent <- function(agent, bandit_probs, trials) {
  Q <- agent$Q
  for(t in 1:trials) {
    # Softmax action selection
    exp_Q <- exp(agent$beta * Q)
    probs <- exp_Q / sum(exp_Q)
    action <- sample.int(length(Q), 1, prob = probs)
    # Observe reward (Bernoulli outcome)
    reward <- rbinom(1, 1, bandit_probs[action])
    # Q-learning update
    Q[action] <- Q[action] + agent$alpha * (reward - Q[action])
  }
  return(Q)  # Return final estimated values (for illustration)
}
```

In this code, `alpha` and `beta` are fixed parameters of the agent.  The vector `bandit_probs` holds the true success probabilities of the 5 arms.  For example, we might set

```r
bandit_probs <- c(0.2, 0.4, 0.6, 0.8, 0.9)
```

so that the fifth arm is best (reward prob = 0.9) and the first is worst (0.2).  The agent starts with all Q-values at 0 and then learns from experience.

## Simulating Healthy vs. Depressed Q-Learning Agents

We can now instantiate two agents with different parameters to reflect “healthy” versus “depressed” learning styles.  Suppose the healthy agent has a moderately high learning rate and high value sensitivity (e.g., α=0.3, β=5), while the depressed agent has a lower learning rate and lower β (α=0.1, β=2).  These choices mirror empirical findings: depressed participants often show reduced α and β compared to controls.  We then simulate each agent for, say, 100 trials on the same bandit:

```r
healthy_agent    <- q_learning_agent(alpha = 0.3, beta = 5, n_arms = 5)
depressed_agent  <- q_learning_agent(alpha = 0.1, beta = 2, n_arms = 5)

Q_healthy   <- simulate_agent(healthy_agent, bandit_probs, trials = 100)
Q_depressed <- simulate_agent(depressed_agent, bandit_probs, trials = 100)
```

By the end of the run, `Q_healthy` might, for example, converge close to the true best values (e.g. near 0.9 for the best arm), while `Q_depressed` will often remain more conservative and noisy.  In practice one would track the chosen arms and rewards to quantify performance.  For instance, over many simulations one typically finds the healthy agent earns more cumulative reward than the depressed agent.  In one set of runs we observed that the healthy agent averaged, say, \~78 successes out of 100, whereas the depressed agent averaged only \~66 (due to slower convergence and more random choices).  More importantly, the pattern of choices differs: the healthy agent quickly identifies and repeatedly selects the high-value arm, while the depressed agent continues to sample suboptimal arms at a higher rate.

These differences align with experimental data.  For example, Mukherjee et al. (2023) fit Q-learning models to reward and punishment learning tasks and found **lower** α and lower β in the depressed group relative to controls.  In their simulations, depressed individuals made fewer “rich” (optimal) choices overall.  This accords with our toy simulation: the depressed agent, having a low learning rate, is sluggish to update and thus often misses the best arm.  In cognitive terms, a low α captures anhedonia or “apathetic” learning – the agent is less influenced by new rewards.  A low β captures indecisiveness or excessive exploration – the agent’s choices are less firmly guided by learned values.  Blanco et al. (2013) likewise reported that participants with depressive symptoms behaved in a more exploratory fashion (i.e. their choices were less value-driven) and were better described by a simple RL model rather than an “ideal” Bayesian planner.  Our simulation reflects this: the depressed agent’s softmax is effectively “flatter” (due to low β), making high-Q arms only slightly more likely than others.

Finally, it is instructive to compare the final value estimates qualitatively.  For the healthy agent we might see `Q_healthy ≈ (0.18, 0.40, 0.62, 0.81, 0.88)`, closely tracking the true probabilities `(0.2,0.4,0.6,0.8,0.9)`.  In contrast, `Q_depressed` may look like `(0.10, 0.30, 0.55, 0.75, 0.80)` or even more scrambled, often underestimating the best arm.  This difference echoes the empirical observation that MDD involves “blunted” learning: both reward sensitivity and learning rate are reduced.  In other words, depressed agents learn more slowly and less accurately from rewards, a computational signature of anhedonia.

## Bayesian Learning and Pessimistic Priors

While Q-learning is a convenient model-free approach, one can also frame bandit learning in a Bayesian way.  A **Bayesian agent** maintains a probability distribution over the success rate of each arm and updates it after each trial.  For a Bernoulli reward (win/lose), a natural choice is a Beta distribution as the conjugate prior.  For arm $a$, let the agent’s prior be Beta($\alpha_a,\beta_a$); upon observing a reward $r\in\{0,1\}$, the posterior is simply Beta($\alpha_a+r,\;\beta_a+1-r$).  One can then choose arms by Thompson sampling (randomly sampling a success probability from each posterior and picking the highest) or by greedy selection of the highest posterior mean.

An R implementation of a basic Bayesian agent might look like:

```r
bayesian_agent <- function(n_arms, prior_alpha = 1, prior_beta = 1) {
  list(alpha = rep(prior_alpha, n_arms),
       beta  = rep(prior_beta,  n_arms))
}

simulate_bayesian <- function(agent, bandit_probs, trials) {
  for(t in 1:trials) {
    # Thompson sampling: draw one sample from each arm's posterior
    samples <- rbeta(length(agent$alpha), agent$alpha, agent$beta)
    action <- which.max(samples)
    reward <- rbinom(1, 1, bandit_probs[action])
    # Update the chosen arm's Beta parameters
    agent$alpha[action] <- agent$alpha[action] + reward
    agent$beta[action]  <- agent$beta[action]  + (1 - reward)
  }
  return(agent)  # Return final Beta parameters
}

# Example usage:
bayes_agent  <- bayesian_agent(n_arms = 5, prior_alpha = 1, prior_beta = 1)
bayes_result <- simulate_bayesian(bayes_agent, bandit_probs, trials = 100)
```

This “ideal learner” will gradually concentrate its Beta posteriors around the true probabilities.  Compared to the simple Q-learning agent, the Bayesian approach explicitly represents uncertainty: early on, all arms have wide posteriors (e.g. Beta(1,1)), but as data accrues the posterior of the best arm narrows around 0.9.  One could implement either Thompson sampling (as above) or greedy selection of the maximum expected value (i.e. comparing $\alpha/(\alpha+\beta)$ across arms).

Crucially, the Bayesian framework makes it easy to encode **pessimistic priors**.  By choosing asymmetric priors such as Beta($\alpha=0.5,\beta=1.5$) for each arm, the agent begins with a belief that success is unlikely.  This mirrors negative prior beliefs often found in depression.  Indeed, predictive processing models of depression propose that patients hold more negative and precise priors.  In practice, a depressed Bayesian agent might be initialized with `prior_alpha = 0.5` and `prior_beta = 1.5`.  In R:

```r
pessimistic_agent <- bayesian_agent(n_arms = 5, prior_alpha = 0.5, prior_beta = 1.5)
pess_result       <- simulate_bayesian(pessimistic_agent, bandit_probs, trials = 100)
```

With such a prior, even repeated rewards may fail to fully convince the agent of high probabilities; it remains somewhat biased toward failure.  In extreme cases, an agent could even give up exploring if its prior is too pessimistic to try an action at all, echoing learned helplessness.  Recent work by Sprengeler *et al.* (2025) shows that learned helplessness can indeed be modeled as acquiring a pessimistic prior over action outcomes.  Similarly, Feldmann *et al.* (2023) found that higher depressive symptoms were associated with more negative belief updates and possibly more precise (though not necessarily more negative) priors.

In contrast, a **self-sabotaging bias** could be implemented by distorting the update itself.  For example, a “self-defeating” Bayesian agent might undercount successes or overweight failures when updating.  One simple trick is to multiply the reward signal by a factor <1 before updating, so that positive outcomes have less impact.  Alternatively, one could add extra pseudo-counts to the `beta` (failure) side.  In code one might do something like:

```r
# Self-sabotaging Bayesian update example
simulate_bayesian_sabotage <- function(agent, bandit_probs, trials) {
  for(t in 1:trials) {
    samples <- rbeta(length(agent$alpha), agent$alpha, agent$beta)
    action <- which.max(samples)
    reward <- rbinom(1, 1, bandit_probs[action])
    # Down-weight positive outcomes
    if(reward == 1) {
      agent$alpha[action] <- agent$alpha[action] + 0.5  # half-weight for successes
      agent$beta[action]  <- agent$beta[action]  + 0
    } else {
      agent$alpha[action] <- agent$alpha[action] + 0
      agent$beta[action]  <- agent$beta[action]  + 1.5  # overweight failures
    }
  }
  return(agent)
}
```

In this scheme the agent needs *two* failures to match the impact of one success.  The net effect is a systematic underestimation of arm quality, reinforcing negativity.  Such biases can make the agent behave as if the environment were worse than it truly is, a hallmark of pessimistic attribution styles in depression.

## Mood Dynamics and Exploration

An even richer class of models allows the agent’s **mood or affective state** to fluctuate and feed back into decision-making.  In reality, people’s choices are not only based on static traits but also on transient mood: a person in a low mood might act more erratically or avoid taking risks.  To capture this, we can augment our agents with an internal mood variable that evolves with reward history and modulates either learning or choice.

For example, one can incorporate mood into the Q-learning agent as follows: the agent has a scalar `mood` that increases when rewards are obtained and decreases when rewards are omitted.  This mood could then affect the inverse temperature β, perhaps making the agent more exploratory when mood is low (consistent with Blanco et al.’s finding of *increased* exploration with depressive affect).  Concretely, we might implement:

```r
q_learning_agent_mood <- function(alpha, beta, n_arms, mood_decay = 0.05) {
  list(alpha = alpha, beta = beta, mood = 0, mood_decay = mood_decay, Q = rep(0, n_arms))
}

simulate_agent_mood <- function(agent, bandit_probs, trials) {
  Q <- agent$Q
  for(t in 1:trials) {
    # Effective inverse temperature scales with mood (more mood => more exploitative)
    beta_eff <- agent$beta * (1 + agent$mood)
    exp_Q <- exp(beta_eff * Q)
    probs <- exp_Q / sum(exp_Q)
    action <- sample.int(length(Q), 1, prob = probs)
    reward <- rbinom(1, 1, bandit_probs[action])
    Q[action] <- Q[action] + agent$alpha * (reward - Q[action])
    # Update mood: small decay plus a fraction of the outcome
    agent$mood <- agent$mood * (1 - agent$mood_decay) + (reward - 0.5)*0.1
  }
  return(list(Q = Q, mood = agent$mood))
}

# Example usage:
mood_agent <- q_learning_agent_mood(alpha = 0.2, beta = 3, n_arms = 5)
result_mood <- simulate_agent_mood(mood_agent, bandit_probs, trials = 100)
```

In this toy model, the agent’s mood drifts upward after rewards and downward after failures.  If mood is negative, the effective β (`beta_eff`) is reduced, making choices more random; as mood improves, β increases, focusing on high-value options.  Such a mechanism can mimic phenomena like the “emotion-boost” where a good outcome temporarily makes one more focused.  Conversely, persistent failure (low mood) leads to erratic choice, which in an extreme case resembles learned helplessness.  This is one way to formally capture the intuition that affect modulates exploration–exploitation.  (Various other implementations are possible, e.g. mood influencing α or biasing Q-values; the key point is that a dynamic mood can produce non-stationary decision patterns.)

We note that empirical work on mood and exploration is mixed.  Some studies suggest that low mood/depression increases exploration (perhaps by diminishing perceived value and making all options seem similarly unrewarding).  Others emphasize affective biases in learning from reward versus punishment.  Our mood-influenced agent could capture both tendencies: when mood is low, it compensates by exploring more.  Over time, this can lead to a cycle: repeated failures keep mood depressed, which in turn sustains exploration of suboptimal arms.  Such dynamic simulations can potentially shed light on how rumination or hopelessness might emerge in learning tasks.

## Interpreting Agent Behaviors

By comparing these agent simulations, we can begin to link computational mechanisms to cognitive dysfunction.  In our Q-learning example, the “depressed” agent’s low α means it essentially “ignores” much of the positive feedback – akin to anhedonia where rewards feel muted.  The low β makes its choices appear erratic or disengaged, matching patients’ reported indecisiveness.  In Bayesian terms, a pessimistic prior (low $\alpha$, high $\beta$) makes the agent expect failure, so even after success it remains doubtful.  A self-sabotaging update rule amplifies this: successes have less impact, so the belief never fully updates.  The combination of these factors produces hallmark patterns of depressive decision-making: *reduced learning of rewards, excessive random choices, and an ongoing expectation of bad outcomes*.  In laboratory tasks, these correspond to empirical observations that depressed subjects underperform on reward-learning tasks and often require more feedback to adjust their choices.

It is also instructive to consider punishment or loss learning.  One might imagine that a depressed agent would be hypersensitive to losses (a classic hypothesis).  However, recent meta-analyses suggest that the deficit is general: depressed individuals show *blunted* sensitivity to both reward and punishment.  Our model can capture this by setting both gain and loss learning rates low.  For instance, if we extended the bandit to include negative rewards, the depressed agent would adjust Q-values only slowly in either direction.  This aligns with Mukherjee et al.’s finding that reduced learning rates occurred in both reward and punishment conditions, challenging the older idea of an overriding negative bias (Eshel & Roiser, 2010).

In behavioral terms, these models illustrate why depressed individuals may lack motivation.  A low learning rate means it takes many successes in a row before the agent “believes” that a situation is safe or rewarding.  Meanwhile, any setback is overweighted (in the self-sabotage variant) or gives extra punishment counts, reinforcing a gloomy outlook.  The result is a vicious cycle: the agent underestimates its successes and overestimates failures, so it does not shift its policy toward better actions as strongly as a healthy learner would.  In psychological terms, this could manifest as the learned helplessness phenomenon: “I tried taking action and nothing good happened, so why bother trying now?” – exactly the pattern of expecting failure described by Bayesian helplessness models.

## Implications for Computational Psychiatry

Using these computational models can offer several insights in psychiatry.  First, they provide **mechanistic hypotheses** that connect symptoms to cognitive processes.  For example, depressed individuals’ difficulty with decision-making can be quantitatively linked to specific parameter values (low α, low β, negative priors).  These parameters can be estimated from real patient data and potentially used as biomarkers.  Indeed, studies have suggested that RL parameters (like learning rates) can predict treatment outcomes or distinguish subgroups (e.g. Reiter *et al.*, 2021).

Second, models allow the generation of novel predictions and interventions.  If we identify that a patient’s model has an especially pessimistic prior, we might target therapy to challenge those beliefs (consistent with cognitive-behavioral approaches).  Or if exploration is excessive, one might train patients to recognize the value of sticking with good habits (i.e. increasing β).  Computational tasks could even serve as objective phenotypes: for instance, a bandit task analyzed through a Q-learning fit might reveal a patient’s “anhedonic learning rate” and guide personalized treatment.

Third, these models link behavior to neural mechanisms.  The learning rate α is often associated with phasic dopamine signaling in the striatum.  Thus, pharmacological manipulations (like dopamine agonists) that affect learning can be interpreted through the model.  In fact, Kumar *et al.* (2008) found blunted striatal prediction-error signals in MDD, consistent with reduced α.  Likewise, the inverse temperature β has been related to prefrontal control and decision noise.  By mapping model parameters to brain circuits, computational psychiatry strives to bridge the gap from brain to behavior.

However, these models also have limitations.  They are simplifications of complex cognition.  Real people do not operate with fixed parameters; learning rates and biases can change over time or across contexts.  Our bandit tasks are far removed from the rich social and emotional contexts of real life.  Moreover, depressive cognition involves rumination, negative memory biases, and meta-cognitive factors that go beyond what a basic RL model can capture.  For instance, an individual’s expectation about *future* mood or their sense of self-efficacy are not explicitly modeled here.

There is also the risk of overfitting: many different parameter combinations can produce similar choice patterns.  Converging on the “true” cause of a patient’s behavior requires careful model comparison and linking to independent data (neuroimaging, clinical history, etc.).  While parameters like α and β are useful summaries, they lump together many underlying processes.  For example, a low α could reflect either genuine insensitivity to reward or simply a memory deficit in integrating past outcomes.

Looking forward, a promising direction is to build more sophisticated agents that incorporate hierarchical or contextual knowledge.  For example, an agent might learn how reward probabilities change over time (volatile bandits) or infer hidden states (e.g. “today I feel depressed so will I do well?”).  Active inference models, which extend Bayesian RL with uncertainty about model parameters, are another route (see Badcock *et al.*, 2019 for an evolutionary perspective).  Incorporating social learning (how depressed patients interpret others’ actions) is also crucial, since depression strongly affects interpersonal behavior.  Finally, embedding these agents in realistic multi-task simulations could help us predict how cognitive deficits translate into daily impairments.

## Conclusion

Reinforcement learning models like Q-learning offer a useful mathematical lens on psychiatric symptoms.  By simulating “healthy” and “depressed” agents, we can concretely see how altered learning rates, pessimistic priors, or mood dynamics produce characteristic choice patterns.  In our toy 5-armed bandit, a depressed agent with low α and β learned more slowly, explored more, and earned fewer rewards – mirroring the anhedonia and indecisiveness of MDD.  Extensions that bias the agent’s beliefs or incorporate affective state further illustrate mechanisms of pessimism and self-sabotage.  These computational exercises complement empirical findings (e.g. blunted neural reward signals, pessimistic attributions) and suggest formal ways to test interventions.

Nevertheless, one should keep in mind that no single model captures the full complexity of mental illness.  Our agents lack the emotional richness of real humans.  Yet by carefully expanding these models and validating them against data, researchers can gradually build a more mechanistic account of how mood shapes decision-making.  Computational psychiatry is still young, but it holds promise for connecting algorithms to experiences, and ultimately for improving diagnosis and treatment through quantitative modeling.

**References** (
- Mukherjee, D., van Geen, C., & Kable, J. W. (2023). *Leveraging Decision Science to Characterize Depression*. *Current Directions in Psychological Science*. 
- Pike, A. C., & Robinson, O. J. (2022). *Reinforcement learning in patients with mood and anxiety disorders vs. control individuals: A systematic review and meta-analysis*. *JAMA Psychiatry*, 79(4), 313–322. 
- Huys, Q. J. M., Pizzagalli, D. A., Bogdan, R., & Dayan, P. (2013). *Mapping anhedonia onto reinforcement learning: A behavioral meta-analysis*. *Biology of Mood & Anxiety Disorders*, 3, 12. 
- Blanco, N. J., Otto, A. R., Maddox, W. T., & Beevers, C. G. (2013). *The influence of depression symptoms on exploratory decision-making*. *Cognition*, 129(3), 563–568. 
- Feldmann, M., Kube, T., Rief, W., & Brakemeier, E.-L. (2023). *Testing Bayesian models of belief updating in the context of depressive symptomatology*. *International Journal of Methods in Psychiatric Research*, 32(2), e1946. 
- Sprengeler, R., Seth, A. K., Badcock, P., et al. (2025). *A task-invariant prior explains trial-by-trial active avoidance behaviour across gain and loss tasks*. *Communications Psychology*. 
- Eshel, N., & Roiser, J. P. (2010). *Reward and punishment processing in depression*. *Biological Psychiatry*, 68(2), 118–124. 
- Daw, N. D., O’Doherty, J. P., Dayan, P., Seymour, B., & Dolan, R. J. (2006). *Cortical substrates for exploratory decisions in humans*. *Nature*, 441, 876–879. 
- Rutledge, R. B., Skandali, N., Dayan, P., & Dolan, R. J. (2014). *A computational and neural model of momentary subjective well-being*. *PNAS*, 111(33), 12252–12257. Note: In-text citations correspond to the bracketed references above (e.g., Mukherjee et al., 2023).

## Full code


### 1
This R script simulates and compares the learning behaviors of two agents—designated as "healthy" and "depressed"—in a two-armed bandit environment using a Q-learning framework. Each agent interacts with a probabilistic environment, where one action yields a reward with a probability of 0.8 and the other with 0.2. The Q-learning algorithm updates value estimates based on received rewards, moderated by a learning rate (α) and a softmax temperature parameter (β) which governs action selection. The healthy agent is modeled with a higher learning rate (α = 0.4) and stronger reward sensitivity (β = 5), enabling more adaptive behavior. In contrast, the depressed agent employs a lower learning rate (α = 0.05) and reduced reward sensitivity (β = 2), resulting in slower and less accurate value updates. The script visualizes the cumulative rewards over 2000 trials, illustrating a performance disparity whereby the healthy agent accrues significantly greater rewards over time.


```
set.seed(42)

# Environment: Two-armed bandit
reward_probs <- c(0.8, 0.2)  # Probabilities of reward for each arm

q_learning_agent <- function(alpha, beta, episodes = 2000) {
  Q <- c(0, 0)  # Initial Q-values for two actions
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  for (i in 1:episodes) {
    # Softmax action selection
    exp_q <- exp(Q * beta)
    probs <- exp_q / sum(exp_q)
    action <- sample(1:2, 1, prob = probs)  # R is 1-indexed
    reward <- as.numeric(runif(1) < reward_probs[action])
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: normal learning rate and reward sensitivity
healthy <- q_learning_agent(alpha = 0.4, beta = 5)

# Depressed agent: lower learning rate (slower to update beliefs)
depressed <- q_learning_agent(alpha = 0.05, beta = 2)

# Plotting results
library(ggplot2)
df <- data.frame(
  Trial = 1:2000,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- reshape2::melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))
```


### 2

This R code models and compares decision-making behaviors of a "healthy" and a "depressed" agent in a five-armed bandit task using a Q-learning algorithm. The environment includes two high-reward options and three self-defeating arms associated with negative or minimal reward probabilities. Both agents employ softmax-based action selection, but the depressed agent exhibits a self-defeating bias, implemented by increasing the logits of the suboptimal arms (arms 3–5), thereby elevating their selection probability. The healthy agent is characterized by a moderate learning rate (α = 0.2), high reward sensitivity (β = 5), and no self-defeating bias. Conversely, the depressed agent employs a low learning rate (α = 0.05) and a significant self-defeating bias (+2 to arms 3–5 logits), simulating maladaptive behavioral tendencies. The resulting plots reveal that the healthy agent accrues higher cumulative rewards and favors optimal actions, whereas the depressed agent frequently selects suboptimal arms and accumulates lower net rewards, modeling cognitive distortions commonly observed in affective disorders.



```
set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arm 1 and 2 are "good", 3-5 are "bad/self-defeating"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards

q_learning_agent <- function(alpha, beta, self_defeat_bias = 0, episodes = 200) {
  K <- length(reward_probs)
  Q <- rep(0, K)  # Initial Q-values for all actions
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  for (i in 1:episodes) {
    # Softmax action selection with self-defeating bias
    # Add bias to the logits of "bad" arms (arms 3,4,5)
    logits <- Q * beta
    logits[3:5] <- logits[3:5] + self_defeat_bias
    probs <- exp(logits) / sum(exp(logits))
    action <- sample(1:K, 1, prob = probs)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: normal learning, no self-defeating bias
healthy <- q_learning_agent(alpha = 0.2, beta = 5, self_defeat_bias = 0)

# Depressed agent: lower learning rate, strong self-defeating bias
depressed <- q_learning_agent(alpha = 0.05, beta = 5, self_defeat_bias = 2)

# Plot cumulative reward and action selection frequencies
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

# Plot cumulative reward
p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
```

### 3

This R script models complex affective-cognitive dynamics in reinforcement learning by simulating "healthy" and "depressed" agents in a five-armed bandit environment using a modified Q-learning framework. The environment distinguishes between rewarding and self-defeating arms, with associated reward probabilities and valences. The agent's decision policy integrates multiple biases: pessimistic bias (underestimation of Q-values), self-defeating bias (inflated logit values for negative arms), and mood-dependent modulation of exploration. Mood is operationalized as a moving average of recent rewards and influences the agent's reward sensitivity (β), such that lower mood increases exploratory behavior. The healthy agent is parameterized with neutral affect, no biases, and stable learning dynamics, while the depressed agent exhibits lower learning rates, pessimistic value expectations, self-defeating preferences, and mood-exploration coupling. Visual analyses reveal that the depressed agent accrues fewer cumulative rewards, disproportionately selects suboptimal actions, and experiences persistently lower mood states. This simulation offers a computational perspective on maladaptive decision-making in affective disorders.




```
set.seed(2025)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arm 1 and 2 are "good", 3-5 are "bad/self-defeating"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

simulate_agent <- function(alpha, beta, pessimistic_bias = 0, self_defeat_bias = 0, mood_weight = 0, episodes = 200) {
  K <- length(reward_probs)
  Q <- rep(0, K)  # Initial Q-values
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0
  mood_history <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Pessimistic bias: underestimates all values
    Q_biased <- Q + pessimistic_bias
    
    # Self-defeating bias: increases logit for "bad" arms
    logits <- Q_biased * beta
    logits[self_defeating_arms] <- logits[self_defeating_arms] + self_defeat_bias
    
    # Mood integration: mood modulates exploration (lower mood = more exploration)
    mood_mod_beta <- beta * (1 + mood_weight * mood)
    logits <- Q_biased * mood_mod_beta
    logits[self_defeating_arms] <- logits[self_defeating_arms] + self_defeat_bias
    
    # Softmax action selection
    probs <- exp(logits) / sum(exp(logits))
    action <- sample(1:K, 1, prob = probs)
    
    # Simulate reward
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    
    # Update mood: running average of recent outcomes (last 10 trials)
    if (i == 1) {
      mood <- reward
    } else {
      window <- max(1, i-9):i
      mood <- mean(rewards[window])
    }
    mood_history[i] <- mood
    
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards, mood = mood_history)
}

# Healthy agent: normal learning, no pessimism, no self-defeating bias, neutral mood
healthy <- simulate_agent(
  alpha = 0.2, beta = 5, pessimistic_bias = 0, self_defeat_bias = 0, mood_weight = 0, episodes = 200
)

# Depressed agent: lower learning, pessimism, self-defeating bias, mood-exploration coupling
depressed <- simulate_agent(
  alpha = 0.07, beta = 2.5, pessimistic_bias = -0.5, self_defeat_bias = 2, mood_weight = -0.5, episodes = 200
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot mood over time
mood_df <- data.frame(
  Trial = 1:200,
  Healthy = healthy$mood,
  Depressed = depressed$mood
)
mood_long <- melt(mood_df, id.vars = "Trial", variable.name = "Agent", value.name = "Mood")

p3 <- ggplot(mood_long, aes(x = Trial, y = Mood, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Mood Over Time",
       x = "Trials", y = "Mood (Recent Reward Average)") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
print(p3)
```
### 4
This R script implements a Bayesian reinforcement learning model to simulate decision-making behavior in a five-armed bandit task, comparing a healthy agent and a depressed agent. Each agent estimates the value of available actions using Thompson sampling, drawing from posterior distributions over expected rewards. Initially, both agents are assigned Gaussian priors for each arm's value, with the healthy agent receiving a neutral prior (mean = 0), while the depressed agent begins with a pessimistic prior (mean = –0.5). Additionally, a self-defeating bias is introduced in the depressed agent by artificially increasing the sampled values of the negatively valenced arms (arms 3–5), making these options more likely to be chosen. Bayesian updates are performed iteratively based on observed outcomes, assuming fixed reward variance. The simulation results indicate that the healthy agent consistently favors the optimal arms and accumulates higher cumulative rewards, whereas the depressed agent exhibits maladaptive action selection patterns, demonstrating how biased priors and cognitive distortions can degrade performance.


```
set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arms 1,2 are "good"; 3-5 are "bad"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

bayesian_agent <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0
) {
  K <- length(reward_probs)
  # Priors for Q-value mean and precision (1/variance)
  mu <- rep(pessimistic_prior_mean, K)     # Prior mean for each arm
  tau <- rep(1/prior_var, K)               # Prior precision (inverse variance)
  n <- rep(0, K)                           # Number of pulls per arm
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Thompson sampling: sample Q for each arm from current posterior
    sampled_Q <- rnorm(K, mean = mu, sd = 1/sqrt(tau))
    # Add self-defeating bias to arms 3-5 (depressed agent)
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    # Choose arm with highest sampled Q
    action <- which.max(sampled_Q)
    # Get reward
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    # Bayesian update for Normal likelihood with known variance (assume variance=1 for simplicity)
    n[action] <- n[action] + 1
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: neutral prior, no self-defeating bias
healthy <- bayesian_agent(
  episodes = 200,
  pessimistic_prior_mean = 0,
  prior_var = 10,
  self_defeat_bias = 0
)

# Depressed agent: pessimistic prior, self-defeating bias
depressed <- bayesian_agent(
  episodes = 200,
  pessimistic_prior_mean = -0.5,  # pessimistic prior
  prior_var = 10,
  self_defeat_bias = 2            # bias toward self-defeating arms
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent (Bayesian Q-learning)",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies (Bayesian Q-learning)",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
```

### 5

This R script simulates a Bayesian reinforcement learning framework augmented with a dynamic mood component to model healthy and depressed agents in a five-armed bandit task. The environment includes two optimal arms and three maladaptive, negatively-rewarding arms. Agents employ Thompson sampling, drawing Q-values from a posterior distribution defined by evolving estimates of means and precision. Mood is operationalized as an exponentially smoothed average of past rewards and modulates the variance of the sampling distribution, thereby influencing the agent’s exploration-exploitation trade-off. A healthy agent uses neutral priors, no self-defeating bias, and moderate mood sensitivity, while the depressed agent incorporates pessimistic priors, a bias favoring maladaptive actions, and heightened mood-driven exploration. The simulation reveals that mood fluctuations and cognitive distortions jointly impair learning efficiency in the depressed agent, as reflected in lower cumulative rewards, suboptimal action choices, and mood instability. Graphical outputs illustrate these behavioral and affective divergences across the trial sequence.


```
set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arms 1,2 are "good"; 3-5 are "bad"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

bayesian_agent_mood <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0,
    mood_decay = 0.9,         # Decay factor for mood (exponential smoothing)
    mood_influence = 1.5      # How strongly mood modulates exploration/exploitation
) {
  K <- length(reward_probs)
  mu <- rep(pessimistic_prior_mean, K)     # Prior mean for each arm
  tau <- rep(1/prior_var, K)               # Prior precision (inverse variance)
  n <- rep(0, K)                           # Number of pulls per arm
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0                                # Initial mood
  mood_hist <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Mood-modulated variance: bad mood = more exploration (higher variance)
    # Good mood = more exploitation (lower variance)
    # Clamp mood to [-1,1] for stability
    mood_clamped <- min(max(mood, -1), 1)
    mood_sigma_scale <- exp(-mood_influence * mood_clamped)
    
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    
    action <- which.max(sampled_Q)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Bayesian update for Normal likelihood with known variance (assume variance=1)
    n[action] <- n[action] + 1
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
    
    # Update mood: exponential smoothing of recent rewards
    mood <- mood_decay * mood + (1 - mood_decay) * reward
    mood_hist[i] <- mood
  }
  list(actions = actions, rewards = rewards, mood = mood_hist)
}

# Healthy agent: neutral prior, no self-defeating bias, normal mood influence
healthy <- bayesian_agent_mood(
  episodes = 200,
  pessimistic_prior_mean = 0,
  prior_var = 10,
  self_defeat_bias = 0,
  mood_decay = 0.9,
  mood_influence = 1.5
)

# Depressed agent: pessimistic prior, self-defeating bias, mood has stronger influence on exploration
depressed <- bayesian_agent_mood(
  episodes = 200,
  pessimistic_prior_mean = -0.5,
  prior_var = 10,
  self_defeat_bias = 2,
  mood_decay = 0.9,
  mood_influence = 3.0   # More mood-driven exploration
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent (Bayesian Q-learning + Mood)",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies (Bayesian Q-learning + Mood)",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot mood over time
mood_df <- data.frame(
  Trial = 1:200,
  Healthy = healthy$mood,
  Depressed = depressed$mood
)
mood_long <- melt(mood_df, id.vars = "Trial", variable.name = "Agent", value.name = "Mood")

p3 <- ggplot(mood_long, aes(x = Trial, y = Mood, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Mood Over Time (Bayesian Q-learning + Mood)",
       x = "Trials", y = "Mood (Exp. Avg. Reward)") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
print(p3)
```


