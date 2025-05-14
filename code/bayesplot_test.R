library(viridis)
library(brms)
library(bayesplot)
mako_scheme <- mako(6)
mako_scheme <- stringr::str_remove_all(mako_scheme, "FF$")
color_scheme_set(mako_scheme)
color_scheme_view()
x <- brm(Sepal.Length ~ Petal.Length, data = iris)

