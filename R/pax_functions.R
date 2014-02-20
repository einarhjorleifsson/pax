#' @title PAX setup
#' 
#' @description Set the directory structure and copies the relevant base files
#' (only setup for cod).
#' 
#' @export
#' 
pax_setup <- function() 
  {
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
#' @param tegund A character of length 2 containing species number. E.g. "01"
#' for cod
#' @param ar Years for which to compile the catch in numbers
#' 
pax_getdata <- function(tegund,ar) 
  {
  path <- paste(path.package("pax"),'shell_scripts',sep='/')
  system(paste(path,"01vpasksl.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 03ldist_5cm.sh
#' 
pax_prepare_length <- function() 
  {
  path <- paste(path.package("pax"),'shell_scripts',sep='/')
  system(paste(path,"03ldist_5cm.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 05agematkey_5cm.kt.sh
#' 
pax_agematurity <- function() 
  {
  path <- paste(path.package("pax"),"shell_scripts",sep="/")
  system(paste(path,"05agematkey_5cm.kt.sh",sep="/"))
}

#' @title Prepare length distributions
#' 
#' @description Runs 06agelen.kt.sh
#' 
pax_agelength <- function() 
{
  path <- paste(path.package("pax"),"shell_scripts",sep="/")
  system(paste(path,"06agelen.kt.sh",sep="/"))
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 07avelewt.kt.sh
#' 
pax_avelength <- function() 
{
  path <- paste(path.package("pax"),"shell_scripts",sep="/")
  system(paste(path,"07avelewt.kt.sh",sep="/"))
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 07avelewt.kt.sh
#' 
pax_catchnum <- function() 
{
  path <- paste(path.package("pax"),"shell_scripts",sep="/")
  system(paste(path,"08catchnum.kt.sh",sep="/"))
}