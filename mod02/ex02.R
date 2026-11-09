setwd("C:/Users/asus/OneDrive/Ambiente de Trabalho/Mestrado/Desempenho e Dimensionamento de Redes e Sistemas/Modulo 2")
getwd()  

# Estimacao das probabilidades de transicao de uma 2-DTMC (0 = nao atacado, 1 = atacado)
mydata = read.table("2dtmcdata.txt", sep = "\t")

# Converte o data frame num vetor com a sequencia diaria, por ordem
# (funciona quer os dados estejam numa coluna, quer numa linha)
x = as.vector(t(as.matrix(mydata)))
x = x[!is.na(x)]

# Pares (estado atual, estado seguinte) de dias consecutivos
atual   = x[-length(x)]
seguinte = x[-1]

# Contagem das transicoes: n_ij = numero de vezes que o estado i e seguido do estado j
n = table(factor(atual, levels = 0:1), factor(seguinte, levels = 0:1))

# Estimativa: p_ij = n_ij / (numero de transicoes que partem do estado i)
P = n / rowSums(n)

cat("Numero de dias:", length(x), "\n\n")
cat("Contagens das transicoes (linha = estado atual, coluna = estado seguinte):\n")
print(n)
cat("\nMatriz de probabilidades de transicao estimada:\n")
print(round(P, 4))