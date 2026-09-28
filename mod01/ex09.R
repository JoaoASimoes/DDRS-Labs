setwd("C:/Users/fonse/OneDrive/Ambiente de Trabalho/MESTRADO/DDRS/Lab/DDRS-Labs/mod01")

df_yt <- read.csv("youtube.csv", header=TRUE)
df_dw <- read.csv("download.csv", header=TRUE)
df_id <- read.csv("idle.csv", header=TRUE)

# Extrair a coluna de "Length"
len_yt <- df_yt$Length
len_dw <- df_dw$Length
len_id <- df_id$Length

# 2. Remoçao pacotes afetados por TSO
# A função which() devolve os índices onde a condição é verdadeira.
# O sinal negativo [-] remove esses índices do vetor.
len_yt <- len_yt[-which(len_yt > 1514)]
len_dw <- len_dw[-which(len_dw > 1514)]

# Para o tráfego idle, pode não haver pacotes maiores que 1514, o que faria o which() 
# devolver integer(0) e o vetor ficar vazio. A validação length(which(...) > 0) previne esse erro.
if(length(which(len_id > 1514)) > 0) {
  len_id <- len_id[-which(len_id > 1514)]
}

# 3 Visualiçao
# par(mfrow=c(3,1)) agrupa os 3 gráficos na mesma janela numa coluna
par(mfrow=c(3,1), mar=c(4,4,2,1))

hist(len_yt, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="steelblue",
     main="Cenário A: YouTube Streaming", xlab="Tamanho (Bytes)", ylab="Frequência")

hist(len_dw, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="firebrick",
     main="Cenário B: Large File Download", xlab="Tamanho (Bytes)", ylab="Frequência")

hist(len_id, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="darkgray",
     main="Cenário C: Doing Nothing (Idle)", xlab="Tamanho (Bytes)", ylab="Frequência")