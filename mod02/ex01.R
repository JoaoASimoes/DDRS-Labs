mydata=read.table("/home/simoes/Tecas/UCs/DDRS/Labs/DDRS-Labs/mod02/2dtmcdata.txt",sep="\t")

# Converter o data frame num vetor
x <- mydata[, 1]

# Estados atual e seguinte
current_state <- x[-length(x)]
next_state <- x[-1]

# Contar o número de transições
transition_counts <- table(current_state, next_state)

# Estimar as probabilidades de transição
transition_probabilities <- prop.table(
  transition_counts,
  margin = 1
)

# Mostrar contagens
cat("Transition counts:\n")
print(transition_counts)

# Mostrar matriz de probabilidades
cat("\nEstimated transition probabilities:\n")
print(transition_probabilities)

# Criar tabela final
results <- data.frame(
  From = c(0, 0, 1, 1),
  To = c(0, 1, 0, 1),
  Probability = c(
    transition_probabilities["0", "0"],
    transition_probabilities["0", "1"],
    transition_probabilities["1", "0"],
    transition_probabilities["1", "1"]
  )
)

cat("\nResults table:\n")
print(results)