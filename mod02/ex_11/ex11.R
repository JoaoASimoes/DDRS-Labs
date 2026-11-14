# ------------------------------------------------------------------
# Kleinrock approximation for packet switched networks
# Uses the same input structures as the pnet.R simulator:
#   LinkCapacities : vector, capacity of each link in bits/s (links 1..N)
#   Flows          : list of lists; each flow has
#                      $rate       arrival rate (packets/s)
#                      $packetsize mean packet length (bits)
#                      $route      vector of link ids
# Outputs: average delay of each flow, average number of packets in the
# network and average packet delay in the network.
# ------------------------------------------------------------------
kleinrock <- function(LinkCapacities, Flows) {
  numLinks <- length(LinkCapacities)
  numFlows <- length(Flows)

  # 1) Per link: arrival rate (packets/s) and offered load (bits/s)
  lambdaLink <- numeric(numLinks)
  bitsLink   <- numeric(numLinks)
  for (f in 1:numFlows) {
    for (l in Flows[[f]]$route) {
      lambdaLink[l] <- lambdaLink[l] + Flows[[f]]$rate
      bitsLink[l]   <- bitsLink[l]   + Flows[[f]]$rate * Flows[[f]]$packetsize
    }
  }

  # 2) Service rate of each link (packets/s): mu = C / (mean packet length)
  #    (if all flows have the same mean length Lp this is simply C/Lp)
  used <- lambdaLink > 0                      # links with no traffic are ignored
  muLink <- rep(Inf, numLinks)
  muLink[used] <- LinkCapacities[used] / (bitsLink[used] / lambdaLink[used])
  if (any(lambdaLink >= muLink)) stop("Unstable network: some link has lambda >= mu")

  # 3) Each link is approximated by an independent M/M/1 queue
  WLink <- 1 / (muLink - lambdaLink)          # average delay in link (queue + service)
  LLink <- lambdaLink * WLink                 # average number of packets in link

  # 4) (i) Average delay of each flow = sum of link delays along its route
  WFlow <- sapply(Flows, function(fl) sum(WLink[fl$route]))

  # 5) (ii) Average number of packets in the network
  L <- sum(LLink)

  # 6) (iii) Average packet delay in the network (Little's law):
  #    W = L / gamma, gamma = total arrival rate of all flows
  gamma <- sum(sapply(Flows, function(fl) fl$rate))
  W <- L / gamma

  return(list(lambdaLink = lambdaLink, WLink = WLink, LLink = LLink,
              WFlow = WFlow, L = L, W = W))
}

# Prints the results
printKleinrock <- function(r) {
  for (i in seq_along(r$WFlow))
    cat(sprintf("Average delay of flow %d = %f\n", i, r$WFlow[i]))
  cat(sprintf("Average number of packets in the network = %f\n", r$L))
  cat(sprintf("Average packet delay in the network = %f\n", r$W))
}

# ------------------------------ TESTS ------------------------------
# Test 1: one link, C = 64 kb/s, rate = 32 pkts/s, mean size 1000 bits
# Hand: mu = 64, W = 1/(64-32) = 0.03125 s, L = 1
printKleinrock(kleinrock(c(64000),
  list(list(rate=32, packetsize=1000, route=c(1)))))

# Test 2: two tandem links, same flow
# Hand: W = 2*0.03125 = 0.0625 s, L = 2
printKleinrock(kleinrock(c(64000, 64000),
  list(list(rate=32, packetsize=1000, route=c(1,2)))))

# Test 3: 3 links; flow 1 on links 1-2, flow 2 on links 2-3 (rate 16 each)
# Hand: link 1,3: W=1/48, L=1/3; link 2 (rate 32): W=1/32, L=1
#       W_flow = 1/48+1/32 = 0.052083 s; L = 5/3 = 1.666667; W = L/32 = 0.052083 s
printKleinrock(kleinrock(c(64000, 64000, 64000),
  list(list(rate=16, packetsize=1000, route=c(1,2)),
       list(rate=16, packetsize=1000, route=c(2,3)))))

# Test 4: the network in the default parameters.R of pnet.R
# Hand: link1 mu=12500 lambda=7500 -> W=1/5000 ; link2 mu=12500 lambda=10000 -> W=1/2500
#       link3 mu=25000 lambda=22500 -> W=1/2500
#       flow1 = 0.0006, flow2 = 0.0008, flow3 = 0.0004 s
printKleinrock(kleinrock(c(100e6,100e6,200e6),
  list(list(rate=7500,  packetsize=8000, route=c(1,3)),
       list(rate=10000, packetsize=8000, route=c(2,3)),
       list(rate=5000,  packetsize=8000, route=c(3)))))
