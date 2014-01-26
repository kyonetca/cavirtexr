# ==============================================================================================
# Simple interface to python-nws service
# ==============================================================================================

library(nws)
NWS.WORKSPACE <- 'cavirtexbot'

# ==============================================================================================
# Get from nws
# ==============================================================================================
nws.get <- function(var.name, host='localhost', port=8765) {
  tryCatch(expr={
    # first try to get data from nws
    nwss <- nwsServer(host, port)
    ws <- nwsOpenWs(nwss, NWS.WORKSPACE, persistent=TRUE)
    res <- nwsFindTry(ws, xName=var.name, defaultVal=NA)
    nwsClose(ws)
    return(res)
  }, erorr = function(e) {
    # on fail echo error message and return NA
    print(e)
    return(NA)
  })
}

# ==============================================================================================
# Write to nws
# ==============================================================================================
nws.put <- function(var.name, val, host='localhost', port=8765) {
  tryCatch(expr={
    nwss <- nwsServer(host, port)
    ws <- nwsOpenWs(nwss, NWS.WORKSPACE, persistent=TRUE)
    try(nwsDeleteVar(ws, var.name))
    nwsStore(ws,xName=var.name,xVal=val)
    nwsClose(ws)  
  }, error = function(e) {
    print(e)
  })
}