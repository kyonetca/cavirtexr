cavirtexr
=========

`cavirtexr` is a very simple Shiny app that provides an alternate front end to www.cavirtex.com with (semi) realtime order book and basic charting. This app is known to run on recent versions of Ubuntu and other standard Linux distros. It unfortunately has not yet been tested on Windows, so your mileage may vary!

Dependencies
============

This app depends on the bitcoinchartsr package. Before attempting to run the shiny web app, you will need to install it! To install the bitcoinchartsr package run the following commands in R:

```
library(devtools)
install_github('https://github.com/br00t999/bitcoinchartsr.git')
```

Launching the web app
=====================

From the project root directory, run the following commands in R:

```
library(shiny)
runApp('webapp', launch.browser=TRUE)
```

All feedback and suggestions are welcome! 

info@taypeinternational.com






