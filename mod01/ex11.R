#Estimates the coverage of confidence intervals

E=1000                          #Number of experiments
SizesOfSamples=c(5,10,50,5000)  #Sizes of samples

#Critical points t distribution
#qt() aceita um vetor de graus de liberdade (n-1), devolvendo os 4 valores criticos de uma vez
tcritical=qt(0.975,df=SizesOfSamples-1)

#Funcao que estima a cobertura do IC a 95% para a media
#gen: funcao que gera uma amostra de tamanho N da distribuicao a testar
#mu:  media verdadeira da distribuicao (conhecida apenas porque e uma simulacao)
coverage=function(gen,mu) {
  InInt=rep(0,length(SizesOfSamples))   #Contador de ICs que contem mu, um por tamanho de amostra
  for (i in seq_along(SizesOfSamples)) {
    N=SizesOfSamples[i]
    for (j in 1:E) {
      a=gen(N)                          #Gera uma amostra de tamanho N
      ma=mean(a)                        #Media amostral
      va=var(a)                         #Variancia amostral (divide por N-1)
      alinf=ma-tcritical[i]*sqrt(va/N)  #Limite inferior do IC
      alsup=ma+tcritical[i]*sqrt(va/N)  #Limite superior do IC
      if (mu>alinf & mu<alsup) InInt[i]=InInt[i]+1  #Conta se o IC contem a media verdadeira
    }
  }
  InInt/E   #Cobertura = proporcao de ICs que contem mu
}

#Standard normal distribution
cat("Standard Normal distribution: ", coverage(function(N) rnorm(N), 0))

#Exponential distribution
#Media da Exp(lambda) = 1/lambda = 1
cat("\nExponential distribution: ", coverage(function(N) rexp(N,rate=1), 1))

#Standard Lognormal distribution with sigma^2=1
#Media da Lognormal = e^(mu+sigma^2/2) = e^(0.5)
cat("\nLognormal distribution, sigma^2=1: ", coverage(function(N) rlnorm(N,meanlog=0,sdlog=1), exp(0+1/2)))

#Standard Lognormal distribution with sigma^2=2
#sdlog e o desvio padrao, nao a variancia: sigma^2=2 implica sdlog=sqrt(2)
#Media = e^(0+2/2) = e^1
cat("\nLognormal distribution, sigma^2=2: ", coverage(function(N) rlnorm(N,meanlog=0,sdlog=sqrt(2)), exp(0+2/2)))


# O que se pode concluir?
# Na distribuição Normal, a cobertura é de cerca de 95% para qualquer n, porque o intervalo da t de Student é exato para dados normais. 
# Nas distribuições assimétricas, a cobertura fica abaixo dos 95% quando n é pequeno, e é tanto pior quanto maior a assimetria. 
# Com n = 5, a cobertura é de cerca de 87% na Exponencial, 83% na Lognormal com σ² = 1 e 70% na Lognormal com σ² = 2. 
# Com o aumento de n, a cobertura aproxima-se dos 95%, pelo Teorema do Limite Central, mas mais lentamente quanto maior a assimetria.

# Todos os intervalos de confiança são fiáveis?
# Não. O nível de 95% só é garantido com dados normais ou com amostras suficientemente grandes. 
# Com dados assimétricos e n pequeno, o intervalo é demasiado estreito e falha a média verdadeira mais vezes do que o nível de confiança indica.



