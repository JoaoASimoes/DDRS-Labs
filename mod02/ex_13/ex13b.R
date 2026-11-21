# Exercicio 13 b)
# Corre o pnet.R varias vezes com a rede do exercicio 13 e compara o atraso
# medio de cada fluxo e o atraso medio na rede com a aproximacao de Kleinrock
# (13 a), calculada pelo kleinrock.R.
# Os parametros da rede sao definidos neste script, na funcao parameters()
# abaixo, que substitui o parameters.R (nao e preciso alterar o parameters.R).

# Pastas onde estao os ficheiros (alterar se mudarem de sitio)
pasta_lab <- "C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab"
pasta_pnet <- file.path(pasta_lab, "pnet")

# Parametros da rede do exercicio 13 (conteudo do parameters.R a indicar no
# relatorio). Ids das ligacoes:
#  1: 1-2   2: 2-4   3: 4-6   4: 1-3   5: 3-5   6: 5-6   7: 2-5
parameters <- function() {
  # Capacidade de cada ligacao (todas com 256 kb/s)
  LinkCapacities <<- rep(256e3, 7)
  
  # Fluxos: taxa de chegada (pacotes/s), tamanho medio (bits) e rota (ids das ligacoes)
  Flows <<- list(list(rate = 215, packetsize = 1000, route = c(1, 2, 3)),  # fluxo 1: 1-2-4-6
                 list(rate = 64, packetsize = 1000, route = c(4, 5)),      # fluxo 2: 1-3-5
                 list(rate = 128, packetsize = 1000, route = c(4, 5, 6)),  # fluxo 3: 1-3-5-6
                 list(rate = 128, packetsize = 1000, route = c(7)))        # fluxo 4: 2-5
  
  # Tempo de simulacao: mesma regra do parameters.R (10000 / menor taxa)
  endTime <<- 10000 * (1 / 64)
}

# Le o codigo do pnet.R e retira a linha que carrega o parameters.R
# (os parametros passam a vir da funcao parameters() definida acima)
codigo_pnet <- readLines(file.path(pasta_pnet, "pnet.R"), warn = FALSE)
codigo_pnet <- codigo_pnet[!grepl("parameters.R", codigo_pnet)]

# Funcao que devolve a media e a semiamplitude do IC a 95% (t de Student)
ic <- function(x) {
  n <- length(x)
  media <- mean(x)
  semiamp <- qt(0.975, n - 1) * sd(x) / sqrt(n)
  return(c(media, semiamp))
}

# Semente para os resultados serem reprodutiveis
set.seed(123)

# Numero de corridas independentes
nruns <- 10

# Matriz com o atraso medio de cada fluxo (colunas) em cada corrida (linhas)
# e vetor com o atraso medio na rede em cada corrida
atrasos <- NULL
atraso_rede <- numeric(nruns)

# Muda para a pasta do pnet.R, para ele encontrar as rotinas (init.R, timing.R, ...)
pasta_original <- getwd()
setwd(pasta_pnet)

# Ciclo sobre as corridas
for (r in 1:nruns) {
  # Executa o pnet.R (o texto que ele imprime e descartado)
  saida <- capture.output(eval(parse(text = codigo_pnet)))
  
  # Vai buscar ao pnet.R o atraso medio de cada fluxo
  atrasos <- rbind(atrasos, FlowStats[, 2] / FlowStats[, 1])
  
  # Atraso medio na rede: atraso total de todos os pacotes / numero de pacotes
  atraso_rede[r] <- sum(FlowStats[, 2]) / sum(FlowStats[, 1])
}

# Volta para a pasta de trabalho original
setwd(pasta_original)

# Aproximacao de Kleinrock (13 a), calculada pelo kleinrock.R com os mesmos
# LinkCapacities e Flows usados na simulacao
source(file.path(pasta_lab, "Kleinrock.R"))
teo <- kleinrock(LinkCapacities, Flows)
W_fluxo_teo <- teo$WFlow      # atraso medio de cada fluxo
W_rede_teo <- teo$W           # atraso medio na rede

# Tabela de resultados (atrasos em milissegundos)
tabela <- data.frame(Fluxo = character(), W_Kleinrock_ms = numeric(),
                     W_simulado_ms = numeric(), IC_95_ms = numeric())
for (f in 1:numFlows) {
  ic_f <- ic(atrasos[, f])
  linha <- data.frame(Fluxo = paste("Fluxo", f),
                      W_Kleinrock_ms = 1000 * W_fluxo_teo[f],
                      W_simulado_ms = 1000 * ic_f[1],
                      IC_95_ms = 1000 * ic_f[2])
  tabela <- rbind(tabela, linha)
}
ic_rede <- ic(atraso_rede)
linha_rede <- data.frame(Fluxo = "Rede",
                         W_Kleinrock_ms = 1000 * W_rede_teo,
                         W_simulado_ms = 1000 * ic_rede[1],
                         IC_95_ms = 1000 * ic_rede[2])
tabela <- rbind(tabela, linha_rede)

# Arredonda as colunas numericas a 3 casas decimais
tabela[, 2:4] <- round(tabela[, 2:4], 3)

# Mostra os parametros usados
cat("Capacidade das ligacoes =", LinkCapacities, "bits/s\n")
cat("Tempo de simulacao (endTime) =", endTime, "s\n")
cat("Numero de corridas =", nruns, "\n")
cat("\n")

# Mostra a tabela
print(tabela, row.names = FALSE)