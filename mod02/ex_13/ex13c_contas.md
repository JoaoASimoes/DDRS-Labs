# Ex. 13 c) Bifurcação ótima do fluxo 1 (cálculos à mão)

## 1. Dados

- Todas as ligações: C = 256 kb/s
- Tamanho médio dos pacotes: L_p = 1000 bits

| Fluxo | Rota | λ (pacotes/s) |
|---|---|---|
| 1 | 1-2-4-6 **ou** 1-2-5-6 (bifurcável) | 215 |
| 2 | 1-3-5 | 64 |
| 3 | 1-3-5-6 | 128 |
| 4 | 2-5 | 128 |

**Taxa de serviço de cada ligação**

Fórmula:

$$\mu = \frac{C}{L_p}$$

Cálculo:

$$\mu = \frac{256000}{1000} = 256 \text{ pacotes/s}$$

**Total de pacotes que entram na rede**

Fórmula (soma das taxas de todos os fluxos):

$$\gamma = \sum_{k} \lambda_k$$

Cálculo:

$$\gamma = 215 + 64 + 128 + 128 = 535 \text{ pacotes/s}$$

## 2. Variáveis

O fluxo 1 divide-se em:

- x1 pela rota A: 1-2-4-6 (ligações 1-2, 2-4, 4-6)
- x2 pela rota B: 1-2-5-6 (ligações 1-2, 2-5, 5-6)

Restrições:

$$x_1 + x_2 = 215, \qquad x_1 \ge 0, \quad x_2 \ge 0$$

## 3. Função a minimizar

**Porquê L e não W**

Fórmula (lei de Little):

$$W = \frac{L}{\gamma}$$

Como γ = 535 é constante, minimizar o atraso médio W é o mesmo que minimizar L, o número médio de pacotes na rede.

**Número médio de pacotes na rede (aproximação de Kleinrock)**

Fórmula (cada ligação é uma fila M/M/1; somam-se todas):

$$L = \sum_{\text{ligações } (i,j)} \frac{\lambda_{ij}}{\mu - \lambda_{ij}}$$

onde λ_ij é a soma das taxas dos fluxos que passam na ligação (i,j).

Carga de cada ligação em função da divisão:

| Ligação | Carga λ_ij (pacotes/s) | Depende de x1, x2? |
|---|---|---|
| 1-2 | 215 | não (as duas rotas passam lá) |
| 2-4 | x1 | sim |
| 4-6 | x1 | sim |
| 2-5 | 128 + x2 (fluxo 4 + parte do fluxo 1) | sim |
| 5-6 | 128 + x2 (fluxo 3 + parte do fluxo 1) | sim |
| 1-3 | 64 + 128 = 192 | não |
| 3-5 | 64 + 128 = 192 | não |

Substituindo na fórmula de L, e juntando numa constante as ligações que não dependem da divisão:

$$L(x_1, x_2) = 2\,\frac{x_1}{256 - x_1} + 2\,\frac{128 + x_2}{256 - (128 + x_2)} + \text{constante}$$

$$L(x_1, x_2) = 2\,\frac{x_1}{256 - x_1} + 2\,\frac{128 + x_2}{128 - x_2} + \text{constante}$$

## 4. Derivadas

Fórmula (derivada do número de pacotes de uma ligação M/M/1 em ordem à sua carga):

$$\frac{d}{d\lambda}\left(\frac{\lambda}{\mu - \lambda}\right) = \frac{\mu}{(\mu - \lambda)^2}$$

Aplicando a cada rota (cada rota tem 2 ligações cuja carga depende da divisão):

$$\frac{\partial L}{\partial x_1} = \frac{2 \cdot 256}{(256 - x_1)^2} \qquad \frac{\partial L}{\partial x_2} = \frac{2 \cdot 256}{(256 - (128 + x_2))^2} = \frac{2 \cdot 256}{(128 - x_2)^2}$$

## 5. Verificar se o ótimo usa as duas rotas

Regra (slides 26 a 28): se a derivada de uma rota é maior do que a da outra, compensa tirar tráfego da rota com derivada maior e dá-lo à de derivada menor.

Com todo o fluxo 1 pela rota A (x1 = 215, x2 = 0), como no 13 a), usando as fórmulas do passo 4:

$$\frac{\partial L}{\partial x_1} = \frac{512}{(256 - 215)^2} = \frac{512}{41^2} \approx 0{,}305$$

$$\frac{\partial L}{\partial x_2} = \frac{512}{(128 - 0)^2} = \frac{512}{128^2} \approx 0{,}031$$

A derivada da rota B é menor, por isso compensa passar tráfego da rota A para a rota B. O ótimo tem x1 > 0 e x2 > 0.

## 6. Condição de ótimo

Fórmula (slide 27: no ótimo, com as duas rotas usadas, as derivadas são iguais):

$$\frac{\partial L}{\partial x_1} = \frac{\partial L}{\partial x_2}$$

Substituindo as derivadas do passo 4:

$$\frac{2 \cdot 256}{(256 - x_1)^2} = \frac{2 \cdot 256}{(128 - x_2)^2}$$

$$(256 - x_1)^2 = (128 - x_2)^2$$

$$256 - x_1 = 128 - x_2 \quad \Rightarrow \quad x_1 = x_2 + 128$$

Juntando com a restrição x1 + x2 = 215:

$$(x_2 + 128) + x_2 = 215 \quad \Rightarrow \quad 2x_2 = 87 \quad \Rightarrow \quad x_2 = 43{,}5$$

$$x_1 = 215 - 43{,}5 = 171{,}5$$

**Bifurcação ótima: x1 = 171,5 pacotes/s (1-2-4-6) e x2 = 43,5 pacotes/s (1-2-5-6)**

Verificação (fórmulas do passo 4 com os valores ótimos): as derivadas ficam iguais

$$\frac{512}{(256 - 171{,}5)^2} = \frac{512}{84{,}5^2} \approx 0{,}0717 \qquad \frac{512}{(128 - 43{,}5)^2} = \frac{512}{84{,}5^2} \approx 0{,}0717$$

As ligações 2-4, 4-6, 2-5 e 5-6 ficam todas com 171,5 pacotes/s: como têm a mesma capacidade, o ótimo equilibra a carga entre elas.

## 7. Número médio de pacotes e atraso em cada ligação

Fórmulas (M/M/1):

$$L_{ij} = \frac{\lambda_{ij}}{\mu - \lambda_{ij}} \qquad W_{ij} = \frac{1}{\mu - \lambda_{ij}}$$

Cálculos (W_ij em ms = 1000 / (μ − λ_ij)):

| Ligação | λ_ij (pacotes/s) | μ − λ_ij | L_ij | W_ij (ms) |
|---|---|---|---|---|
| 1-2 | 215 | 41 | 215/41 = 5,244 | 1000/41 = 24,39 |
| 2-4 | 171,5 | 84,5 | 171,5/84,5 = 2,030 | 1000/84,5 = 11,83 |
| 4-6 | 171,5 | 84,5 | 2,030 | 11,83 |
| 1-3 | 192 | 64 | 192/64 = 3 | 1000/64 = 15,63 |
| 3-5 | 192 | 64 | 3 | 15,63 |
| 5-6 | 171,5 | 84,5 | 2,030 | 11,83 |
| 2-5 | 171,5 | 84,5 | 2,030 | 11,83 |

**Número médio de pacotes na rede**

Fórmula:

$$L = \sum_{(i,j)} L_{ij}$$

Cálculo:

$$L = 5{,}244 + 4 \times 2{,}030 + 2 \times 3 = 19{,}36 \text{ pacotes}$$

## 8. Atraso médio na rede

Fórmula (lei de Little):

$$W = \frac{L}{\gamma}$$

Cálculo:

$$W = \frac{19{,}36}{535} = 0{,}03619 \text{ s} = \mathbf{36{,}19 \text{ ms}}$$

## 9. Atraso de cada fluxo

Fórmula (atraso de um fluxo = soma dos atrasos das ligações da sua rota):

$$W_k = \sum_{(i,j) \in \text{rota}_k} W_{ij}$$

Cálculos:

- **Fluxo 1, rota A** (1-2, 2-4, 4-6): 24,39 + 11,83 + 11,83 = 48,06 ms
- **Fluxo 1, rota B** (1-2, 2-5, 5-6): 24,39 + 11,83 + 11,83 = 48,06 ms
- **Fluxo 2** (1-3, 3-5): 15,63 + 15,63 = **31,25 ms**
- **Fluxo 3** (1-3, 3-5, 5-6): 15,63 + 15,63 + 11,83 = **43,08 ms**
- **Fluxo 4** (2-5): **11,83 ms**

**Atraso do fluxo 1 bifurcado**

Fórmula (média dos atrasos das duas rotas, pesada pela taxa de cada uma):

$$W_1 = \frac{x_1 W_A + x_2 W_B}{x_1 + x_2}$$

Cálculo:

$$W_1 = \frac{171{,}5 \times 48{,}06 + 43{,}5 \times 48{,}06}{215} = \mathbf{48{,}06 \text{ ms}}$$

**Verificação do atraso médio na rede**

Fórmula (média dos atrasos dos fluxos, pesada pelas taxas, slide 19):

$$W = \frac{\sum_k \lambda_k W_k}{\sum_k \lambda_k}$$

Cálculo:

$$W = \frac{215 \times 48{,}06 + 64 \times 31{,}25 + 128 \times 43{,}08 + 128 \times 11{,}83}{535} = \frac{19361}{535} \approx 36{,}19 \text{ ms}$$

Dá o mesmo que o passo 8.

## 10. Comparação com o 13 a)

| | 13 a) sem bifurcação | 13 c) fluxo 1 bifurcado |
|---|---|---|
| Fluxo 1 | 73,17 ms | 48,06 ms |
| Fluxo 2 | 31,25 ms | 31,25 ms |
| Fluxo 3 | 39,06 ms | 43,08 ms |
| Fluxo 4 | 7,81 ms | 11,83 ms |
| L (rede) | 23,73 pacotes | 19,36 pacotes |
| **W (rede)** | **44,36 ms** | **36,19 ms** |

**Redução do atraso médio na rede**

Fórmula:

$$\text{Redução} = 1 - \frac{W_{13c}}{W_{13a}}$$

Cálculo:

$$\text{Redução} = 1 - \frac{36{,}19}{44{,}36} \approx 0{,}184 = \mathbf{18{,}4\,\%}$$

**Conclusão:** bifurcar o fluxo 1 alivia as ligações 2-4 e 4-6, que estavam quase cheias (215 de 256 pacotes/s). O fluxo 1 ganha muito, os fluxos 3 e 4 pioram um pouco (passam a partilhar 5-6 e 2-5 com parte do fluxo 1), o fluxo 2 não muda, e o atraso médio da rede desce 18,4%.
