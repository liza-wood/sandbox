library(tidyverse)
df <- read.csv("data/interviews.csv")
#df <- interviews_no_frames
# created edgelist of documents and concepts
edges <- df %>% 
  mutate(concept_idea = paste(type_of_concept, category, idea, sep = "_")) %>% 
  select(document.ID, concept_idea) %>% 
  unique()

# create cross-tabulation using crossprod
V <- crossprod(table(edges[c(1,2)]))
diag(V) <- 0
V <- data.frame(V)
V <- select(V, -contains("C_"))
rownames(V)
ideas_cooccur <- slice(V, 1:29) # here separate challenges from solutions
#str(ideas_cooccur)

ideas_cooccur
upper.tri(ideas_cooccur)
?upper.diag

# some stringr work
colnames(ideas_cooccur) <- gsub('S_', '', colnames(ideas_cooccur))colnames(ideas_cooccur) <- gsub('\\.', ' ', colnames(ideas_cooccur))
rownames(ideas_cooccur) <- gsub('C_', '', rownames(ideas_cooccur))

# heatmap requires some manual work; see what categories you have in both rownames and colnames
table(rownames(ideas_cooccur))
table(colnames(ideas_cooccur))

# use same colors as in the boxplots, using viridis
library(scales)
library(viridisLite)
q_colors =  7 # catgories
v_colors =  viridis(q_colors)
v_colors # check exact colors
# choose color scheme for body of heatmap
library(RColorBrewer)
colors <- colorRampPalette(brewer.pal(8, "Purples"))(10)
# make heatmap 
library(gplots)
gplots::heatmap.2(as.matrix(ideas_cooccur), scale = 'none',
        col = colors,
        trace = "none", density.info = "none", # added these
        cexRow = 0.7, cexCol = 0.7, margins = c(11,11), 
        labRow = gsub(".*_", "", rownames(ideas_cooccur)),# fix rownames
        labCol = gsub(".*_", "", colnames(ideas_cooccur)),# fix colnames
        xlab = "Solutions", ylab = "Challenges",
        ColSideColors = c( #manually assign color to category
          RowSideColors = c(
            rep("#8FD744FF", 8), # Funding/Resources 
            rep("#440154FF", 8), # Institutions
            rep("#31688EFF", 8), # Leadership
            rep('#21908CFF', 4), # Local communities
            rep('#35B779FF', 6), # Planning
            rep('#FDE725FF', 2), # Regulation
            rep('#443A83FF', 4)) # Science
        ),
        RowSideColors = c(
          rep("#8FD744FF", 5), # Funding/Resources 
          rep("#440154FF", 8), # Institutions
          rep("#31688EFF", 6), # Leadership
          rep('#21908CFF', 4), # Local communities
          rep('#35B779FF', 1), # Planning
          rep('#FDE725FF', 2), # Regulation
          rep('#443A83FF', 3))) # Science
par(lend = 1)           # square line ends for the color legend
legend("topright",      # location of the legend on the heatmap plot
       legend = c("Funding/Resources", "Institutions", "Leadership", 
                  "Local communities", "Planning", "Regulation", "Science"), # category labels
       col = c("#8FD744FF", "#440154FF", "#31688EFF", "#21908CFF", "#35B779FF", 
               "#FDE725FF", "#443A83FF"),  # color key
       lty= 1,             # line style
       lwd = 10, # line width
       cex = .6
)

# this above works but I don't have the key for the values
# so I create a basic plot in ggplot
ideas_cooccur$id <- rownames(ideas_cooccur)
ic <- melt(ideas_cooccur, id.vars = "id")
colnames(ic) <- c("challenges", "solutions", "value")
ic$challenges <- gsub('C_', '', ic$challenges)
ic$solutions <- gsub('S_', '', ic$solutions)

library("ggplot2")
plot <- ggplot(ic, aes(x = challenges, y = solutions)) +
  geom_tile(aes(fill = value)) +
  scale_fill_gradient2() 

# and use cownplot to extract only the legend
library("cowplot")
legend <- get_legend(plot)

# next step: smack the ggplot legend onto heatmap
# how?


