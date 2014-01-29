library(shiny)
library(shinyGridster)

# Define UI for dataset viewer application
shinyUI(basicPage(
  tags$head(
    tags$title('CAVIRTEX CAD/BTC Market Data')
  ),
  mainPanel(
#     tags$style(type="text/css", '{body bg-color:#F0F0F0;}'),
    gridster(width=220, height=50,
             gridsterItem(row=1, col=1, sizex=5, sizey=1, h2('CAVIRTEX CAD/BTC Market Data')),
             gridsterItem(row=2, col=1, sizex=2, sizey=6, # ohlc data
                        h5('OHLCV Data'),
                        dataTableOutput("ohlcTable"),
                        tags$style(type="text/css", '#ohlcTable tr {font-size:9pt;}'),
                        tags$style(type="text/css", '#ohlcTable tfoot {display:none;}')
             ),
             gridsterItem(row=2, col=3, sizex=3, sizey=6, # ohlc chart
                        h5('OHLCV Chart'),
                        plotOutput('chart')
             ), 
             gridsterItem(row=8, col=1, sizex=1, sizey=1, # chart controls 1
                        selectInput("ohlc.frequency", "OHLCV Frequency:", choices = c("minutes", "3-minutes", "5-minutes", "10-minutes", "15-minutes", "30-minutes", "hours", "days", "weeks", "months"))
             ), 
             gridsterItem(row=8, col=2, sizex=1, sizey=1, # chart controls 2
                        selectInput(inputId = "chart_type", label = "Chart Type:", choices = c("Candlestick" = "candlesticks", "Matchstick" = "matchsticks", "Bar" = "bars", "Line" = "line"))
             ), 
             gridsterItem(row=8, col=3, sizex=3, sizey=1, # chart controls 3
                        sliderInput(inputId="timeline.slider", label="Last (n) periods...", min=10, max=1440, value=120)
             ),
             gridsterItem(row=9, col=1, sizex=5, sizey=1, 
                          checkboxGroupInput(inputId='ta_checks', label='Technical Indicators:', choices=c('Volume'='vo','Bollinger Bands'='bb'), selected=c('Volume'))             
             ),
             gridsterItem(row=10, col=1, sizex=2, sizey=6, # order book data
                        h5('Order Book Data'),
                        dataTableOutput('booksummaryTable'),
                        tags$style(type="text/css", '#booksummaryTable tfoot {display:none;}'),
                        tags$style(type="text/css", '#booksummaryTable tr {font-size:10pt;}'),
                        dataTableOutput("orderbookTable"), 
                        tags$style(type="text/css", '#orderbookTable tfoot {display:none;}'),
                        tags$style(type="text/css", '#orderbookTable tr {font-size:9pt;}')
             ),
             gridsterItem(row=1, col=3, sizex=3, sizey=6, # order book graph
                        h5('Order Book Chart (20 levels)'),
                        plotOutput('book')
             ),
             gridsterItem(row=11, col=1, sizex=2, sizey=6, # recent trades
                        h5('Recent Trades'),
                        dataTableOutput("recentTradesTable"),
                        tags$style(type="text/css", '#recentTradesTable tr {font-size:9pt;}'),
                        tags$style(type="text/css", '#recentTradesTable tfoot {display:none;}')
             ),
             gridsterItem(row=11, col=5, sizex=3, sizey=6, # market order calculator
                        h5('Market Order Cost Calculator'),
                        numericInput("btc.qty", "BTC to buy/sell:", 1),
                        numericInput("fee", "Fee rate (%):", 1.05),
                        h5('Market Order Buy Cost:'),
                        verbatimTextOutput('market.order.buy'),
                        h5('Market Order Sell Proceeds:'),
                        verbatimTextOutput('market.order.sell'),
                        h5('Trade Profitable At (Long):'),
                        verbatimTextOutput('long.profit'),
                        h5('Trade Profitable At (Short):'),
                        verbatimTextOutput('short.profit')
             ),
             gridsterItem(row=12, col=1, sizex=5, sizey=1, # footer
                        p('')
             ),
             gridsterItem(row=14, col=1, sizex=1, sizey=1, # footer
                        a(href='https://taypeinternational.com', img(src='logo.png'))
             ),
             gridsterItem(row=14, col=2, sizex=3, sizey=1, # footer
                        p('')
             ),
             gridsterItem(row=15, col=5, sizex=1, sizey=1, # footer
                        a(href='https://github.com/br00t999/cavirtexr', 'Open source', target='_blank'),
                        p('2014 TAYPE I B S Inc. All rights reserved.'),
                        tags$style(type="text/css", 'p {font-size:smaller;}')
             )
    )
  )
))
