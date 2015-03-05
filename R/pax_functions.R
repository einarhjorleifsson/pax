#' @title PAX setup
#' 
#' @description Set the directory structure and copies the relevant base files
#' (only setup for cod).
#' 
#' The following files are generated in the working directory
#' \itemize{
#'   \item .species Contains the MRI species code. E.g. cod has code "01" 
#'   \item .year Contains the year for which the catch at age is being calculated
#'   \item .pax_bin Path to the pax binary files
#'   \item .pax_path Path to the pax-package
#'   \item .pax_srcipts Path to the pax shell scripts
#'   \item LOGFILE - file that stores some logs
#' }
#' 
#' The following directories are copied to the working directory
#' \itemize{
#'   \item agelen
#'   \item avelewt
#'   \item catch_no
#'   \item keys
#'   \item ldist
#' } 
#' 
#' @export
#' 
#' @param Species A character of length 2 containing species number. E.g. "01"
#' for cod
#' @param Year Year for which to compile the catch in numbers
pax_setup <- function(Species,Year) 
  {
  tmpfile <- file(".species",open='w')
  cat(Species,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  tmpfile <- file(".year",open="w")
  cat(Year,file=tmpfile,append=TRUE)
  close(tmpfile)
  
  tmpfile <- file(".pax_path",open='w')
  pax_path <- path.package("pax")
  cat(pax_path,file=tmpfile,append=TRUE)
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
  cat("A log file on the PAX\n",file=tmpfile,append=TRUE)
  cat(paste(" Started:",lubridate::now(),"\n"),file=tmpfile,append=TRUE)
  cat(paste(" Operating on year",Year,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" Operating on species",Species,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax shell scripts path",pax_scripts,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax bin path",pax_bin,"\n"),file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
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
#' @description A wrapper around 01vpasksl.sh  It is assumed user is on the 
#' hafro-net and has access to the /net/hafkaldi/export/u2/data directory
#' 
#' The following files are generated in the data directory
#' \itemize{
#'   \item sskyyyy.pre
#'   \item sslyyyy.pre
#'   \item ssskyyyy.pre
#'   \item ssslyyyy.pre
#'   \item k
#'   \item l
#'   \item stod
#'   \item t
#' }
#' 
#' In addition relevant control files (v, s and t files) are made in the keys
#' and ldist directory
#' 
#' @export
#' 
pax_getdata <- function() 
  {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  system(paste(path,"01vpasksl.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_getdata\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 01vpasksl.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  
}

#' @title Prepare length distributions
#' 
#' @description A wrapper around 03ldist_5cm.sh
#' 
#' Return files $k$i$j.len that contain the length distribution for gear $k,
#' region $i and season $j and $k$i$j.syni the synis_id.
#' 
#' @export
pax_prepare_length <- function() 
  {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  system(paste(path,"03ldist_5cm.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_prepare_length\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 03ldist_5cm.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
}

#' @title Prepare length distributions
#' 
#' @description Runs 05agematkey_5cm.kt.sh
#' 
#' Obtain age-length keys and maturity keys based on otolith samples 
#' i.e. the number of fish with each age-length-sex 
#' combination, based on the age-determined data.
#' 
#' @export
pax_agematurity <- function() 
  {
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"05agematkey_5cm.kt.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_agematurity\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 05agematkey_5cm.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
}

#' @title Skitamix
#' 
#' @description Skitamix
#' 
#' @export
pax_combinekeys <- function()
{
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"CombineKeys.sh",sep="/"))
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
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_agelength\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 06agelen.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
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
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_avelength\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 07avelewt.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 08catchnum.kt.sh
#' 
#' @export
pax_catchnum <- function() 
{
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"08catchnum.kt.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_catchnum\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 08catchnum.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
}