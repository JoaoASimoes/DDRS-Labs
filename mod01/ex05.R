lambda <- 3
n <- 10000
#n <- 10
interarrivals <- rexp(n, rate = lambda) # gerar diretamentenúmeros exponenciais com rate, sem runif()
tempos_chegada <- cumsum(interarrivals) # Soma dos números exponenciais
head(tempos_chegada)

taxa_amostral <- n / tempos_chegada[n]
cat("Taxa teorica (lambda):", lambda, "\n")
cat("Taxa amostral:", taxa_amostral, "\n")
