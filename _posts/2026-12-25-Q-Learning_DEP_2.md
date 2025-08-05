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

$$\alpha^{(t)} = \alpha_{\text{base}} \cdot h^{(t)}$$

where the helplessness factor $h^{(t)}$ decreases following consecutive negative outcomes:

$$h^{(t)} = \begin{cases}
\eta & \text{if } \text{consecutive\_punishments} \geq \theta \\
1 & \text{otherwise}
\end{cases}$$

Here, $\theta$ is the helplessness threshold (number of consecutive negative outcomes required) and $\eta < 1$ is the reduction factor. Depressed agents have lower thresholds and stronger reductions, making them more susceptible to helplessness.

#### Rumination and Cognitive Bias

Rumination—the tendency to repeatedly focus on negative events—is modeled through asymmetric mood updates:

$$\Delta m = \begin{cases}
w_+ \cdot r & \text{if } r > 0 \\
w_- \cdot |r| & \text{if } r < 0
\end{cases}$$

For depressed agents, $w_- > w_+$, meaning negative outcomes have disproportionate impact on mood compared to positive outcomes of equivalent magnitude. This asymmetry captures the well-documented negativity bias in depression.

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

### Population-Level Analysis

To capture the heterogeneity within clinical populations, we simulate 30 agents per group (non-depressed and depressed) and analyze aggregate behavior patterns. This approach reveals both group-level differences and within-group variability.

The simulation generates comprehensive datasets tracking cumulative rewards and mood trajectories across all agents and trials. Statistical analysis focuses on group means and standard errors, providing robust estimates of population-level effects while acknowledging individual differences.

### Results and Clinical Implications

The meta-cognitive framework produces several clinically relevant findings:

1. **Cumulative Reward Deficits**: Depressed agents show consistently lower cumulative rewards throughout the task, with the gap widening over time. This pattern reflects the compounding effects of multiple cognitive biases operating simultaneously.

2. **Mood Instability**: Depressed agents exhibit greater mood volatility and more negative average mood states. The interaction between rumination and learned helplessness creates a self-perpetuating cycle of negativity.

3. **Learning Impairments**: The combination of pessimistic priors, reduced learning rates, and self-defeating biases severely impairs the ability to identify and exploit rewarding options. Even when depressed agents occasionally discover good choices, learned helplessness prevents them from capitalizing on this knowledge.

4. **Individual Variability**: Despite shared parameter sets, agents within each group show meaningful individual differences in trajectories. This variability underscores the importance of personalized approaches in computational psychiatry.

## Broader Implications for Computational Psychiatry

### Mechanistic Insights

Our mood-modulated RL framework provides several mechanistic insights into depressive cognition:

**Cascade Effects**: The models demonstrate how multiple cognitive biases interact synergistically rather than additively. Pessimistic priors make negative outcomes more likely, which triggers rumination and learned helplessness, further degrading performance and mood. This cascade helps explain why depression can be so persistent and self-reinforcing.

**Dynamic Instability**: Unlike static trait models, our framework captures the dynamic nature of mood and its feedback effects on cognition. This temporal dimension is crucial for understanding both the episodic nature of depression and the potential for recovery through targeted interventions.

**Individual Differences**: The incorporation of population-level heterogeneity acknowledges that depression manifests differently across individuals. This recognition is essential for developing personalized treatment approaches based on computational phenotyping.

### Clinical Applications

The framework suggests several potential clinical applications:

**Computational Biomarkers**: Model parameters (e.g., learning rates, mood decay, helplessness thresholds) could serve as objective markers of depressive severity and treatment response. Unlike subjective rating scales, these parameters are grounded in formal mathematical theory and can be estimated from behavioral data.

**Intervention Targeting**: By identifying which computational mechanisms are most impaired in individual patients, clinicians could tailor interventions accordingly. For example, patients with strong self-defeating biases might benefit from behavioral activation, while those with learned helplessness might require cognitive restructuring.

**Treatment Monitoring**: Longitudinal tracking of model parameters could provide early indicators of treatment response or relapse risk, enabling proactive clinical management.

### Limitations and Future Directions

While our framework represents a significant advance in modeling affective decision-making, several limitations must be acknowledged:

**Environmental Complexity**: Real-world decision-making occurs in rich, dynamic environments with complex reward structures. Our bandit tasks, while useful for isolating specific mechanisms, lack the complexity of naturalistic choice situations.

**Neural Implementation**: Although our models are inspired by neuroscientific findings, they remain abstract computational descriptions. Future work should more explicitly link model parameters to specific neural circuits and neurotransmitter systems.

**Temporal Scales**: Our models operate on trial-by-trial timescales, but depression involves changes across multiple temporal scales—from milliseconds (neural responses) to months or years (clinical episodes). Multi-scale modeling approaches will be necessary to capture this complexity.

**Social and Cultural Factors**: Depression is influenced by social relationships, cultural context, and socioeconomic factors that are not captured in our individual-agent models. Extensions incorporating social learning and cultural transmission would enhance ecological validity.

### Future Research Directions

Several promising directions emerge from this work:

**Hierarchical Models**: Extending the framework to include higher-order beliefs about task structure, volatility, and self-efficacy could capture more sophisticated aspects of depressive cognition.

**Active Inference**: Incorporating active inference principles would allow agents to not only learn from experience but also actively seek information to reduce uncertainty—a capacity that may be impaired in depression.

**Intervention Modeling**: Developing computational models of therapeutic interventions (e.g., cognitive-behavioral therapy, pharmacotherapy) could help optimize treatment protocols and predict individual responses.

**Cross-Diagnostic Applications**: The framework could be extended to model other psychiatric conditions characterized by altered reward processing, such as addiction, anxiety disorders, or bipolar disorder.

## Conclusion

The integration of mood dynamics into reinforcement learning models represents a crucial step toward more realistic and clinically relevant computational models of mental health. Our comprehensive framework demonstrates how multiple cognitive biases—pessimistic priors, self-defeating behaviors, rumination, and learned helplessness—interact to produce the characteristic patterns of behavior observed in depression.

The two simulation studies presented here illustrate different aspects of this complexity. The first framework captures population heterogeneity and environmental influences, showing how individual differences in affective traits interact with life events to produce diverse trajectories. The second framework focuses on within-individual mechanisms, demonstrating how meta-cognitive processes can create self-perpetuating cycles of negative mood and poor decision-making.

Together, these models provide a rich computational account of depressive cognition that goes beyond simple deficits in reward learning. They capture the dynamic, multifaceted nature of depression while remaining grounded in formal mathematical principles. This combination of clinical relevance and theoretical rigor makes them valuable tools for both basic research and clinical application.

As computational psychiatry continues to mature, models like these will play an increasingly important role in understanding mental illness, developing targeted interventions, and ultimately improving outcomes for patients. The challenge ahead lies in validating these models against real-world data, extending them to capture additional aspects of human psychology, and translating computational insights into effective clinical tools.

The future of mental health treatment may well depend on our ability to understand the computational principles underlying normal and abnormal cognition. By providing formal, testable models of how mood influences decision-making, our framework contributes to this ambitious but essential goal.

## References

Badcock, P. B., Friston, K. J., Ramstead, M. J., Ploeger, A., & Hohwy, J. (2019). The hierarchically mechanistic mind: A free-energy formulation of the human psyche. *Physics of Life Reviews*, 31, 104–121.

Beck, A. T., Rush, A. J., Shaw, B. F., & Emery, G. (1979). *Cognitive therapy of depression*. Guilford Press.

Blanco, N. J., Otto, A. R., Maddox, W. T., Beevers, C. G., & Love, B. C. (2013). The influence of depression symptoms on exploratory decision-making. *Cognition*, 129(3), 563–568.

Dayan, P., & Huys, Q. J. M. (2008). Serotonin, inhibition, and negative mood. *PLoS Computational Biology*, 4(2), e4.

Eshel, N., & Roiser, J. P. (2010). Reward and punishment processing in depression. *Biological Psychiatry*, 68(2), 118–124.

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience*, 38*, 1–23.

Huys, Q. J. M., Pizzagalli, D. A., Bogdan, R., & Dayan, P. (2013). Mapping anhedonia onto reinforcement learning: A behavioral meta-analysis. *Biology of Mood & Anxiety Disorders*, 3, 12.

Kumar, P., Waiter, G., Ahearn, T., Milders, M., Reid, I., & Steele, J. D. (2008). Abnormal temporal difference reward-learning signals in major depression. *Brain*, 131(8), 2084–2093.

Maia, T. V., & Frank, M. J. (2011). From reinforcement learning models to psychiatric and neurological disorders. *Nature Neuroscience*, 14(2), 154–162.

Montague, P. R., Dolan, R. J., Friston, K. J., & Dayan, P. (2012). Computational psychiatry. *Trends in Cognitive Sciences*, 16(1), 72–80.

Pike, A. C., & Robinson, O. J. (2022). Reinforcement learning in patients with mood and anxiety disorders vs control individuals: A systematic review and meta-analysis. *JAMA Psychiatry*, 79(4), 313–322.

Pittig, A., Treanor, M., LeBeau, R. T., & Craske, M. G. (2018). The role of associative learning in anxiety disorders: A reassessment. *Behaviour Research and Therapy*, 112, 1–17.

Rottenberg, J., & Hindash, A. C. (2015). Emerging evidence for emotion context insensitivity in depression. *Current Opinion in Psychology*, 4, 72–77.

Rutledge, R. B., Skandali, N., Dayan, P., & Dolan, R. J. (2014). A computational and neural model of momentary subjective well-being. *Proceedings of the National Academy of Sciences*, 111(33), 12252–12257.

Seligman, M. E. P. (1972). Learned helplessness: Annual review of medicine and a theory for the age of personal control. *Annual Review of Medicine*, 23(1), 407–412.

Sutton, R. S., & Barto, A. G. (2018). *Reinforcement learning: An introduction* (2nd ed.). MIT Press.

Thompson, W. R. (1933). On the likelihood that one unknown probability exceeds another in view of the evidence of two samples. *Biometrika*, 25(3-4), 285–294.

Treadway, M. T., & Zald, D. H. (2013). Parsing anhedonia: Translational models of reward-processing deficits in psychopathology. *Current Directions in Psychological Science*, 22(3), 244–249.

Whitton, A. E., Treadway, M. T., & Pizzagalli, D. A. (2015). Reward processing dysfunction in major depression, bipolar disorder and schizophrenia. *Current Opinion in Psychiatry*, 28(1), 7–12.
