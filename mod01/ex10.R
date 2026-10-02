# Exercicio 10 - Intervalos de confianca a 95% para o RTT medio
rtt <- c(328, 329, 327, 328, 330, 327, 328, 329, 328, 330)  # RTTs medidos (ms)
n <- length(rtt)
media <- mean(rtt)
variancia <- var(rtt)                  # variancia amostral (divide por n-1)
erro_padrao <- sqrt(variancia / n)     # erro padrao da media

alpha <- 1 - 0.95
quantil <- 1 - alpha / 2               # 0.975 para IC a 95%

norm_dis <- media + c(-1, 1) * qnorm(quantil) * erro_padrao      # IC com a Normal
stu_dis  <- media + c(-1, 1) * qt(quantil, n - 1) * erro_padrao  # IC com a t-Student

cat("IC 95% Normal:    [", norm_dis[1], ";", norm_dis[2], "] ms\n")
cat("IC 95% t-Student: [", stu_dis[1], ";", stu_dis[2], "] ms\n")
