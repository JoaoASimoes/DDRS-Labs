# M/M/2 queue simulator based on Annex A
ArrivalRate=8
ServiceRate=10
NumCustomers=100000
Time=0
NumQueueCompleted=0
NumInQueue=0
AcumDelay=0
QueueArrivalTime=c()

# Position 1 is the next arrival; positions 2 and 3 are server departures.
EventList=c(rexp(1, ArrivalRate), Inf, Inf)

while (NumQueueCompleted < NumCustomers) {
  NextEventType=which.min(EventList)
  Time=EventList[NextEventType]

  if (NextEventType == 1) {
    # Schedule the next arrival.
    EventList[1]=Time + rexp(1, ArrivalRate)

    FreeServers=which(is.infinite(EventList[2:3])) + 1

    if (length(FreeServers) > 0) {
      # The customer starts service immediately and has zero queue delay.
      Server=FreeServers[1]
      EventList[Server]=Time + rexp(1, ServiceRate)
      NumQueueCompleted=NumQueueCompleted + 1
    } else {
      # Both servers are busy, so the customer joins the FIFO queue.
      QueueArrivalTime=c(QueueArrivalTime, Time)
      NumInQueue=NumInQueue + 1
    }
  } else {
    # NextEventType identifies the server whose service has just finished.
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


