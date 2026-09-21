# Função do Simulador M/M/1
simulate_MM1 <- function(ArrivalRate, ServiceRate, max_completed = 1000) {
  Time = 0
  NumCompleted = 0
  ServerStatus = 0
  AreaServerStatus = 0 
  TimePreviousEvent = 0
  AcumDelaySystem = 0
  
  # tempo de chegada de TODOS os clientes
  SystemArrivalTime = c()
  
  # EventList: [1] Próxima Chegada, [2] Próxima Partida
  EventList = c(rexp(1, ArrivalRate), Inf)
  
  while (NumCompleted < max_completed) {
    NextEventType = which.min(EventList)  #EventList=[3.5, inf]
    Time = EventList[NextEventType]       #Time=3.5
    
    AreaServerStatus = AreaServerStatus + ServerStatus * (Time - TimePreviousEvent)
    TimePreviousEvent = Time
    
    if (NextEventType == 1) {
      EventList[1] = Time + rexp(1, ArrivalRate)
      
      SystemArrivalTime = c(SystemArrivalTime, Time)
      
      if (ServerStatus == 0) {
        ServerStatus = 1
        EventList[2] = Time + rexp(1, ServiceRate)
      }
    } else {
      # O cliente SAI DO SISTEMA. O delay in sistem = diferença entre o tempo 
      # atual (saída) e o tempo em que entrou.
      AcumDelaySystem = AcumDelaySystem + (Time - SystemArrivalTime[1])
      #remove o cliente servido
      SystemArrivalTime = SystemArrivalTime[-1]
      NumCompleted = NumCompleted + 1
      
      if (length(SystemArrivalTime) > 0) {
        #se ainda há clientes na fila
        EventList[2] = Time + rexp(1, ServiceRate)
      } else {
        ServerStatus = 0
        EventList[2] = Inf
      }
    }
  }
  
  # stats simuladas
  AvgDelaySystem = AcumDelaySystem / NumCompleted
  ServerUtilization = AreaServerStatus / Time
  
  #Stats teóricas
  AvgDelayTheoretical = 1 / (ServiceRate - ArrivalRate)
  UtilizationTheoretical = ArrivalRate / ServiceRate
  
  cat(sprintf("=== Cenário: Lambda = %g, Mu = %g (Ratio = %.2f) ===\n", 
              ArrivalRate, ServiceRate, ArrivalRate/ServiceRate))
  cat(sprintf("Average Delay System (Simulado): %f\n", AvgDelaySystem))
  cat(sprintf("Average Delay System (Teórico) : %f\n", AvgDelayTheoretical))
  cat(sprintf("Server Utilization (Simulado)  : %.2f%%\n", ServerUtilization * 100))
  cat(sprintf("Server Utilization (Teórico)   : %.2f%%\n\n", UtilizationTheoretical * 100))
}


#tráfego medium (Lambda = 1, Mu = 2 -> Ratio = 0.5)
simulate_MM1(ArrivalRate = 1, ServiceRate = 2)

# Cenário 2: Tráfego Elevado (Lambda = 4, Mu = 5 -> Ratio = 0.8)
# Quando o ratio se aproxima de 1, o delay aumenta exponencialmente.
simulate_MM1(ArrivalRate = 4, ServiceRate = 5)