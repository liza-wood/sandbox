# Main packages for scraping and data wrangling
library(rtweet)

# Twitter key hidden

davis_tweets <- rtweet::search_tweets(q= "the|a|.*", n=1000000, 
                      geocode = "38.5449,121.7405,15mi",
                      token = token_rtweet)


th <- getUser('bk_vaitla')
tweets <- get_timelines(user = 'bk_vaitla', n = 10000, 
                        token = token_rtweet)
following_df = bind_rows(lapply(th$getFriends(n = 5000, 
                                              retryOnRateLimit=3), 
                                as.data.frame))
followers_df = bind_rows(lapply(th$getFollowers(n = 5000, 
                                                retryOnRateLimit=3), 
                                as.data.frame))
friends <- unique(rbind(followers_df, following_df))

