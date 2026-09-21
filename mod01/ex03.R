  n <- 1000  
  prob <- 0.9 
  set.seed(123)
  
  amostra <- runif(n)
  bernoulli<- ifelse(amostra<= prob, 0 ,1) 
    
  hist(bernoulli ,
    main= sprintf("Histogram Bernoulli Prob=%f", prob),
    xlab= "Values",
    ylab= "Frequency",
    )