#Determines the flow blocking probabilities of a circuit switched network using
#the product bound.

source("erlB.R")

##############################################################################
#Insert here the input parameters

#Links must be identified by contiguous integers starting at 1. These numbers
#must be used as indexes of the LinkCapacities vector and of the vectors
#defining the routes of each flow. Do not use the node numbers for this
#purpose!

#Define here the capacity of each link. The capacity must be expressed in number
#of circuits. This assumes that each call occupies one circuit.
#Ex. 14 c) - optimal solution of question a)
#Link ids: 1: 1-2   2: 2-3   3: 1-4   4: 2-4   5: 4-3
LinkCapacities=c(4,4,4,0,4) #In number of circuits

Flows=list(list(load=0.5,route=c(1)),     #Flow 1: 1->2
           list(load=0.5,route=c(2)),     #Flow 2: 2->3
           list(load=0.5,route=c(3,5)))   #Flow 3: 1->3 via node 4

#Do not write bellow this line!
###############################################################################

numLinks=length(LinkCapacities)
numFlows=length(Flows)

#Computes load of each link
LinkLoads=rep(0,numLinks)
for (j in 1:numFlows) {
  Route=Flows[[j]]$route
  Load=Flows[[j]]$load
  LinkLoads[Route]=LinkLoads[Route]+Load
}

#Computes blocking probability of each link
LinkBlocking=c(length=numLinks)
for (i in 1:numLinks) {
  LinkBlocking[i]=erlB(LinkLoads[i],LinkCapacities[i])
}

#Computes blocking probability of each flow
FlowBlocking=c(length=numFlows)
for (i in 1:numFlows) {
  Route=Flows[[i]]$route
  AcceptProb=1
  for (j in 1:length(Route)) {
    Link=Route[j]
    AcceptProb=AcceptProb*(1-LinkBlocking[Link])
  }
  FlowBlocking[i]=1-AcceptProb
}

for (i in 1:numFlows) {
  cat(sprintf("Blocking probability of flow %d = %f",i,FlowBlocking[i]),"\n")
}
