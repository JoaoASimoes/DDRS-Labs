ArrivalRate=8
ServiceRate=10
NumCustomers=100000
Time=0
NumQueueCompleted=0
NumInQueue=0
AcumDelay=0
QueueArrivalTime=c()

EventList=c(rexp(1, ArrivalRate), Inf, Inf)

while (NumQueueCompleted < NumCustomers) {
  NextEventType=which.min(EventList)
  Time=EventList[NextEventType]

  if (NextEventType == 1) {
    EventList[1]=Time + rexp(1, ArrivalRate)

    FreeServers=which(is.infinite(EventList[2:3])) + 1

    if (length(FreeServers) > 0) {
      Server=FreeServers[1]
      EventList[Server]=Time + rexp(1, ServiceRate)
      NumQueueCompleted=NumQueueCompleted + 1
    } else {
      QueueArrivalTime=c(QueueArrivalTime, Time)
      NumInQueue=NumInQueue + 1
    }
  } else {
    Server=NextEventType

    if (NumInQueue == 0) {
      EventList[Server]=Inf
    } else {
      AcumDelay=AcumDelay + Time - QueueArrivalTime[1]
      QueueArrivalTime=QueueArrivalTime[-1]
      NumInQueue=NumInQueue - 1
      NumQueueCompleted=NumQueueCompleted + 1
      EventList[Server]=Time + rexp(1, ServiceRate)
    }
  }
}

AvgDelay=AcumDelay / NumQueueCompleted

m=2                                    # numero de servidores
rho=ArrivalRate/(m*ServiceRate)        # fator de utilizacao
a=m*rho
PQ=(a^m/(factorial(m)*(1-rho))) /
  (sum(a^(0:(m-1))/factorial(0:(m-1))) + a^m/(factorial(m)*(1-rho)))  # probabilidade de uma chegada encontrar todos os servidores ocupados
TheoreticalDelayQueue=PQ*rho/(ArrivalRate*(1-rho))

TheoreticalDelayQueue
AvgDelay