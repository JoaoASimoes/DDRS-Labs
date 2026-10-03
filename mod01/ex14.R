# ==============================================================
# Replication/Deletion analysis for an M/M/1 queue
# ==============================================================

# Load the functions frepdel() and fmm1_wu()
source("~/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod01/repdel.R")

# --------------------------------------------------------------
# General parameters
# --------------------------------------------------------------

set.seed(1234)

mu <- 1                    # service rate
conf <- 0.95               # confidence level
NumDeletions <- 100        # warm-up observations deleted
n0 <- 10                   # initial number of replicas

# Number of independent executions of frepdel() per configuration.
# This reduces the random variability of the results.
nRuns <- 20


# --------------------------------------------------------------
# Auxiliary function
# --------------------------------------------------------------

mean_replicas <- function(gamma, lambda, mu, NumDelays) {
  
  replicas <- numeric(nRuns)
  
  for (i in 1:nRuns) {
    print("a")
    
    replicas[i] <- frepdel(
      gamma        = gamma,
      ArrivalRate  = lambda,
      ServiceRate  = mu,
      NumDeletions = NumDeletions,
      NumDelays    = NumDelays,
      conf         = conf,
      n0           = n0
    )
  }
  
  mean(replicas)
}


# ==============================================================
# 1. Number of replicas vs relative error
# ==============================================================

# Keep rho and NumDelays fixed
rho_fixed <- 0.7
lambda_fixed <- rho_fixed * mu
NumDelays_fixed <- 1000

gamma_values <- c(0.02, 0.05, 0.10, 0.15, 0.20)

replicas_gamma <- sapply(
  gamma_values,
  function(g)
    mean_replicas(
      gamma = g,
      lambda = lambda_fixed,
      mu = mu,
      NumDelays = NumDelays_fixed
    )
)

plot(
  gamma_values,
  replicas_gamma,
  type = "b",
  pch = 19,
  xlab = "Relative error (gamma)",
  ylab = "Average number of required replicas",
  main = "Required replicas vs relative error"
)

grid()


# ==============================================================
# 2. Number of replicas vs number of delays per replica
# ==============================================================

# Keep relative error and rho fixed
gamma_fixed <- 0.05

NumDelays_values <- c(100, 250, 500, 1000, 2000, 5000)

replicas_delays <- sapply(
  NumDelays_values,
  function(N)
    mean_replicas(
      gamma = gamma_fixed,
      lambda = lambda_fixed,
      mu = mu,
      NumDelays = N
    )
)

plot(
  NumDelays_values,
  replicas_delays,
  type = "b",
  pch = 19,
  log = "x",
  xlab = "Number of delays used in each replica",
  ylab = "Average number of required replicas",
  main = "Required replicas vs number of delays"
)

grid()


# ==============================================================
# 3. Number of replicas vs rho = lambda / mu
# ==============================================================

# rho must always be < 1
rho_values <- c(0.1, 0.2, 0.3, 0.4, 0.5,
                0.6, 0.7, 0.8, 0.9, 0.95)

replicas_rho <- sapply(
  rho_values,
  function(rho) {
    
    lambda <- rho * mu
    
    mean_replicas(
      gamma = gamma_fixed,
      lambda = lambda,
      mu = mu,
      NumDelays = NumDelays_fixed
    )
  }
)

plot(
  rho_values,
  replicas_rho,
  type = "b",
  pch = 19,
  xlab = expression(rho == lambda / mu),
  ylab = "Average number of required replicas",
  main = expression(paste("Required replicas vs ", rho))
)

grid()


# ==============================================================
# 4. Theoretical variance of the M/M/1 queuing delay
# ==============================================================

# Annex B:
#
# Var(Wq) = rho(2-rho) / [mu^2 (1-rho)^2]

rho_variance <- seq(0.01, 0.99, by = 0.01)

variance_Wq <- (
  rho_variance * (2 - rho_variance)
) / (
  mu^2 * (1 - rho_variance)^2
)

plot(
  rho_variance,
  variance_Wq,
  type = "l",
  lwd = 2,
  xlab = expression(rho == lambda / mu),
  ylab = expression(Var(W[Q])),
  main = expression(paste("Variance of queuing delay vs ", rho))
)

grid()


# ==============================================================
# 5. Print results
# ==============================================================

results_gamma <- data.frame(
  RelativeError = gamma_values,
  AverageReplicas = replicas_gamma
)

results_delays <- data.frame(
  NumDelays = NumDelays_values,
  AverageReplicas = replicas_delays
)

results_rho <- data.frame(
  rho = rho_values,
  lambda = rho_values * mu,
  AverageReplicas = replicas_rho
)

cat("\n--- Relative error analysis ---\n")
print(results_gamma)

cat("\n--- Number of delays analysis ---\n")
print(results_delays)

cat("\n--- rho analysis ---\n")
print(results_rho)