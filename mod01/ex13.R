# Impacto das condicoes iniciais numa fila M/M/1

source("~/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod01/initcond.R", echo = TRUE)

set.seed(12345)  # Torna a experiencia reprodutivel

arrival_rate <- 3
service_rate <- 4
num_runs <- 25
confidence_level <- 0.95

# Executa as replicas independentes de um cenario e calcula o IC para a media.
simulate_case <- function(run_length, init_clients) {
  avg_delays <- replicate(
    num_runs,
    fmm1_initcond(
      ArrivalRate = arrival_rate,
      ServiceRate = service_rate,
      NumEndClients = run_length,
      InitClients = init_clients
    )
  )
  
  print(avg_delays)

  standard_error <- sd(avg_delays) / sqrt(num_runs)
  margin <- qt(
    1 - (1 - confidence_level) / 2,
    df = num_runs - 1
  ) * standard_error

  data.frame(
    RunLength = run_length,
    InitClients = init_clients,
    MeanDelay = mean(avg_delays),
    CI95Lower = mean(avg_delays) - margin,
    CI95Upper = mean(avg_delays) + margin
  )
}

# As quatro combinacoes pedidas: dois comprimentos e duas condicoes iniciais.
cases <- expand.grid(
  RunLength = c(20, 2000),
  InitClients = c(0, 10)
)

results <- do.call(
  rbind,
  Map(simulate_case, cases$RunLength, cases$InitClients)
)

rownames(results) <- NULL
print(results, digits = 4, row.names = FALSE)

# Valor teorico em regime estacionario: Wq = lambda / (mu * (mu - lambda)).
theoretical_delay <- arrival_rate /
  (service_rate * (service_rate - arrival_rate))
cat(sprintf("\nAtraso medio teorico em regime estacionario: %.4f\n", theoretical_delay))

# Conclusao:
# Em execucoes curtas (20 atrasos), a condicao inicial tem um efeito forte. Uma
# fila inicialmente vazia produz um periodo transitorio com atrasos menores,
# enquanto 10 clientes iniciais produzem atrasos maiores. Assim, os estimadores
# sao enviesados em sentidos opostos relativamente ao valor estacionario 0.75.
# Em execucoes longas (2000 atrasos), o transitorio inicial representa apenas
# uma pequena fracao das observacoes: as estimativas das duas condicoes iniciais
# ficam proximas entre si e do valor teorico. Logo, aumentar o comprimento da
# execucao reduz substancialmente o impacto das condicoes iniciais.
