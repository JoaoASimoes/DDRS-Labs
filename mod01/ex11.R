# Exercicio 11 - Cobertura de intervalos de confianca a 95% para a media
set.seed(123)                          # garante reprodutibilidade
E = 1000                               # numero de experiencias
SizesOfSamples = c(5, 10, 50, 5000)    # tamanhos de amostra

# Pontos criticos da t-Student (um por tamanho de amostra, com n-1 graus de liberdade)
tcritical = qt(0.975, df = SizesOfSamples - 1)

# Estima a cobertura do IC a 95% para a media
# gen: funcao que gera uma amostra de tamanho N da distribuicao a testar
# mu:  media verdadeira da distribuicao (conhecida apenas porque e uma simulacao)
coverage = function(gen, mu) {
  InInt = rep(0, length(SizesOfSamples))   # contador de ICs que contem mu, por tamanho de amostra
  for (i in seq_along(SizesOfSamples)) {
    N = SizesOfSamples[i]
    for (j in 1:E) {
      a = gen(N)                           # gera uma amostra de tamanho N
      ma = mean(a)                         # media amostral
      va = var(a)                          # variancia amostral (divide por N-1)
      alinf = ma - tcritical[i] * sqrt(va / N)   # limite inferior do IC
      alsup = ma + tcritical[i] * sqrt(va / N)   # limite superior do IC
      if (mu > alinf & mu < alsup) InInt[i] = InInt[i] + 1   # conta se o IC contem mu
    }
  }
  InInt / E                                # cobertura = proporcao de ICs que contem mu
}

# Normal padrao (media 0)
cat("Standard Normal distribution: ", coverage(function(N) rnorm(N), 0))

# Exponencial com lambda = 1 (media 1/lambda = 1)
cat("\nExponential distribution: ", coverage(function(N) rexp(N, rate = 1), 1))

# Lognormal com mu = 0 e sigma^2 = 1 (media e^(mu + sigma^2/2) = e^0.5)
cat("\nLognormal distribution, sigma^2=1: ",
    coverage(function(N) rlnorm(N, meanlog = 0, sdlog = 1), exp(0 + 1/2)))

# Lognormal com mu = 0 e sigma^2 = 2 (sdlog e o desvio padrao: sdlog = sqrt(2); media e^1)
cat("\nLognormal distribution, sigma^2=2: ",
    coverage(function(N) rlnorm(N, meanlog = 0, sdlog = sqrt(2)), exp(0 + 2/2)))
cat("\n")
