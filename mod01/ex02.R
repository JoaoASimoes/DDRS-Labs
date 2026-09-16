  set.seed(123)
  1000->n  
  hist(runif(n),   #runif por default: [0,1]
    main= sprintf("Histogram N=%d", n),
    xlab= "Values",
    ylab= "Frequency",) 
  
  set.seed(123)
  5->n 
  hist(runif(n),   #runif por default: [0,1]
       main= sprintf("Histogram N=%d", n),
       xlab= "Values",
       ylab= "Frequency",)
  
  set.seed(123)
  20->n  
  hist(runif(n),   #runif por default: [0,1]
       main= sprintf("Histogram N=%d", n),
       xlab= "Values",
       ylab= "Frequency",)
  
# meter outro histograma mas com os valores, para ambos os histogramas, de n mais baixos, por exemplo 5
  
  
# se corrermos 2x runif(5) com a mesma seed(mesmo Zo) os resultados serao exatamente iguais ou seja runif() 
# não inventa números de forma aleatória e imprevisível e sim baseado numa expressao com parametros

  