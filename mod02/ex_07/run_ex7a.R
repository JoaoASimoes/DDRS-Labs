# run_ex7.R — Corre o ppl.R (com o parameters.R atual) e acrescenta os
# resultados, mais os valores teóricos M/M/1, ao ficheiro ex7a_resultados.csv.
# Uso: editar o parameters.R e correr  source("run_ex7.R")
# (repetir para cada cenário; cada corrida acrescenta linhas ao CSV)

source("ppl.R")   # corre a simulação e imprime o report

mu  = LinkCapacity / Flows[[1]]$packetsize               # μ = C / L̄
lam = sum(sapply(Flows, function(f) f$arrivalrate))      # λ = λ1 + λ2

res = data.frame(
  rho           = lam / mu,
  flow          = 1:numFlows,
  lambda        = sapply(Flows, function(f) f$arrivalrate),
  endTime       = endTime,
  atraso_sim_ms = 1e3 * FlowStats[,2] / FlowStats[,1],
  atraso_teo_ms = 1e3 / (mu - lam),                       # M/M/1: W = 1/(μ-λ)
  thr_sim_bps   = FlowStats[,3] / Time,
  thr_teo_bps   = sapply(Flows, function(f) f$arrivalrate * f$packetsize)
)

# Linha agregada (os dois fluxos juntos, λ = λ1 + λ2)
total = data.frame(
  rho           = lam / mu,
  flow          = "total",
  lambda        = lam,
  endTime       = endTime,
  atraso_sim_ms = 1e3 * sum(FlowStats[,2]) / sum(FlowStats[,1]),  # média sobre todos os pacotes
  atraso_teo_ms = 1e3 / (mu - lam),
  thr_sim_bps   = sum(FlowStats[,3]) / Time,
  thr_teo_bps   = sum(res$thr_teo_bps)
)
res = rbind(res, total)

# ID da simulação: 1 na primeira corrida, depois último ID do CSV + 1
f = "ex7a_resultados.csv"
sim_id = if (file.exists(f)) max(read.csv(f)$sim_id) + 1 else 1
res = cbind(sim_id = sim_id, res)
print(res)

write.table(res, f, sep=",", row.names=FALSE,
            col.names=!file.exists(f), append=file.exists(f))