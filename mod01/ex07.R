# Exercicio 7 - Simulador M/M/2: atraso medio em fila
set.seed(123)                          # garante reprodutibilidade
ArrivalRate = 8                        # lambda (alterar para 18 no segundo cenario)
ServiceRate = 10                       # mu
NumCustomers = 100000                  # numero de atrasos a determinar
Time = 0
NumQueueCompleted = 0
NumInQueue = 0
AcumDelay = 0
QueueArrivalTime = c()

# Lista de eventos: [chegada, partida do servidor 1, partida do servidor 2]
EventList = c(rexp(1, ArrivalRate), Inf, Inf)

while (NumQueueCompleted < NumCustomers) {
  NextEventType = which.min(EventList)
  Time = EventList[NextEventType]

  if (NextEventType == 1) {                                  # evento de chegada
    EventList[1] = Time + rexp(1, ArrivalRate)
    FreeServers = which(is.infinite(EventList[2:3])) + 1     # servidores livres

    if (length(FreeServers) > 0) {                           # servidor livre: atraso nulo
      Server = FreeServers[1]
      EventList[Server] = Time + rexp(1, ServiceRate)
      NumQueueCompleted = NumQueueCompleted + 1
    } else {                                                 # servidores ocupados: entra na fila
      QueueArrivalTime = c(QueueArrivalTime, Time)
      NumInQueue = NumInQueue + 1
    }
  } else {                                                   # evento de partida
    Server = NextEventType

    if (NumInQueue == 0) {                                   # fila vazia: servidor fica livre
      EventList[Server] = Inf
    } else {                                                 # primeiro da fila inicia servico
      AcumDelay = AcumDelay + Time - QueueArrivalTime[1]
      QueueArrivalTime = QueueArrivalTime[-1]
      NumInQueue = NumInQueue - 1
      NumQueueCompleted = NumQueueCompleted + 1
      EventList[Server] = Time + rexp(1, ServiceRate)
    }
  }
}

AvgDelay = AcumDelay / NumQueueCompleted                     # atraso medio em fila simulado

# Valor teorico (Anexo C do guia)
m = 2                                                        # numero de servidores
rho = ArrivalRate / (m * ServiceRate)                        # fator de utilizacao
a = m * rho
# probabilidade de uma chegada encontrar todos os servidores ocupados
PQ = (a^m / (factorial(m) * (1 - rho))) /
  (sum(a^(0:(m - 1)) / factorial(0:(m - 1))) + a^m / (factorial(m) * (1 - rho)))
TheoreticalDelayQueue = PQ * rho / (ArrivalRate * (1 - rho)) # atraso medio em fila teorico

ErroRelativo = (AvgDelay - TheoreticalDelayQueue) / TheoreticalDelayQueue   # com sinal

cat("W_Q simulado:", AvgDelay, "\n")
cat("W_Q teorico: ", TheoreticalDelayQueue, "\n")
cat("Erro relativo:", round(100 * ErroRelativo, 1), "%\n")
