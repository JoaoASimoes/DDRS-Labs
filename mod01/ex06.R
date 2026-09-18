# Exercício 6

ArrivalRate=1
ServiceRate=2
Time=0
NumQueueCompleted=0
ServerStatus=0
NumInQueue=0
AreaServerStatus=0  # Variáveis para eferuar o cálculo da 
TimePreviousEvent=0 # utilização do servidor inicializadas
AcumDelay=0
QueueArrivalTime=c()
EventList=c(rexp(1,ArrivalRate),Inf)
while (NumQueueCompleted<1000) {
  NextEventType=which.min(EventList)
  Time=EventList[NextEventType]
  AreaServerStatus = AreaServerStatus + ServerStatus * (Time-TimePreviousEvent) # Para fazer o calculo da percentagem de utilização
  if (NextEventType==1) {
    EventList[1]=Time+rexp(1,ArrivalRate)
    if (ServerStatus==1) {
      QueueArrivalTime=c(QueueArrivalTime,Time)
      NumInQueue=NumInQueue+1
    } else {
      NumQueueCompleted=NumQueueCompleted+1
      ServerStatus=1
      EventList[2]=Time+rexp(1,ServiceRate)
    }
  } else {
    if (NumInQueue==0) {
      ServerStatus=0
      EventList[2]=Inf
    } else {
      AcumDelay=AcumDelay+Time-QueueArrivalTime[1]
      QueueArrivalTime=QueueArrivalTime[-1]
      NumInQueue=NumInQueue-1
      NumQueueCompleted=NumQueueCompleted+1
      EventList[2]=Time+rexp(1,ServiceRate)
    }
  }
  TimePreviousEvent = Time # Fazer update à variável
}
AvgDelay=AcumDelay/NumQueueCompleted
AvgDelayTheoretical = 1/ (ServiceRate - ArrivalRate)
cat("O average delay é:",AvgDelay, "\n")
cat("O average delay teórico é:",AvgDelayTheoretical,"\n")

ServerUtilization = (AreaServerStatus/Time) * 100
cat("A percentagem de utilização deste servidor é:", ServerUtilization, "\n")
