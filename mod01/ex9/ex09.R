# Os ficheiros CSV devem estar na mesma pasta que este script
df_yt <- read.csv("youtube.csv", header=TRUE)
df_dw <- read.csv("download.csv", header=TRUE)
df_id <- read.csv("idle.csv", header=TRUE)

# extrair Length
len_yt <- df_yt$Length
len_dw <- df_dw$Length
len_id <- df_id$Length

# remoção pacotes afetados por TSO
len_yt <- len_yt[-which(len_yt > 1514)]
len_dw <- len_dw[-which(len_dw > 1514)]

# Para o tráfego idle, pode não haver pacotes maiores que 1514
if(length(which(len_id > 1514)) > 0) {
  len_id <- len_id[-which(len_id > 1514)]
}

# guarda diretamente na pasta onde o script está a ser executado)
png("histogramas.png", width=800, height=800) 

par(mfrow=c(3,1), mar=c(4,4,2,1))

hist(len_yt, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="steelblue",
     main="Cenário A: YouTube Streaming", xlab="Tamanho (Bytes)", ylab="Frequência")

hist(len_dw, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="firebrick",
     main="Cenário B: Large File Download", xlab="Tamanho (Bytes)", ylab="Frequência")

hist(len_id, breaks=seq(0, 1600, by=50), xlim=c(0, 1600), col="darkgray",
     main="Cenário C: Doing Nothing (Idle)", xlab="Tamanho (Bytes)", ylab="Frequência")

dev.off()