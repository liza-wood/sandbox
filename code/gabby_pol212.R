library(readr)
dst <- read_csv("~/Desktop/POL212/dst.csv") 
colnames(dst)
library(ggplot2)
library(dplyr)

# remove NAs
dst <- dst %>%
  na.omit()

## LW: So I assume n_true is the variable you made but I don't have it in my data, so based on what you wrote it seems like is is the number of science and mgmt themes? So I made that... but my model results are a little different than yours, so maybe I made it differently
library(stringr)
sci_cols <- which(str_detect(colnames(dst), 'sci_'))
mgmt_cols <- which(str_detect(colnames(dst), 'mgmt_'))
dst$n_scithemes <- rowSums(dst[,sci_cols])
dst$n_mgmtthemes <- rowSums(dst[,mgmt_cols])
dst$n_true <- rowSums(dst[c('n_scithemes','n_mgmtthemes')])

# create df 
## LW: Not necessary, already a df
# dst.df <- data.frame(dst)

# linear regression, effect of basically # trues and project length on funding
dst.lm <- lm(funds_numeric ~ n_true + n_years, data = dst)
summary(dst.lm)

stargazer::stargazer(dst.lm, 
          column.sep.width="1pt", font.size="small", digits=2,
          title = "Effect of Interdisciplinarity on Funding Allocation",
          dep.var.labels = c("Funding Allocation"),
          covariate.labels = c("Interdisciplinarity", "Project Length"),
          star.cutoffs = c(0.05, 0.01, 0.001), type = "text")

library(interflex)

ols.interaction.binning <- interflex(estimator = "binning", Y = "funds_numeric", D = "n_years", X = "n_true", data = as.data.frame(dst))
plot(ols.interaction.binning)

# moderators are more like controls, and treatments are the thing you're really interested in, right? So shouldn't they be reversed?
ols.interaction.binning2 <- interflex(estimator = "binning", Y = "funds_numeric", X = "n_years", D = "n_true", data = as.data.frame(dst))
plot(ols.interaction.binning2)

# Here are my thoughts: 
## 1. If we look at take 2 of those marginal effects (ols.interaction.binning2), it does look like n years is mediating in some way. We have some variation acorss the bin (low, high, low). But there are some weird stuff it looks like with the data before running down thta path
## Basically, it looks like there is something up with the relationship between funding and n_years after a certain threshold
ggplot(dst, aes(x = n_years, y = funds_numeric)) +
  geom_point()
# So ^^, we see something weird. All of the really long projects are not even funded
# When we truncate it at a certain year limit, we can see how there is a climb but then a long drop/flattening...
ggplot(dst, aes(x = n_years, y = funds_numeric)) +
  geom_point() +
  geom_smooth()

# This is likely because there are a lot of funded projects, and they are all the long-term ones. So we should do something about that

## 2. This related to the second thought. The model results give me a weird indiciation: there is a negative coef for n_years, saying more time the less money. May be worth actually removing those with zero funding (there is kind of a lot)

dst_funded <- dplyr::filter(dst, funds_numeric > 200) # there is one with 123$ funding, which seems just like a mistake
ggplot(dst_funded, aes(x = n_years, y = funds_numeric)) +
  geom_point() +
  geom_smooth(method = 'lm')
# This ^^ seems way more reasonable
# So what does this model say?
dst.lm2 <- lm(funds_numeric ~ n_true + n_years, data = dst_funded)
summary(dst.lm2)
# So, there is an effect of years, but none for interdisc, at least not when pairs with years
## On its own, maybe
dst.lm2a <- lm(funds_numeric ~ n_true, data = dst_funded)
summary(dst.lm2a)

ggplot(dst_funded, aes(x = n_true, y = funds_numeric)) +
  geom_point() +
  geom_smooth(method = 'lm')

# So no, there really isn't an interaction effect... or at least we don't have enough data to see it. It is sensible that the longer the projects, the more complex, the more the money, and it all gets a bit hard to disentangle.  
ols.interaction.binning3 <- interflex(estimator = "linear", Y = "funds_numeric", D = "n_years", X = "n_true", data = as.data.frame(dst_funded))
plot(ols.interaction.binning3)

ols.interaction.binning4 <- interflex(estimator = "binning", Y = "funds_numeric", X = "n_years", D = "n_true", data = as.data.frame(dst_funded))
plot(ols.interaction.binning4)


pp_df <- with(dst_funded, data.frame(n_years = median(n_years), 
                                     n_true = 1:max(dst_funded$n_true)))

# Using predict function to get predicted probabilities, with standard errors
pp_pred <- cbind(pp_df, predict(dst.lm2, 
                                newdata = pp_df, type = "response", se=TRUE))
