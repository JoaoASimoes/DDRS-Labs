# Ex. 14 – Guia para correr e apresentar

Cada pasta tem tudo o que essa alínea precisa. Em cada uma: **RStudio → Session → Set Working Directory → Choose Directory** (escolhe a pasta) e depois corre o script indicado.

Numeração dos links (igual em todos os scripts): **1: 1-2 · 2: 2-3 · 3: 1-4 · 4: 2-4 · 5: 4-3**

---

## a) `a_reducload/` → `source("reducload_cost.R")`
Já tem a solução ótima. Resultado esperado:
```
Blocking probability of link 1 = 0.001580
Blocking probability of link 2 = 0.001580
Blocking probability of link 3 = 0.001573
Blocking probability of link 4 = 1.000000   <- 0 circuitos; nenhum fluxo o usa
Blocking probability of link 5 = 0.001573
Blocking probability of flow 1 = 0.001580
Blocking probability of flow 2 = 0.001580
Blocking probability of flow 3 = 0.003143
Total cost of solution is 4800 Euros
```
**Tentativa e erro:** os 7 passos estão comentados no script. Para mostrar um passo, troca o `LinkCapacities` (e a rota do fluxo 3, se indicado) e corre outra vez. Sugestão para a aula: passos 3, 4 e 7.

## b) `b_simulacao/` → `source("ex14b.R")`
Corre o simulador do professor 10 vezes e dá média e IC a 95% de cada fluxo. Pode demorar alguns minutos (aparece "Replication k done" após cada réplica). Para uma corrida única: `source("cnet.R")`.

Parâmetros (`parameters.R`): capacidades `c(4,4,4,0,4)`; cada fluxo com `duration=1`, `rate=0.5` (ρ = 0,5), `bwd=1`; `endTime = 100000`; 10 réplicas.

Resultado esperado: cerca de **0,0016 em todos os fluxos**, com IC de ±0,0002 aproximadamente. Se ficar lento, baixa `endTime` no `parameters.R` ou `nRep` no `ex14b.R`.

## c) `c_prodbound/` → `source("prodbound.R")`
Resultado esperado:
```
Blocking probability of flow 1 = 0.001580
Blocking probability of flow 2 = 0.001580
Blocking probability of flow 3 = 0.003158
```

---

## Tabela final para o relatório (preenche a coluna da simulação)

| Fluxo | Reduced load (a) | Simulação (b), IC 95% | Product bound (c) |
|---|---|---|---|
| 1 | 0,00158 | ____ ± ____ | 0,00158 |
| 2 | 0,00158 | ____ ± ____ | 0,00158 |
| 3 | 0,00314 | ____ ± ____ | 0,00316 |

Se algum valor de a) ou c) não bater com o esperado, ou a simulação der erro, manda-me o output.

A explicação teórica de cada alínea (com os slides do `circnet`) está em `ex14_explicacao.md`.
