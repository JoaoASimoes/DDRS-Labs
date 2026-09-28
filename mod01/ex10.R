rtt <- c(328,329,327,328,330,327,328,329,328,330)
n <- length(rtt)
media <- mean(rtt)
variancia <- var(rtt)           # desvio padrão amostral (divide por n-1)
raiz <- sqrt(variancia / n)     # Valor dentro da raiz

alpha = 1-0.95
temp = 1- alpha/2

norm_dis <- media + c(-1, 1) * qnorm(temp) * raiz     # Cálculo com a distribuição normal
stu_dis  <- media + c(-1, 1) * qt(temp, n - 1) * raiz # Cálculo com a distribuição Student's

cat("IC 95% Normal:  [", norm_dis[1], ";", norm_dis[2], "] ms\n")
cat("IC 95% t-Student: [", stu_dis[1], ";", stu_dis[2], "] ms\n")

# A variância populacional do RTT é desconhecida e foi estimada a partir de apenas 10 amostras. 
# A distribuição t de Student tem em conta a incerteza adicional introduzida pela estimação do desvio padrão. 
# Por isso, o seu valor crítico é maior (qt(0,975; 9) = 2,262, contra qnorm(0,975) = 1,960) e o intervalo é mais largo.

# O intervalo baseado na Normal, [327,73; 329,07] ms, é mais estreito, mas com n = 10 subestima a incerteza.
# O intervalo da Normal só seria adequado se a variância fosse conhecida ou se a amostra fosse grande.
# Nesse caso, os dois intervalos seriam praticamente idênticos.