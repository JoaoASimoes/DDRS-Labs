  set.seed(123)
  5->n 
  hist(runif(n),   #runif por default: [0,1]
       main= sprintf("Histogram N=%d", n),
       xlab= "Values",
       ylab= "Frequency",)
  
  par(mfrow = c(1, 2))
  
  set.seed(123)
  20 -> n  
  hist(runif(n),
       main = sprintf("Histogram 1 com N=%d", n),
       xlab = "Values",
       ylab = "Frequency")
  
  # Segundo gráfico
  set.seed(123)
  20 -> n  
  hist(runif(n),
       main = sprintf("Histogram 2 com N=%d", n),
       xlab = "Values",
       ylab = "Frequency")
  
  par(mfrow = c(1, 1))
  
# se corrermos 2x runif(5) com a mesma seed(mesmo Zo) os resultados serao exatamente iguais ou seja runif() 
# não inventa números de forma aleatória e imprevisível e sim baseado numa expressao com parametros

  