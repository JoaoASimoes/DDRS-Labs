# Exercicio 4 - Probabilidades limite de uma DTMC com 3 estados
library(expm)

# Matriz de probabilidades de transicao (linha = estado atual, coluna = estado seguinte)
P = matrix(c(0.6, 0.0, 0.4,
             0.7, 0.2, 0.1,
             0.0, 0.2, 0.8),
           nrow = 3, byrow = TRUE,
           dimnames = list(0:2, 0:2))
N = nrow(P)
print(rowSums(P))   # verificacao: cada linha tem de somar 1

# ---------------------------------------------------------------
# (i) Equacoes de balanco, forma matricial:
#     pi (P + E - I) = e   =>   pi = e (P + E - I)^(-1)
#     e: vetor linha de uns; E: matriz NxN de uns; I: identidade
# ---------------------------------------------------------------
e = matrix(1, nrow = 1, ncol = N)
E = matrix(1, nrow = N, ncol = N)
I = diag(N)
pi_balanco = as.vector(e %*% solve(P + E - I))

# ---------------------------------------------------------------
# (ii) Multiplicacao de matrizes:
#      calcular P^n ate as linhas ficarem iguais; cada linha e pi
# Com a equação de Chapman-Kolmogorov
# ---------------------------------------------------------------
for (n in c(2, 5, 10, 20)) {
  cat("\nP^", n, ":\n", sep = "")
  print(round(P %^% n, 4))
}
Pn = P %^% 20
pi_matriz = Pn[1, ]

# ---------------------------------------------------------------
# (iii) Simulacao (slide 35: pi_j = fracao de tempo no estado j):
#       gerar uma trajetoria longa e contar as visitas a cada estado
# ---------------------------------------------------------------
set.seed(1)
n_passos = 100000
estado = 0                          # estado inicial (nao influencia o limite)
visitas = numeric(N)
for (k in 1:n_passos) {
  # proximo estado escolhido com as probabilidades da linha do estado atual
  estado = sample(0:(N - 1), 1, prob = P[estado + 1, ])
  visitas[estado + 1] = visitas[estado + 1] + 1
}
pi_sim = visitas / n_passos

# ---------------------------------------------------------------
# Tabela de resultados
# ---------------------------------------------------------------
resultados = data.frame(Estado    = 0:(N - 1),
                        Balanco   = round(pi_balanco, 4),
                        Matriz    = round(pi_matriz, 4),
                        Simulacao = round(pi_sim, 4))
cat("\nProbabilidades limite:\n")
print(resultados, row.names = FALSE)