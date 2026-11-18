# Exercicio 7 c)
# Ligacao ponto a ponto com prioridade estrita (nao preemptiva), dois fluxos
# Poisson com pacotes de tamanho fixo. Corre o ppl.R varias vezes e mostra o
# atraso medio de cada fluxo (simulado com IC a 95% e teorico) e a razao W2/W1.
# Este ficheiro tem de estar na mesma pasta que o ppl.R e as suas rotinas.

# Funcao que devolve a media e a semiamplitude do IC a 95% (t de Student)
ic <- function(x) {
  n <- length(x)
  c(mean(x), qt(0.975, n - 1) * sd(x) / sqrt(n))
}

# Parametros
C <- 100e3                  # capacidade da ligacao (bits/s)
L <- 1000                   # tamanho fixo dos pacotes (bits)
lambda1 <- 10               # fluxo 1, prioridade alta (pacotes/s)
lambda2 <- 85               # fluxo 2, prioridade baixa (pacotes/s)

# Funcao que substitui o parameters.R
parameters <- function() {
  LinkCapacity <<- C
  Flows <<- list(list(sourcetype = 2, arrivalrate = lambda1, packetsize = L, priority = 1),
                 list(sourcetype = 2, arrivalrate = lambda2, packetsize = L, priority = 2))
  endTime <<- 10000 * (1 / min(lambda1, lambda2))   # mesma regra do parameters.R
}

# Le o codigo do ppl.R e retira a linha que carrega o parameters.R
codigo <- readLines("ppl.R", warn = FALSE)
codigo <- codigo[!grepl("parameters.R", codigo)]

set.seed(123)
nruns <- 10
W1 <- numeric(nruns); W2 <- numeric(nruns)
for (r in 1:nruns) {
  saida <- capture.output(eval(parse(text = codigo)))
  W1[r] <- FlowStats[1, 2] / FlowStats[1, 1]
  W2[r] <- FlowStats[2, 2] / FlowStats[2, 1]
}

# Valores teoricos: M/D/1 com prioridade estrita nao preemptiva
S    <- L / C                          # tempo de servico (s)
rho1 <- lambda1 * S
rho  <- (lambda1 + lambda2) * S
W0   <- (lambda1 + lambda2) * S^2 / 2  # tempo residual medio
W1_teo <- W0 / (1 - rho1) + S
W2_teo <- W0 / ((1 - rho1) * (1 - rho)) + S

ic1 <- ic(W1); ic2 <- ic(W2); icr <- ic(W2 / W1)
cat("C =", C, "bits/s; L =", L, "bits; lambda1 =", lambda1, "; lambda2 =", lambda2,
    "; rho =", rho, "; endTime =", 10000 / min(lambda1, lambda2), "s\n\n")
print(data.frame(Fluxo = c("1 (alta)", "2 (baixa)", "W2/W1"),
                 Teorico = round(c(1000 * W1_teo, 1000 * W2_teo, W2_teo / W1_teo), 3),
                 Simulado = round(c(1000 * ic1[1], 1000 * ic2[1], icr[1]), 3),
                 IC95 = round(c(1000 * ic1[2], 1000 * ic2[2], icr[2]), 3)), row.names = FALSE)
