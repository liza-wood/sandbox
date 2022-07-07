library(tidyverse)
df <- read.csv("data/interviews.csv")

edges <- df %>% 
  mutate(concept_idea = paste(type_of_concept, idea, sep = "_")) %>% 
  select(document.ID, concept_idea) %>% 
  unique()

V <- crossprod(table(edges[c(1,2)]))
diag(V) <- 0
V <- data.frame(V)
V <- select(V, -contains("C_"))
rownames(V)
ideas_cooccur <- slice(V, 1:29)

edges <- df %>% 
  mutate(concept_category = paste(type_of_concept, category, sep = "_")) %>% 
  select(document.ID, concept_category) %>% 
  unique()

V <- crossprod(table(edges[c(1,2)]))
diag(V) <- 0
V <- data.frame(V)
V <- select(V, -contains("C_"))
rownames(V)
concept_cooccur <- slice(V, 1:7)


# Does widening the data help?
wide <- df %>% 
  pivot_wider(names_from = type_of_concept, values_from = idea) %>% 
  select(document.ID, category, C, S)

wide %>% 
  group_by(document.ID, category, C) %>% 
  count()

wide %>% 
  group_by(document.ID, category, S) %>% 
  count()
