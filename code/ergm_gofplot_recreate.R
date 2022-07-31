library(tidyverse)
library(statnet)
library(stringr)
setwd('~/Box/osa_networks/')

nodes <- read.csv("data_combined_3/net_nodes.csv") 
edges <- read.csv("data_combined_3/net_edges.csv")
net <- igraph::graph_from_data_frame(edges, vertices = nodes, directed = F)
mat <- as.matrix(igraph::get.adjacency(net))
noweight <- function(x){ifelse(x == 0, 0, 1)}
mat[,1:ncol(mat)] <- sapply(mat[,1:ncol(mat)], noweight)
net = network(x = mat,
              vertex.attr = nodes,
              directed = F)

m1 <- ergm(net ~ edges + 
                 gwdegree(.25, fixed = T) + 
                 gwesp(.25, fixed = T),
                 control = control.ergm(seed = 1992, parallel = 4,
                                      MCMLE.termination = 'Hummel',
                                      MCMLE.effectiveSize = NULL))

gof_obj <- gof(m1
gof_deg <- data.frame(gof_obj$summary.deg)
gof_deg$degree <- as.numeric(str_extract(rownames(gof_deg), "\\d+"))

gof_deg %>% 
  mutate(prop_obs = obs/sum(obs),
         prop_mean = mean/sum(obs),
         prop_min = min/sum(obs),
         prop_max = max/sum(obs)) %>% 
  filter(degree < 80) %>% 
  ggplot() +
  geom_errorbar(aes(x = degree, y = prop_mean, 
                    ymin = prop_min, ymax = prop_max),
                color = "gray", size = 1) +
  geom_point(aes(x = degree, y = prop_mean), 
             color = "blue", shape = 18, size = 3) +
  geom_point(aes(x = degree, y = prop_obs)) +
  geom_line(aes(x = degree, y = prop_obs)) +
  theme_classic() +
  labs(y = "proportion of nodes")