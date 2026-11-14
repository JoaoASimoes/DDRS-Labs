# Ex. 11 – Aproximação de Kleinrock

## Ideia
Cada link da rede é tratado como uma fila **M/M/1 independente** (chegadas de Poisson, pacotes de tamanho exponencial). É exato no 1.º link; nos seguintes é uma aproximação, porque o tempo de transmissão dos pacotes correlaciona tamanhos e chegadas, o que viola o M/M/1.

## Cálculo
1. **λ de cada link** = soma das taxas dos fluxos que passam nesse link.
2. **μ de cada link** = C / tamanho médio do pacote (pacotes/s).
3. **Por link:** atraso W = 1/(μ − λ) e nº médio de pacotes L = λ/(μ − λ).
4. **(i) Atraso de cada fluxo** = soma dos W dos links da sua rota.
5. **(ii) Nº médio de pacotes na rede** = soma dos L de todos os links.
6. **(iii) Atraso médio na rede** = L / γ (lei de Little), com γ = soma das taxas de todos os fluxos.

Se algum link tiver λ ≥ μ, a rede é instável e o script pára com erro.

## Script
- Usa as mesmas estruturas do `pnet.R`: vetor `LinkCapacities` e lista `Flows` (campos `rate`, `packetsize`, `route`).
- É genérico: aceita qualquer topologia e qualquer conjunto de fluxos, porque as rotas são vetores de índices de links.
- Se os fluxos tiverem tamanhos de pacote diferentes, usa a média ponderada pelas taxas em cada link.

## Testes (cálculo à mão)
| Teste | Resultado |
|---|---|
| 1 link, λ = 32, C = 64 kb/s, Lp = 1000 b | W = 0,03125 s; L = 1 |
| 2 links em série | W = 0,0625 s; L = 2 |
| 3 links, 2 fluxos (1-2 e 2-3, λ = 16 cada) | W de cada fluxo = 0,0521 s; L = 5/3; W rede = 0,0521 s |
| Rede do `parameters.R` | fluxos: 0,0006 / 0,0008 / 0,0004 s; L = 14,5; W rede = 0,000644 s |
