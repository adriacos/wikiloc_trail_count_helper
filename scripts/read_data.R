#if (!require("lubridate")){
#  install.packages("lubridate")
#}
library(lubridate)

source("scripts/save_data.R")



readData <- function(registers=10){
  print("readData")
  
  data_started <- getStartedNotDone()
  if(!is.null(data_started) && nrow(data_started) >= registers){
    return(data_started[1:registers,])
  } else if(is.null(data_started) || nrow(data_started) == 0){
    data_ifn4 <- readIFN4(getIdsAlreadyDoneOrInProcess(), registers)  
    data_ifn4 <- addColumnsToData(data_ifn4)
    insertIFN_WL_TrailN(data_ifn4)
    return(data_ifn4)
  } else{
    data_ifn4 <- readIFN4(getIdsAlreadyDoneOrInProcess(),registers-nrow(data_started)) 
    data_ifn4 <- addColumnsToData(data_ifn4)
    insertIFN_VA_Class(data_ifn4)
    
    return(rbind(data_started,data_ifn4))
  }
}

addColumnsToData <- function(data){
  data$trailNumber <- NA
  
  data$sys_dt_started <- Sys.time()
  data$sys_dt_done <- NA
  data
}

getStartedNotDone <- function(){
  print("getStartedNotDone")
  ifn_wl_trailn <- readIFN_WL_TrailN()
  if (!is.null(ifn_wl_trailn)) {
    return(ifn_wl_trailn[
      (is.na(ifn_wl_trailn$sys_dt_done)
     &(Sys.time() > (as.POSIXct(ifn_wl_trailn$sys_dt_started) + minutes(1))))
    , ])
  }
  return(NULL)
}

getIdsAlreadyDoneOrInProcess <- function(){
  print("getIdsAlreadyDone")
  ifn_wl_trailn <- readIFN_WL_TrailN()
  if (!is.null(ifn_wl_trailn)) {
 
    return(ifn_wl_trailn[
      (!is.na(ifn_wl_trailn$sys_dt_done)
       || (is.na(ifn_wl_trailn$sys_dt_done) 
           & (Sys.time() <= (as.POSIXct(ifn_wl_trailn$sys_dt_started) + minutes(1)))))
      , c("plot_id")])
    
  }
  return(NULL)
}

readIFN_WL_TrailN <- function(){
  print("ifn_wl_trailn.csv")
  try(return(read.csv("./data/ifn_wl_trailn.csv")))
  return(NULL)
}

readIFN4 <- function(notIn_ids, rows){
  print("readIFN4")
  #TODO: use read.csv.sql filtering by not in notIn_ids
  ifn4 <- read.csv("./data/20220330_nfi_data.csv")[ 
    ,c('plot_id',
       'coords_longitude', 
       'coords_latitude', 
       'admin_province', 
       'admin_region', 
       'admin_municipality',
       'admin_aut_community',
       'topo_fdm_slope_percentage',
       'topo_altitude_asl' )]
  if(!is.null(notIn_ids)){
    ifn4 <- ifn4[!(ifn4$plot_id %in% notIn_ids),]
  }
  ifn4 <- ifn4[1:rows,]
  ifn4
}