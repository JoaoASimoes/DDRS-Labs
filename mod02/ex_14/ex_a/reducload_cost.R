#Determines the flow blocking probabilities of a circuit switched network using
#the reduced load approximation. It uses the method of repeated substitutions
#(Keith Ross book, page 184)

setwd("/home/simoes/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod02/ex_14/ex_a")
source("erlB.R")

##############################################################################
#Insert here the input parameters

#Links must be identified by contiguous integers starting at 1. These numbers
#must be used as indexes of the LinkCapacities vector and of the vectors
#defining the routes of each flow. Do not use the node numbers for this
#purpose!

#Define here the capacity of each link. The capacity must be expressed in number
#of circuits. This assumes that each call occupies one circuit.
#Ex. 14 a) - Link ids: 1: 1-2   2: 2-3   3: 1-4   4: 2-4   5: 4-3
#Flow 1: 1->2   Flow 2: 2->3   Flow 3: 1->3

#OPTIMAL SOLUTION (step 7): cost 4800 Euros, all flows with blocking < 1%
LinkCapacities=c(4,4,4,0,4) #In number of circuits

#Define here the link costs
LinkCosts=c(500,500,100,1000,100)

Flows=list(list(load=0.5,route=c(1)),
           list(load=0.5,route=c(2)),
           list(load=0.5,route=c(3,5)))

#TRIAL-AND-ERROR STEPS (to show to the teacher, replace the lines above):
#Steps 1-3: flow 3 through 1-2-3 -> use route=c(1,2) in flow 3
#  Step 1: LinkCapacities=c(2,2,0,0,0)  -> blocking too high          (2000 Euros)
#  Step 2: LinkCapacities=c(4,4,0,0,0)  -> flow 3 = 2.99% > 1%         (4000 Euros)
#  Step 3: LinkCapacities=c(5,5,0,0,0)  -> OK, but expensive           (5000 Euros)
#Steps 4-7: flow 3 through 1-4-3 -> use route=c(3,5) in flow 3
#  Step 4: LinkCapacities=c(3,3,3,0,3)  -> all flows > 1%              (3600 Euros)
#  Step 5: LinkCapacities=c(4,4,3,0,3)  -> flow 3 = 2.44% > 1%         (4600 Euros)
#  Step 6: LinkCapacities=c(4,4,4,0,3)  -> flow 3 = 1.41% > 1%         (4700 Euros)
#  Step 7: LinkCapacities=c(4,4,4,0,4)  -> OK, minimum cost            (4800 Euros)

#Do not write bellow this line!
##############################################################################

numLinks=length(LinkCapacities)
numFlows=length(Flows)

niter=0
errorTarget=0.00001
error=Inf

LinkBlocking=rep(0,numLinks)
LinkBlockingPrevious=rep(Inf,numLinks)
while (error > errorTarget) { #Repeated substitutions
  LinkLoads=rep(0,numLinks)
  for (j in 1:numLinks) { #Iterates over links
    for (k in 1:numFlows) { #Iterates over flows
      Route=Flows[[k]]$route
      if (any(Route==j)) { #Checks to see if this flow crosses link j
        Load=Flows[[k]]$load
        AcceptRoute=Route[-which(Route==j)] #Removes link j from this flow
        LengthAcceptRoute=length(AcceptRoute)
        if (LengthAcceptRoute==0) { #Computes acceptance probability of this flow
          AcceptProb=1
        } else {
          AcceptProb=1
          for (l in 1:LengthAcceptRoute) {
            Link=AcceptRoute[l]
            AcceptProb=AcceptProb*(1-LinkBlocking[Link]) 
          }
        }
        ReducedLoad=Load*AcceptProb #Computes reduced load of this flow
        LinkLoads[j]=LinkLoads[j]+ReducedLoad #Accumulates load in link
      }
    } #Ends iteration over flows
  } #Ends iteration over links
  for (m in 1:numLinks) { #Calculates link blocking probabilities
    LinkBlocking[m]=erlB(LinkLoads[m],LinkCapacities[m])
  }
  error=max(abs(LinkBlocking-LinkBlockingPrevious))
  LinkBlockingPrevious=LinkBlocking
  niter=niter+1
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

#print results
cat(sprintf("Number of iterations = %d",niter),"\n")
for (i in 1:numLinks) {
  cat(sprintf("Blocking probability of link %d = %f",i,LinkBlocking[i]),"\n")
}
for (i in 1:numFlows) {
  cat(sprintf("Blocking probability of flow %d = %f",i,FlowBlocking[i]),"\n")
}
cat(sprintf("Total cost of solution is %d Euros",sum(LinkCapacities*LinkCosts)),"\n")
