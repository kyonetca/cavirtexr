library(stringr)

# ==========================================================================================
# Calculate the cost to execute a market order
# ==========================================================================================
market.order <- function(qty, buy.sell='buy', order.book=nws.get('book', NWS.HOST, NWS.PORT), fee=0.0) {
  if(buy.sell == 'buy') {
    # how much will it cost to purchase qty of BTC by market order
    # when you buy fee is charged in CAD
    order.book$asks$amount.cum <- cumsum(order.book$asks$amount)  
    rownames(order.book$asks) <- NULL 
    buy.these <- order.book$asks[ 1:rownames(first(order.book$asks[ order.book$asks$amount.cum >= qty, ])), ]
    cost <- sum(as.numeric(buy.these$price * buy.these$amount)) - ((last(buy.these$amount.cum) - qty) * last(as.numeric(buy.these$price)))
    # to compensate for fees, we add on fee to cost
    cost <- cost * (1 + (fee / 100.0))
    return(cost)
  } else if(buy.sell == 'sell') {
    # how much will you receive to sell qty of BTC by market order
    # when you sell fee is charged in BTC
    order.book$bids$amount.cum <- cumsum(order.book$bids$amount)  
    rownames(order.book$bids) <- NULL
    sell.these <- order.book$bids[ 1:rownames(first(order.book$bids[ order.book$bids$amount.cum >= (qty * (1 - (fee / 100.0))), ])), ]
    # we adjust the qty by the BTC fee
    revenue <- sum(as.numeric(sell.these$price * sell.these$amount)) - ((last(sell.these$amount.cum) - (qty * (1 - (fee / 100.0)))) * last(as.numeric(sell.these$price)))
    return(revenue)
  } else {
    stop('Must either "buy" or "sell"')
  }
}

# # =================================================================================================
# # get long short profit boundaries for a given market order qty
# # =================================================================================================
# get.profit.boundaries <- function(qty, order.book, fee.rate) {
#   ratio = (1 - fee.rate)^(-2)
#   short = entry.price / ratio
#   long = entry.price * ratio
#   #   message(sprintf('%s <--( %s )--> %s', short, entry_price, long))
#   #   message(sprintf('spread: %s', (long-entry_price)))
#   list(short=short, long=long)  
# }

# ==========================================================================================
# Generic plot method for orderbook class ( used in Shiny app )
# ==========================================================================================
plot.orderbookjson <- function(x, y, ...) {
  par(mfcol=c(1,2), bg='#FFFFFF', col.axis='#000000', cex.axis=0.75, col.main='#000000', las=2, oma=c(0,0,0,1))
  max.y <- ifelse(max(as.numeric(x$bids$amount[1:20])) > max(as.numeric(x$asks$amount[1:20])), yes=max(as.numeric(x$bids$amount[1:20])), no=max(as.numeric(x$asks$amount[1:20])))
  plot(y=x$bids$amount[1:20], x=x$bids$price[1:20], type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$bids$price[1:20])), max(as.numeric(x$bids$price[1:20]))), ylim=c(0, max.y), axes=FALSE, col='#00CC00', lend='square', )
  axis(side=1, at=seq(min(as.numeric(x$bids$price[1:20])), max(as.numeric(x$bids$price[1:20])), ((max(as.numeric(x$bids$price[1:20])) - min(as.numeric(x$bids$price[1:20]))) / 5)), col='black')
  axis(side=2, at=seq(0, max.y, (max.y / 10)), col='black')
  grid(NA,NULL, lty = 6, col = "grey")
  title('Bids')
  plot(y=x$asks$amount[1:20], x=x$asks$price[1:20], type='h', lwd=12, yaxt='n', ann=FALSE, xlim=c(min(as.numeric(x$asks$price[1:20])), max(as.numeric(x$asks$price[1:20]))), ylim=c(0, max.y), axes=FALSE, col='#FF7700', lend='square')
  axis(side=1, at=seq(min(as.numeric(x$asks$price[1:20])), max(as.numeric(x$asks$price[1:20])), ((max(as.numeric(x$asks$price[1:20])) - min(as.numeric(x$asks$price[1:20]))) / 5)), col='black')
  axis(side=4, at=seq(0, max.y, (max.y / 10)), col='black')
  grid(NA,NULL, lty = 6, col = "grey")
  title('Asks')
}