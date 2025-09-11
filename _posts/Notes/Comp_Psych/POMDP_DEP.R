library(pomdp)

model <- POMDP(
  name = "DepressionBias",
  states = c("Positive", "Negative"),
  actions = c("Attend Positive", "Attend Negative", "Wait"),
  observations = c("Pos Stimulus", "Neg Stimulus"),
  transition_prob = list(
    "Attend Positive" = "identity",
    "Attend Negative" = "identity",
    "Wait" = "identity"
  ),
  observation_prob = rbind(
    O_("Attend Positive", "Positive", "Pos Stimulus", 0.9),
    O_("Attend Positive", "Positive", "Neg Stimulus", 0.1),
    O_("Attend Positive", "Negative", "Pos Stimulus", 0.4),
    O_("Attend Positive", "Negative", "Neg Stimulus", 0.6),
    
    O_("Attend Negative", "Positive", "Pos Stimulus", 0.3),
    O_("Attend Negative", "Positive", "Neg Stimulus", 0.7),
    O_("Attend Negative", "Negative", "Pos Stimulus", 0.2),
    O_("Attend Negative", "Negative", "Neg Stimulus", 0.8),
    
    O_("Wait", "Positive", "Pos Stimulus", 0.5),
    O_("Wait", "Positive", "Neg Stimulus", 0.5),
    O_("Wait", "Negative", "Pos Stimulus", 0.5),
    O_("Wait", "Negative", "Neg Stimulus", 0.5)
  ),
  reward = rbind(
    R_("Attend Positive", "Positive", "*", "*", 2),
    R_("Attend Positive", "Negative", "*", "*", -1),
    R_("Attend Negative", "Positive", "*", "*", -2),
    R_("Attend Negative", "Negative", "*", "*", -1),
    R_("Wait", "*", "*", "*", -0.5)
  ),
  discount = 0.95,
  horizon = Inf
)

# ✅ Normalize before solving
model <- normalize_POMDP(model)

solution <- solve_POMDP(model)

simulate_POMDP(
  model = model,
  policy = policy(solution),
  belief = c(Positive = 0.5, Negative = 0.5),
  n = 10
)