library(stringr)

# ==========================================================================================
# Calculate the cost to execute a market order
# ==========================================================================================
market.order <- function(qty, buy.sell='buy', order.book=cavirtex.get.orderbook(), fee=0.0) {
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
  par(mfcol=c(1,2), bg='#FFFFFF', col.axis='#000000', cex.axis=0.75, col.main='#000000', las=2, oma=c(0,0,0,1))
  max.y <- ifelse(max(as.numeric(x$bids$amount)) > max(as.numeric(x$asks$amount)), yes=max(as.numeric(x$bids$amount)), no=max(as.numeric(x$asks$amount)))
  plot(y=x$bids$amount, x=x$bids$price, type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$bids$price)), max(as.numeric(x$bids$price))), ylim=c(0, max.y), axes=FALSE, col='#00CC00', lend='square', )
  axis(side=1, at=seq(min(as.numeric(x$bids$price)), max(as.numeric(x$bids$price)), ((max(as.numeric(x$bids$price)) - min(as.numeric(x$bids$price))) / 5)), col='black')
  axis(side=2, at=seq(0, max.y, (max.y / 10)), col='black')
  title('Bids')
  plot(y=x$asks$amount, x=x$asks$price, type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$asks$price)), max(as.numeric(x$asks$price))), ylim=c(0, max.y), axes=FALSE, col='#FF7700', lend='square')
  axis(side=1, at=seq(min(as.numeric(x$asks$price)), max(as.numeric(x$asks$price)), ((max(as.numeric(x$asks$price)) - min(as.numeric(x$asks$price))) / 5)), col='black')
  axis(side=4, at=seq(0, max.y, (max.y / 10)), col='black')
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