# Ex. 13a - Kleinrock approximation for the network of Figure 3
# Requires kleinrock.R in the same folder.
source("kleinrock.R")

# Link ids (contiguous integers, NOT node numbers):
#  1: 1-2   2: 2-4   3: 4-6   4: 1-3   5: 3-5   6: 5-6   7: 2-5
LinkCapacities <- rep(256e3, 7)          # all links 256 kb/s

# Routes written with link ids; packets have mean length 1000 bits
Flows <- list(list(rate = 215, packetsize = 1000, route = c(1, 2, 3)),  # flow 1: 1-2-4-6
              list(rate = 64,  packetsize = 1000, route = c(4, 5)),     # flow 2: 1-3-5
              list(rate = 128, packetsize = 1000, route = c(4, 5, 6)),  # flow 3: 1-3-5-6
              list(rate = 128, packetsize = 1000, route = c(7)))        # flow 4: 2-5

r <- kleinrock(LinkCapacities, Flows)
print(data.frame(link = 1:7, lambda = r$lambdaLink, W = r$WLink, L = r$LLink))
printKleinrock(r)
