# Exercicio 6 - Consequencias da falta de estabilidade num sistema M/M/1
# Estudo do atraso medio na fila em funcao da duracao da simulacao
# (NumQueueCompleted) para rho = 1 e rho = 2.
# rho = 0.5 e incluido como referencia de um sistema estavel.

# ---------------------------------------------------------------
# Simulador M/M/1 do professor, colocado dentro de uma funcao.
# Unica alteracao: a fila (QueueArrivalTime) usa um indice de inicio
# (Head) em vez de remover o 1.o elemento com QueueArrivalTime[-1].
# Com rho >= 1 a fila cresce sem limite e QueueArrivalTime[-1] copia
# o vetor inteiro a cada partida, o que torna a simulacao demasiado
# lenta para valores grandes de StoppingCondition. A logica do
# simulador (eventos, contagens e calculo do atraso) e a mesma.
# Argumento extra record: se TRUE, devolve o atraso na fila de cada
# cliente (0 para quem entra logo em servico), usado no grafico 1.
# ---------------------------------------------------------------
mm1_sim = function(ArrivalRate, ServiceRate, StoppingCondition, record = FALSE) {
  
  #Initialization
  Time = 0                 #simulation clock
  NumQueueCompleted = 0    #number of clients that crossed the queue
  ServerStatus = 0         #server status (idle or busy)
  NumInQueue = 0           #number of clients currently in the queue
  AcumDelay = 0            #accumulated delay of clients
  QueueArrivalTime = c()   #arrival times of clients in the queue
  Head = 1                 #position of the first client in the queue
  if (record) Delays = numeric(StoppingCondition)  #delay of each client
  EventList = c(rexp(1, ArrivalRate), Inf)  #no departure from empty system
  
  #Simulation loop
  while (NumQueueCompleted < StoppingCondition) {
    NextEventType = which.min(EventList)    #type of next event
    Time = EventList[NextEventType]         #jumps clock to next event
    if (NextEventType == 1) {               #arrival event
      EventList[1] = Time + rexp(1, ArrivalRate)  #schedules next arrival
      if (ServerStatus == 1) {              #client goes to queue
        QueueArrivalTime[Head + NumInQueue] = Time  #stores arrival time
        NumInQueue = NumInQueue + 1
      } else {                              #client goes directly to server
        NumQueueCompleted = NumQueueCompleted + 1
        if (record) Delays[NumQueueCompleted] = 0
        ServerStatus = 1
        EventList[2] = Time + rexp(1, ServiceRate)  #schedules departure
      }
    } else {                                #departure event
      if (NumInQueue == 0) {                #system becomes empty
        ServerStatus = 0
        EventList[2] = Inf
      } else {                              #next client leaves the queue
        AcumDelay = AcumDelay + Time - QueueArrivalTime[Head]
        if (record) Delays[NumQueueCompleted + 1] = Time - QueueArrivalTime[Head]
        Head = Head + 1                     #removes this client from queue
        NumInQueue = NumInQueue - 1
        NumQueueCompleted = NumQueueCompleted + 1
        EventList[2] = Time + rexp(1, ServiceRate)  #schedules departure
      }
    }
  }
  if (record) return(Delays)               #delay of each client
  return(AcumDelay / NumQueueCompleted)    #average delay in queue
}

# ---------------------------------------------------------------
# Experiencia
# ServiceRate fixo em 1; ArrivalRate = rho * ServiceRate
# ---------------------------------------------------------------
set.seed(1)
ServiceRate = 1
rhos   = c(0.5, 1, 2)
stops  = c(1e3, 1e4, 1e5)          # valores de NumQueueCompleted
runs   = 5                         # corridas independentes por caso

res = data.frame()
for (rho in rhos) {
  ArrivalRate = rho * ServiceRate
  # Atraso teorico na fila (slide 16): so e valido para rho < 1
  Wq_theo = if (rho < 1) ArrivalRate / (ServiceRate * (ServiceRate - ArrivalRate)) else Inf
  for (stop in stops) {
    Wq = replicate(runs, mm1_sim(ArrivalRate, ServiceRate, stop))
    res = rbind(res, data.frame(rho = rho,
                                NumQueueCompleted = stop,
                                Wq_media = round(mean(Wq), 2),
                                Wq_min   = round(min(Wq), 2),
                                Wq_max   = round(max(Wq), 2),
                                Wq_teorico = Wq_theo))
  }
}
print(res, row.names = FALSE)

# ---------------------------------------------------------------
# Curvas teoricas de referencia (em funcao de N)
#  rho < 1 : Wq constante = lambda / (mu * (mu - lambda))
#  rho = 1 : a fila comporta-se como um passeio aleatorio sem deriva;
#            media acumulada ~ (2/3) * sqrt(2 * sigma2 * N / pi),
#            com sigma2 = 1/mu^2 + 1/lambda^2
#  rho > 1 : cada cliente espera em media mais (1/mu - 1/lambda) do que
#            o anterior; media acumulada ~ (1/mu - 1/lambda) * N / 2
# ---------------------------------------------------------------
Wq_ref = function(rho, N) {
  lambda = rho * ServiceRate; mu = ServiceRate
  if (rho < 1)  return(rep(lambda / (mu * (mu - lambda)), length(N)))
  if (rho == 1) return((2/3) * sqrt(2 * (1/mu^2 + 1/lambda^2) * N / pi))
  return((1/mu - 1/lambda) * N / 2)
}
cols = c("darkgreen", "blue", "red")

# ---------------------------------------------------------------
# Grafico 1: media acumulada do atraso ao longo de uma corrida longa
# (simula primeiro; o desenho fica numa funcao para poder ser
#  mostrado no ecra e gravado em ficheiro)
# ---------------------------------------------------------------
Nlong = max(stops)
k = 1:Nlong
curvas = list()
for (i in seq_along(rhos)) {
  curvas[[i]] = sapply(1:3, function(r) {
    d = mm1_sim(rhos[i] * ServiceRate, ServiceRate, Nlong, record = TRUE)
    m = cumsum(d) / k
    m[m <= 0] = NA                      # escala log nao aceita zeros
    m
  })
}

desenha_grafico1 = function() {
  plot(NA, xlim = c(1, Nlong), ylim = c(1e-2, 1e5), log = "xy",
       xlab = "Clientes que completaram a fila (n)",
       ylab = "Atraso medio na fila acumulado",
       main = "Media acumulada do atraso na fila (3 corridas por rho)")
  for (i in seq_along(rhos)) {
    for (r in 1:3) lines(k, curvas[[i]][, r], col = adjustcolor(cols[i], 0.7), lwd = 1.2)
    lines(k, Wq_ref(rhos[i], k), col = cols[i], lty = 2, lwd = 1.5)
  }
  legend("topleft", bty = "n",
         legend = c(paste("rho =", rhos), "referencia teorica"),
         col = c(cols, "black"), lty = c(1, 1, 1, 2), lwd = 2)
}

# ---------------------------------------------------------------
# Grafico 2: atraso medio na fila em funcao de NumQueueCompleted
# (media das corridas; barras = minimo e maximo)
# ---------------------------------------------------------------
xx = 10^seq(log10(min(stops)), log10(max(stops)), length.out = 50)

desenha_grafico2 = function() {
  plot(NA, xlim = range(stops), ylim = c(0.1, 1e5), log = "xy",
       xlab = "NumQueueCompleted (N)", ylab = "Atraso medio na fila",
       main = paste0("Atraso medio na fila em funcao de N (", runs,
                     " corridas; barras = min/max)"))
  for (i in seq_along(rhos)) {
    s = res[res$rho == rhos[i], ]
    arrows(s$NumQueueCompleted, s$Wq_min, s$NumQueueCompleted, s$Wq_max,
           angle = 90, code = 3, length = 0.04, col = cols[i])
    lines(s$NumQueueCompleted, s$Wq_media, type = "b", pch = 19, col = cols[i], lwd = 2)
    lines(xx, Wq_ref(rhos[i], xx), col = cols[i], lty = 2)
  }
  legend("topleft", bty = "n",
         legend = c(paste("rho =", rhos), "referencia teorica"),
         col = c(cols, "black"), lty = c(1, 1, 1, 2), pch = c(19, 19, 19, NA), lwd = 2)
}

# ---------------------------------------------------------------
# Mostrar no ecra (painel Plots do RStudio) e gravar em PNG
# ---------------------------------------------------------------
desenha_grafico1()
desenha_grafico2()                      # no RStudio, usar as setas do painel Plots

png("grafico1_media_acumulada.png", width = 2000, height = 1300, res = 200)
desenha_grafico1()
dev.off()
png("grafico2_atraso_vs_N.png", width = 2000, height = 1300, res = 200)
desenha_grafico2()
dev.off()
cat("Graficos gravados em:", "C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exercício 6", "\n")