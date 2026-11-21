# Ex. 14 – Rede de comutação de circuitos

## Dados e numeração dos links
- Cada chamada ocupa b = 64 kb/s = 1 circuito. Carga oferecida de cada fluxo: ρ = 0,5 Erlang.
- Numeração dos links (a mesma do `LinkCosts` por defeito do `reducload_cost.R`):

| Id | Link | Custo/circuito |
|---|---|---|
| 1 | 1-2 | 500 € |
| 2 | 2-3 | 500 € |
| 3 | 1-4 | 100 € |
| 4 | 2-4 | 1000 € |
| 5 | 4-3 | 100 € |

## Teoria (slides `circnet`)
- **Erlang B** (anotação no slide 39): bloqueio de um link com C circuitos e carga ρ, ER(ρ, C) = (ρ^C / C!) / Σᵢ₌₀..C (ρ^i / i!). É a função `erlB.R`.
- **Product bound** (slides 38–40): carga do link = soma das cargas dos fluxos que o atravessam; bloqueio do fluxo B_k ≤ 1 − Π(1 − ER(ρ̄ⱼ, Cⱼ)). Assume bloqueio independente de link para link. Dá um **limite superior**.
- **Reduced load** (slides 42–46): a carga oferecida ao link j é reduzida pelo bloqueio nos *outros* links da rota: Lⱼ = ER(Σ ρ_k Π(1 − Lᵢ), Cⱼ). São equações de ponto fixo, resolvidas por **substituições repetidas** (slide 46). Bloqueio do fluxo B_k ≈ 1 − Π(1 − Lⱼ) (slide 44).
- **Limitação** (slide 41): com um único fluxo a atravessar J links de capacidade C, o bloqueio exato é ER(ρ, C) para qualquer J, mas o product bound dá 1 − (1 − ER(ρ, C))^J.

## a) Rotas e capacidades ótimas (`reducload_cost.R`)

**Rotas:** escolhe-se o caminho mais barato por circuito.
- Fluxo 1 (1→2): link 1 (500 €) em vez de 1-4-2 (1100 €).
- Fluxo 2 (2→3): link 2 (500 €) em vez de 2-4-3 (1100 €).
- Fluxo 3 (1→3): links 3 e 5, via nó 4 (200 €), em vez de 1-2-3 (1000 €).

**Tentativa e erro** (bloqueios por reduced load, guiado pelos bloqueios de cada link):

| Passo | Capacidades (links 1..5) | Rota fluxo 3 | Bloqueio fluxos 1 / 2 / 3 | Custo | OK? |
|---|---|---|---|---|---|
| 1 | 2, 2, 0, 0, 0 | 1-2-3 | 17,8% / 17,8% / 32,5% | 2000 € | não |
| 2 | 4, 4, 0, 0, 0 | 1-2-3 | 1,50% / 1,50% / 2,99% | 4000 € | não |
| 3 | 5, 5, 0, 0, 0 | 1-2-3 | 0,31% / 0,31% / 0,61% | 5000 € | sim |
| 4 | 3, 3, 3, 0, 3 | 1-4-3 | 1,27% / 1,27% / 2,44% | 3600 € | não |
| 5 | 4, 4, 3, 0, 3 | 1-4-3 | 0,16% / 0,16% / 2,44% | 4600 € | não |
| 6 | 4, 4, 4, 0, 3 | 1-4-3 | 0,16% / 0,16% / 1,41% | 4700 € | não |
| **7** | **4, 4, 4, 0, 4** | **1-4-3** | **0,158% / 0,158% / 0,314%** | **4800 €** | **sim** |

**Solução ótima: 4 circuitos (256 kb/s) nos links 1-2, 2-3, 1-4 e 4-3; nada no 2-4; custo 4800 €.**
Com 3 circuitos em qualquer link o bloqueio passa 1% (ER(0,5; 3) = 1,27%), e a rota 1-2-3 obriga a 5 circuitos nos links caros (5000 €). Confirmei por pesquisa exaustiva (todas as rotas, 0 a 8 circuitos por link) que 4800 € é o mínimo.

## b) Simulação (`cnet.R`)
**Parâmetros** (`parameters.R` do cnet): `LinkCapacities = c(4,4,4,0,4)`; cada fluxo com `duration = 1`, `rate = 0,5` (ρ = 0,5 Erlang), `bwd = 1` e as rotas da alínea a); `endTime = 50000·(1/0,5) = 100000` (≈50 000 chamadas por fluxo). O script `ex14b.R` corre 10 réplicas e calcula o IC a 95%.

Valores esperados (simulação própria, 10 réplicas, IC 95%; **substitui pelos teus**):

| Fluxo | Reduced load | Simulação |
|---|---|---|
| 1 | 0,158% | 0,155% ± 0,008% |
| 2 | 0,158% | 0,161% ± 0,010% |
| 3 | 0,314% | **0,158% ± 0,006%** |

**A simulação é mais fiável.**
- Fluxos 1 e 2 (um só link): coincidem, porque aí Erlang B é exato.
- Fluxo 3: o reduced load dá o **dobro** do real. Os links 1-4 e 4-3 só transportam o fluxo 3, por isso têm *sempre* a mesma ocupação: o bloqueio não é independente de link para link, ao contrário do que a aproximação assume (slides 43–44). A rota comporta-se como um único link de 4 circuitos, com bloqueio exato ER(0,5; 4) = 0,158%. É o caso do slide 41.
- O bloqueio é muito pequeno, por isso a simulação precisa de runs longos para ter poucas chamadas bloqueadas com IC estreito.

## c) Product bound (`prodbound.R`)

| Fluxo | Product bound | Reduced load | Simulação |
|---|---|---|---|
| 1 | 0,158% | 0,158% | ≈0,155% |
| 2 | 0,158% | 0,158% | ≈0,161% |
| 3 | 0,316% | 0,314% | ≈0,158% |

- Fluxos 1 e 2: os três métodos coincidem (um só link, não há carga a reduzir).
- Fluxo 3: o product bound é ligeiramente maior do que o reduced load, porque não reduz a carga. Com bloqueios tão pequenos a redução quase não muda nada.
- Confirma o slide 38: é um limite superior, bom quando as rotas têm poucos links e os bloqueios são pequenos. Mas, tal como o reduced load, sobrestima o fluxo 3 por assumir independência entre links (slide 41).

## Conclusão
- Compensa encaminhar o fluxo 3 pelo caminho mais longo mas mais barato (via nó 4).
- Reduced load e product bound são rápidos e conservadores; a simulação é a referência.
