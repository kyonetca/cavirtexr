library(shiny)
library(bitcoinchartsr)
library(lubridate)
library(quantmod)
library(cavirtex)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  book <- NA
  
  vtx.hours <- NA
  vtx.days <- NA
  vtx.months  <- NA 
  vtx.hours <- NA
  
  # Return the requested dataset
  freqInput <- reactive({
    switch(input$ohlc.frequency,
           "hours" = vtx.hours,
           "days" = vtx.days,
           "months" = vtx.months)
  })
  
  output$chart <- renderPlot({
    vtx.hours <- get_bitcoincharts_data(symbol='virtexCAD', start.date=as.character(Sys.Date() - years(1)), ohlc.frequency='hours')
    vtx.days <- to.daily(vtx.hours[ paste(as.character(Sys.Date() - days(30)), '/', sep='') ], name=rep('', 5), drop.time=FALSE)
    vtx.months  <- to.monthly(vtx.hours, name=rep('', 5))
    vtx.hours <- vtx.hours[ paste(as.character(Sys.Date() - days(2)), '/', sep='') ]
    vtx.hours <<- vtx.hours
    vtx.days <<- vtx.days
    vtx.months <<- vtx.months
    switch(input$ohlc.frequency,
           "hours" = chartSeries(vtx.hours),
           "days" = chartSeries(vtx.days),
           "months" = chartSeries(vtx.months))
    invalidateLater(millis=((((60 - minute(Sys.time())) + 1) * 60) * 1000), session)
  })
  
  output$ohlc.display <- renderPrint({
    ohlc.frequency <- freqInput()
    switch(input$ohlc.frequency,
           "hours" = head(as.data.frame(vtx.hours)[ order(index(vtx.hours), decreasing=TRUE), 1:5], 4),
           "days" = head(as.data.frame(vtx.days)[ order(index(vtx.days), decreasing=TRUE), 1:5], 4),
           "months" = head(as.data.frame(vtx.months)[ order(index(vtx.months), decreasing=TRUE), 1:5], 4))
  })
  
  output$book <- renderPlot({
    book <- cavirtex.get.orderbook()
    book <<- book
    plot(book)
    invalidateLater(millis=5000, session)
  })
  
  output$recent.trades <- renderPrint({
    print(book$recent.trades[1:5,])
    invalidateLater(millis=5000, session)
  })
  
  output$bookprint <- renderPrint({
    print(book)
    invalidateLater(millis=5000, session)
  })
  
  output$booksummary <- renderPrint({
    cat(paste('Best bid: $', 
              paste(book$bids[ as.numeric(book$bids$price) == max(as.numeric(book$bids$price)), 'price'], sep=' ', collapse=' '), 
              '   \t\tBid Depth: ', sum(as.numeric(book$bids$amount)), 'BTC'), '\n')
    cat(paste('Best ask: $', 
              paste(book$asks[ as.numeric(book$asks$price) == min(as.numeric(book$asks$price)), 'price'], sep=' ', collapse=' '), 
              '   \t\tAsk Depth: ', sum(as.numeric(book$asks$amount)), 'BTC'), '\n')
    cat(paste('Bid / Ask spread: $', abs(as.numeric(book$asks[1,3]) - as.numeric(book$bids[1,3]))), '\n')
    invalidateLater(millis=5000, session)
  })
  
  output$market.order.buy <- renderPrint({
    try(cat(market.order(input$btc.qty, 'buy', book), '\n'))
    invalidateLater(millis=5000, session)
  })
  
  output$market.order.sell<- renderPrint({
    try(cat(market.order(input$btc.qty, 'sell', book), '\n'))
    invalidateLater(millis=5000, session)
  })
})
