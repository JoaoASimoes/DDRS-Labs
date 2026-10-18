# 1. Taxas de transicao lambda_ij (linha = origem, coluna = destino)
lambda <- matrix(c(0, 2, 0,
                   1, 0, 1,
                   1, 1, 0),
                 nrow = 3, byrow = TRUE)

# Taxa total de saida de cada estado: nu_i = soma_j lambda_ij
nu <- rowSums(lambda)

A <- matrix(c(
  2, -1, -1,  # Estado 1
  0, -1,  2,  # Estado 3
  1,  1,  1   # Normalizacao
), nrow = 3, byrow = TRUE)

b <- c(0, 0, 1)

# Resolver o sistema
pi_teorico <- as.vector(solve(A, b))

print(pi_teorico)

# Matriz de probabilidades de salto
P <- sweep(lambda, 1, nu, "/")

# 3. Simulacao - View 1
simular_view1 <- function(tempo_total, nu, P) {
  estado <- 1
  tempo <- 0
  tempo_em_cada_estado <- numeric(length(nu))

  while (tempo < tempo_total) {
    dt <- rexp(1, rate = nu[estado])

    dt_efetivo <- min(dt, tempo_total - tempo) # para nao exceder tempo_total
    tempo_em_cada_estado[estado] <- tempo_em_cada_estado[estado] + dt_efetivo
    tempo <- tempo + dt_efetivo

    if (tempo < tempo_total) {
      estado <- sample(1:length(nu), size = 1, prob = P[estado, ])
    }
  }

  tempo_em_cada_estado / tempo_total
}

# 4. Simulacao - View 2
# Geram-se tempos exponenciais independentes para cada transicao possivel.
# A transicao realizada e a que tiver o menor tempo.
simular_view2 <- function(tempo_total, lambda) {
  estado <- 1
  tempo <- 0
  tempo_em_cada_estado <- numeric(nrow(lambda))

  while (tempo < tempo_total) {
    destinos <- which(lambda[estado, ] > 0)
    tempos_possiveis <- rexp(length(destinos),
                             rate = lambda[estado, destinos])

    indice_primeiro <- which.min(tempos_possiveis)
    dt <- tempos_possiveis[indice_primeiro]

    dt_efetivo <- min(dt, tempo_total - tempo)
    tempo_em_cada_estado[estado] <- tempo_em_cada_estado[estado] + dt_efetivo
    tempo <- tempo + dt_efetivo

    if (tempo < tempo_total) {
      estado <- destinos[indice_primeiro]
    }
  }

  tempo_em_cada_estado / tempo_total
}

# 5. Executar simulacoes e comparar
set.seed(123)  # Permite repetir os resultados
tempo_total <- 100000

pi_view1 <- simular_view1(tempo_total, nu, P)
pi_view2 <- simular_view2(tempo_total, lambda)

resultados <- data.frame(
  Estado = 1:3,
  Teorico = pi_teorico,
  View1 = pi_view1,
  View2 = pi_view2
)

print(round(resultados, 4))

# 6. Grafico comparativo
comparacao <- rbind(Teorico = pi_teorico,
                    View1 = pi_view1,
                    View2 = pi_view2)

barplot(comparacao,
        beside = TRUE,
        col = c("gray70", "steelblue", "coral"),
        names.arg = c("Estado 1", "Estado 2", "Estado 3"),
        ylab = "Proporcao de tempo",
        ylim = c(0, 0.55),
        legend.text = rownames(comparacao),
        args.legend = list(x = "topright"),
        main = "CTMC: teoria vs simulacao")
