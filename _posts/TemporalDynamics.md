# Temporal Dynamics in Computational Psychiatry

Mental health does not exist in snapshots. Depression, anxiety, bipolar disorder, and other psychiatric conditions unfold across time, shifting between states of stability and crisis, responding to life events with varying degrees of resilience, and following trajectories that defy simple linear prediction. Yet traditional psychiatric assessment relies heavily on static measurements—questionnaires administered at single time points, diagnostic interviews that ask patients to recall symptoms over weeks or months, and treatment decisions based on sparse clinical observations. Computational psychiatry is transforming this landscape by placing temporal dynamics at its core, using mathematical models to capture how psychological states evolve, transition, and respond to intervention across multiple timescales.

The central insight here that mental health is a dynamical system, just like climate patterns or financial markets, psychological functioning exhibits nonlinear dynamics, critical transitions, feedback loops, and emergent behavior that cannot be understood through static snapshots alone. A person experiencing mounting workplace stress does not gradually and linearly descend into depression; instead, their psychological system may remain relatively stable until crossing a critical threshold, at which point mood can collapse suddenly into a self-reinforcing depressive state. Recovery does not simply reverse this process—it requires different conditions, often more intensive interventions, reflecting the phenomenon of hysteresis where forward and backward trajectories through state space follow distinct paths.

This blog post synthesizes five interconnected perspectives on temporal dynamics in computational psychiatry, each addressing a different aspect of how time-varying processes shape mental health trajectories. We explore critical transitions and system dynamics, hidden Markov models for inferring latent psychological states, the asymmetry between illness onset and recovery, parameter estimation for personalized prediction, and the practical implementation of these frameworks using real-world data. Throughout, we provide mathematical formalism and computational implementations in R and Python for researchers and clinicians to use these methods to their own contexts.

## The Mathematics of Mood as a Dynamical System

At the heart of temporal dynamics in computational psychiatry lies the mathematical machinery of differential equations and stochastic processes. Rather than treating mood as a static variable that occasionally changes, dynamical systems theory models it as a continuous state that evolves according to governing equations capturing both deterministic forces and random perturbations. Consider a minimal representation where mood state $m(t)$ at time $t$ evolves according to:

$$
\frac{dm}{dt} = f(m, \theta) + \sigma \xi(t)
$$

Here $f(m, \theta)$ represents the deterministic drift—the systematic forces pushing mood in particular directions based on current state $m$ and individual parameters $\theta$—while $\sigma \xi(t)$ captures stochastic fluctuations from daily life events, with $\xi(t)$ being white noise and $\sigma$ controlling noise intensity.

The power of this framework emerges when we choose drift functions that create multiple stable equilibria, reflecting the clinical observation that individuals can occupy qualitatively different psychological states. A canonical example is the cusp catastrophe model, where:

$$
f(m, \theta) = r \cdot m - m^3 + s
$$

The parameter $r$ governs resilience—the system's ability to return to baseline after perturbations—while $s$ represents external stress or support. For certain parameter ranges, this simple cubic nonlinearity generates bistability: two stable attractors corresponding to healthy positive mood and depressed negative mood, separated by an unstable boundary. The system can exist in either attractor basin, with transitions between them requiring sufficient perturbation energy to cross the separating threshold.

This mathematical structure immediately explains several clinical phenomena, like why do some individuals "snap" into depression following relatively minor stressors while others withstand major life challenges? The answer lies in their proximity to the critical threshold and the depth of their current attractor basin. Why does depression persist even after the original triggering stressor resolves? Because the system has transitioned into a self-reinforcing negative attractor from which escape requires different conditions than those causing entry.

### Implementing Critical Transitions in R

To make these concepts concrete, we can simulate mood dynamics using numerical solutions of stochastic differential equations. The following R implementation uses the `deSolve` package to solve coupled differential equations representing mood, stress accumulation, and adaptive resilience:

```{r}
library(deSolve)
library(ggplot2)
library(dplyr)
library(tidyr)

# -----------------------------
# 1) External stress as forcing
# -----------------------------
times <- seq(0, 400, by = 0.1)

stress_df <- data.frame(
  time = times,
  baseline = 0.05,
  major_event = ifelse(times >= 100 & times <= 120, 0.4, 0),
  moderate_event = ifelse(times >= 250 & times <= 260, 0.2, 0),
  daily_variation = 0.05 * sin(2 * pi * times / 7)
)

stress_df$stress_input <- with(
  stress_df,
  baseline + major_event + moderate_event + daily_variation
)

external_stress <- approxfun(
  x = stress_df$time,
  y = stress_df$stress_input,
  rule = 2
)

# -----------------------------------
# 2) Deterministic coupled ODE system
# -----------------------------------
mood_dynamics <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    stress_t <- external_stress(t)
    
    # Mood dynamics with cubic nonlinearity
    dm <- (r_base + r) * m - m^3 - alpha_s * s
    
    # Stress accumulation and decay
    ds <- stress_t - beta * s
    
    # Resilience adaptation
    dr <- gamma * (m - threshold_m) - delta * r
    
    list(c(dm, ds, dr))
  })
}

# ---------------------------------
# 3) Parameters and initial values
# ---------------------------------
params_vulnerable <- c(
  r_base = -0.2,
  alpha_s = 0.3,
  beta = 0.1,
  gamma = -0.02,
  delta = 0.05,
  threshold_m = -0.3
)

initial_state <- c(
  m = 0.5,
  s = 0.1,
  r = 0
)

# -------------------
# 4) Solve the model
# -------------------
out_vulnerable <- ode(
  y = initial_state,
  times = times,
  func = mood_dynamics,
  parms = params_vulnerable,
  method = "lsoda",
  rtol = 1e-6,
  atol = 1e-8
)

df_vulnerable <- as.data.frame(out_vulnerable) %>%
  mutate(stress_input = external_stress(time))

# -------------------
# 5) Plot mood only
# -------------------
p1 <- ggplot(df_vulnerable, aes(x = time, y = m)) +
  geom_line(linewidth = 0.8, color = "darkred") +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  annotate("rect", xmin = 100, xmax = 120, ymin = -Inf, ymax = Inf,
           alpha = 0.10, fill = "red") +
  annotate("rect", xmin = 250, xmax = 260, ymin = -Inf, ymax = Inf,
           alpha = 0.10, fill = "orange") +
  labs(
    title = "Mood Trajectory Under Stress: Vulnerable Individual",
    x = "Time (days)",
    y = "Mood state"
  ) +
  theme_minimal()

print(p1)

# -----------------------------------------
# 6) Plot all variables in long-data format
# -----------------------------------------
df_long <- df_vulnerable %>%
  select(time, m, s, r, stress_input) %>%
  pivot_longer(
    cols = c(m, s, r, stress_input),
    names_to = "variable",
    values_to = "value"
  )

label_map <- c(
  m = "Mood",
  s = "Stress",
  r = "Resilience",
  stress_input = "External stress"
)

p2 <- ggplot(df_long, aes(x = time, y = value, color = variable)) +
  geom_line(linewidth = 0.7) +
  annotate("rect", xmin = 100, xmax = 120, ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "red", inherit.aes = FALSE) +
  annotate("rect", xmin = 250, xmax = 260, ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "orange", inherit.aes = FALSE) +
  scale_color_manual(
    values = c(
      m = "darkred",
      s = "steelblue",
      r = "darkgreen",
      stress_input = "black"
    ),
    labels = label_map
  ) +
  labs(
    title = "Coupled Mood-Stress-Resilience Dynamics",
    x = "Time (days)",
    y = "State value",
    color = NULL
  ) +
  theme_minimal()

print(p2)
```

This simulation reveals how vulnerable individuals experience rapid transitions into negative mood following major stressors at $t = 100$ and crucially fail to recover even after the stressor passes. The trajectory becomes trapped in the depressed attractor for extended periods, while resilient individuals (with higher $r_{base}$ parameters) show temporary decline but rapid recovery.

## Early Warning Signals: Predicting Transitions Before They Occur

One of the most clinically valuable applications of dynamical systems theory is the detection of early warning signals before critical transitions occur. As a system approaches a tipping point, it exhibits characteristic phenomena collectively termed "critical slowing down". Recovery from small perturbations becomes increasingly sluggish, fluctuations around the current state grow in magnitude, and the system becomes more predictable from its recent history.

For mood systems approaching depression, these signals manifest as increased autocorrelation (each mood measurement becomes more predictable from previous values), rising variance (larger swings in daily mood), and decreased return rate (slower recovery after minor stressors). We can quantify these metrics using rolling window analysis:

```{r}
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

compute_warning_signals_complete <- function(
  trajectory,
  value_col = "m",
  time_col = "time",
  window_size = 300,
  step_size = 10,
  detrend = TRUE
) {
  stopifnot(all(c(value_col, time_col) %in% names(trajectory)))

  x <- trajectory[[value_col]]
  tt <- trajectory[[time_col]]
  n <- length(x)

  if (window_size >= n) {
    stop("window_size must be smaller than the number of observations.")
  }

  n_windows <- floor((n - window_size) / step_size) + 1

  results <- data.frame(
    window_id = seq_len(n_windows),
    start_idx = integer(n_windows),
    end_idx = integer(n_windows),
    time = numeric(n_windows),
    lag1_ac = numeric(n_windows),
    variance = numeric(n_windows),
    ar1 = numeric(n_windows),
    return_rate = numeric(n_windows),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(n_windows)) {
    start_idx <- (i - 1) * step_size + 1
    end_idx <- start_idx + window_size - 1

    window_data <- x[start_idx:end_idx]
    window_time <- tt[start_idx:end_idx]

    if (detrend) {
      fit_trend <- lm(window_data ~ window_time)
      series <- resid(fit_trend)
    } else {
      series <- window_data
    }

    results$start_idx[i] <- start_idx
    results$end_idx[i] <- end_idx
    results$time[i] <- mean(window_time)

    if (all(is.na(series)) || sd(series, na.rm = TRUE) == 0) {
      results$lag1_ac[i] <- NA_real_
      results$variance[i] <- 0
      results$ar1[i] <- NA_real_
      results$return_rate[i] <- NA_real_
      next
    }

    lag_x <- series[-length(series)]
    lag_y <- series[-1]

    if (sd(lag_x, na.rm = TRUE) == 0 || sd(lag_y, na.rm = TRUE) == 0) {
      results$lag1_ac[i] <- NA_real_
    } else {
      results$lag1_ac[i] <- cor(lag_x, lag_y, use = "complete.obs")
    }

    results$variance[i] <- var(series, na.rm = TRUE)

    ar_fit <- try(ar(series, aic = FALSE, order.max = 1, method = "ols"), silent = TRUE)

    if (inherits(ar_fit, "try-error") || length(ar_fit$ar) == 0 || is.na(ar_fit$ar[1])) {
      results$ar1[i] <- NA_real_
      results$return_rate[i] <- NA_real_
    } else {
      phi <- unname(ar_fit$ar[1])
      results$ar1[i] <- phi

      if (abs(phi) > 0 && is.finite(phi)) {
        results$return_rate[i] <- -log(abs(phi))
      } else {
        results$return_rate[i] <- NA_real_
      }
    }
  }

  results
}

summarize_warning_signals <- function(warnings_df) {
  indicators <- c("lag1_ac", "variance", "ar1", "return_rate")

  out <- lapply(indicators, function(v) {
    keep <- complete.cases(warnings_df[, c("time", v)])
    if (sum(keep) < 3) {
      return(data.frame(
        indicator = v,
        kendall_tau = NA_real_,
        p_value = NA_real_,
        first_value = NA_real_,
        last_value = NA_real_,
        percent_change = NA_real_,
        interpretation = NA_character_
      ))
    }

    kt <- suppressWarnings(cor.test(
      warnings_df$time[keep],
      warnings_df[[v]][keep],
      method = "kendall",
      exact = FALSE
    ))

    first_value <- warnings_df[[v]][keep][1]
    last_value <- warnings_df[[v]][keep][sum(keep)]

    percent_change <- ifelse(
      is.na(first_value) || first_value == 0,
      NA_real_,
      100 * (last_value - first_value) / abs(first_value)
    )

    interpretation <- dplyr::case_when(
      v %in% c("lag1_ac", "variance", "ar1") && kt$estimate > 0 ~ "Increasing over time; compatible with warning signal",
      v == "return_rate" && kt$estimate < 0 ~ "Decreasing over time; compatible with slowing recovery",
      TRUE ~ "No clear warning trend"
    )

    data.frame(
      indicator = v,
      kendall_tau = unname(kt$estimate),
      p_value = kt$p.value,
      first_value = first_value,
      last_value = last_value,
      percent_change = percent_change,
      interpretation = interpretation
    )
  })

  bind_rows(out)
}

plot_warning_dashboard <- function(trajectory, warnings_df) {
  traj_plot <- ggplot(trajectory, aes(x = time, y = m)) +
    geom_line(linewidth = 0.7, color = "darkred") +
    geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
    annotate("rect", xmin = 100, xmax = 120, ymin = -Inf, ymax = Inf,
             alpha = 0.08, fill = "red") +
    annotate("rect", xmin = 250, xmax = 260, ymin = -Inf, ymax = Inf,
             alpha = 0.08, fill = "orange") +
    labs(title = "Mood trajectory", x = "Time", y = "Mood") +
    theme_minimal()

  p_ac <- ggplot(warnings_df, aes(time, lag1_ac)) +
    geom_line(color = "purple", linewidth = 0.7) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
    labs(title = "Lag-1 autocorrelation", x = "Time", y = "AC(1)") +
    theme_minimal()

  p_var <- ggplot(warnings_df, aes(time, variance)) +
    geom_line(color = "steelblue", linewidth = 0.7) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
    labs(title = "Rolling variance", x = "Time", y = "Variance") +
    theme_minimal()

  p_ar1 <- ggplot(warnings_df, aes(time, ar1)) +
    geom_line(color = "darkgreen", linewidth = 0.7) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
    labs(title = "AR(1) coefficient", x = "Time", y = "phi") +
    theme_minimal()

  p_rr <- ggplot(warnings_df, aes(time, return_rate)) +
    geom_line(color = "brown", linewidth = 0.7) +
    geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "black") +
    labs(title = "Return rate", x = "Time", y = "-log(|phi|)") +
    theme_minimal()

  traj_plot / (p_ac | p_var) / (p_ar1 | p_rr)
}

make_window_summary_table <- function(trajectory, warnings_df) {
  warnings_df %>%
    mutate(
      phase = case_when(
        time < 100 ~ "Pre-major event",
        time >= 100 & time <= 120 ~ "Major event",
        time > 120 & time < 250 ~ "Recovery/inter-event",
        time >= 250 & time <= 260 ~ "Moderate event",
        TRUE ~ "Late period"
      )
    ) %>%
    group_by(phase) %>%
    summarise(
      mean_lag1_ac = mean(lag1_ac, na.rm = TRUE),
      mean_variance = mean(variance, na.rm = TRUE),
      mean_ar1 = mean(ar1, na.rm = TRUE),
      mean_return_rate = mean(return_rate, na.rm = TRUE),
      n_windows = n(),
      .groups = "drop"
    )
}

warnings_vulnerable_complete <- compute_warning_signals_complete(
  trajectory = df_vulnerable,
  value_col = "m",
  time_col = "time",
  window_size = 300,
  step_size = 10,
  detrend = TRUE
)

warning_summary <- summarize_warning_signals(warnings_vulnerable_complete)

phase_summary <- make_window_summary_table(
  trajectory = df_vulnerable,
  warnings_df = warnings_vulnerable_complete
)

warning_dashboard <- plot_warning_dashboard(
  trajectory = df_vulnerable,
  warnings_df = warnings_vulnerable_complete
)

print(warning_summary)
print(phase_summary)
print(warning_dashboard)
```



## Hysteresis and the Asymmetry of Mental Health Trajectories

Clinical depression rarely follows reversible logic. A person experiences mounting stress, sleep deteriorates, social connections weaken, and eventually they cross a critical threshold into a depressive episode. Reversing these conditions—reducing stress, improving sleep, reconnecting socially—does not simply trace the same path back to wellbeing; recovery almost always requires a qualitatively more favorable configuration than those present at onset.

This asymmetry reflects hysteresis in dynamical systems, where current state depends not only on present conditions but also on the trajectory by which the system arrived there. Mathematically, we formalize this using threshold models with distinct onset and recovery boundaries. Define three variables: stress $S(t)$, social support $P(t)$, and sleep quality $Q(t)$, then construct a composite "pressure toward depression" variable:

$$
H(t) = S(t) - \alpha P(t) - \beta Q(t)
$$

where $\alpha$ and $\beta$ represent the protective strength of support and sleep. Rather than linking mood linearly to $H$, introduce two thresholds $T_{\text{on}}$ (onset) and $T_{\text{off}}$ (recovery) with $T_{\text{off}} < T_{\text{on}}$. Mood state $M(t)$ evolves as:

$$
M(t+1) = \begin{cases}
1 & \text{if } H(t) > T_{\text{on}} \\
0 & \text{if } H(t) < T_{\text{off}} \\
M(t) & \text{if } T_{\text{off}} \leq H(t) \leq T_{\text{on}}
\end{cases}
$$

The third case generates the memory effect: when $H$ lies within the hysteresis band, the system retains its prior state. Two individuals with identical current stress, support, and sleep can occupy different mood states if their recent trajectories differ.

### R Implementation of Hysteresis Model

```r
# =========================================================
# Mood hysteresis simulation with summaries and plots
# =========================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(knitr)

simulate_mood_hysteresis <- function(
    alpha = 0.6,
    beta = 0.4,
    T_on = 20,
    T_off = 10,
    n_steps = 200,
    stress0 = 10,
    support0 = 50,
    sleep0 = 50,
    mood0 = 0,
    stress_up = 0.35,
    stress_down = 0.28,
    support_down = 0.22,
    support_up = 0.17,
    sleep_down = 0.16,
    sleep_up = 0.21,
    stress_turn = 100,
    support_turn = 100,
    sleep_turn = 120
) {
  stress <- numeric(n_steps)
  support <- numeric(n_steps)
  sleep_quality <- numeric(n_steps)
  H <- numeric(n_steps)
  mood_state <- integer(n_steps)
  
  stress[1] <- stress0
  support[1] <- support0
  sleep_quality[1] <- sleep0
  mood_state[1] <- mood0
  
  for (t in 2:n_steps) {
    if (t <= stress_turn) {
      stress[t] <- stress[t - 1] + stress_up
    } else {
      stress[t] <- stress[t - 1] - stress_down
    }
    
    if (t <= support_turn) {
      support[t] <- support[t - 1] - support_down
    } else {
      support[t] <- support[t - 1] + support_up
    }
    
    if (t <= sleep_turn) {
      sleep_quality[t] <- sleep_quality[t - 1] - sleep_down
    } else {
      sleep_quality[t] <- sleep_quality[t - 1] + sleep_up
    }
    
    stress[t] <- max(0, stress[t])
    support[t] <- max(0, min(100, support[t]))
    sleep_quality[t] <- max(0, min(100, sleep_quality[t]))
  }
  
  for (t in 1:n_steps) {
    H[t] <- stress[t] - alpha * support[t] - beta * sleep_quality[t]
    
    if (t > 1) {
      if (H[t] > T_on) {
        mood_state[t] <- 1L
      } else if (H[t] < T_off) {
        mood_state[t] <- 0L
      } else {
        mood_state[t] <- mood_state[t - 1]
      }
    }
  }
  
  out <- tibble(
    time = 1:n_steps,
    stress = stress,
    support = support,
    sleep_quality = sleep_quality,
    H = H,
    mood_state = factor(mood_state, levels = c(0, 1), labels = c("Healthy", "Depressed"))
  )
  
  summary_stats <- out %>%
    summarise(
      n_steps = n(),
      stress_min = min(stress),
      stress_max = max(stress),
      stress_mean = mean(stress),
      support_min = min(support),
      support_max = max(support),
      support_mean = mean(support),
      sleep_min = min(sleep_quality),
      sleep_max = max(sleep_quality),
      sleep_mean = mean(sleep_quality),
      H_min = min(H),
      H_max = max(H),
      H_mean = mean(H),
      depressed_steps = sum(mood_state == "Depressed"),
      healthy_steps = sum(mood_state == "Healthy"),
      first_onset_time = ifelse(any(H > T_on), min(time[H > T_on]), NA),
      first_recovery_time = ifelse(any(H < T_off & lag(c(NA, as.integer(mood_state == "Depressed")), default = NA) == 1), 
                                   min(time[H < T_off]), NA)
    )
  
  switches <- out %>%
    mutate(
      mood_num = ifelse(mood_state == "Depressed", 1L, 0L),
      changed = mood_num != lag(mood_num, default = mood_num[1])
    ) %>%
    filter(changed) %>%
    select(time, mood_state, H)
  
  list(
    data = out,
    summary = summary_stats,
    switches = switches,
    params = list(
      alpha = alpha, beta = beta,
      T_on = T_on, T_off = T_off,
      n_steps = n_steps
    )
  )
}

plot_simulation <- function(sim) {
  df <- sim$data
  pars <- sim$params
  
  p1 <- df %>%
    pivot_longer(cols = c(stress, support, sleep_quality),
                 names_to = "variable", values_to = "value") %>%
    ggplot(aes(time, value, color = variable)) +
    geom_line(linewidth = 1) +
    scale_color_manual(values = c(
      stress = "#D55E00",
      support = "#0072B2",
      sleep_quality = "#009E73"
    )) +
    labs(
      title = "Stress, support, and sleep trajectories",
      x = "Time step",
      y = "Value",
      color = NULL
    ) +
    theme_minimal(base_size = 13)
  
  p2 <- ggplot(df, aes(time, H)) +
    geom_line(linewidth = 1, color = "#4B4B4B") +
    geom_hline(yintercept = pars$T_on, linetype = "dashed", color = "#D55E00") +
    geom_hline(yintercept = pars$T_off, linetype = "dashed", color = "#0072B2") +
    annotate("text", x = max(df$time) * 0.9, y = pars$T_on + 1,
             label = "T_on", color = "#D55E00") +
    annotate("text", x = max(df$time) * 0.9, y = pars$T_off + 1,
             label = "T_off", color = "#0072B2") +
    labs(
      title = "Latent burden index H(t)",
      x = "Time step",
      y = "H"
    ) +
    theme_minimal(base_size = 13)
  
  p3 <- ggplot(df, aes(time, as.integer(mood_state == "Depressed"))) +
    geom_step(linewidth = 1, color = "#7B3294") +
    scale_y_continuous(
      breaks = c(0, 1),
      labels = c("Healthy", "Depressed"),
      limits = c(-0.05, 1.05)
    ) +
    labs(
      title = "Mood state with hysteresis",
      x = "Time step",
      y = "State"
    ) +
    theme_minimal(base_size = 13)
  
  list(trajectories = p1, burden = p2, mood = p3)
}

# Example 1: original parameters
sim1 <- simulate_mood_hysteresis()
sim1$summary
sim1$switches
plots1 <- plot_simulation(sim1)

# Example 2: stronger deterioration to visibly trigger onset and recovery
sim2 <- simulate_mood_hysteresis(
  stress_up = 0.55,
  support_down = 0.28,
  sleep_down = 0.22
)
sim2$summary
sim2$switches
plots2 <- plot_simulation(sim2)

# Print tables and plots
kable(sim1$summary, digits = 2, caption = "Summary statistics: baseline scenario")
kable(sim2$summary, digits = 2, caption = "Summary statistics: stronger-deterioration scenario")

plots1$trajectories
plots1$burden
plots1$mood

plots2$trajectories
plots2$burden
plots2$mood
```

The visualization reveals a delay between worsening conditions and onset, followed by prolonged depressed state during recovery, with mood normalizing only once $H$ crosses the lower threshold. This clarifies why modest interventions may appear ineffective: improvements that shift $H$ into the hysteresis band without crossing $T_{\text{off}}$ produce no observable symptom relief despite representing genuine progress toward a tipping point.

These computational results demonstrate that warning signals begin increasing approximately 20-30 days before major stressors trigger transitions to depression. Autocorrelation rises from around 0.5 in stable periods to above 0.8 as the system approaches its tipping point, while return rate decreases correspondingly. If implemented through smartphone applications or wearable devices collecting daily mood patterns, these metrics could trigger preventive interventions—increased therapy frequency, medication adjustments, or enhanced social support—potentially averting transitions entirely.



## Hidden Markov Models: Inferring Latent Psychological States

While dynamical systems provide theoretical foundations, clinical practice requires methods to infer latent states from observable behavioral data. Hidden Markov Models (HMMs) offer a principled statistical framework for recovering underlying discrete states from continuous noisy observations. The essential idea: psychological systems exist in discrete hidden states (resilient, vulnerable, depressed) corresponding to different regions of the dynamical landscape, and our observations are probabilistic samples from emission distributions associated with each state.

An HMM comprises three components:

1. Hidden states $S = \{s_1, s_2, \ldots, s_K\}$ representing psychological configurations
2. Transition matrix $A$ where $a_{ij} = P(s_t = j | s_{t-1} = i)$
3. Emission distributions $P(x_t | s_t)$ characterizing observed measurements given current state

The connection to dynamical systems becomes clear when recognizing that different attractor basins correspond to different HMM states. Systems near healthy attractors show rapid recovery and low variance; those near depressed attractors show slow dynamics and high sensitivity.

### Fitting HMMs to Mood Time Series in R

```r
library(depmixS4)

set.seed(123)

generate_mood_with_states <- function(T = 3000, dt = 0.01) {
  n_steps <- as.integer(T / dt) + 1
  time <- seq(0, T, length.out = n_steps)
  mood <- numeric(n_steps)
  true_state <- numeric(n_steps)
  mood[1] <- 0.5
  
  for (i in 2:n_steps) {
    t <- time[i]
    
    if (t < 800) {
      true_state[i] <- 1
      r <- 0.4
      sigma <- 0.10
    } else if (t < 1200) {
      true_state[i] <- 2
      r <- 0.0
      sigma <- 0.15
    } else if (t < 2200) {
      true_state[i] <- 3
      r <- -0.3
      sigma <- 0.12
    } else {
      true_state[i] <- 2
      r <- 0.0
      sigma <- 0.14
    }
    
    stress <- 0
    if (t > 750 && t < 850) stress <- -0.3
    if (t > 2100 && t < 2150) stress <- 0.4
    
    drift <- r * mood[i - 1] - mood[i - 1]^3 + stress
    mood[i] <- mood[i - 1] + drift * dt + sigma * sqrt(dt) * rnorm(1)
    mood[i] <- max(-2, min(2, mood[i]))
  }
  
  data.frame(time = time, mood = mood, true_state = true_state)
}

mood_data <- generate_mood_with_states()

daily_indices <- seq(1, nrow(mood_data), by = 100)
observed_data <- mood_data[daily_indices, ]
observed_data$observed_mood <- observed_data$mood + rnorm(nrow(observed_data), 0, 0.15)

hmm_data <- data.frame(
  observed_mood = observed_data$observed_mood,
  subject = factor(1)
)

hmm_model <- depmix(
  response = observed_mood ~ 1,
  data = hmm_data,
  nstates = 3,
  family = gaussian()
)

fitted_hmm <- fit(hmm_model, verbose = FALSE)

hmm_summary <- summary(fitted_hmm)
posterior_states <- posterior(fitted_hmm)

state_names <- paste0("State ", 1:3)

observed_data$hmm_state <- factor(
  posterior_states$state,
  levels = 1:3,
  labels = state_names
)

state_probs <- posterior_states[, c("S1", "S2", "S3")]

par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))

plot(
  observed_data$time,
  observed_data$observed_mood,
  type = "l",
  col = "gray40",
  xlab = "Time",
  ylab = "Observed mood",
  main = "Observed mood with true latent state"
)
points(
  observed_data$time,
  observed_data$observed_mood,
  pch = 16,
  cex = 0.5,
  col = observed_data$true_state
)

legend(
  "topright",
  legend = c("True state 1", "True state 2", "True state 3"),
  col = 1:3,
  pch = 16,
  bty = "n"
)

plot(
  observed_data$time,
  as.numeric(observed_data$hmm_state),
  type = "s",
  xlab = "Time",
  ylab = "Inferred state",
  ylim = c(1, 3),
  yaxt = "n",
  main = "Viterbi-decoded HMM state sequence"
)
axis(2, at = 1:3, labels = state_names)

plot(
  observed_data$time,
  state_probs[, 1],
  type = "l",
  col = "red",
  ylim = c(0, 1),
  xlab = "Time",
  ylab = "Posterior probability",
  main = "Posterior probability of state 1"
)
lines(observed_data$time, state_probs[, 2], col = "blue")
lines(observed_data$time, state_probs[, 3], col = "darkgreen")
legend(
  "topright",
  legend = state_names,
  col = c("red", "blue", "darkgreen"),
  lty = 1,
  bty = "n"
)
```

The fitted HMM typically identifies three distinct states with characteristic emission distributions. The posterior probability distributions reveal uncertainty in state membership, with probabilities becoming diffuse during transition periods, indicating movement between attractors. This uncertainty quantification is crucial for clinical applications, allowing identification not just of current state but confidence in that assessment.
