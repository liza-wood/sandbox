
# Not everything is an object
is.object(c('a', 'b', 'c'))
is.object(9)
is.object(data.frame())

# objects are meant to 'encapsulate' complex data

library(palmerpenguins)
data("penguins")
is.object(penguins)

penguins_lm <- lm(body_mass_g ~ species + sex, data = penguins)
class(penguins_lm)
attr(penguins_lm, 'class')

summary(penguins_lm)
summary(penguins)

# S3 objects are very permissive
penguins_lm$mine = 14
penguins_lm$coefficients

# so permissive that you can overwrite basically anything
penguins_lm$coefficients <- "overwrite"

# Now summary doesn't know what to do with it
summary(penguins_lm)

library(lme4)
penguins_lme <- lmer( body_mass_g ~ species + sex + (1|island), 
                      data=penguins )
penguins_lme
penguins_lme@beta
# the preferred way to do the same:
slot(penguins_lme, "beta")
# this does not work
slot(penguins_lm, "coefficients")
penguins_lme@test = 5
summ <- summary(penguins_lme)