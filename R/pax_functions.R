# TODO:
#  1) Go through all shell scripts and ensure they are calling functions 
#     from within the pax-package
#  2) Make a switch in all pax-functions: param: pax "shell" vs. "R"


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
#' The following directories are created in the working directory
#' \itemize{
#'   \item agelen
#'   \item avelewt
#'   \item catch_no
#'   \item data
#'   \item keys
#'   \item ldist
#'   \item par
#' } 
#' 
#' @export
#' 
#' @param Species A character of length 2 containing species number. E.g. "01"
#' for cod
#' @param Year Numerial specifying the year to be compiled
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
  
  # Generate a log file
  tmpfile <- file("LOGFILE",open="w")
  
  cat("A log file on the PAX\n",file=tmpfile,append=TRUE)
  cat("\nCalled function: pax_getdata\n",file=tmpfile,append=TRUE)
  cat(paste(" Started:",lubridate::now(),"\n"),file=tmpfile,append=TRUE)
  cat(paste(" Operating on year",Year,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" Operating on species",Species,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax shell scripts path:",pax_scripts,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax bin path:",pax_bin,"\n"),file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  
  if(!file.exists("agelen")) {
    dir.create("agelen")
    cat(" created directory: agelen \n",file=tmpfile,append=TRUE)
    }
  if(!file.exists("avelewt")) {
    dir.create("avelewt")
    cat(" created directory: avelewt \n",file=tmpfile,append=TRUE)
    }
  if(!file.exists("catch_no")) {
    dir.create("catch_no")
    cat(" created directory: catch_no \n",file=tmpfile,append=TRUE)
  }
  if(!file.exists("data")) {
    dir.create("data")
    cat(" created directory: data \n",file=tmpfile,append=TRUE)
    }
  
  if(!file.exists("par"))  {
    dir.create("par")
    cat(" created directory: par \n",file=tmpfile,append=TRUE)
  }

  path <- paste(path.package("pax"),'setup',sep='/')
  # note this replaces the 02makellist.sh
  cmd <- paste("cp -r -p ",path,"/",Species,"/ldist .",sep="")
  system(cmd)
  cat(paste(" ",cmd," \n",sep=""),file=tmpfile,append=TRUE)
  
  # note this replaces the 04makeklist.sh
  cmd <- paste("cp -r -p ",path,"/",Species,"/keys .",sep="")
  system(cmd)
  cat(paste(" ",cmd," \n\n",sep=""),file=tmpfile,append=TRUE)
  close(tmpfile)
}


#' @title Gets all relevant input data for generating catch in numbers
#' 
#' @description A wrapper around the (01)vpasksl.sh. The 
#' 
#' It is assumed user is on the 
#' hafro-net and has access to the /net/hafkaldi/export/u2/data directory
#' 
#' The following files are generated in the data directory
#' \itemize{
#'   \item sskyyyy.pre  otolith data
#'   \item sslyyyy.pre  length data
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
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scipts.
#' 
pax_getdata <- function(pax="shell") 
  {
  
  if(pax != "shell" | pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  if(pax=="shell") {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  system(paste(path,"01vpasksl.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("\nCalled function: pax_getdata\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 01vpasksl.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  
  return(NULL)
  }
  
  if(pax=="R") {
    message("R native implementation not yet available")
    return(NULL)
  }
  
}

#' @title Prepare length distributions
#' 
#' @description A wrapper around 03ldist_5cm.sh
#' 
#' Return files $k$i$j.len that contain the length distribution for gear $k,
#' region $i and season $j and $k$i$j.syni the synis_id.
#' 
#' @export
#' 
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scipts.
pax_prepare_length <- function(pax="shell") 
  {
  
  #if(pax != "shell" | pax != "R") stop('Specify either pax="shell" or pax="R"')

  if(pax=="shell") {
    path <- paste(path.package("pax"),'pax_scripts',sep='/')
    system(paste(path,"03ldist_5cm.sh",sep="/"))
    
    tmpfile <- file("LOGFILE",open="a")
    cat("Called function: pax_prepare_length\n",file=tmpfile,append=TRUE)
    cat(" invoked shell script 03ldist_5cm.sh\n",file=tmpfile,append=TRUE)
    cat(" \n",file=tmpfile,append=TRUE)
    close(tmpfile)
    return(NULL) 
  }
  
  if(pax=="R") {
    message("R native implementation not yet available")
    return(NULL)
  }
  
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
#' 
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scipts.
pax_agematurity <- function(pax="shell") 
  {
  
  #if(pax != "shell" | pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  if(pax=="shell") {  
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"05agematkey_5cm.kt.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_agematurity\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 05agematkey_5cm.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  return(NULL)
  }
  
  if(pax=="R") {
    message("R native implementation not yet available")
    return(NULL)
  }
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