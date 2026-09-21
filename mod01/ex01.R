  n <- 1000
  h <- runif(n) #runif por default: [0,1]

  hist(h ,
      main="Histogram(Uniform data)",
      xlab= "Values",
      ylab= "Frequency",
      col="Blue")

  p<- diff(h$breaks) #hbreaks[]= [0.1, 0.2, 0.3,..,1.0]

  valoresperado<- n * p  #Valor esperado da frequência para cada barra
  desvio <- sqrt(n * p * (1 - p))#o porquê de não ser o valor esperado nas barras todas

  print(valoresperado)
  print(sigma)