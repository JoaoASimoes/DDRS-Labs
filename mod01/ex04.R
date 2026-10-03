lambda <- 3
n <- 10000
random_inversa <- runif(n)
x <- -log(1-random_inversa)/lambda # Função da inversa
hist(x, prob=TRUE) # com o prob true assim o eixo y representa a densidsade

x_vals <- seq(0, max(x), length.out = 200) 
y_vals <- dexp(x_vals, rate = lambda)      
lines(x_vals, y_vals, col = "blue", lwd = 2)
