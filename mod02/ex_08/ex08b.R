# Exercicio 8 b)
# Compara a variancia amostral das estimativas do atraso medio em fila
# (100 amostras = 100 corridas independentes) no M/M/1 e nos dois M/G/1 bimodais.
# Este ficheiro tem de estar na mesma pasta que o mg1_bimodal.R (ou ajusta o caminho).

# Le o codigo do mg1_bimodal.R
codigo <- readLines("/home/simoes/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod02/mg1_bimodal.R", warn = FALSE)

# Posicao das linhas onde estao definidos s1/p1 e s2/p2
linha_s1 <- grep("^s1=", codigo)
linha_s2 <- grep("^s2=", codigo)

# Parametros dos dois sistemas bimodais
sistemas <- data.frame(
  nome = c("M/Bimodal-1/1", "M/Bimodal-2/1"),
  s1 = c(1, 1),
  p1 = c(0.9, 0.99),
  s2 = c(11, 101),
  p2 = c(0.1, 0.01)
)

set.seed(123)

# Numero de amostras (corridas independentes) por sistema
nruns <- 100

tabela <- data.frame()

for (k in 1:nrow(sistemas)) {
  codigo_k <- codigo
  codigo_k[linha_s1] <- sprintf("s1=%g;p1=%g", sistemas$s1[k], sistemas$p1[k])
  codigo_k[linha_s2] <- sprintf("s2=%g;p2=%g", sistemas$s2[k], sistemas$p2[k])

  mm1 <- numeric(nruns)
  bim <- numeric(nruns)

  for (r in 1:nruns) {
    saida <- capture.output(eval(parse(text = codigo_k)))
    mm1[r] <- AvgDelayMM1
    bim[r] <- AvgDelayBimodal
  }

  # O M/M/1 e igual nos dois casos (E[S] = 2): so entra uma vez
  if (k == 1) {
    wqMM1 <- (ArrivalRate / ServiceRate) / (ServiceRate - ArrivalRate)
    tabela <- rbind(tabela, data.frame(Sistema = "M/M/1",
                                       C2 = 1,
                                       Wq_teorico = wqMM1,
                                       Media = mean(mm1),
                                       Variancia = var(mm1)))
  }

  tabela <- rbind(tabela, data.frame(Sistema = sistemas$nome[k],
                                     C2 = C2PK,
                                     Wq_teorico = wqPK,
                                     Media = mean(bim),
                                     Variancia = var(bim)))
}

# Desvio padrao e razao da variancia relativamente ao M/M/1
tabela$Desvio_padrao <- sqrt(tabela$Variancia)
tabela$Razao_var_MM1 <- tabela$Variancia / tabela$Variancia[1]

tabela[, 2:7] <- round(tabela[, 2:7], 4)

cat("Numero de amostras por sistema =", nruns, "\n")
cat("StoppingCondition =", StoppingCondition, "\n\n")
print(tabela, row.names = FALSE)
