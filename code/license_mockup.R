#https://rintze.zelle.me/ref-extractor/ Can put paper into this and get the doc to a json, then...


df <- read.csv("data/license.csv")

colnames(df) <- c("social.return", seq(2000,2020, by = 1))
df <- df %>% pivot_longer(cols = c('2000':'2020'), names_to = "year", values_to = "value")

library(dplyr)
library(tidyr)
library(ggplot2)
ggplot(df, aes(x = year, y = value, color = social.return)) + 
  geom_line(aes(group = social.return)) +
  theme_classic() +
  labs(x = "Amount private funding", y = "Proportion of crops", color = "Social Return") +
  theme(axis.text.x = element_blank(),
        axis.ticks = element_blank()) +
  scale_color_manual(values=c("#ac83ac", "#2171b5", "#6baed6"))


## DAGS ----

library(dagitty)
library(rethinking)
dag <-dagitty("dag{
funding -> minorbreeding 
funding -> accessibility
minorbreeding  -> accessibility
}")
drawdag(dag)
adjustmentSets(dag, exposure="funding",outcome="accessibility")
impliedConditionalIndependencies(dag)
?adjustmentSets

dag <-dagitty("dag{
croptraits -> accessibility
croptype -> accessibility
}")
drawdag(dag)
adjustmentSets(dag, exposure="croptraits",outcome="accessibility")
impliedConditionalIndependencies(dag)

## BETA VS LOGIT ---- 

df <- data.frame(
  "access" = sample(0:1, 10000, replace = T),
  "funding" = seq(0.1, 0.8, length.out = 50)
)

library(dplyr)
df.agg <- df %>% 
  group_by(funding) %>% 
  summarize(access.avg = mean(access))

library(stats)
plant.level <- glm(access ~ funding, df, family = "binomial")

library(betareg)
lgu.level <- betareg(access.avg ~ funding, df.agg)

summary(plant.level)
plant.level$df.null
summary(lgu.level)
lgu.level$df.null

