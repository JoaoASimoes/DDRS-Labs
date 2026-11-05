# run_ex9.R — Corre o webserverfarm.R (com o ArrivalRate que lá estiver) e
# acrescenta os resultados ao ficheiro ex9_resultados.csv.
# Uso: mudar o ArrivalRate no webserverfarm.R e correr  source("run_ex9.R")
setwd("/home/simoes/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod02/ex_09")
source("webserverfarm.R")   # corre as duas políticas e imprime os resultados

res = data.frame(
  rho              = ro,
  lambda           = ArrivalRate,
  num_jobs         = StoppingCondition,
  random_sim       = AvgDelayRandom,
  random_teo       = TrueAvgDelay,                           # 1/(μ(1-ρ))
  jsq_sim          = AvgDelayJSQ,
  mm2_ref          = 1 / (ServiceRate * (1 - ro^2))          # M/M/2 (fila central), só referência
)

f = "ex9_resultados.csv"
sim_id = if (file.exists(f)) max(read.csv(f)$sim_id) + 1 else 1
res = cbind(sim_id = sim_id, res)
print(res)

write.table(res, f, sep=",", row.names=FALSE,
            col.names=!file.exists(f), append=file.exists(f))
