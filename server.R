library(shiny)
library(bitcoinchartsr)
library(lubridate)
library(quantmod)
library(stringr)
source('nws_api.R')
source('cavirtex-order-book.R')

NWS.HOST <- 'localhost'
NWS.PORT <- 9090

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  book <- NA
  
  vtx.minutes <- NA
  vtx.minutes.3 <- NA
  vtx.minutes.5 <- NA
  vtx.minutes.10 <- NA
  vtx.minutes.15 <- NA
  vtx.minutes.30 <- NA
  vtx.hours <- NA
  vtx.days <- NA
  vtx.weeks <- NA
  vtx.months  <- NA 
  vtx.hours <- NA
  
  # Return the requested dataset
  freqInput <- reactive({
    switch(input$ohlc.frequency,
           "minutes"=vtx.minutes,
           "3-minutes"=vtx.minutes.3,
           "5-minutes"=vtx.minutes.5,
           "10-minutes"=vtx.minutes.10,
           "15-minutes"=vtx.minutes.15,
           "30-minutes"=vtx.minutes.30,
           "hours" = vtx.hours,
           "days" = vtx.days,
           "weeks"=vtx.weeks,
           "months" = vtx.months)
  })
  
  timelineSlider <- reactive({
    
  })
  
  make.chart <- function(symbol) {
    if(input$ohlc.frequency == "minutes") data <- vtx.minutes
    if(input$ohlc.frequency == "3-minutes") data <- vtx.minutes.3
    if(input$ohlc.frequency == "5-minutes") data <- vtx.minutes.5
    if(input$ohlc.frequency == "10-minutes") data <- vtx.minutes.10
    if(input$ohlc.frequency == "15-minutes") data <- vtx.minutes.15
    if(input$ohlc.frequency == "30-minutes") data <- vtx.minutes.30
    if(input$ohlc.frequency == "hours") data <- vtx.hours
    if(input$ohlc.frequency == "days") data <- vtx.days
    if(input$ohlc.frequency == "weeks") data <- vtx.weeks
    if(input$ohlc.frequency == "months") data <- vtx.months
    if(str_detect(input$ohlc.frequency, 'minutes')) freq <- 'minutes' else freq <- input$ohlc.frequency
    ta.str <- ifelse('bb' %in% input$ta_checks, 'addBBands()', '')
    ta.str <- c(ta.str, ifelse('vo' %in% input$ta_checks, 'addVo()', ''))
    ta.str <- ta.str[ ta.str != '' ]
    print(paste(ta.str, collapse=',', sep=''))
    if(length(ta.str) > 0) chartSeries(data, theme='white', TA=paste(ta.str, collapse=',', sep=''), TAsep=',',
                                 name = 'virtexCAD',
                                 type = input$chart_type,
                                 subset = paste("last", input$timeline.slider, freq))
    else chartSeries(data, theme='white', TA=NULL,
                     name = 'virtexCAD',
                     type = input$chart_type,
                     subset = paste("last", input$timeline.slider, freq))
  }
  
  output$chart <- renderPlot({
    vtx.minutes <- nws.get('ohlc.bitcoincharts', NWS.HOST, NWS.PORT)
    colnames(vtx.minutes) <- str_join('.', colnames(vtx.minutes))
    vtx.minutes.3 <- to.minutes3(vtx.minutes, name=rep('', 5))
    vtx.minutes.5 <- to.minutes5(vtx.minutes, name=rep('', 5))
    vtx.minutes.10 <- to.minutes10(vtx.minutes, name=rep('', 5))
    vtx.minutes.15 <- to.minutes15(vtx.minutes, name=rep('', 5))
    vtx.minutes.30 <- to.minutes30(vtx.minutes, name=rep('', 5))
    vtx.hours <- to.hourly(vtx.minutes, name=rep('', 5))
    vtx.days <- to.daily(vtx.hours, name=rep('', 5))
    vtx.weeks <- to.weekly(vtx.minutes, name=rep('', 5))
    vtx.months  <- to.monthly(vtx.hours, name=rep('', 5))
    vtx.minutes <<- vtx.minutes
    vtx.minutes.3 <<- vtx.minutes.3
    vtx.minutes.5 <<- vtx.minutes.5
    vtx.minutes.10 <<- vtx.minutes.10
    vtx.minutes.15 <<- vtx.minutes.15
    vtx.minutes.30 <<- vtx.minutes.30
    vtx.hours <<- vtx.hours
    vtx.days <<- vtx.days
    vtx.weeks <<- vtx.weeks
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
    if(input$ohlc.frequency == "3-minutes") data <- vtx.minutes.3
    if(input$ohlc.frequency == "5-minutes") data <- vtx.minutes.5
    if(input$ohlc.frequency == "10-minutes") data <- vtx.minutes.10
    if(input$ohlc.frequency == "15-minutes") data <- vtx.minutes.15
    if(input$ohlc.frequency == "30-minutes") data <- vtx.minutes.30
    if(input$ohlc.frequency == "hours") data <- vtx.hours
    if(input$ohlc.frequency == "days") data <- vtx.days
    if(input$ohlc.frequency == "weeks") data <- vtx.weeks
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
    try(cat(market.order(input$btc.qty, 'buy', book, input$fee), '\n'))
    invalidateLater(millis=5000, session)
  })
  
  output$market.order.sell <- renderPrint({
    try(cat(market.order(input$btc.qty, 'sell', book, input$fee), '\n'))
    invalidateLater(millis=5000, session)
  })
  
#   output$long.profit <- renderPrint({
#     try(cat(get.profit.boundaries(book, input$fee), '\n'))
#     invalidateLater(millis=5000, session)
#   })
#   
#   output$short.profit <- renderPrint({
#     try(cat(get.profit.boundaries(input$btc.qty, book, input$fee), '\n'))
#     invalidateLater(millis=5000, session)
#   })
})
