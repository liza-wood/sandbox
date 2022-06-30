library(dplyr)
library(stringr)
library(ggraph)
library(igraph)

df <- read.csv("data/sn_resilience.csv")

# Need to get each author into their own cell
## First determine how many author columns we need
df$n_author <- str_count(df$Author, ";")+1
## Separate into that many columns, separated by ;
df <- separate(df, Author, into = paste0("author", seq(1:max(df$n_author))), sep = ";")

## Let's try to make names uniform because something there is a full first name and other times there is a single letter. So lets default to a single letter by asking regex to take only the first letter after the common
remove_firstname <- function(x){
  str_remove(x, "(?<=, \\w{1}).*")
}
## Use this to identify which columns we want to apply this function to
author_cols <- which(str_detect(colnames(df), "author\\d"))
df[,author_cols] <- sapply(df[,author_cols], remove_firstname)
## Also just trim some white space to make sure we're all uniform
df[,author_cols] <- sapply(df[,author_cols], trimws)


# Create bipartite network of papers and authors
## Pivoting to get an edgelist of authors and papers
edges <- df %>% 
  tidyr::pivot_longer(cols = colnames(df[,author_cols]), 
                                       names_to = "author.n", values_to = "author") %>% 
  filter(author != "") %>% select(author, Title)

## Identify your nodes
nodes <- edges %>% select(author) %>% unique()

## There are probably cleaner ways to get this into matrix form but this is cheap and easy
## Graph from bipartite edgelist
graph <- graph.data.frame(edges)
## Get the adjacency matrix
adj <- igraph::get.adjacency(graph, sparse = F)
## Project it is go from bipartite to unimode
mat <- adj %*% t(adj) 
## Replace diagonals with zero because self-loops don't make sense here
diag(mat)=0
## Want to remove the paper titles now, so identify the paper columns (which are also the row numbers) and remove them from the matrix
paper_nums <- which(!(colnames(mat) %in% nodes$author))
mat <- mat[-paper_nums,-paper_nums]


# Map authorship
graph <- graph_from_adjacency_matrix(mat)
## Thinking through isolates here: An isolate would mean someone who has no co-authors in this database; So someone who single authored a paper and never authored with anyone else in this database. You may or may not want to remove this. I'm going to.
iso <- which(degree(graph) == 0)
graph <- delete.vertices(graph, iso)

## We can look at this all at once, but there are probably loads of components
V(graph)$deg <- log(igraph::degree(graph, mode = "all"))

ggraph(graph, layout = "stress", bbox = 18) +
  geom_edge_link(width = 1, alpha = 0.2, color = "gray50") +
  geom_node_point(size = V(graph)$deg, color = "darkblue", alpha = 0.5) + 
  theme_void() +
  theme(text= element_text(size=10, family="Times"),
        legend.position = "none") 
## Yep, lots of components that are for just each paper, meaning these authors are connected based on their publication together on one paper, but nothing more. 

# Let's take a look at your components and try to pull out the interesting ones
V(graph)$comp <- igraph::components(graph)$membership
## Lots of clusters. Let's look at 12 since they have the most
table(V(graph)$comp)
## Subsetting component 12
comp12 <- induced_subgraph(graph, V(graph)$comp == 12)

# Degree centrality here is not very interesting because it will gravitate towards papers with the most authors (have lots of co-authors on one paper will jack up your degree centrality); betwenness is probably more interesting
V(comp12)$bw <- log(igraph::betweenness(comp12))
table(V(comp12)$bw)
V(comp12)$label <- ifelse(V(comp12)$bw > 8, V(comp12)$name, "")

ggraph(comp12, layout = "stress", bbox = 18) +
  geom_edge_link(width = 1, alpha = 0.2, color = "gray50") +
  geom_node_point(size = V(comp12)$deg, color = "darkblue", alpha = 0.5) + 
  geom_node_text(aes(label = V(comp12)$label)) +
  theme_void()

# Just for fun, what about the next largest component?
table(V(graph)$comp)
## Subsetting component 4
comp4 <- induced_subgraph(graph, V(graph)$comp == 4)
V(comp4)$bw <- log(igraph::betweenness(comp4))
table(V(comp4)$bw)
V(comp4)$label <- ifelse(V(comp4)$bw > 6, V(comp4)$name, "")

ggraph(comp4, layout = "stress", bbox = 18) +
  geom_edge_link(width = 1, alpha = 0.2, color = "gray50") +
  geom_node_point(size = V(comp4)$deg, color = "darkblue", alpha = 0.5) + 
  geom_node_text(aes(label = V(comp4)$label)) +
  theme_void()

#Who is the most between author? (Connector?)
V(graph)$bw <- betweenness(graph)
bw <- data.frame(V(graph)$bw, V(graph)$name)
colnames(bw) <- c("bw_score", "author")


# Because it is already in this script and could be fun --- topic modelling the article titles
library(tidytext)
library(topicmodels)
library(textstem)

# Tokenize each word in the title and lemmatize it to take only its stem, remove stop words and remove numbers
df.title <- df %>% 
  unnest_tokens(word, Title) %>% 
  filter(!word %in% stop_words$word) %>% 
  filter(!(str_detect(word, "\\d"))) %>% 
  select(Key, word)
lemmas <- tibble(word = unique(df.title$word))
lemmas$lemma <- lemmatize_words(lemmas$word)
df.title <- left_join(df.title, lemmas) 

## Create a DTM (document term matrix) 
c_dtm <- df.title %>% 
  group_by(Key) %>% 
  count(lemma) %>% 
  cast_dtm(Key, lemma, n)

# How many topics do we want?
library(ldatuning)
topic_number <- FindTopicsNumber(c_dtm, 
                  topics = seq(from = 5, to = 25, by = 1),
                  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
                  method = "Gibbs",
                  control = list(alpha = .2),
                  mc.cores = NA,
                  verbose = TRUE)

# Woof, it looks like maybe 10-13. 
FindTopicsNumber_plot(topic_number)

# Let's make a topic model
tm <- LDA(c_dtm, k = 10, control = list(alpha = .2))
## Function for plotting the top N words in each topic
topics_n <- function(lda, n) {
  tidy(lda, matrix = "beta") %>% 
    group_by(topic) %>% top_n(n, beta) %>%
    ggplot(aes(x = reorder(term, beta), y = beta, fill = topic)) + #fill = term
    geom_col() + coord_flip() + guides(fill = FALSE) +
    scale_color_brewer() + 
    facet_wrap(vars(topic), ncol = 5, scales = "free") +
    theme_minimal(base_size = 12) +
    scale_y_continuous(labels = c()) +
    labs(title = "Top words by topic", 
         x = "Word", y = "Beta")
}
topics_n(tm, 5)

# How does each word map to each topic? This is the beta value of the tm
topics <- tidy(tm, matrix = "beta")
## These are probabilities -- all words have some percentage of being in a topic, and add up to one. See next line:
topics %>% group_by(topic) %>% summarize(total = sum(beta))
## This assignments the word in each paper to a topic
aug <- augment(tm, data = c_dtm)

## Gamma will tell us the probability that a title falls into each topic
titles <- tidy(tm, matrix = "gamma") 
## Again, these add up to zero
titles %>% group_by(document) %>% summarize(total = sum(gamma))

## You can identify the most likely topic for each paper
top_gamma <- titles %>% 
  group_by(document) %>% 
  filter(gamma == max(gamma))
top_gamma$document <- as.numeric(top_gamma$document)

