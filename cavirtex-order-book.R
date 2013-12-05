#!/usr/bin/Rscript

# ==========================================================================================
# You can run this as a cron job on a *nix box :-) Just uncomment the code at the bottom 
# of the page, modify the permissions so that the script is executable and run it!
# ==========================================================================================

library(RCurl)
library(XML)
library(stringr)

# ==========================================================================================
# Scrapes www.cavirtex.com order book ( https://www.cavirtex.com/orderbook )
# ==========================================================================================
cavirtex.get.orderbook <- function() {
  message('Getting cavirtex order book...')
  txt <- getURL('https://www.cavirtex.com/orderbook')
  xmltext <- htmlParse(txt, asText=TRUE)
  xmltable <- xpathApply(xmltext, "//table//tr//td")
  
  bids <- cbind(unlist(lapply((xmltable[ seq(11, 90, 4) ]), xmlValue)), 
                unlist(lapply(lapply(lapply(lapply(xmltable[ seq(12,90, 4) ], xmlValue), str_split, '/'), unlist), function(x) { x[1] })), 
                unlist(lapply((xmltable[ seq(13, 90, 4) ]), xmlValue)), 
                unlist(lapply(lapply((xmltable[ seq(14, 90, 4) ]), xmlValue), str_replace, 'CAD', '')))
  
  asks <- cbind(unlist(lapply((xmltable[ seq(91, 170, 4) ]), xmlValue)), 
                unlist(lapply(lapply(lapply(lapply(xmltable[ seq(92, 170, 4) ], xmlValue), str_split, '/'), unlist), function(x) { x[1] })), 
                unlist(lapply((xmltable[ seq(93, 170, 4) ]), xmlValue)), 
                unlist(lapply(lapply((xmltable[ seq(94, 170, 4) ]), xmlValue), str_replace, 'CAD', '')))
  
  recent.trades <- cbind(unlist(lapply((xmltable[ seq(171, 250, 4) ]), xmlValue)), 
                        unlist(lapply((xmltable[ seq(172, 250, 4) ]), xmlValue)), 
                        unlist(lapply((xmltable[ seq(173, 250, 4) ]), xmlValue)), 
                        unlist(lapply((xmltable[ seq(174, 250, 4) ]), xmlValue)))
  
  bids <- as.data.frame(bids, stringsAsFactors=FALSE)
  asks <- as.data.frame(asks, stringsAsFactors=FALSE)
  recent.trades <- as.data.frame(recent.trades, stringsAsFactors=FALSE)
  
  colnames(bids) <- colnames(asks) <- c('created', 'amount', 'price', 'value')
  colnames(recent.trades) <- c('processed', 'BTC', 'CAD', 'price')
  
  bids$created <- strptime(str_replace(str_replace(unlist(bids[,1]), 'a.m.', 'AM'), 'p.m.', 'PM'), format='%b. %d, %Y, %H:%M %p', tz='MST')
  asks$created <- strptime(str_replace(str_replace(unlist(asks[,1]), 'a.m.', 'AM'), 'p.m.', 'PM'), format='%b. %d, %Y, %H:%M %p', tz='MST')
  recent.trades$processed <- strptime(str_replace(str_replace(unlist(recent.trades$processed), 'a.m.', 'AM'), 'p.m.', 'PM'), format='%b. %d, %Y, %H:%M %p', tz='MST')
  
  bids <- bids[ order(as.numeric(bids$price), decreasing=TRUE), ]
  asks <- asks[ order(as.numeric(asks$price)), ]
  recent.trades <- recent.trades[ order(as.Date(recent.trades$processed)), ]
  
  res <- list('bids'=bids, 'asks'=asks, 'recent.trades'=recent.trades)
  class(res) <- 'orderbook'
  return(res)
}

# ==========================================================================================
# Calculate the cost to execute a market order
# ==========================================================================================
market.order <- function(qty, buy.sell='buy', order.book=cavirtex.get.orderbook()) {
  if(buy.sell == 'buy') {
    # how much will it cost to purchase qty of BTC by market order
    order.book$asks$amount.cum <- cumsum(order.book$asks$amount)  
    buy.these <- order.book$asks[ 1:rownames(first(order.book$asks[ order.book$asks$amount.cum >= qty, ])), ]
    cost <- sum(as.numeric(buy.these$value)) - ((last(buy.these$amount.cum) - qty) * last(as.numeric(buy.these$price)))
    return(cost)
  } else if(buy.sell == 'sell') {
    # how much will you receive to sell qty of BTC by market order
    order.book$bids$amount.cum <- cumsum(order.book$bids$amount)  
    sell.these <- order.book$bids[ 1:rownames(first(order.book$bids[ order.book$bids$amount.cum >= qty, ])), ]
    revenue <- sum(as.numeric(sell.these$value)) - ((last(sell.these$amount.cum) - qty) * last(as.numeric(sell.these$price)))
    return(revenue)
  } else {
    stop('Must either "buy" or "sell"')
  }
}

# ==========================================================================================
# Generic print method for orderbook class ( used in Shiny app )
# ==========================================================================================
print.orderbook <- function(x, ...) {
  book <- cbind(x$bids[ ,2:4 ], rep('|', 20), x$asks[ order(as.numeric(x$asks$price), decreasing=FALSE),4:2])
  colnames(book) <- c('bids.amount', 'bids.price', 'bids.value', '', 'asks.amount', 'asks.price', 'asks.value')
  print(book)
}

# ==========================================================================================
# Generic plot method for orderbook class ( used in Shiny app )
# ==========================================================================================
plot.orderbook <- function(x, y, ...) {
  par(mfcol=c(1,2), bg='#222222', col.axis='gray', cex.axis=0.75, col.main='#656565', las=2, oma=c(0,0,0,1))
  max.y <- ifelse(max(as.numeric(x$bids$amount)) > max(as.numeric(x$asks$amount)), yes=max(as.numeric(x$bids$amount)), no=max(as.numeric(x$asks$amount)))
  plot(y=x$bids$amount, x=x$bids$price, type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$bids$price)), max(as.numeric(x$bids$price))), ylim=c(0, max.y), axes=FALSE, col='green', lend='square')
  axis(side=1, at=seq(min(as.numeric(x$bids$price)), max(as.numeric(x$bids$price)), ((max(as.numeric(x$bids$price)) - min(as.numeric(x$bids$price))) / 5)), col='gray')
  axis(side=2, at=seq(0, max.y, (max.y / 10)), col='gray')
  title('Bids')
  plot(y=x$asks$amount, x=x$asks$price, type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$asks$price)), max(as.numeric(x$asks$price))), ylim=c(0, max.y), axes=FALSE, col='orange', lend='square')
  axis(side=1, at=seq(min(as.numeric(x$asks$price)), max(as.numeric(x$asks$price)), ((max(as.numeric(x$asks$price)) - min(as.numeric(x$asks$price))) / 5)), col='gray')
  axis(side=4, at=seq(0, max.y, (max.y / 10)), col='gray')
  title('Asks')
}

# ==========================================================================================
# Generic summary method for orderbook class ( used in Shiny app )
# ==========================================================================================
summary.orderbook <- function(object, ...) {
  print(paste('Best bid: $', paste(object$bids[ as.numeric(object$bids$price) == max(as.numeric(object$bids$price)), 'price'], sep=',', collapse=' ')))
  print(paste('Best ask: $', paste(object$asks[ as.numeric(object$asks$price) == min(as.numeric(object$asks$price)), 'price'], sep=',', collapse=' ')))
  spread <- abs(as.numeric(object$asks[1,3]) - as.numeric(object$bids[1,3]))
  print(paste('Bid / Ask spread: $', spread[1]))
}

# ==========================================================================================
# Uncommment the code below this line to run as a shell script that grabs the order book
# every fifteen seconds (slow enough to be polite, but fast enough to catch most of the 
# action)
# 
# exit <- FALSE
# 
# while(!exit) {
#   book <- cavirtex.get.orderbook()
#   print('=========================================================================')
#   print(paste('CAVIRTEX ORDER BOOK', Sys.time()))
#   print('=========================================================================')
#   print(book)
#   print('=========================================================================')
#   print(summary(book))
#   print('=========================================================================')
#   Sys.sleep(15)
# }