# Exercício 7c — Prioridade estrita com pacotes de tamanho fixo

## Parâmetros da simulação (1.º caso)

```r
parameters = function() {
  LinkCapacity<<-100e3
  Flows<<-list(list(sourcetype=2,arrivalrate=10,packetsize=1000,priority=1),   # alta prioridade
               list(sourcetype=2,arrivalrate=83,packetsize=1000,priority=2))   # baixa prioridade
  endTime<<-10000*(1/10)   # 1000 s
}
```
## Modelo teórico

O sistema é uma **M/D/1
- **M:** cada fluxo tem chegadas de Poisson.
- **D:** o tempo de serviço é fixo, S = L/C.

Fórmulas, com o atraso medido da chegada até ao fim da transmissão, como no `departures.R`:

| Grandeza | Fórmula |
|---|---|
| Tempo de serviço | S = L / C |
| Carga do fluxo 1 | ρ₁ = λ₁ · S |
| Carga total | ρ = (λ₁ + λ₂) · S |
| Tempo residual médio | W₀ = Σ λᵢ E\[Sᵢ²] / 2 = (λ₁ + λ₂) · S² / 2 = ρS/2 |
| Atraso do fluxo 1 (alta) | W₁ = W₀ / (1 − ρ₁) + S |
| Atraso do fluxo 2 (baixa) | W₂ = W₀ / ((1 − ρ₁)(1 − ρ)) + S |
| Atraso médio total | W = W₀ / (1 − ρ) + S (igual a FIFO M/D/1) |
| Throughput do fluxo i | λᵢ · L |

O que cada termo significa:

- **W₀** é o tempo que, em média, falta para acabar o pacote em transmissão quando chega um novo pacote. Com tamanho fixo, E\[S²] = S².
- **O fluxo 1** espera por W₀ e pelos pacotes de alta prioridade que já estão na fila. É isto que o fator 1/(1 − ρ₁) contabiliza.
- **O fluxo 2** espera também por todos os pacotes de alta prioridade que vão chegando entretanto, daí o fator extra 1/(1 − ρ).

## Justificação dos parâmetros escolhidos

### 1. C e L
S = L/C = 1000 / 100 000 = **0,01 s**, ou seja, μ = 100 pkt/s. Cada λ em pkt/s corresponde diretamente a uma percentagem de carga (λ₂ = 83 → 83%), o que facilita as contas.

### 2. Estabilidade
ρ = (10 + 83) × 0,01 = **0,93 < 1**, por isso o sistema é estável.

### 3. Condição W₂ ≥ 4·W₁ ⇒ ρ ≥ 0,9
Com W₀ = ρS/2:

- W₁ = S · \[1 + ρ / (2(1 − ρ₁))]
- W₂ = S · \[1 + ρ / (2(1 − ρ₁)(1 − ρ))]

Com ρ₁ = 0,1, impor W₂ ≥ 4W₁ dá:

1 + ρ / (1,8(1 − ρ)) ≥ 4 + 4ρ / 1,8

Multiplicando os dois lados por 1,8(1 − ρ):

1,8 − 0,8ρ ≥ 7,2 − 3,2ρ − 4ρ²  ⇒  ρ² + 0,6ρ − 1,35 ≥ 0

Logo:

**ρ ≥ (−0,6 + √5,76) / 2 = 0,9**

O `parameters.R` original (λ₁ = 10, λ₂ = 80) tem ρ = 0,9 e fica **exatamente** no limite (razão de 4,0). Com uma única corrida, a simulação pode dar menos de 4. Por isso escolheu-se **ρ = 0,93**, que dá margem e fica ainda longe de ρ = 1.

### 4. Porquê ρ₁ pequeno (0,1)
O fluxo prioritário só "vê" a sua própria carga ρ₁ e o pacote em transmissão (W₀). Com ρ₁ baixo, o seu atraso fica próximo de S, e quase toda a espera recai sobre o fluxo 2, através do fator 1/(1 − ρ). Isto maximiza a diferença entre os dois fluxos.

### 5. Porquê não ρ ainda mais perto de 1
Quando ρ → 1, W₂ → ∞ e a variância da estimativa cresce muito, o que obrigaria a simulações muito mais longas. Com ρ = 0,93 a diferença entre fluxos é clara e o tempo de simulação continua razoável.

### 6. endTime = 10000 / λ_min = 1000 s
Segue a regra do próprio `parameters.R`: o fluxo mais lento gera cerca de 10 000 pacotes, e o fluxo 2 cerca de 83 000. São amostras suficientes para estimar bem os dois atrasos.

## Valores teóricos

| | Cálculo | Valor |
|---|---|---|
| S | 1000 / 100 000 | 10 ms |
| ρ₁ | 10 × 0,01 | 0,10 |
| ρ | 93 × 0,01 | 0,93 |
| W₀ | 93 × 0,01² / 2 | 4,65 ms |
| **W₁ (alta)** | 4,65 / 0,9 + 10 | **15,17 ms** |
| **W₂ (baixa)** | 4,65 / (0,9 × 0,07) + 10 | **83,81 ms** |
| W total | 4,65 / 0,07 + 10 | 76,43 ms |
| **W₂ / W₁** | 83,81 / 15,17 | **5,53 ≥ 4 ✓** |

| Throughput teórico | Valor |
|---|---|
| Fluxo 1 | 10 × 1000 = 10 000 bit/s |
| Fluxo 2 | 83 × 1000 = 83 000 bit/s |
| Total | 93 000 bit/s |

## Conclusões

1. **A prioridade cumpre o objetivo.** O fluxo 1 tem um atraso cerca de 5,5 vezes menor, quase igual ao tempo de transmissão (15 ms face a 10 ms), como se a ligação estivesse só com 10% de carga.
2. **Tem um custo para o fluxo 2.** Em FIFO M/D/1 (alínea b), os dois fluxos teriam 76,4 ms. Com prioridade, o fluxo 1 desce para 15,2 ms e o fluxo 2 sobe para 83,8 ms.
3. **Lei de conservação de Kleinrock.** A média ponderada dos atrasos, (10 × 15,17 + 83 × 83,81) / 93 = 76,43 ms, é igual ao atraso em FIFO. A prioridade não reduz o atraso médio total; apenas o redistribui entre os fluxos.
4. **O fluxo 1 não tem atraso zero na fila.** Como o escalonamento é não-preemptivo, tem sempre de esperar que acabe o pacote em transmissão (termo W₀).
5. **O throughput não muda.** Com o sistema estável, cada fluxo mantém o throughput λᵢ · L. O escalonamento só altera a ordem pela qual os pacotes são servidos, não quantos são servidos.
