#' @title PAX setup
#' 
#' @description Set the directory structure and copies the relevant base files
#' (only setup for cod).
#' 
#' @export
#' 
#' @param tegund A character of length 2 containing species number. E.g. "01"
#' for cod
#' @param ar Years for which to compile the catch in numbers
pax_setup <- function(tegund,ar) 
  {
  tmpfile <- file(".species",open='w')
  cat(tegund,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  tmpfile <- file(".year",open="w")
  cat(ar,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  tmpfile <- file(".pax_scripts",open='w')
  pax_scripts <- paste(path.package("pax"),'pax_scripts',sep='/')
  cat(pax_scripts,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  tmpfile <- file(".pax_bin",open='w')
  pax_bin <- paste(path.package("pax"),'pax_bin',sep='/')
  cat(pax_bin,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  #teg=`.species`
  #ar=`.year`
  #paxscripts=`.pax_scripts`
  #paxbin=`.pax_bin`
  
  # Generate a log file
  tmpfile <- file("LOGFILE",open="w")
  cat("A log file",append=TRUE)
  cat(paste(" Operating on year",ar),append=TRUE)
  cat(paste(" Operating on species",tegund),append=TRUE)
  cat(paste(" pax shell scripts path",pax_scripts),append=TRUE)
  cat(paste(" pax bin path",pax_bin),append=TRUE)
  cat(" ",append=TRUE)
  close(tmpfile)
  
  path <- paste(path.package("pax"),'setup',sep='/')
  system(paste("cp -r -p ",path,"/agelen .",sep=""))
  system(paste("cp -r -p ",path,"/avelewt .",sep=""))
  system(paste("cp -r -p ",path,"/catch_no .",sep=""))
  system(paste("cp -r -p ",path,"/keys .",sep=""))
  system(paste("cp -r -p ",path,"/ldist .",sep=""))
}


#' @title Gets all relevant input data for generating catch in numbers
#' 
#' @description Script calls 01vpasksl.sh
#' 
#' @export
#' 
pax_getdata <- function() 
  {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  system(paste(path,"01vpasksl.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 03ldist_5cm.sh
#' 
#' @export
pax_prepare_length <- function() 
  {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  system(paste(path,"03ldist_5cm.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 05agematkey_5cm.kt.sh
#' 
#' @export
pax_agematurity <- function() 
  {
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"05agematkey_5cm.kt.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 06agelen.kt.sh
#' 
#' @export
pax_agelength <- function() 
{
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"06agelen.kt.sh",sep="/"))
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 07avelewt.kt.sh
#' 
#' @export
pax_avelength <- function() 
{
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"07avelewt.kt.sh",sep="/"))
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 07avelewt.kt.sh
#' 
#' @export
pax_catchnum <- function() 
{
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"08catchnum.kt.sh",sep="/"))
}