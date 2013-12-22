library(shiny)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  h2("CAVIRTEX BTCCAD MARKET"),
  
  # Sidebar with controls to select a dataset and specify the number
  # of observations to view
  sidebarPanel(
    tags$head(
      tags$style("body { background-color: #222222; } form.well { background-color: #222222; border-color: gray; } pre { background-color: #222222; color: gray; font-weight:bold; font-size:9pt;}")
    ),
    
    numericInput("btc.qty", "BTC to buy/sell:", 20),
    numericInput("fee", "Fee rate (%):", 0),
    
    h5('Market Order Buy Cost:'),
    verbatimTextOutput('market.order.buy'),
    
    h5('Market Order Sell Proceeds:'),
    verbatimTextOutput('market.order.sell'),
    
    h5('OHLC'),
    
    verbatimTextOutput('ohlc.display'),
    
    h5('Recent Trades'),
    
    verbatimTextOutput('recent.trades'),
    
    selectInput("ohlc.frequency", "Choose a frequency:", 
                choices = c("minutes", "hours", "days", "weeks", "months")),
    
    h5('Order Book'),
    
    verbatimTextOutput('booksummary'),
    
    verbatimTextOutput('bookprint')
  ),
  
  # Show a summary of the dataset and an HTML table with the requested
  # number of observations
  mainPanel(
    h5('Chart'),
    plotOutput('chart'),
    h5('Order Book'),
    plotOutput('book')
  )
))
