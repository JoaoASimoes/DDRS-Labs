# Slotted ALOHA com N utilizadores finitos (THINKING / BACKLOGGED)
# Estimacao do throughput por simulacao de eventos discretos e
# comparacao com o valor teorico dado por aloha_theo(N, p, s)
setwd("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exercício 3")
getwd()  
source("aloha_theo.R")

# Simulacao: so se guarda n = numero de utilizadores BACKLOGGED
aloha_sim = function(N, p, s, n_slots = 2e5, warmup = 1e4) {
  n = 0                                  # nenhum BACKLOGGED no inicio
  succ = 0
  for (slot in 1:(warmup + n_slots)) {
    a = rbinom(1, N - n, s)              # THINKING que transmitem
    b = rbinom(1, n, p)                  # BACKLOGGED que transmitem
    tx = a + b
    if (tx == 1) {                       # sucesso
      if (slot > warmup) succ = succ + 1
      if (b == 1) n = n - 1              # BACKLOGGED volta a THINKING
    } else if (tx >= 2) {                # colisao
      n = n + a                          # novos passam a BACKLOGGED
    }
  }
  return(succ / n_slots)
}

set.seed(1)
runs = 10
conf = data.frame(N     = c(10,   10,   20,   50),
                  sigma = c(0.01, 0.05, 0.10, 0.02),
                  p     = c(0.10, 0.20, 0.30, 0.05))

res = data.frame()
for (k in 1:nrow(conf)) {
  N = conf$N[k]; s = conf$sigma[k]; p = conf$p[k]
  Th = replicate(runs, aloha_sim(N, p, s))
  m  = mean(Th)
  ci = qt(0.975, runs - 1) * sd(Th) / sqrt(runs)   # IC 95%
  th = aloha_theo(N, p, s)
  res = rbind(res, data.frame(N = N, sigma = s, p = p,
                              Th_sim = round(m, 4), IC95 = round(ci, 4),
                              Th_theo = round(th, 4),
                              erro_pct = round(100 * abs(m - th) / th, 2)))
}
print(res, row.names = FALSE)
