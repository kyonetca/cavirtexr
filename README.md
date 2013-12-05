cavirtexr
=========

A very simple Shiny app that provides an alternate front end to www.cavirtex.com with (semi) realtime order book

DEPENDENCIES:
=============

This app depends on the bitcoinchartsr package. Before attempting to run the shiny web app, you will need to install it! To install the bitcoinchartsr package run the following commands in R:

library(devtools)
install_github('https://github.com/br00t999/bitcoinchartsr.git')

LAUNCHING THE WEB APP:
======================

From the project root directory, run the following commands in R:

library(shiny)
runApp('webapp', launch.browser=TRUE)

All feedback and suggestions are welcome! 

Peter Taylor
peter.taylor@taypeinternational.com






