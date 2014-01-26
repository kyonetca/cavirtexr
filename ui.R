library(shiny)
library(shinyGridster)

# Define UI for dataset viewer application
shinyUI(basicPage(
  mainPanel(
    # Simple integer interval
    gridster(width=220, height=50,
             gridsterItem(row=1, col=1, sizex=2, sizey=6, # ohlc data
                          dataTableOutput("ohlcTable"),
                          tags$style(type="text/css", '#ohlcTable tr {font-size:9pt;}'),
                          tags$style(type="text/css", '#ohlcTable tfoot {display:none;}')
             ),
             gridsterItem(row=1, col=3, sizex=3, sizey=6, # ohlc chart
                          h5('OHLCV Chart'),
                          plotOutput('chart')
             ), 
             gridsterItem(row=7, col=1, sizex=1, sizey=1, # chart controls 1
                          selectInput("ohlc.frequency", "OHLCV Frequency:", choices = c("minutes", "hours", "days", "months"))
             ), 
             gridsterItem(row=7, col=2, sizex=1, sizey=1, # chart controls 2
                          selectInput(inputId = "chart_type", label = "Chart Type:", choices = c("Candlestick" = "candlesticks", "Matchstick" = "matchsticks", "Bar" = "bars", "Line" = "line"))
             ), 
             gridsterItem(row=7, col=3, sizex=3, sizey=1, # chart controls 3
                          sliderInput(inputId="timeline.slider", label="Last (n) periods...", min=10, max=1440, value=120)
             ),
             gridsterItem(row=8, col=1, sizex=2, sizey=6, # order book graph
                          dataTableOutput('booksummaryTable'),
                          tags$style(type="text/css", '#booksummaryTable tfoot {display:none;}'),
                          tags$style(type="text/css", '#booksummaryTable tr {font-size:10pt;}'),
                          dataTableOutput("orderbookTable"), 
                          tags$style(type="text/css", '#orderbookTable tfoot {display:none;}'),
                          tags$style(type="text/css", '#orderbookTable tr {font-size:9pt;}')
             ),
             gridsterItem(row=8, col=3, sizex=3, sizey=6, # order book graph
                          h5('Order Book'),
                          plotOutput('book')
             ),
             gridsterItem(row=9, col=1, sizex=2, sizey=6, # order book data
                          dataTableOutput("recentTradesTable"),
                          tags$style(type="text/css", '#recentTradesTable tr {font-size:9pt;}'),
                          tags$style(type="text/css", '#recentTradesTable tfoot {display:none;}')
             ),
             gridsterItem(row=9, col=5, sizex=3, sizey=6, # order book graph
                        h5('Market Order Cost Calculator'),
                        numericInput("btc.qty", "BTC to buy/sell:", 1),
                        numericInput("fee", "Fee rate (%):", 0),
                        h5('Market Order Buy Cost:'),
                        verbatimTextOutput('market.order.buy'),
                        h5('Market Order Sell Proceeds:'),
                        verbatimTextOutput('market.order.sell')
             )
    )
    
  )
))
