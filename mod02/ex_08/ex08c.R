# Exercicio 8 c)
# E o script do 8 a) (M/M/1 e M/G/1 bimodal com FIFO, pelo mg1_bimodal.R) com
# corridas extra do sistema com prioridade estrita nao-preemptiva aos ratos
# (mg1_bimodal_prio.R), para os dois sistemas.
# Os simuladores, os parametros (Ro, StoppingCondition) e os valores teoricos
# vem desses dois ficheiros; este script so troca s1, p1, s2 e p2 para cada
# sistema, repete as corridas, calcula os IC e mostra a tabela.
# Os tres ficheiros tem de estar na mesma pasta.

# Funcao que devolve a media e a semiamplitude do IC a 95% (t de Student)
ic <- function(x) {
  n <- length(x)
  media <- mean(x)
  semiamp <- qt(0.975, n - 1) * sd(x) / sqrt(n)
  return(c(media, semiamp))
}

# Funcao que troca o valor de um parametro no codigo (ex.: "p1=0.99" -> "p1=0.9")
# Funciona com "s1=1;p1=0.99" na mesma linha ou com cada parametro na sua linha
troca_parametro <- function(codigo, nome, valor) {
  padrao <- paste0("(^|;)", nome, "=[0-9.]+")
  novo <- paste0("\\1", nome, "=", valor)
  codigo <- sub(padrao, novo, codigo)
  return(codigo)
}

# Le o codigo dos dois simuladores
codigo_fifo <- readLines("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab/packets/mg1_bimodal.R", warn = FALSE)
codigo_prio <- readLines("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab/MG1_bimodal_prio.R", warn = FALSE)

# Parametros dos dois sistemas bimodais
sistemas <- data.frame(
  nome = c("M/Bimodal-1/1", "M/Bimodal-2/1"),
  s1 = c(1, 1),
  p1 = c(0.9, 0.99),
  s2 = c(11, 101),
  p2 = c(0.1, 0.01)
)

# Semente para os resultados serem reprodutiveis
set.seed(123)

# Numero de corridas independentes por sistema
nruns <- 20

# Tabela de resultados
tabela <- data.frame()

# Ciclo sobre os dois sistemas bimodais
for (k in 1:nrow(sistemas)) {
  # Poe os parametros deste sistema nos dois simuladores
  fifo_k <- codigo_fifo
  prio_k <- codigo_prio
  for (nome in c("s1", "p1", "s2", "p2")) {
    fifo_k <- troca_parametro(fifo_k, nome, sistemas[k, nome])
    prio_k <- troca_parametro(prio_k, nome, sistemas[k, nome])
  }
  
  # Vetores onde se guardam os resultados de cada corrida
  mm1 <- numeric(nruns)
  fifo <- numeric(nruns)
  prio_total <- numeric(nruns)
  prio_ratos <- numeric(nruns)
  prio_elefantes <- numeric(nruns)
  
  # Ciclo sobre as corridas
  for (r in 1:nruns) {
    # FIFO: executa o mg1_bimodal.R (o texto que ele imprime e descartado)
    saida <- capture.output(eval(parse(text = fifo_k)))
    mm1[r] <- AvgDelayMM1
    fifo[r] <- AvgDelayBimodal
    
    # Prioridade: executa o mg1_bimodal_prio.R
    saida <- capture.output(eval(parse(text = prio_k)))
    prio_total[r] <- AvgDelayPrio
    prio_ratos[r] <- AvgDelayRatos
    prio_elefantes[r] <- AvgDelayElefantes
  }
  
  # Intervalos de confianca
  ic_mm1 <- ic(mm1)
  ic_fifo <- ic(fifo)
  ic_total <- ic(prio_total)
  ic_ratos <- ic(prio_ratos)
  ic_elefantes <- ic(prio_elefantes)
  
  # O M/M/1 e igual nos dois casos (E[S] = 2), por isso so entra uma vez,
  # com os resultados obtidos no primeiro sistema (como no 8 a)
  if (k == 1) {
    wqMM1 <- (ArrivalRate / ServiceRate) / (ServiceRate - ArrivalRate)
    linha_mm1 <- data.frame(Sistema = "M/M/1",
                            Politica = "FIFO",
                            Wq_teorico = wqMM1,
                            Wq_simulado = ic_mm1[1],
                            IC_95 = ic_mm1[2])
    tabela <- rbind(tabela, linha_mm1)
  }
  
  # Linhas da tabela para este sistema (valores teoricos vem dos dois ficheiros)
  linhas <- data.frame(
    Sistema = sistemas$nome[k],
    Politica = c("FIFO", "Prioridade (total)", "Prioridade (ratos)", "Prioridade (elefantes)"),
    Wq_teorico = c(wqPK, wqPrio, wqRatos, wqElefantes),
    Wq_simulado = c(ic_fifo[1], ic_total[1], ic_ratos[1], ic_elefantes[1]),
    IC_95 = c(ic_fifo[2], ic_total[2], ic_ratos[2], ic_elefantes[2])
  )
  tabela <- rbind(tabela, linhas)
}

# Arredonda as colunas numericas a 3 casas decimais
tabela[, 3:5] <- round(tabela[, 3:5], 3)

# Mostra os parametros comuns lidos dos simuladores
cat("Ro =", Ro, "\n")
cat("StoppingCondition =", StoppingCondition, "\n")
cat("Numero de corridas por sistema =", nruns, "\n")
cat("lambda =", ArrivalRate, "\n")
cat("mu =", ServiceRate, "\n")
cat("\n")

# Mostra a tabela
print(tabela, row.names = FALSE)