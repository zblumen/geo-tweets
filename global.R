library(leaflet)
library(twitteR)
tokendf = read.csv("/home/zach/Documents/geo-tweet-token.txt",row.names=1,as.is=TRUE)
# OAuth authentication
consumer_key <- tokendf["Consumer Key (API Key)",]
consumer_secret <- tokendf["Consumer Secret (API Secret)",]
access_token <- tokendf["Access Token",]
access_secret <- tokendf["Access Token Secret",]
options(httr_oauth_cache = TRUE) # enable using a local file to cache OAuth access credentials between R sessions
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
