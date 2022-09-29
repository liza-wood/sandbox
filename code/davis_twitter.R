# Main packages for scraping and data wrangling
library(rtweet)

consumer_key <- "5Ksu3KltXDdNMYPeeauKQZ21H"
consumer_secret <-"lG0CEPzZLN55yMHuy6e5pWRiR6CdEAh6dWBIo2hGjo299NMh58"
access_token <- "2737151198-EPbvpcB9TstDRAdw3HyuVNW1CWsv6lJxUAjbABu"
access_secret <- "t566GrMlfu34qNM6goEuUctlHN5rFmvcb2V8MgAC0Gs1S" 
#token_twitteR = setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
app_name = "agCSS" # this is the app name in Twitter under my Twitter developer account
token_rtweet <- create_token(app_name, consumer_key, consumer_secret, access_token, access_secret)

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

