num_experiments <- 1000
num_coins <- 5
prob_head <- 0.7


tosses <- matrix(
  runif(num_experiments * num_coins) < prob_head,
  nrow = num_experiments,
  ncol = num_coins
)

num_heads <- rowSums(tosses)
estimated_probability <- mean(num_heads == 2)

exact_probability <- dbinom(2, size = num_coins, prob = prob_head)

cat(sprintf("Simulation estimate (%d experiments): %.4f\n",
            num_experiments, estimated_probability))
cat(sprintf("Exact probability:                      %.4f\n",
            exact_probability))