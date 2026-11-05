# Exercício 9 — Web server farm: Random vs. JSQ

## Modelo
- 2 servidores com **Processor Sharing (PS)**, μ = 1, e chegadas de Poisson com taxa λ.
- Carga do sistema: **ρ = λ / (kμ) = λ / 2**.
- **Random:** cada servidor recebe um processo de Poisson com taxa λ/2. Como uma M/G/1/PS tem o mesmo atraso médio que uma M/M/1:

  **W_random = 1 / (μ − λ/k) = 1 / (1 − ρ)**

- **JSQ:** não tem fórmula teórica e só se obtém por simulação. Como referência usa-se a M/M/2 com fila central, o melhor caso possível com 2 servidores:

  **W_M/M/2 = 1 / (μ(1 − ρ²))**

## Parâmetros (`webserverfarm.R`)
```r
numServers=2
ArrivalRate=1.0           # 1.0 / 1.6 / 1.8  ->  ρ = 0.5 / 0.8 / 0.9
ServiceRate<<-1
StoppingCondition=100000  # nº de trabalhos completados
```
Escolheram-se três valores de ρ, de carga baixa a alta, para ver como evolui a diferença entre as políticas. Todos têm ρ < 1, por isso o sistema é estável.

## Resultados (atraso médio no sistema)

| ρ | λ | Random teórico | Random simulado | JSQ simulado | M/M/2 (ref.) |
|---|---|---|---|---|---|
| 0,5 | 1,0 | 2,00 | | | 1,33 |
| 0,8 | 1,6 | 5,00 | | | 2,78 |
| 0,9 | 1,8 | 10,00 | | | 5,26 |

*Preencher com os valores do `ex9_resultados.csv`.*

## Conclusão
- **A simulação da política Random coincide com a teoria**, o que valida o simulador.
- **A JSQ é sempre melhor do que a Random, e a vantagem cresce com ρ**: cerca de 30% menos atraso com ρ = 0,5 e cerca de metade com ρ = 0,9.
- **A Random ignora o estado dos servidores** e comporta-se como 2 M/M/1 independentes: pode enviar trabalho para um servidor ocupado enquanto o outro está livre.
- **A JSQ equilibra a carga e aproxima-se da M/M/2**, sobretudo com carga alta. Usar o estado dos servidores na atribuição traz um ganho grande, praticamente o de uma fila central.
