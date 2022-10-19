data.frame("site_id" = c(1,rep.int(1:3, time = 10)),
           "chick_weight" = runif(n = 31, min = 30, max = 100),
           "transimtter_weight" = runif(n = 31, min = 1.3, max = 1.8),
           "age" = runif(31, min = 7, max = 13),
           "fbs_35" = c(rep(T, 15), rep(F, 16)))