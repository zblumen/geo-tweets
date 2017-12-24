ui = fluidPage(
  #Some javascript dtuff so we can press enter for an update
  tags$script(
    '$(document).on("keyup", function(e) {
        if(e.keyCode == 13){
            Shiny.onInputChange("keyPressed", Math.random());
        }
      });'
  ),
    fluidRow(
      column(3, textInput("searchkw", label = "search:", value = "#dinner")),
      column(3, textInput("loc", label = "Location:", value = "Washington DC")),
      column(3, textInput("rad", label = "Radius (Mi):", value = "6")),
      #column(3, textInput("lat", label = "latitude:", value = 40.75)),
      #column(3, textInput("long", label = "longitude:", value = -74)),
      column(3, style = "margin-top: 25px;", actionButton("search_button", label = "search Twitter!", value = "#dinner"))
    ),
    fluidRow(leafletOutput("myMap")),
    fluidRow(tableOutput("table"))       
)
server = function(input, output) {
  # google_loc = eventReactive(c(input$keyPressed,input$search_button),{
  #   geocode(input$loc,output = "latlona",source="google")
  # })
  dataInput <- eventReactive(c(input$keyPressed,input$search_button),{#reactive({ 
    google_loc = geocode(input$loc,output = "latlona",source="google")
    validate(need(!is.na(google_loc$lon),"Please enter a different location.  Cannot geo-locate"))
    radius  = gsub("[^(0-9)|\\.]",'',input$rad) %>% as.numeric()
    validate(need(!is.na(radius) & radius > 0,"Please enter a valide number for radius in miles"))    
    tweets <- twListToDF(searchTwitter(input$searchkw, n = 1000
                         ,geocode = paste0(google_loc$lat, ",", google_loc$lon, ",",radius,"mi"))) 
    tweets$created <- as.character(tweets$created)
    tweets <- tweets[!is.na(tweets[, "longitude"]), ]
    list(tweets=tweets,center = google_loc)
  })
  
  # Create a reactive leaflet map
  mapTweets <- reactive({
    map = leaflet() %>% addTiles() %>%
      addMarkers(as.numeric(dataInput()$tweets$longitude), as.numeric(dataInput()$tweets$latitude), 
      popup = dataInput()$tweets$screenName) %>%
      setView(dataInput()$center$lon, dataInput()$center$lat, zoom = 10)
  })
  output$myMap = renderLeaflet({mapTweets()})
  
  # Create a reactive table 
  output$table <- renderTable(
    {dataInput()$tweets[, c("screenName", "longitude", "latitude", "created")]}
  )
}


shinyApp(ui=ui,server=server)