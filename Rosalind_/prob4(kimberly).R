n <- 28
k <- 5

repro_pairs <- 0
young_pairs <- 0
un_born <- 1

for (i in 1:n) {
  repro_pairs <- repro_pairs + young_pairs
  young_pairs <- un_born
  un_born <- k*repro_pairs
}

print(repro_pairs+young_pairs)
