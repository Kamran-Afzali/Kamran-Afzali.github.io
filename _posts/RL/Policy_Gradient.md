## Learning Policies versus Learning Values: A Deep Dive into the Policy Gradient Theorem

In the landscape of **reinforcement learning (RL)**, an agent seeks to learn a strategy—a **policy**—to maximize cumulative rewards in an uncertain environment. Historically, much of the foundational literature centered on **value-based methods**. These algorithms, like Q-Learning, focus on learning the *value* of being in a state or taking an action, and then derive a policy from these value estimates.

However, another powerful and more direct paradigm exists: **policy-based methods**. Instead of learning values first, these methods directly parameterize and optimize the policy itself. This approach is particularly effective in high-dimensional or continuous action spaces and forms the basis for many state-of-the-art algorithms.

This post explores the distinction between these two paradigms, delves into the mathematics of the **Policy Gradient Theorem**—the theoretical cornerstone of policy-based RL—and examines the fundamental differences that make each approach suited to different problem domains.

---

### The Two Paradigms of Reinforcement Learning

At its core, RL is about finding an optimal policy, denoted $\pi(a|s)$, which is a probability distribution over actions $a$ given a state $s$. The two primary approaches tackle this optimization from fundamentally different angles, each with distinct advantages and theoretical foundations.

#### Value-Based Methods: Learning Worth Before Action

Value-based methods learn a **value function** that estimates the expected return from any given state or state-action pair. The most fundamental is the action-value function, $Q^{\pi}(s,a)$, which represents the expected cumulative reward from taking action $a$ in state $s$ and then following policy $\pi$. This function satisfies the **Bellman equation**:

$$Q^{\pi}(s,a) = \mathbb{E}_{\pi} \left[ \sum_{k=0}^{\infty} \gamma^k R_{t+k+1} \, \Big| \, S_t=s, A_t=a \right]$$

where $\gamma \in [0, 1)$ is the discount factor that weights future rewards. The ultimate goal is to find the optimal action-value function, $Q^*(s,a)$, which satisfies the Bellman optimality equation. Once $Q^*(s,a)$ is known, the optimal policy $\pi^*$ emerges implicitly by acting greedily at every state:

$$\pi^*(s) = \arg\max_a Q^*(s,a)$$

This indirect approach to policy optimization has proven remarkably successful in discrete environments. Value-based methods often demonstrate superior sample efficiency and come with strong convergence guarantees in tabular settings. However, they face significant challenges when dealing with continuous action spaces, requiring either discretization or complex optimization procedures over the action space at each decision point. Additionally, the policy derived from value estimates can exhibit instability when the underlying value function is noisy or when combined with function approximation.

#### Policy-Based Methods: Direct Optimization of Behavior

Policy-based methods take a fundamentally different approach by bypassing the intermediate step of learning a value function. Instead, they directly parameterize the policy as $\pi_\theta(a|s)$, where $\theta$ is a vector of parameters that might represent the weights of a neural network or coefficients in a linear model. The optimization objective becomes finding the parameters $\theta$ that maximize a performance measure, typically the expected return from a starting state distribution:

$$J(\theta) = \mathbb{E}_{\pi_\theta} \left[ G_0 \right] = \mathbb{E}_{\pi_\theta} \left[ \sum_{t=0}^{\infty} \gamma^t R_{t+1} \, \Big| \, S_0 \sim \mu_0 \right]$$

where $\mu_0$ represents the initial state distribution. Optimization proceeds through **gradient ascent** on this objective:

$$\theta \leftarrow \theta + \alpha \nabla_\theta J(\theta)$$

where $\alpha$ is the learning rate and $\nabla_\theta J(\theta)$ is the **policy gradient**.

This direct approach naturally accommodates stochastic policies and excels in continuous or high-dimensional action spaces where the greedy action selection of value-based methods becomes computationally intractable. Policy-based methods often exhibit better convergence properties when combined with function approximation, as they avoid the instabilities that can arise from the indirect policy derivation in value-based approaches. However, they typically suffer from high variance in gradient estimates, which can lead to slower convergence and may converge to local rather than global optima.

The contrast between these paradigms extends beyond computational considerations. Value-based methods excel when we can accurately estimate the worth of different choices, making them particularly suited to environments with well-defined state-action values. Policy-based methods shine when the optimal behavior is inherently stochastic or when the action space complexity makes value-based approaches impractical.

---

### The Cornerstone: The Policy Gradient Theorem

The central challenge in policy-based methods lies in computing the gradient $\nabla_\theta J(\theta)$. The objective function $J(\theta)$ depends on the complex interplay between the policy parameters, the state and action distributions they generate, and the environment's dynamics. A naive differentiation approach is intractable because the gradient affects not only the immediate policy decisions but also the distribution of future states encountered.

The **Policy Gradient Theorem** provides an elegant and computationally tractable solution to this challenge. For episodic tasks, the theorem establishes that:

$$\nabla_\theta J(\theta) = \mathbb{E}_{\pi_\theta} \left[ \sum_{t=0}^{T-1} G_t \nabla_\theta \log \pi_\theta(A_t|S_t) \right]$$

where $G_t = \sum_{k=t}^{T-1} \gamma^{k-t} R_{k+1}$ represents the discounted return from time step $t$ onward.

#### Mathematical Intuition and Derivation

The theorem's elegance lies in its intuitive interpretation. The term $\nabla_\theta \log \pi_\theta(A_t|S_t)$ is known as the **score function** or **eligibility vector**. This vector points in the direction within parameter space that most increases the log-probability of taking action $A_t$ from state $S_t$. The policy gradient update pushes the parameters in this direction, weighted by the return $G_t$.

When $G_t$ is high, indicating a favorable outcome, the update increases the probability of taking action $A_t$ in state $S_t$. Conversely, when $G_t$ is low, representing an unfavorable outcome, the update decreases this probability. This mechanism provides a direct connection between outcomes and policy adjustments without requiring explicit value function estimates.

The mathematical derivation begins by considering the objective as an expectation over all possible trajectories $\tau = (S_0, A_0, R_1, S_1, A_1, \ldots)$:

$$J(\theta) = \sum_{\tau} P(\tau; \theta) R(\tau)$$

where $R(\tau)$ is the total return of trajectory $\tau$ and $P(\tau; \theta)$ is its probability under policy $\pi_\theta$. The gradient becomes:

$$\nabla_\theta J(\theta) = \sum_{\tau} R(\tau) \nabla_\theta P(\tau; \theta)$$

Applying the **log-derivative trick**, $\nabla_x f(x) = f(x) \nabla_x \log f(x)$, transforms this into:

$$\nabla_\theta J(\theta) = \sum_{\tau} R(\tau) P(\tau; \theta) \nabla_\theta \log P(\tau; \theta) = \mathbb{E}_{\tau \sim \pi_\theta} \left[ R(\tau) \nabla_\theta \log P(\tau; \theta) \right]$$

The trajectory probability decomposes as:

$$P(\tau; \theta) = p(S_0) \prod_{t=0}^{T-1} \pi_\theta(A_t|S_t) p(S_{t+1}|S_t, A_t)$$

Taking the logarithm and gradient:

$$\nabla_\theta \log P(\tau; \theta) = \sum_{t=0}^{T-1} \nabla_\theta \log \pi_\theta(A_t|S_t)$$

The environment dynamics and initial state distribution vanish from the gradient because they don't depend on $\theta$. This crucial insight allows us to compute policy gradients without requiring knowledge of the environment model.

#### Variance Reduction Through Baselines

While theoretically sound, the basic policy gradient estimate suffers from high variance. The return $G_t$ can vary dramatically between episodes even with identical policies, leading to noisy and unstable learning. The theorem can be enhanced by subtracting a **baseline** $b(S_t)$ from the return:

$$\nabla_\theta J(\theta) = \mathbb{E}_{\pi_\theta} \left[ \sum_{t=0}^{T-1} (G_t - b(S_t)) \nabla_\theta \log \pi_\theta(A_t|S_t) \right]$$

This modification introduces no bias because:

$$\mathbb{E}_{\pi_\theta} [b(S_t) \nabla_\theta \log \pi_\theta(A_t|S_t)] = \sum_s d^\pi(s) \sum_a b(s) \nabla_\theta \pi_\theta(a|s) = \sum_s d^\pi(s) b(s) \nabla_\theta \sum_a \pi_\theta(a|s) = 0$$

where $d^\pi(s)$ is the state visitation distribution under policy $\pi$, and the final equality follows because $\sum_a \pi_\theta(a|s) = 1$ for all states.

The optimal baseline choice is the state-value function $V^{\pi_\theta}(S_t)$, which leads to using the **advantage function**:

$$A^{\pi_\theta}(S_t, A_t) = Q^{\pi_\theta}(S_t, A_t) - V^{\pi_\theta}(S_t) \approx G_t - V^{\pi_\theta}(S_t)$$

This insight bridges the gap between value-based and policy-based methods, forming the theoretical foundation for **Actor-Critic architectures**.

---

### Beyond Pure Approaches: The Synthesis

The dichotomy between value-based and policy-based methods has largely given way to hybrid approaches that leverage the strengths of both paradigms. The most prominent example is the **Actor-Critic** family of algorithms, where a *critic* learns value function estimates to provide low-variance signals for a *actor* that maintains and updates the policy parameters.

In Actor-Critic methods, the critic learns an approximation to the value function $V^{\pi_\theta}(s)$, which serves as the baseline in the policy gradient update. This combination addresses the high variance problem of pure policy methods while maintaining the direct policy optimization advantages. Advanced variants like Proximal Policy Optimization (PPO) and Actor-Critic with Experience Replay (ACER) further enhance this synthesis by incorporating additional variance reduction techniques and sample efficiency improvements.

The REINFORCE algorithm, one of the earliest and most fundamental policy gradient methods, implements the basic policy gradient theorem directly by using Monte Carlo returns as unbiased estimates of $G_t$. While conceptually important and mathematically elegant, REINFORCE suffers from the high variance issues discussed above. Modern policy gradient methods have largely superseded pure REINFORCE through the incorporation of value function baselines and more sophisticated variance reduction techniques. We will explore these advanced Actor-Critic methods and their practical implementations in detail in subsequent posts.

---

### Conclusion: Complementary Paths to Optimal Control

The evolution from value-based to policy-based methods, and ultimately to their synthesis in Actor-Critic architectures, represents a fundamental progression in reinforcement learning theory and practice. Value-based methods provide a solid foundation with strong theoretical guarantees and sample efficiency in appropriate domains. Policy-based methods offer direct optimization of the desired behavior with natural handling of stochastic policies and continuous action spaces.

The Policy Gradient Theorem stands as one of the most elegant results in reinforcement learning, providing a principled foundation for direct policy optimization while revealing deep connections between policy improvement and value estimation. Its mathematical beauty lies not just in its derivation, but in how it transforms an apparently intractable optimization problem into a practical algorithm that can learn complex behaviors through experience.

Modern reinforcement learning has embraced the complementary nature of these approaches. The most successful algorithms combine the stability and efficiency of value learning with the direct optimization power of policy gradients. This synthesis has enabled breakthroughs in complex domains from robotics to game playing, demonstrating that the apparent dichotomy between learning values and learning policies is better understood as a spectrum of approaches, each with its place in the reinforcement learning toolkit.

Understanding both paradigms and their theoretical foundations provides the knowledge necessary to choose appropriate methods for specific problems and to appreciate the sophisticated algorithms that drive today's most impressive reinforcement learning applications.
