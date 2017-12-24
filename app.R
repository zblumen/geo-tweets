library(leaflet)
library(twitteR)
ui = fluidPage(
    fluidRow(
      column(4, textInput("searchkw", label = "search:", value = "#dinner")),
      column(4, textInput("lat", label = "latitude:", value = 40.75)),
      column(4, textInput("long", label = "longitude:", value = -74)) 
    ),
    fluidRow(leafletOutput("myMap")),
    fluidRow(tableOutput("table"))       
    # column(8, leafletOutput("myMap")),
    # column(12, tableOutput('table'))
)
server = function(input, output) {
  # Issue search query to Twitter
  tokendf = read.csv("/home/zach/Documents/geo-tweet-token.txt",row.names=1,as.is=TRUE)
  # OAuth authentication
  consumer_key <- tokendf["Consumer Key (API Key)",]
  consumer_secret <- tokendf["Consumer Secret (API Secret)",]
  access_token <- tokendf["Access Token",]
  access_secret <- tokendf["Access Token Secret",]
  options(httr_oauth_cache = TRUE) # enable using a local file to cache OAuth access credentials between R sessions
  setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
  dataInput <- reactive({  
    tweets <- twListToDF(searchTwitter(input$searchkw, n = 100, 
                                       geocode = paste0(input$lat, ",", input$long, ",100km"))) 
    tweets$created <- as.character(tweets$created)
    tweets <- tweets[!is.na(tweets[, "longitude"]), ]
  })
  
  # Create a reactive leaflet map
  mapTweets <- reactive({
    map = leaflet() %>% addTiles() %>%
      addMarkers(as.numeric(dataInput()$longitude), as.numeric(dataInput()$latitude), popup = dataInput()$screenName) %>%
      setView(input$long, input$lat, zoom = 11)
  })
  output$myMap = renderLeaflet({mapTweets()})
  
  # Create a reactive table 
  output$table <- renderTable(
    {dataInput()[, c("screenName", "longitude", "latitude", "created")]}
  )
}


shinyApp(ui=ui,server=server)