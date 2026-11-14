# Ex. 12 – Kleinrock vs simulação (2 links em série)

## Cenário
2 links em série, C = 64 kb/s, pacotes exponenciais de média 1000 bits → μ = 64 pacotes/s. Um fluxo de Poisson com λ = ρ·μ passa pelos dois links.

## Método
- **Kleinrock:** cada link é M/M/1 com a mesma λ, logo **W = 2 / (μ − λ)**.
- **Simulação:** `pnet.R` (sem alterar o simulador), com rota `c(1,2)`, `endTime = nPkts/λ` e várias réplicas independentes. Reporta-se a média e o intervalo de confiança a 95%. O script `ex12.R` faz tudo isto.

## Resultados (atraso médio, em s)
| ρ | Kleinrock | Simulação (IC 95%) | Erro relativo |
|---|---|---|---|
| 0,05 | 0,0329 | 0,0335 ± 0,0001 | −1,7% |
| 0,5 | 0,0625 | 0,0646 ± 0,0002 | −3,3% |
| 0,95 | 0,625 | 0,403 ± 0,006 | +55% |
| 0,975 | 1,25 | 0,731 ± 0,021 | +71% |

> ⚠️ Estes valores vêm de uma simulação equivalente que fiz em Python (recursão de Lindley, 20 réplicas, ignorando 10% iniciais), porque não tenho R. **Corre o `ex12.R` e usa os teus números na tabela do relatório**; devem ser semelhantes.

## Conclusão
- **ρ baixo (0,05 e 0,5):** a aproximação é muito boa (erro de poucos %). Quase não há filas, e o atraso é dominado pelos tempos de transmissão.
- **ρ alto (0,95 e 0,975):** Kleinrock **sobrestima** muito o atraso (+55% a +71%).
- **Razão:** o 2.º link não é M/M/1. O pacote tem o mesmo tamanho nos dois links, por isso a sua chegada ao 2.º link está correlacionada com o tamanho. Um pacote só chega ao 2.º link depois de ser transmitido no 1.º, por isso quase não espera lá. O 1.º link já é M/M/1 exato, e o 2.º contribui com bem menos do que 1/(μ−λ).
- **Em resumo:** Kleinrock é uma aproximação por excesso, ou seja, conservadora. É precisa com carga baixa e moderada, e pouco precisa com carga alta.
