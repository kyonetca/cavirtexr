library(shiny)
library(bitcoinchartsr)
library(lubridate)
library(quantmod)
source('nws_api.R')
source('cavirtex-order-book.R')

NWS.HOST <- 'localhost'
NWS.PORT <- 9090

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  book <- NA
  
  vtx.minutes <- NA
  vtx.hours <- NA
  vtx.days <- NA
  vtx.months  <- NA 
  vtx.hours <- NA
  
  # Return the requested dataset
  freqInput <- reactive({
    switch(input$ohlc.frequency,
           "minutes"=vtx.minutes,
           "hours" = vtx.hours,
           "days" = vtx.days,
           "months" = vtx.months)
  })
  
  timelineSlider <- reactive({
    
  })
  
  make.chart <- function(symbol) {
    if(input$ohlc.frequency == "minutes") data <- vtx.minutes
    if(input$ohlc.frequency == "hours") data <- vtx.hours
    if(input$ohlc.frequency == "days") data <- vtx.days
    if(input$ohlc.frequency == "months") data <- vtx.months
    chartSeries(data, theme='white',
                name = 'virtexCAD',
                type = input$chart_type,
                subset = paste("last", input$timeline.slider, input$ohlc.frequency))
  }
  
  output$chart <- renderPlot({
    vtx.minutes <- nws.get('ohlc.bitcoincharts', NWS.HOST, NWS.PORT)
    colnames(vtx.minutes) <- str_join('.', colnames(vtx.minutes))
    vtx.hours <- to.hourly(vtx.minutes, name=rep('', 5))
    vtx.days <- to.daily(vtx.hours, name=rep('', 5))
    vtx.months  <- to.monthly(vtx.hours, name=rep('', 5))
    vtx.minutes <<- vtx.minutes
    vtx.hours <<- vtx.hours
    vtx.days <<- vtx.days
    vtx.months <<- vtx.months
    make.chart()
    invalidateLater(millis=((((60 - minute(Sys.time())) + 1) * 60) * 1000), session)
  })
  
  output$book <- renderPlot({
    book <- nws.get('book', NWS.HOST, NWS.PORT)
    book <<- book
    plot(book)
    invalidateLater(millis=5000, session)
  })
  
  output$orderbookTable <- renderDataTable(searchDelay=500, expr={
    res <- cbind(book$bids[1:5,-1], book$asks[1:5,-1])
    res <- res[ , c(1:3,6:4) ]
    colnames(res) <- c('bids.amount', 'bids.price',	'bids.value',	'asks.value',	'asks.price', 'asks.amount')
    res
  }, options=list(bFilter=0, bSort=0, bProcessing=0, bPaginate=0, bInfo=0))

  output$recentTradesTable <- renderDataTable(searchDelay=500, expr={
    invalidateLater(millis=5000, session)
    res <- cbind(as.character(book$recent.trades$processed[1:10]), book$recent.trades[1:10, c(2, 4)])
    colnames(res) <- c('Time', 'BTC', 'Price')
    rownames(res) <- NULL
    as.matrix(res[ order(as.POSIXct(res[,1]), decreasing=TRUE), ])
  }, options=list(bFilter=0, bSort=0, bProcessing=0, bPaginate=0, bInfo=0))

  output$ohlcTable <- renderDataTable(searchDelay=500, expr={
    invalidateLater(millis=5000, session)
    if(input$ohlc.frequency == "minutes") data <- vtx.minutes
    if(input$ohlc.frequency == "hours") data <- vtx.hours
    if(input$ohlc.frequency == "days") data <- vtx.days
    if(input$ohlc.frequency == "months") data <- vtx.months
    res <- as.data.frame(data)
    res <- cbind(rownames(res), res)
    rownames(res) <- NULL
    colnames(res) <- c('Time', 'Open', 'High', 'Low', 'Close', 'Volume')
    res <- res[ order(as.POSIXct(res[,1]), decreasing=TRUE), ]
    as.matrix(res[1:6, 1:6])
  }, options=list(bFilter=0, bSort=0, bProcessing=0, bPaginate=0, bInfo=0))
  
  output$booksummaryTable <- renderDataTable({
    invalidateLater(millis=5000, session)
    best.bid <- as.numeric(book$bids[ as.numeric(book$bids$price) == max(as.numeric(book$bids$price)), 'price'])
    best.ask <- as.numeric(book$asks[ as.numeric(book$asks$price) == min(as.numeric(book$asks$price)), 'price'])
    spread <- best.ask - best.bid
    bid.depth <- sum(as.numeric(book$bids$amount))
    ask.depth <- sum(as.numeric(book$asks$amount))
    as.matrix(cbind(bid.depth, best.bid, spread, best.ask, ask.depth))
  }, options=list(bFilter=0, bSort=0, bProcessing=0, bPaginate=0, bInfo=0))
  
  output$market.order.buy <- renderPrint({
    try(cat(market.order(input$btc.qty, 'buy', book), '\n'))
    invalidateLater(millis=5000, session)
  })
  
  output$market.order.sell<- renderPrint({
    try(cat(market.order(input$btc.qty, 'sell', book), '\n'))
    invalidateLater(millis=5000, session)
  })
})
