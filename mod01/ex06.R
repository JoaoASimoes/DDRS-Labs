ArrivalRate=3
ServiceRate=10
Time=0
NumSystemCompleted=0
NumQueueCompleted=0
ServerStatus=0
NumInQueue=0
AcumQueueDelay=0
AcumSystemDelay=0
AcumBusyTime=0
QueueArrivalTime=c()
EventList=c(rexp(1,ArrivalRate),Inf)

SystemArrivalTime=c()

while (NumSystemCompleted<1000) {
  NextEventType=which.min(EventList)
  NextEventTime=EventList[NextEventType]
  
  AcumBusyTime=AcumBusyTime+ServerStatus*(NextEventTime-Time)
  
  Time=EventList[NextEventType]
  if (NextEventType==1) {
    EventList[1]=Time+rexp(1,ArrivalRate)
    SystemArrivalTime=c(SystemArrivalTime,Time)
    if (ServerStatus==1) {
      QueueArrivalTime=c(QueueArrivalTime,Time)
      NumInQueue=NumInQueue+1
    } else {
      NumQueueCompleted=NumQueueCompleted+1
      ServerStatus=1
      EventList[2]=Time+rexp(1,ServiceRate)
    }
  } else {
    AcumSystemDelay=AcumSystemDelay+Time-SystemArrivalTime[1]
    SystemArrivalTime=SystemArrivalTime[-1]
    
    NumSystemCompleted = NumSystemCompleted+1

    if (NumInQueue==0) {
      ServerStatus=0
      EventList[2]=Inf
    } else {
      AcumQueueDelay=AcumQueueDelay+Time-QueueArrivalTime[1]
      QueueArrivalTime=QueueArrivalTime[-1]
      
      NumInQueue=NumInQueue-1
      NumQueueCompleted=NumQueueCompleted+1
      EventList[2]=Time+rexp(1,ServiceRate)
    }
  }
}


AvgDelayQueue=AcumQueueDelay/NumQueueCompleted
AvgDelaySystem=AcumSystemDelay/NumSystemCompleted
ServerUtilization=AcumBusyTime/Time

TheoreticalDelayQueue=ArrivalRate/(ServiceRate*(ServiceRate-ArrivalRate))

TheoreticalDelaySystem=1/(ServiceRate-ArrivalRate)

TheoreticalUtilization=ArrivalRate/ServiceRate

print(sprintf("Queue delay: simulation = %.4f | theoretical = %.4f",AvgDelayQueue,TheoreticalDelayQueue))

print(sprintf("System delay: simulation = %.4f | theoretical = %.4f",AvgDelaySystem,TheoreticalDelaySystem))

print(sprintf("Server utilization: simulation = %.4f | theoretical = %.4f",ServerUtilization,TheoreticalUtilization))

