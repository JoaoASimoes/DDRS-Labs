Os três sistemas têm o mesmo E[S] = 2 e a mesma utilização (ρ = 0,5), mas diferem na variabilidade do serviço, C² = 1, 2,25 e 24,75.
Pela fórmula de Pollaczek-Khinchine, o atraso médio cresce com (1+C²) \[queuesys, slides do M/G/1, ~39–40; “Less variability, less delay”].
Por isso Wq vale 2, 3,25 e 25,75, e as simulações confirmam estes valores.

A tabela mostra que a variância das estimativas de Wq também cresce muito com C².
Cada estimativa é uma realização de uma variável aleatória, que pode ter variância elevada \[outdata, slide 28].
Neste caso, os serviços longos (11 ou 101) são raros: o número deles em cada corrida varia, e cada um provoca uma longa acumulação em fila.
O atraso médio de cada corrida oscila então muito.
\[Esta parte é raciocínio nosso, não vem dos slides; a tabela é que a confirma.]

A variância foi calculada com 100 réplicas independentes \[outdata, slides 30–31, método das replicações; variância: revprob, slide 23].
Com alta variabilidade, as estimativas ficam pouco fiáveis e o IC fica largo.
Para manter a precisão é preciso mais réplicas ou corridas mais longas \[outdata, slide 32, paragem por precisão do IC].
A variabilidade do tamanho dos jobs afeta, portanto, o atraso médio e também a fiabilidade e o custo da simulação.
