rm(list=ls())
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
searchkw="#dinner"
tweets <- twListToDF(searchTwitter(searchkw, n = 100, 
                                   geocode = paste0(40.75, ",", -74, ",10km")))
tweets$created <- as.character(tweets$created)
tweets <- tweets[!is.na(tweets[, "longitude"]), ]
map = leaflet() %>% addTiles() %>%
  addMarkers(as.numeric(tweets$longitude), as.numeric(tweets$latitude), popup = tweets$screenName) %>%
  setView(40.75, -74, zoom = 11)

