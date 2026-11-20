#This is the function where the user defines the simulation scenario
#Ex. 14 b) - optimal solution of question a)
#Link ids: 1: 1-2   2: 2-3   3: 1-4   4: 2-4   5: 4-3

parameters = function() {

  #Capacity of each link in number of circuits (each call occupies 1 circuit)
  LinkCapacities<<-c(4,4,4,0,4)

  #Flows: rho = rate*duration = 0.5*1 = 0.5 Erlang
  Flows<<-list(list(duration=1,rate=0.5,bwd=1,route=c(1)),     #Flow 1: 1->2
               list(duration=1,rate=0.5,bwd=1,route=c(2)),     #Flow 2: 2->3
               list(duration=1,rate=0.5,bwd=1,route=c(3,5)))   #Flow 3: 1->3 via 4

  #Simulation end time: ~50000 calls per flow. Blocking is ~0.16%, so we need
  #many calls to observe enough blocked calls (~80 per flow)
  endTime<<-50000*(1/0.5)

}
