
# Mathematical Formalism of FEP and Active Inference

**Introduction**

The Free Energy Principle (FEP) and its algorithmic implementation in Active Inference represent a unifying theory of cognition, perception, and action. Rooted in statistical physics and variational Bayesian inference, this framework posits that biological systems maintain their structural and functional integrity by minimizing a variational bound on sensory surprise. This minimization drives both perceptual inference and decision-making, allowing organisms to navigate uncertainty while maintaining homeostasis.

Although widely cited in cognitive science, neuroscience, and machine learning, the underlying mathematics of FEP and Active Inference can seem opaque. This post aims to provide a rigorous walkthrough of its formal architecture, transitioning from basic probability and variational principles to advanced formulations involving path integrals, gradient flows, and stochastic differential equations. The goal is to demonstrate that far from being metaphysical or speculative, the FEP is grounded in well-established principles of information theory, thermodynamics, and statistical inference.



## Generative Models and Bayesian Inference

At the heart of the FEP is a generative model, which defines how an agent believes sensory data arise from hidden states of the world. Let $s$ denote hidden states, and $o$ denote sensory observations. The generative model defines the joint distribution:

$$
P(o, s)
$$

This joint distribution encodes the agent's belief about how sensory inputs $o$ are generated from latent causes $s$. From this, inference becomes the process of computing the posterior:

$$
P(s \mid o) = \frac{P(o, s)}{P(o)}
$$

While conceptually simple, this exact computation is often intractable due to the need to evaluate the evidence $P(o) = \sum_s P(o, s)$ (or integrate in continuous domains). Therefore, Active Inference employs variational inference to approximate the true posterior with a simpler distribution $Q(s)$, chosen from a tractable family of distributions.



## Variational Free Energy

The quality of this approximation is measured by the variational free energy $F$, defined as:

$$
F = \mathbb{E}_{Q(s)}[\log Q(s) - \log P(o, s)]
$$

This is the negative Evidence Lower Bound (ELBO) in variational inference, and it satisfies:

$$
F = D_{\text{KL}}(Q(s) \| P(s \mid o)) - \log P(o)
$$

Here, $D_{\text{KL}}$ is the Kullback-Leibler divergence. Since $-\log P(o)$ is constant with respect to $Q$, minimizing $F$ is equivalent to minimizing the divergence between the approximate posterior and the true posterior. Thus, perception becomes:

$$
Q^*(s) = \arg\min_Q F
$$

In other words, the agent infers the most plausible hidden causes for its observations by minimizing free energy.



## Action and Expected Free Energy

While perception corresponds to belief updating about the present, action requires planning over possible futures. To model this, Active Inference introduces the concept of **expected free energy** $G(\pi)$, which evaluates a policy $\pi$ — a sequence of future actions — based on its expected impact on belief and sensory states:

$$
G(\pi) = \mathbb{E}_{Q(o, s \mid \pi)}[\log Q(s \mid \pi) - \log P(o, s)]
$$

Through algebraic manipulation, this expression can be decomposed as:

$$
G(\pi) = \mathbb{E}_{Q(o \mid \pi)}\left[ D_{\text{KL}}(Q(s \mid o, \pi) \| P(s)) \right] - \mathbb{E}_{Q(o \mid \pi)}[\log P(o)]
$$

This decomposition reveals two fundamental components:

1. **Epistemic Value**: the expected information gain from executing policy $\pi$, encouraging exploration.
2. **Extrinsic Value**: the expected log likelihood of preferred outcomes, guiding exploitation.

By selecting the policy that minimizes $G(\pi)$, the agent balances exploration and goal-directed behavior:

$$
\pi^* = \arg\min_\pi G(\pi)
$$



## Generalized Free Energy in Continuous Time

In continuous-time formulations, beliefs and observations evolve along trajectories. This is captured by the generalized free energy functional:

$$
\mathcal{F}[q] = \int_0^T \mathbb{E}_{q(s_t)}\left[ \log q(s_t) - \log p(o_t, s_t) \right] \, dt
$$

Here, $q(s_t)$ is the time-indexed approximate posterior, and $p(o_t, s_t)$ is the generative model at time $t$. This integral represents a path-dependent cost functional, akin to action functionals in Lagrangian mechanics.

Minimizing this functional leads to variational dynamics described by:

$$
\frac{dq(s_t)}{dt} = - \nabla_q \mathcal{F}[q]
$$

This defines a gradient flow in the space of distributions, mirroring the Fokker-Planck equation that governs the time evolution of probability densities in stochastic systems.



## Generalized Coordinates of Motion

To fully model perception in continuous environments, the FEP employs generalized coordinates of motion:

$$
\tilde{s} = \{s, \dot{s}, \ddot{s}, \dots\}
$$

These extended state representations encode the position, velocity, acceleration, and higher-order temporal derivatives of hidden states. By modeling sensory flows through time, this formalism allows the generative model to predict smooth temporal trajectories rather than static snapshots.

This is essential for capturing the temporal structure of perception, particularly in vision and proprioception, where sensory dynamics contain information critical for interpretation.



## Decomposition of Expected Free Energy

Returning to the discrete-time expected free energy, its decomposition highlights its role in simultaneously reducing uncertainty and pursuing preferred states. The formal expression:

$$
G(\pi) = \mathbb{E}_{q(o \mid \pi)}\left[ D_{\text{KL}}(q(s \mid o, \pi) \| p(s)) \right] - \mathbb{E}_{q(o \mid \pi)}[\log p(o)]
$$

splits into:

* The first term quantifies epistemic value: expected divergence between posterior and prior beliefs. It favors policies that produce informative observations.
* The second term quantifies extrinsic value: expected log probability of preferred observations. It favors policies that align with the agent's goals.

Crucially, both terms arise from the same generative model and require no additional reward function, distinguishing Active Inference from reinforcement learning frameworks.



## Active Inference as Stochastic Optimal Control

FEP also permits interpretation within stochastic control theory. Let the system dynamics be given by:

$$
ds_t = f(s_t, a_t)dt + \omega_t, \quad o_t = g(s_t) + \nu_t
$$

with $\omega_t$ and $\nu_t$ representing process and observation noise, respectively. Rather than minimizing a cost function $C(s, a)$, the agent minimizes expected free energy:

$$
\pi^* = \arg\min_\pi \mathbb{E}_{q(o, s \mid \pi)}[\mathcal{F}]
$$

This framing reveals Active Inference as a form of risk-sensitive, information-seeking control. It subsumes traditional control objectives (e.g., reaching a target) within a broader variational architecture that includes uncertainty reduction and predictive consistency.



## Information-Theoretic Foundations

At a deeper level, FEP is an information-theoretic principle. It posits that agents minimize the divergence between predicted and actual sensory states, effectively maximizing mutual information between beliefs and observations.

In this context, expected free energy bounds the expected surprise of observations under a given policy:

$$
G(\pi) \geq -\log p(o \mid \pi)
$$

Minimizing $G(\pi)$ thus ensures that the agent selects actions that render future observations less surprising and more consistent with its model. This information-theoretic view aligns with efficient coding hypotheses in neuroscience and resonates with Shannon’s foundational work on entropy and uncertainty.



## Thermodynamic Analogy

A compelling interpretation of the FEP is thermodynamic. The variational free energy mirrors the Helmholtz free energy from statistical physics:

$$
F = U - T S
$$

Here, $U$ denotes internal energy (expected log-likelihood), $S$ is entropy, and $T$ plays an abstract role akin to temperature. Under FEP, the internal energy is interpreted as the agent’s confidence in its generative model, and entropy captures uncertainty about hidden causes.

By minimizing variational free energy, the agent resists entropy-increasing perturbations from its environment. This explains the observation that biological systems persist and adapt despite ongoing exposure to stochastic sensory inputs. In this light, life is the suppression of surprise, or more formally, the minimization of variational free energy over time.



## Conclusion

The Free Energy Principle and Active Inference framework provide a mathematically coherent and unifying theory of intelligent behavior. Far from being metaphysical, this framework is grounded in variational Bayesian inference, stochastic control, information geometry, and thermodynamics.

Through the minimization of variational free energy, agents simultaneously infer the hidden causes of their sensations and select actions that align with both uncertainty reduction and goal-directed behavior. This dual role of inference — retrospective (perception) and prospective (action) — is made tractable through variational methods, expected free energy, and gradient flows in the space of beliefs.

While the conceptual elegance of FEP has inspired a broad literature, it is the formal machinery that anchors it in scientific rigor. From the derivation of the expected free energy functional to its decomposition into epistemic and extrinsic value, FEP offers not just a metaphor but a precise algorithmic account of perception and action.

As computational implementations advance, FEP and Active Inference stand to reshape our understanding of adaptive systems — from brains and bodies to robots and synthetic agents — all bound by the same imperative: to minimize the surprise of existence.

Certainly. Below is a **recapitulative table** summarizing the key mathematical components and interpretations in the Free Energy Principle (FEP) and Active Inference framework. This can be inserted before the conclusion in your blog post for clarity.



### Table: Summary of Key Mathematical Constructs in FEP and Active Inference

| **Concept**                     | **Mathematical Expression**                                                                     | **Interpretation**                                              |
| ------------------------------- | ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **Generative Model**            | $P(o, s)$                                                                                       | Joint probability over observations $o$ and hidden states $s$   |
| **Bayesian Inference**          | $P(s \mid o) = \frac{P(o, s)}{P(o)}$                                                            | Posterior belief about hidden causes given observations         |
| **Variational Free Energy**     | $F = \mathbb{E}_{Q(s)}[\log Q(s) - \log P(o, s)]$                                               | Upper bound on surprise; minimized during perception            |
| **Free Energy Decomposition**   | $F = D_{\text{KL}}(Q(s) \| P(s \mid o)) - \log P(o)$                                            | Trade-off between accuracy and complexity                       |
| **Perceptual Inference**        | $Q^*(s) = \arg\min_Q F$                                                                         | Optimal approximate posterior under free energy minimization    |
| **Expected Free Energy**        | $G(\pi) = \mathbb{E}_{Q(o, s \mid \pi)}[\log Q(s \mid \pi) - \log P(o, s)]$                     | Evaluates future-oriented policies                              |
| **EFE Decomposition**           | $G(\pi) = \mathbb{E}_{Q(o)}[D_{\text{KL}}(Q(s \mid o) \| P(s))] - \mathbb{E}_{Q(o)}[\log P(o)]$ | Epistemic (information gain) + Extrinsic (goal alignment) value |
| **Policy Selection**            | $\pi^* = \arg\min_\pi G(\pi)$                                                                   | Select policies that minimize expected free energy              |
| **Path Integral Formulation**   | $\mathcal{F}[q] = \int_0^T \mathbb{E}_{q(s_t)}[\log q(s_t) - \log p(o_t, s_t)] \, dt$           | Generalized free energy over time in continuous systems         |
| **Gradient Flow on Beliefs**    | $\frac{dq(s_t)}{dt} = - \nabla_q \mathcal{F}[q]$                                                | Belief dynamics follow variational gradient descent             |
| **Generalized Coordinates**     | $\tilde{s} = \{s, \dot{s}, \ddot{s}, \dots\}$                                                   | Encodes temporally extended hidden states                       |
| **Thermodynamic Analogy**       | $F = U - TS$                                                                                    | Internal energy minus entropy (information-theoretic analogue)  |
| **Information-Theoretic Bound** | $G(\pi) \geq -\log P(o \mid \pi)$                                                               | Expected free energy bounds future surprise                     |


