# Exercicio 13 d)
# Todos os fluxos podem ser bifurcados: corre o bg.R (algoritmo gradient
# projection) com a rede do exercicio 13, calcula o atraso medio na rede e
# compara com o 13 a) (sem bifurcacao) e o 13 c) (so o fluxo 1 bifurcado).
# Os parametros da rede sao definidos neste script, na funcao parameters()
# abaixo, que substitui o parameters.R da pasta do bg.R.

# Pasta onde estao o bg.R, o aux_bg.R e o shortestpath.R (alterar se mudar de sitio)
pasta_lab <- "C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2/Exs_Lab"
pasta_bg <- file.path(pasta_lab, "bg")

# Tamanho medio dos pacotes (bits), para passar de bits/s para pacotes/s
tamanho_pacote <- 1000

# Parametros da rede do exercicio 13 (conteudo do parameters.R a indicar no relatorio)
parameters <- function() {
  # Capacidade das ligacoes (bits/s): elemento (i,j) = capacidade da ligacao i->j
  # Ligacoes: 1-2, 1-3, 2-4, 2-5, 3-5, 4-6, 5-6 (todas com 256 kb/s)
  LinkCapacities <<- matrix(c(0, 256e3, 256e3,     0,     0,     0,
                              0,     0,     0, 256e3, 256e3,     0,
                              0,     0,     0,     0, 256e3,     0,
                              0,     0,     0,     0,     0, 256e3,
                              0,     0,     0,     0,     0, 256e3,
                              0,     0,     0,     0,     0,     0),
                            nrow = 6,
                            ncol = 6,
                            byrow = TRUE)
  
  # Fluxos por par origem-destino (OD): origem, destino, taxa (bits/s)
  # Os fluxos 1 e 3 tem o mesmo OD (1->6), por isso juntam-se: 215 + 128 = 343 pacotes/s
  Flows <<- matrix(c(1, 6, 343e3,   # fluxos 1 e 3: 1 -> 6
                     1, 5,  64e3,   # fluxo 2: 1 -> 5
                     2, 5, 128e3),  # fluxo 4: 2 -> 5
                   nrow = 3,
                   ncol = 3,
                   byrow = TRUE)
}

# Le o codigo do bg.R e retira a linha que carrega o parameters.R
# (os parametros passam a vir da funcao parameters() definida acima)
codigo_bg <- readLines(file.path(pasta_bg, "bg.R"), warn = FALSE)
codigo_bg <- codigo_bg[!grepl("parameters.R", codigo_bg)]

# Muda para a pasta do bg.R, para ele encontrar o shortestpath.R e o aux_bg.R
pasta_original <- getwd()
setwd(pasta_bg)

# Executa o bg.R (o texto que ele imprime e guardado em saida)
saida <- capture.output(eval(parse(text = codigo_bg)))

# Volta para a pasta de trabalho original
setwd(pasta_original)

# Atraso medio na rede (lei de Little): W = L / gamma
gamma <- sum(Flows[, 3]) / tamanho_pacote      # pacotes/s que entram na rede (535)
W_13d <- TotalMeanPackets / gamma

# Valores dos exercicios anteriores (13 a: kleinrock.R; 13 c: calculo a mao)
L_13a <- 23.731707
L_13c <- 19.362
W_13a <- L_13a / gamma
W_13c <- L_13c / gamma

# Tabela com a divisao otima de cada par OD pelas suas rotas (em pacotes/s)
tabela_rotas <- data.frame()
for (i in 1:NumODPairs) {
  for (j in 1:length(Paths[[i]])) {
    linha <- data.frame(OD = paste(Flows[i, 1], "->", Flows[i, 2]),
                        Rota = paste(Paths[[i]][[j]]$route, collapse = "-"),
                        Taxa_pkt_s = round(Paths[[i]][[j]]$rate / tamanho_pacote, 3))
    tabela_rotas <- rbind(tabela_rotas, linha)
  }
}

# Tabela com a carga de cada ligacao (em pacotes/s)
origens <- row(LinkCapacities)[LinkCapacities > 0]
destinos <- col(LinkCapacities)[LinkCapacities > 0]
tabela_ligacoes <- data.frame(Ligacao = paste(origens, destinos, sep = "-"),
                              lambda_pkt_s = round(LinkRates[LinkCapacities > 0] / tamanho_pacote, 3))

# Tabela de comparacao com o 13 a) e o 13 c)
tabela_comp <- data.frame(Caso = c("13 a) sem bifurcacao",
                                   "13 c) so o fluxo 1 bifurcado",
                                   "13 d) todos os fluxos bifurcados"),
                          L = round(c(L_13a, L_13c, TotalMeanPackets), 3),
                          W_ms = round(1000 * c(W_13a, W_13c, W_13d), 3))

# Mostra os resultados
cat("Iteracoes: fase I =", niter1, " fase II =", niter2, "\n\n")
cat("Divisao otima de cada par OD pelas rotas:\n")
print(tabela_rotas, row.names = FALSE)
cat("\nCarga de cada ligacao:\n")
print(tabela_ligacoes, row.names = FALSE)
cat("\nComparacao:\n")
print(tabela_comp, row.names = FALSE)
cat("\nReducao em relacao ao 13 a) =", round(100 * (1 - W_13d / W_13a), 1), "%\n")
cat("Reducao em relacao ao 13 c) =", round(100 * (1 - W_13d / W_13c), 1), "%\n")