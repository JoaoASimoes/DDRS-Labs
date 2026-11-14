# Ex. 13a – Atraso médio da rede (Kleinrock)

## Dados
Todos os links: C = 256 kb/s, pacotes de média 1000 bits → **μ = 256 pacotes/s** por link.

Numeração dos links (ids contíguos): 1: 1-2 · 2: 2-4 · 3: 4-6 · 4: 1-3 · 5: 3-5 · 6: 5-6 · 7: 2-5.

## Cálculo
Cada link é uma M/M/1 com W = 1/(μ − λ) e L = λ/(μ − λ).

| Link | Fluxos | λ (pkt/s) | W (ms) | L |
|---|---|---|---|---|
| 1-2 | 1 | 215 | 24,39 | 5,244 |
| 2-4 | 1 | 215 | 24,39 | 5,244 |
| 4-6 | 1 | 215 | 24,39 | 5,244 |
| 1-3 | 2, 3 | 192 | 15,63 | 3,000 |
| 3-5 | 2, 3 | 192 | 15,63 | 3,000 |
| 5-6 | 3 | 128 | 7,81 | 1,000 |
| 2-5 | 4 | 128 | 7,81 | 1,000 |

- Nº médio de pacotes na rede: L = 3×5,244 + 2×3 + 1 + 1 = **23,73 pacotes**
- Taxa total: γ = 215 + 64 + 128 + 128 = **535 pacotes/s**
- **Atraso médio na rede: W = L/γ = 23,73 / 535 ≈ 0,0444 s = 44,4 ms**

Atraso de cada fluxo (soma dos W dos links da rota): fluxo 1 = 73,2 ms · fluxo 2 = 31,3 ms · fluxo 3 = 39,1 ms · fluxo 4 = 7,8 ms.
(Confirmação: média pesada pelas taxas = (215·73,17 + 64·31,25 + 128·39,06 + 128·7,81)/535 = 44,4 ms.)

## Comentário
O fluxo 1 domina: os seus 3 links têm ρ = 215/256 ≈ 0,84 (os mais carregados). Isto sugere que desviar parte do fluxo 1 (alínea c) deve reduzir o atraso.

## Script
`ex13a.R` usa a função `kleinrock()` do ex. 11 com os mesmos dados.
