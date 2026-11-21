# Exercicio 8 a)
# Corre o mg1_bimodal.R varias vezes para os dois sistemas bimodais e mostra
# numa tabela o atraso medio em fila (teorico e simulado, com IC a 95%) do
# M/M/1 e dos dois M/G/1.
# Do mg1_bimodal.R vem: o codigo da simulacao, Ro, StoppingCondition e os
# resultados. Este script so troca as linhas de s1/p1 e s2/p2 para cada sistema.
# Este ficheiro tem de estar na mesma pasta que o mg1_bimodal.R.

# Funcao que devolve a media e a semiamplitude do IC a 95% (t de Student)
ic <- function(x) {
  n <- length(x)
  media <- mean(x)
  semiamp <- qt(0.975, n - 1) * sd(x) / sqrt(n)
  return(c(media, semiamp))
}

# Le o codigo do mg1_bimodal.R
codigo <- readLines("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab/packets/mg1_bimodal.R", warn = FALSE)

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

# Semente para os resultados serem reprodutiveis
set.seed(123)

# Numero de corridas independentes por sistema
nruns <- 20

# Tabela de resultados (uma linha por sistema, mais o M/M/1)
tabela <- data.frame()

# Ciclo sobre os dois sistemas bimodais
for (k in 1:nrow(sistemas)) {
  # Troca as linhas de s1/p1 e s2/p2 pelos valores deste sistema
  codigo_k <- codigo
  codigo_k[linha_s1] <- sprintf("s1=%g;p1=%g", sistemas$s1[k], sistemas$p1[k])
  codigo_k[linha_s2] <- sprintf("s2=%g;p2=%g", sistemas$s2[k], sistemas$p2[k])
  
  # Vetores onde se guardam os resultados de cada corrida
  mm1 <- numeric(nruns)
  bim <- numeric(nruns)
  
  # Ciclo sobre as corridas
  for (r in 1:nruns) {
    # Executa o mg1_bimodal.R (o texto que ele imprime e descartado)
    saida <- capture.output(eval(parse(text = codigo_k)))
    
    # Vai buscar ao mg1_bimodal.R os atrasos medios em fila estimados
    mm1[r] <- AvgDelayMM1
    bim[r] <- AvgDelayBimodal
  }
  
  # Calcula os intervalos de confianca
  ic_mm1 <- ic(mm1)
  ic_bim <- ic(bim)
  
  # O M/M/1 e igual nos dois casos (E[S] = 2), por isso so entra uma vez,
  # com os resultados obtidos no primeiro sistema
  if (k == 1) {
    wqMM1 <- (ArrivalRate / ServiceRate) / (ServiceRate - ArrivalRate)
    linha_mm1 <- data.frame(Sistema = "M/M/1",
                            C2 = 1,
                            Wq_teorico = wqMM1,
                            Wq_simulado = ic_mm1[1],
                            IC_95 = ic_mm1[2])
    tabela <- rbind(tabela, linha_mm1)
  }
  
  # Acrescenta a linha do sistema bimodal
  linha_bim <- data.frame(Sistema = sistemas$nome[k],
                          C2 = C2PK,
                          Wq_teorico = wqPK,
                          Wq_simulado = ic_bim[1],
                          IC_95 = ic_bim[2])
  tabela <- rbind(tabela, linha_bim)
}

# Arredonda as colunas numericas a 3 casas decimais
tabela[, 2:5] <- round(tabela[, 2:5], 3)

# Mostra os parametros comuns lidos do mg1_bimodal.R
cat("Ro =", Ro, "\n")
cat("StoppingCondition =", StoppingCondition, "\n")
cat("Numero de corridas por sistema =", nruns, "\n")
cat("lambda =", ArrivalRate, "\n")
cat("mu =", ServiceRate, "\n")
cat("\n")

# Mostra a tabela
print(tabela, row.names = FALSE)
