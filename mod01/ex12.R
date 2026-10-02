# Exercicio 12 - Variabilidade entre execucoes do simulador M/M/1 (rho = 0.8)
set.seed(123)                          # definida uma unica vez: as 10 execucoes sao diferentes

# Simulador M/M/1 (Anexo A do guia); devolve o atraso medio em fila
mm1 <- function(ArrivalRate = 1, ServiceRate = 1.25) {
  Time = 0; NumQueueCompleted = 0; ServerStatus = 0; NumInQueue = 0; AcumDelay = 0
  QueueArrivalTime = c()
  EventList = c(rexp(1, ArrivalRate), Inf)   # [proxima chegada, proxima partida]
  while (NumQueueCompleted < 1000) {         # termina apos 1000 atrasos
    NextEventType = which.min(EventList)
    Time = EventList[NextEventType]
    if (NextEventType == 1) {                # evento de chegada
      EventList[1] = Time + rexp(1, ArrivalRate)
      if (ServerStatus == 1) {               # servidor ocupado: entra na fila
        QueueArrivalTime = c(QueueArrivalTime, Time)
        NumInQueue = NumInQueue + 1
      } else {                               # servidor livre: atraso nulo
        NumQueueCompleted = NumQueueCompleted + 1
        ServerStatus = 1
        EventList[2] = Time + rexp(1, ServiceRate)
      }
    } else {                                 # evento de partida
      if (NumInQueue == 0) {                 # fila vazia: servidor fica livre
        ServerStatus = 0
        EventList[2] = Inf
      } else {                               # primeiro da fila inicia servico
        AcumDelay = AcumDelay + Time - QueueArrivalTime[1]
        QueueArrivalTime = QueueArrivalTime[-1]
        NumInQueue = NumInQueue - 1
        NumQueueCompleted = NumQueueCompleted + 1
        EventList[2] = Time + rexp(1, ServiceRate)
      }
    }
  }
  AcumDelay / NumQueueCompleted              # atraso medio em fila
}

lambda <- 1; mu <- 1.25
WQ_teorico <- lambda / (mu * (mu - lambda))  # valor teorico: 3.2

res <- replicate(10, mm1(lambda, mu))        # 10 execucoes independentes
erro_relativo <- (res - WQ_teorico) / WQ_teorico   # com sinal

print(data.frame(Execucao = 1:10, WQ_simulado = round(res, 3),
                 Erro_relativo_pct = round(100 * erro_relativo, 1)))
cat("Media =", round(mean(res), 3), " Desvio padrao =", round(sd(res), 3),
    " Erro relativo da media =", round(100 * (mean(res) - WQ_teorico) / WQ_teorico, 1), "%\n")
