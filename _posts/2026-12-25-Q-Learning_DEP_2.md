# Modeling Affective Dynamics in Reinforcement Learning: A Comprehensive Study of Mood-Modulated Decision-Making in Healthy and Depressed Agents

## Introduction

The intersection of emotion and cognition represents one of the most challenging frontiers in computational neuroscience and psychiatry. While traditional reinforcement learning (RL) models have provided powerful insights into decision-making processes, they often treat agents as purely rational actors, overlooking the profound influence of affective states on behavior. This limitation becomes particularly evident when attempting to model psychiatric conditions like Major Depressive Disorder (MDD), where mood disturbances fundamentally alter how individuals learn from experience and make choices.

Depression affects approximately 280 million people worldwide and is characterized by persistent negative mood, anhedonia (reduced capacity to experience pleasure), cognitive biases, and impaired decision-making. From a computational perspective, these symptoms suggest disruptions in the brain's reward-learning circuits—precisely the systems that RL models aim to capture. Recent empirical work has demonstrated that depressed individuals show altered patterns in reinforcement learning tasks: they exhibit reduced learning rates for positive outcomes, increased sensitivity to negative feedback, and more exploratory (less decisive) choice patterns.

Computational psychiatry has emerged as a promising approach to bridge the gap between algorithmic models and clinical phenomena. By incorporating psychological constructs like mood, pessimism, and learned helplessness into formal mathematical frameworks, researchers can generate testable hypotheses about the mechanisms underlying mental illness. Moreover, these models offer the potential to develop personalized interventions by identifying specific computational dysfunctions in individual patients.

In this comprehensive study, we extend traditional Bayesian reinforcement learning by incorporating dynamic mood states that modulate both learning and decision-making processes. We present two complementary simulation frameworks: the first introduces individual differences and environmental perturbations to capture heterogeneity in affective responses, while the second incorporates meta-cognitive mechanisms like learned helplessness and rumination. Through systematic comparison of "healthy" and "depressed" agents, we demonstrate how mood dynamics can produce the characteristic behavioral patterns observed in depression.

## Theoretical Framework: Mood-Modulated Bayesian Learning

### Mathematical Foundations

Our approach builds upon Bayesian reinforcement learning, where agents maintain probability distributions over the expected value of each available action. For a $K$-armed bandit problem, let $Q_k$ represent the true expected reward for arm $k$. The agent maintains a posterior belief over each $Q_k$, which we model as a Gaussian distribution:

$$Q_k \sim \mathcal{N}(\mu_k, \sigma_k^2)$$

where $\mu_k$ is the posterior mean and $\sigma_k^2$ is the posterior variance for arm $k$. Initially, we set uninformative priors: $\mu_k^{(0)} = \mu_0$ and $\sigma_k^{(0)} = \sigma_0^2$, where $\mu_0$ can encode pessimistic or optimistic biases.

At each trial $t$, the agent selects actions using **Thompson Sampling**: it draws a sample $\tilde{Q}_k^{(t)} \sim \mathcal{N}(\mu_k^{(t)}, \sigma_k^{(t)})$ for each arm and chooses the arm with the highest sample:

$$a^{(t)} = \arg\max_k \tilde{Q}_k^{(t)}$$

After observing reward $r^{(t)}$, the agent updates its beliefs using Bayesian inference. Assuming Gaussian likelihood with known variance $\sigma_r^2$, the posterior update follows:

$$\mu_k^{(t+1)} = \frac{\tau_k^{(t)} \mu_k^{(t)} + \alpha^{(t)} r^{(t)}}{\tau_k^{(t)} + \alpha^{(t)}}$$

$$\tau_k^{(t+1)} = \tau_k^{(t)} + \alpha^{(t)}$$

where $\tau_k = 1/\sigma_k^2$ is the precision (inverse variance) and $\alpha^{(t)}$ is an effective learning rate that can be modulated by meta-cognitive factors.

### Mood Integration

The key innovation in our framework is the integration of a dynamic mood state $m^{(t)}$ that influences both action selection and learning. Mood evolves according to an exponential smoothing process:

$$m^{(t+1)} = \lambda m^{(t)} + (1-\lambda) f(r^{(t)}) + \epsilon^{(t)}$$

where $\lambda \in [0,1]$ is the mood decay parameter, $f(r)$ is a function mapping rewards to mood updates, and $\epsilon^{(t)}$ represents external perturbations (e.g., life events).

Mood modulates decision-making through several mechanisms:

1. **Exploration Modulation**: Mood affects the variance of Thompson sampling:
   $$\tilde{Q}_k^{(t)} \sim \mathcal{N}\left(\mu_k^{(t)}, \exp(-\beta m^{(t)}) \sigma_k^{(t)}\right)$$
   
   When mood is negative ($m < 0$), the variance increases, leading to more exploratory behavior. This captures the clinical observation that depressed individuals often exhibit more random, less value-driven choices.

2. **Pessimistic Bias**: Initial beliefs can be shifted based on trait pessimism:
   $$\mu_k^{(0)} = \mu_0 + \gamma \cdot \text{pessimism}$$
   
   where $\gamma$ scales the influence of pessimistic priors.

3. **Self-Defeating Bias**: In action selection, certain arms (representing maladaptive choices) receive artificial boosts:
   $$\tilde{Q}_k^{(t)} \leftarrow \tilde{Q}_k^{(t)} + \delta \cdot \mathbb{I}[k \in \mathcal{S}]$$
   
   where $\mathcal{S}$ is the set of self-defeating arms and $\delta > 0$ is the bias strength.

### Meta-Cognitive Extensions

Our second framework incorporates additional meta-cognitive mechanisms:

**Learned Helplessness**: After experiencing $n$ consecutive negative outcomes, the effective learning rate is reduced:

$$\alpha^{(t)} = \alpha_{\text{base}} \cdot \begin{cases}
\eta & \text{if } \sum_{s=t-n+1}^t \mathbb{I}[r^{(s)} < 0] = n \\
1 & \text{otherwise}
\end{cases}$$

where $\eta < 1$ is the helplessness factor.

**Rumination**: Mood updates are weighted differently for positive and negative outcomes:

$$f(r) = \begin{cases}
w_+ \cdot r & \text{if } r > 0 \\
w_- \cdot r & \text{if } r < 0 \\
0 & \text{if } r = 0
\end{cases}$$

where typically $w_- > w_+$ for depressed agents, reflecting the tendency to ruminate more on negative events.

## Part 1: Individual Differences and Environmental Perturbations

### Simulation Architecture

Our first simulation framework models a population of agents with heterogeneous traits interacting with a common environment. This approach captures the fundamental insight that depression manifests differently across individuals while sharing common underlying mechanisms.

#### Environment Specification

The multi-armed bandit environment consists of five arms with distinct reward profiles:

```
Arm 1: p = 0.7, reward = +1 (high-value option)
Arm 2: p = 0.6, reward = +1 (moderate-value option)  
Arm 3: p = 0.2, reward = -1 (self-defeating option)
Arm 4: p = 0.1, reward = -1 (self-defeating option)
Arm 5: p = 0.05, reward = -2 (highly self-defeating option)
```

This structure creates a clear distinction between adaptive (arms 1-2) and maladaptive (arms 3-5) choices, allowing us to quantify self-defeating behavior.

#### Individual Difference Modeling

To capture realistic population heterogeneity, we model individual differences using a multivariate approach. Recognizing that pessimism and self-defeating tendencies often co-occur in depression, we sample these traits from a correlated bivariate normal distribution:

$$\begin{pmatrix} 
\text{pessimism}_i \\ 
\text{self-defeat}_i 
\end{pmatrix} \sim \mathcal{N}\left(\begin{pmatrix} 0 \\ 0 \end{pmatrix}, \begin{pmatrix} 0.25 & 0.15 \\ 0.15 & 1.0 \end{pmatrix}\right)$$

The positive correlation (r = 0.30) reflects the empirical finding that individuals with negative cognitive biases also tend to engage in self-sabotaging behaviors.

Additional parameters are sampled independently:
- Mood decay: $\lambda_i \sim \text{Uniform}(0.85, 0.98)$
- Mood influence: $\beta_i \sim \mathcal{N}(2, 0.5^2)$

#### Environmental Events

To model the impact of life events on mood and decision-making, we introduce exogenous perturbations at specific trials:

```
Trial 50:  ε = -2 (major negative event)
Trial 120: ε = +1 (positive event)  
Trial 180: ε = -1 (minor negative event)
```

These events directly modify the agent's mood state, simulating how external circumstances can trigger or alleviate depressive episodes.

### Implementation Details

The core agent function implements the mood-modulated Bayesian learning algorithm:

```r
run_agent <- function(params) {
  K <- length(reward_probs)
  # Initialize Bayesian beliefs
  mu <- rep(params$pessimistic_prior_mean, K)  # Prior means
  tau <- rep(1/10, K)  # Prior precisions (1/variance)
  
  # Initialize tracking variables
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0  # Initial mood state
  mood_hist <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Clamp mood to prevent numerical instability
    mood_clamped <- min(max(mood, -1), 1)
    
    # Mood modulates exploration via variance scaling
    mood_sigma_scale <- exp(-params$mood_influence * mood_clamped)
    
    # Thompson sampling with mood modulation
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    
    # Add self-defeating bias to maladaptive arms
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + params$self_defeat_bias
    
    # Select action greedily with respect to samples
    action <- which.max(sampled_Q)
    
    # Observe reward
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Bayesian update for chosen arm
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    
    # Update mood with exponential smoothing
    mood <- params$mood_decay * mood + (1 - params$mood_decay) * reward
    
    # Apply external event if present
    mood <- mood + external_events[i]
    
    # Store results
    actions[i] <- action
    rewards[i] <- reward
    mood_hist[i] <- mood
  }
  
  return(data.frame(trial = 1:episodes, action = actions, 
                   reward = rewards, mood = mood_hist))
}
```

The algorithm begins by initializing Bayesian beliefs with potentially pessimistic priors. At each trial, mood modulates the variance of Thompson sampling—negative mood increases exploration by inflating the sampling variance. Self-defeating bias is implemented by adding a constant to the sampled Q-values of maladaptive arms, making them artificially attractive. After action selection and reward observation, beliefs are updated using standard Bayesian inference, and mood evolves according to the exponential smoothing rule with potential external perturbations.

### Results and Interpretation

The simulation of 20 heterogeneous agents over 200 trials reveals several key patterns:

1. **Mood Trajectory Heterogeneity**: Agents exhibit diverse mood trajectories even when facing identical environmental conditions. Those with higher pessimism and self-defeating bias tend toward more negative mood states and show greater volatility in response to external events.

2. **Event Sensitivity**: The negative event at trial 50 produces variable responses across agents, with some showing rapid recovery while others exhibit persistent mood deterioration. This variability reflects individual differences in resilience—a key factor in depression vulnerability.

3. **Cumulative Performance**: Agents with more negative trait profiles accumulate fewer rewards over time, creating a self-reinforcing cycle where poor performance further degrades mood and decision-making.

The visualization of mood trajectories across all agents illustrates the complex interplay between individual traits and environmental factors. Some agents maintain relatively stable positive mood throughout the task, while others experience prolonged negative periods following adverse events—patterns reminiscent of the heterogeneity observed in clinical populations.

## Part 2: Meta-Cognitive Mechanisms in Depression

### Advanced Psychological Modeling

Our second framework extends the basic mood-modulated model by incorporating sophisticated meta-cognitive mechanisms that are central to depressive cognition. These mechanisms operate "above" the basic learning level, modifying how information is processed and integrated.
#### Learned Helplessness

Learned helplessness represents one of the most influential theories of depression, proposing that repeated uncontrollable negative experiences lead to a generalized expectation of futility. We implement this through an adaptive learning rate mechanism:

$$
\alpha^{(t)} = \alpha_{\text{base}} \cdot h^{(t)}
$$

where the helplessness factor decreases following consecutive negative outcomes:

$$
h^{(t)} = \begin{cases}
\eta & \text{if } \text{consecutive\_punishments} \geq \theta \\
1 & \text{otherwise}
\end{cases}
$$

Here, \( \theta \) is the helplessness threshold (number of consecutive negative outcomes required) and \( \eta < 1 \) is the reduction factor. Depressed agents have lower thresholds and stronger reductions, making them more susceptible to helplessness.

#### Rumination and Cognitive Bias

Rumination—the tendency to repeatedly focus on negative events—is modeled through asymmetric mood updates:

$$
\Delta m = \begin{cases}
w_+ \cdot r & \text{if } r > 0 \\
w_- \cdot |r| & \text{if } r < 0
\end{cases}
$$

For depressed agents, \( w_- > w_+ \), meaning negative outcomes have disproportionate impact on mood compared to positive outcomes of equivalent magnitude. This asymmetry captures the well-documented negativity bias in depression.


#### Agent Parameterization

We define two distinct agent populations with parameter sets derived from empirical findings:

**Non-Depressed Agents:**
- Neutral prior beliefs ($\mu_0 = 0$)
- No self-defeating bias ($\delta = 0$)
- Balanced rumination weights ($w_+ = w_- = 0.5$)
- High helplessness threshold ($\theta = 10$)
- Moderate helplessness factor ($\eta = 0.8$)
- Stable mood ($\lambda = 0.95$)

**Depressed Agents:**
- Pessimistic priors ($\mu_0 = -0.5$)
- Strong self-defeating bias ($\delta = 2$)
- Asymmetric rumination ($w_+ = 0.2, w_- = 0.8$)
- Low helplessness threshold ($\theta = 3$)
- Strong helplessness factor ($\eta = 0.3$)
- Volatile mood ($\lambda = 0.9$)

### Implementation Architecture

The enhanced agent function incorporates all meta-cognitive mechanisms:

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
  K <- length(reward_probs)
  
  # Initialize Bayesian beliefs
  mu <- rep(pessimistic_prior_mean, K)
  tau <- rep(1/prior_var, K)
  
  # Initialize tracking variables
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0
  mood_hist <- numeric(episodes)
  consecutive_punishments <- 0
  alpha_base <- 1.0
  
  for (i in 1:episodes) {
    # Mood-modulated Thompson sampling
    mood_clamped <- min(max(mood, -1), 1)
    mood_sigma_scale <- exp(-mood_influence * mood_clamped)
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    
    # Apply self-defeating bias
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    
    # Action selection
    action <- which.max(sampled_Q)
    
    # Reward observation
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Update learned helplessness counter
    if (reward < 0) {
      consecutive_punishments <- consecutive_punishments + 1
    } else {
      consecutive_punishments <- 0
    }
    
    # Compute effective learning rate based on helplessness
    if (consecutive_punishments >= learned_helplessness_threshold) {
      alpha <- alpha_base * learned_helplessness_factor
    } else {
      alpha <- alpha_base
    }
    
    # Bayesian update with modulated learning rate
    tau[action] <- tau[action] + alpha
    mu[action] <- (mu[action] * (tau[action] - alpha) + alpha * reward) / tau[action]
    
    # Rumination-modulated mood update
    if (reward > 0) {
      mood_update <- rumination_weight_success * reward
    } else if (reward < 0) {
      mood_update <- rumination_weight_failure * reward
    } else {
      mood_update <- 0
    }
    
    # Update mood
    mood <- mood_decay * mood + (1 - mood_decay) * mood_update
    
    # Store results
    actions[i] <- action
    rewards[i] <- reward
    mood_hist[i] <- mood
  }
  
  return(list(actions = actions, rewards = rewards, mood = mood_hist))
}
```

This implementation integrates all meta-cognitive mechanisms into a coherent framework. The learned helplessness mechanism tracks consecutive negative outcomes and reduces learning rates when thresholds are exceeded. Rumination is implemented through asymmetric weighting of positive and negative rewards in mood updates. The combination of these mechanisms with the basic mood-modulated learning creates a rich model capable of reproducing diverse aspects of depressive cognition.

## Discussion

### Population-Level Analysis and Clinical Heterogeneity

To capture the heterogeneity within clinical populations, we simulated 30 agents per group across non-depressed and depressed conditions, analyzing aggregate behavior patterns that reveal both group-level differences and within-group variability. This approach generated comprehensive datasets tracking cumulative rewards and mood trajectories across all agents and trials, with statistical analysis focusing on group means and standard errors to provide robust estimates of population-level effects while acknowledging individual differences.

The meta-cognitive framework produces several clinically relevant findings that illuminate the complex nature of depressive cognition. Depressed agents consistently showed lower cumulative rewards throughout tasks, with performance gaps widening over time, reflecting the compounding effects of multiple cognitive biases operating simultaneously. These agents exhibited greater mood volatility and more negative average mood states, with the interaction between rumination and learned helplessness creating self-perpetuating cycles of negativity.

The combination of pessimistic priors, reduced learning rates, and self-defeating biases severely impaired agents' ability to identify and exploit rewarding options. Even when depressed agents occasionally discovered beneficial choices, learned helplessness prevented them from capitalizing on this knowledge. Despite shared parameter sets, agents within each group showed meaningful individual differences in trajectories, underscoring the importance of personalized approaches in computational psychiatry.

### Mechanistic Insights and Dynamic Processes

Our mood-modulated reinforcement learning framework provides several mechanistic insights into depressive cognition that extend beyond traditional static models. The models demonstrate how multiple cognitive biases interact synergistically rather than additively, creating cascade effects where pessimistic priors make negative outcomes more likely, triggering rumination and learned helplessness that further degrade performance and mood. This cascade helps explain why depression can be so persistent and self-reinforcing, as each negative experience compounds previous difficulties.

Unlike static trait models, our framework captures the dynamic nature of mood and its feedback effects on cognition. This temporal dimension proves crucial for understanding both the episodic nature of depression and the potential for recovery through targeted interventions. The incorporation of population-level heterogeneity acknowledges that depression manifests differently across individuals, recognizing the essential need for personalized treatment approaches based on computational phenotyping.

### Clinical Applications and Translational Potential

The framework suggests several potential clinical applications that could transform how we approach depression assessment and treatment. Model parameters such as learning rates, mood decay, and helplessness thresholds could serve as objective markers of depressive severity and treatment response. Unlike subjective rating scales, these parameters are grounded in formal mathematical theory and can be estimated from behavioral data, providing more reliable and quantifiable measures of clinical state.

By identifying which computational mechanisms are most impaired in individual patients, clinicians could tailor interventions accordingly. Patients with strong self-defeating biases might benefit from behavioral activation approaches, while those with pronounced learned helplessness patterns might require cognitive restructuring interventions. Longitudinal tracking of model parameters could provide early indicators of treatment response or relapse risk, enabling proactive clinical management that anticipates rather than merely responds to symptom changes.

### Limitations and Methodological Considerations

While our framework represents a significant advance in modeling affective decision-making, several limitations must be acknowledged to contextualize these findings appropriately. Real-world decision-making occurs in rich, dynamic environments with complex reward structures that extend far beyond our bandit task paradigms. Although these simplified tasks prove useful for isolating specific mechanisms, they lack the complexity of naturalistic choice situations that patients encounter daily.

Our models, while inspired by neuroscientific findings, remain abstract computational descriptions that require further validation against neural data. Future work should more explicitly link model parameters to specific neural circuits and neurotransmitter systems to enhance biological plausibility. The models operate on trial-by-trial timescales, but depression involves changes across multiple temporal scales, from milliseconds of neural responses to months or years of clinical episodes. Multi-scale modeling approaches will be necessary to capture this full complexity.

Depression is influenced by social relationships, cultural context, and socioeconomic factors that are not captured in our individual-agent models. Extensions incorporating social learning and cultural transmission would enhance ecological validity and better reflect the multifaceted nature of mental health conditions. Additionally, the static nature of our environmental assumptions may not capture the dynamic, evolving challenges that individuals face in real-world contexts.

### Future Research Directions

Several promising directions emerge from this work that could significantly advance computational psychiatry. Extending the framework to include hierarchical models with higher-order beliefs about task structure, volatility, and self-efficacy could capture more sophisticated aspects of depressive cognition, particularly the meta-cognitive processes that maintain negative thought patterns.

Incorporating active inference principles would allow agents to not only learn from experience but also actively seek information to reduce uncertainty, a capacity that may be particularly impaired in depression. This extension could illuminate how depression affects information-seeking behaviors and curiosity, potentially explaining the withdrawal and reduced exploration commonly observed in clinical populations.

Developing computational models of therapeutic interventions, such as cognitive-behavioral therapy or pharmacotherapy, could help optimize treatment protocols and predict individual responses. Such models could simulate how different therapeutic approaches modify the underlying computational parameters, providing a principled framework for treatment selection and monitoring.

The framework could also be extended to model other psychiatric conditions characterized by altered reward processing, including addiction, anxiety disorders, and bipolar disorder. Cross-diagnostic applications would help identify shared computational mechanisms while highlighting disorder-specific features, potentially informing transdiagnostic treatment approaches.

## Conclusion

The integration of mood dynamics into reinforcement learning models represents a crucial step toward more realistic and clinically relevant computational models of mental health. Our comprehensive framework demonstrates how multiple cognitive biases, including pessimistic priors, self-defeating behaviors, rumination, and learned helplessness, interact to produce the characteristic patterns of behavior observed in depression.

The simulation studies presented here illustrate different but complementary aspects of this complexity. The population-level analyses capture heterogeneity and environmental influences, showing how individual differences in affective traits interact with life events to produce diverse trajectories. The mechanistic framework focuses on within-individual processes, demonstrating how meta-cognitive mechanisms can create self-perpetuating cycles of negative mood and poor decision-making.

Together, these models provide a rich computational account of depressive cognition that goes beyond simple deficits in reward learning. They capture the dynamic, multifaceted nature of depression while remaining grounded in formal mathematical principles. This combination of clinical relevance and theoretical rigor makes them valuable tools for both basic research and clinical application, bridging the gap between computational theory and therapeutic practice.

As computational psychiatry continues to mature, models like these will play an increasingly important role in understanding mental illness, developing targeted interventions, and ultimately improving outcomes for patients. The challenge ahead lies in validating these models against real-world data, extending them to capture additional aspects of human psychology, and translating computational insights into effective clinical tools that can be implemented in routine practice.

The future of mental health treatment may well depend on our ability to understand the computational principles underlying normal and abnormal cognition. By providing formal, testable models of how mood influences decision-making, our framework contributes to this ambitious but essential goal. These advances bring us closer to a truly personalized, mechanistically-informed approach to mental health care that can adapt treatments to individual computational profiles and provide more effective, targeted interventions for those suffering from depression and related conditions.

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
