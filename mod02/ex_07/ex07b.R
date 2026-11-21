# Exercicio 7 b) (e comparacao com o 7 a)
# Ligacao ponto a ponto com escalonamento FIFO e dois fluxos Poisson iguais.
# Corre o ppl.R varias vezes para dois valores de rho = lambda/mu, com pacotes
# de tamanho fixo (7 b, M/D/1) e exponencial (7 a, M/M/1), e mostra numa tabela
# o atraso medio por fluxo (simulado com IC a 95% e teorico).
# Do ppl.R e das suas rotinas vem toda a simulacao; este script so define os
# parametros (em vez do parameters.R) e repete as corridas.
# Este ficheiro tem de estar na mesma pasta que o ppl.R e as suas rotinas.

# Funcao que devolve a media e a semiamplitude do IC a 95% (t de Student)
ic <- function(x) {
  n <- length(x)
  media <- mean(x)
  semiamp <- qt(0.975, n - 1) * sd(x) / sqrt(n)
  return(c(media, semiamp))
}

# Parametros fixos
C <- 100e3                        # capacidade da ligacao (bits/s)
L <- 1000                         # tamanho (medio) dos pacotes (bits)
mu <- C / L                       # taxa de servico (pacotes/s)

# Valores de rho a simular e tipos de pacote (1 = exponencial, 2 = fixo)
valores_rho <- c(0.5, 0.9)
tipos <- c(1, 2)
nomes_tipos <- c("Exponencial (M/M/1)", "Fixo (M/D/1)")

# Funcao que substitui o parameters.R: dois fluxos iguais, ambos com
# prioridade 1 (FIFO), cada um com metade da carga total
parameters <- function() {
  LinkCapacity <<- C
  Flows <<- list(list(sourcetype = tipo, arrivalrate = lambda, packetsize = L, priority = 1),
                 list(sourcetype = tipo, arrivalrate = lambda, packetsize = L, priority = 1))
  # tempo de simulacao: mesma regra do parameters.R (10000 / menor taxa de chegada)
  endTime <<- 10000 * (1 / lambda)
}

# Le o codigo do ppl.R e retira a linha que carrega o parameters.R
# (os parametros passam a vir da funcao parameters() definida acima)
codigo <- readLines("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab/packets/ppl.R", warn = FALSE)
codigo <- codigo[!grepl("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab/packets/parameters.R", codigo)]

# Semente para os resultados serem reprodutiveis
set.seed(123)

# Numero de corridas independentes por configuracao
nruns <- 10

# Tabela de resultados
tabela <- data.frame()

# Ciclo sobre os valores de rho
for (rho in valores_rho) {
  # Taxa de chegada de cada fluxo (a carga total e dividida pelos dois)
  lambda <- rho * mu / 2
  
  # Ciclo sobre os tipos de pacote
  for (k in 1:length(tipos)) {
    tipo <- tipos[k]
    
    # Vetores onde se guarda o atraso medio de cada fluxo em cada corrida
    atraso_f1 <- numeric(nruns)
    atraso_f2 <- numeric(nruns)
    
    # Ciclo sobre as corridas
    for (r in 1:nruns) {
      # Executa o ppl.R (o texto que ele imprime e descartado)
      saida <- capture.output(eval(parse(text = codigo)))
      
      # Vai buscar ao ppl.R o atraso medio de cada fluxo (atraso no sistema)
      atraso_f1[r] <- FlowStats[1, 2] / FlowStats[1, 1]
      atraso_f2[r] <- FlowStats[2, 2] / FlowStats[2, 1]
    }
    
    # Atraso medio teorico no sistema (fila + transmissao), igual nos dois fluxos
    if (tipo == 1) {
      W_teo <- 1 / (mu - rho * mu)                        # M/M/1
    } else {
      W_teo <- rho / (2 * mu * (1 - rho)) + 1 / mu        # M/D/1
    }
    
    # Intervalos de confianca
    ic_f1 <- ic(atraso_f1)
    ic_f2 <- ic(atraso_f2)
    
    # Linhas da tabela (atrasos em milissegundos)
    linhas <- data.frame(
      rho = rho,
      lambda_fluxo = lambda,
      Pacotes = nomes_tipos[k],
      Fluxo = c(1, 2),
      W_teorico_ms = 1000 * W_teo,
      W_simulado_ms = 1000 * c(ic_f1[1], ic_f2[1]),
      IC_95_ms = 1000 * c(ic_f1[2], ic_f2[2])
    )
    tabela <- rbind(tabela, linhas)
  }
}

# Arredonda as colunas dos atrasos a 3 casas decimais
tabela[, 5:7] <- round(tabela[, 5:7], 3)

# Mostra os parametros usados
cat("Capacidade da ligacao =", C, "bits/s\n")
cat("Tamanho (medio) dos pacotes =", L, "bits\n")
cat("mu =", mu, "pacotes/s\n")
cat("Tempo de simulacao = 10000 / lambda (s)\n")
cat("Numero de corridas por configuracao =", nruns, "\n")
cat("\n")

# Mostra a tabela
print(tabela, row.names = FALSE)