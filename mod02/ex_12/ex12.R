# Ex. 12 - Kleinrock approximation vs simulation (two tandem links)
# Run in the folder containing the pnet.R files (init.R, timing.R, arrivals.R,
# departures.R) and kleinrock.R. Only the 4 simulator functions are sourced;
# parameters are set here instead of in parameters.R.
source("init.R"); source("timing.R"); source("arrivals.R"); source("departures.R")
source("kleinrock.R")

C  <- 64000            # link capacity (bits/s)
Lp <- 1000             # mean packet length (bits)
mu <- C / Lp           # service rate (packets/s) = 64
rhos  <- c(0.05, 0.5, 0.95, 0.975)
nPkts <- 20000         # approx. packets per replication (endTime = nPkts / lambda)
nRep  <- 10            # independent replications -> confidence interval

LinkCapacities <- c(C, C)
res <- data.frame()
for (rho in rhos) {
  lambda <- rho * mu
  Flows <- list(list(rate = lambda, packetsize = Lp, route = c(1, 2)))
  endTime <- nPkts / lambda

  # (i) Kleinrock approximation
  theo <- kleinrock(LinkCapacities, Flows)$WFlow[1]

  # (ii) simulation: nRep replications of the pnet.R simulator
  d <- numeric(nRep)
  for (r in 1:nRep) {
    init()
    while (Time < endTime) {
      ev <- timing()
      if (ev[2] == 1) arrivals(ev[3]) else departures(ev[3])
    }
    d[r] <- FlowStats[1, 2] / FlowStats[1, 1]   # average delay of this replication
  }
  m <- mean(d)
  ci <- qt(0.975, nRep - 1) * sd(d) / sqrt(nRep)  # 95% confidence interval half-width
  res <- rbind(res, data.frame(rho = rho, Kleinrock = theo, Sim = m, CI95 = ci,
                               RelErrPct = 100 * (theo - m) / m))
}
print(res)
