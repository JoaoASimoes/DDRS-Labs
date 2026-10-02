# Exercicio 3 - Gerador de numeros com distribuicao de Bernoulli
n <- 1000
set.seed(123)                          # garante reprodutibilidade
random <- runif(n, min = 0, max = 1)   # numeros uniformes em [0,1]
p <- 0.2                               # probabilidade de sucesso (repetido para 0.5 e 0.8)
# sucesso (1) quando random < p, o que ocorre com probabilidade p
hist(ifelse(random >= p, 0, 1))
