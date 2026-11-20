# Ex. 14 b) - Blocking probabilities with confidence intervals using the cnet
# simulator. Runs nRep independent replications of cnet and computes the
# mean and the 95% confidence interval of the blocking probability of each flow.
# Put this file in the cnet folder (with parameters.R, init.R, timing.R,
# arrivals.R and departures.R) and run it instead of cnet.R.

setwd("/home/simoes/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod02/ex_14/ex_b")

source("parameters.R"); source("init.R"); source("timing.R")
source("arrivals.R"); source("departures.R")

nRep <- 10                       # number of independent replications
parameters()
Results <- matrix(0, nrow = nRep, ncol = length(Flows))

for (r in 1:nRep) {
  init()                         # resets clock, event list and counters
  while (Time < endTime) {       # same loop as cnet.R
    nextEvent <- timing()
    if (nextEvent[2] == 1) arrivals(nextEvent[3]) else departures(nextEvent[3])
  }
  Results[r, ] <- FlowStats[, 2] / FlowStats[, 1]   # blocking of each flow
  cat(sprintf("Replication %d done", r), "\n")
}

# Mean and 95% confidence interval (t-Student, nRep-1 degrees of freedom)
for (i in 1:length(Flows)) {
  m  <- mean(Results[, i])
  ci <- qt(0.975, nRep - 1) * sd(Results[, i]) / sqrt(nRep)
  cat(sprintf("Flow %d: blocking = %f +- %f  [%f, %f]", i, m, ci, m - ci, m + ci), "\n")
}
