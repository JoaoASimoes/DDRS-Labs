# run_ex7c.R — Corre o ppl.R (com o parameters.R atual) e acrescenta os
# resultados, mais os valores teóricos de prioridade estrita não-preemptiva
# com pacotes de tamanho fixo (M/D/1), ao ficheiro ex7c_resultados.csv.
# Uso: editar o parameters.R e correr  source("run_ex7c.R")
# Assume: 2 fluxos, sourcetype=2 (tamanho fixo), mesmo packetsize,
#         fluxo 1 com priority=1 (alta) e fluxo 2 com priority=2 (baixa).

source("ppl.R")   # corre a simulação e imprime o report

S    = Flows[[1]]$packetsize / LinkCapacity              # tempo de serviço (fixo), s
lams = sapply(Flows, function(f) f$arrivalrate)          # λ1, λ2
rho1 = lams[1] * S                                       # carga do fluxo prioritário
rho  = sum(lams) * S                                     # carga total

W0 = sum(lams) * S^2 / 2                                 # tempo residual médio: Σ λi E[Si²]/2
W1 = W0 / (1 - rho1) + S                                 # alta prioridade
W2 = W0 / ((1 - rho1) * (1 - rho)) + S                   # baixa prioridade
Wt = W0 / (1 - rho) + S                                  # total = M/D/1 FIFO (lei de conservação)

res = data.frame(
  rho           = rho,
  flow          = c(1:numFlows, "total"),
  priority      = c(sapply(Flows, function(f) f$priority), NA),
  lambda        = c(lams, sum(lams)),
  endTime       = endTime,
  atraso_sim_ms = 1e3 * c(FlowStats[,2] / FlowStats[,1],
                          sum(FlowStats[,2]) / sum(FlowStats[,1])),
  atraso_teo_ms = 1e3 * c(W1, W2, Wt),
  thr_sim_bps   = c(FlowStats[,3], sum(FlowStats[,3])) / Time,
  thr_teo_bps   = c(lams, sum(lams)) * Flows[[1]]$packetsize
)

# ID da simulação: 1 na primeira corrida, depois último ID do CSV + 1
f = "ex7c_resultados.csv"
sim_id = if (file.exists(f)) max(read.csv(f)$sim_id) + 1 else 1
res = cbind(sim_id = sim_id, res)
print(res)
cat(sprintf("Razão W2/W1: simulada = %.2f, teórica = %.2f\n",
            res$atraso_sim_ms[2] / res$atraso_sim_ms[1], W2 / W1))

write.table(res, f, sep=",", row.names=FALSE,
            col.names=!file.exists(f), append=file.exists(f))