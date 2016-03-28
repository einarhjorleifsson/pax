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
  
  cat("A log file on the PAX\n\n",file=tmpfile,append=TRUE)
  cat("Called function: pax_setup\n\n",file=tmpfile,append=TRUE)
  cat(paste(" R working directory:   ",getwd(),"\n\n",sep=""),file=tmpfile,append=TRUE)
  cat(paste(" started:               ",lubridate::now(),"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax path:              ",pax_path,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax shell scripts path:",pax_scripts,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" pax bin path:          ",pax_bin,"\n\n"),file=tmpfile,append=TRUE)
  
  cat(paste(" operating on year:     ",Year,"\n"),file=tmpfile,append=TRUE)
  cat(paste(" operating on species:  ",Species,"\n\n"),file=tmpfile,append=TRUE)
  
  cat(" created the following directories:\n",file=tmpfile,append=TRUE)
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
#' @description A wrapper around the (01)vpasksl.sh.
#' 
#' When pax="shell" user has to have access to the /net/hafkaldi/export/u2/data directory.
#' When pax="R" the user can specify the path to the data. The directory within
#' is assumed to be the same as the net-directory.
#' 
#' The following files are generated in the current working directory
#' \itemize{
#'   \item data/sskyyyy.pre  otolith data
#'   \item data/sslyyyy.pre  length data
#'   \item data/ssskyyyy.pre otolith station data
#'   \item data/ssslyyyy.pre length station data
#'   \item data/k
#'   \item data/l
#'   \item data/stod detail station data
#'   \item data/t
#' }
#' 
#' In addition relevant control files (v, s and t files) are made in the keys
#' and ldist directory
#' 
#' @export
#' 
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scripts.
#' @param path The path to the data. Only works if pax="R". If missing (default)
#' the data is obtained from: /net/hafkaldi/export/u2/data.
pax_getdata <- function(pax="shell",path) 
  {
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  record_id <- dag <- man <- reit <- smrt <- vf <- lnr <-
    lfj <- knr <- kfj <- 0
  
  if(pax=="shell") {
  path <- paste(path.package("pax"),'pax_scripts',sep='/')
  cmd <- paste(path,"01vpasksl.sh",sep="/")
  system(cmd)
  
  tmpfile <- file("LOGFILE",open="a")
  cat("\nCalled function: pax_getdata\n",file=tmpfile,append=TRUE)
  cat(paste(" invoked: ",cmd,"\n",sep=""),file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  
  return(invisible(NULL))
  }
  
  if(pax=="R") {
    
    Species <- scan(".species", quiet=TRUE)
    Species <- ifelse(Species < 10,paste("0",Species,sep=""),Species)
    Year    <- scan(".year", quiet=TRUE)
    
    # read files
    if(missing(path)) path <- "/net/hafkaldi/export/u2/data/"
    fi <- paste(path,Species,"/",Species,"k",Year,".pre",sep="")
    if(file.exists) {
      kfile <- fishvice::read_prelude(fi)
    } else {
      stop(paste(fi,"does not exist. Stopped trying"))
    }
    fi <- paste(path,Species,"/",Species,"l",Year,".pre",sep="")
    lfile <- fishvice::read_prelude(fi)
    fi <- paste(path,Species,"/",Species,"n",Year,".pre",sep="")
    nfile <- fishvice::read_prelude(fi)
    fi <- paste(path,"stodvar/s",Year,".pre",sep="")
    sfile <- fishvice::read_prelude(fi)
    
    # write files
    stod <- 
      dplyr::select(sfile,record_id,ar,dag,man,reit,smrt,vf) %>%
      dplyr::arrange(record_id)
    fishvice::write_prelude(stod,"data/stod")
    
    sl <- nfile %>%
      dplyr::select(record_id,lnr,lfj) %>%
      dplyr::arrange(record_id) %>%
      dplyr::left_join(stod,by="record_id") %>%
      dplyr::select(lnr,dag,man,ar,reit,smrt,vf,lfj) %>%
      dplyr::filter(lfj > 0) %>%
      dplyr::arrange(lnr)
    fishvice::write_prelude(sl,"data/01sl2014.pre")
    
    l <- dplyr::select(sl,lnr)
    fishvice::write_prelude(l,"data/l")
    
    lfile <- filter(lfile,lnr %in% l$lnr)
    fishvice::write_prelude(lfile, "data/01l2014.pre")
    
    sk <- nfile %>%
      dplyr::select(record_id,knr,kfj) %>%
      dplyr::arrange(record_id) %>%
      dplyr::left_join(stod,by="record_id") %>%
      dplyr::select(knr,dag,man,ar,reit,smrt,vf,kfj) %>%
      dplyr::filter(knr > 0) %>%
      dplyr::arrange(knr)
    fishvice::write_prelude(sk,"data/01sk2014.pre")
    
    k <- dplyr::select(sk,knr)
    fishvice::write_prelude(k,"data/k")
    
    kfile <- dplyr::filter(kfile,knr %in% k$knr)
    fishvice::write_prelude(kfile, "data/01k2014.pre")
    
    return(invisible(NULL))
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
#' If "R" (not implemented yet) runs native R scripts.
pax_prepare_length <- function(pax="shell") 
  {
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')

  v <- s <- index <- lnr <- fj <- le <- bin <- lemultfj <- 0
  
  if(pax=="shell") {
    path <- paste(path.package("pax"),'pax_scripts',sep='/')
    system(paste(path,"03ldist_5cm.sh",sep="/"))
    
    tmpfile <- file("LOGFILE",open="a")
    cat("Called function: pax_prepare_length\n",file=tmpfile,append=TRUE)
    cat(" invoked shell script 03ldist_5cm.sh\n",file=tmpfile,append=TRUE)
    cat(" \n",file=tmpfile,append=TRUE)
    close(tmpfile)
    return(invisible(NULL)) 
  }
  
  if(pax=="R") {
    
    # the metier specification in the ldist directory 
    metier <- dir("ldist")
    i <- stringr::str_detect(metier,".text") | 
      stringr::str_detect(metier,".len") | 
      stringr::str_detect(metier,".syni") |
      stringr::str_detect(metier,"nafn")
    metier <- metier[!i]
    # svæði
    tmp <- metier[stringr::str_detect(metier,"s")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("ldist",tmp[i],sep="/"))
      x$s <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        area <- x
      } else {
        area <- rbind(area,x)
      }
    }
    # timi
    tmp <- metier[stringr::str_detect(metier,"t")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("ldist",tmp[i],sep="/"))
      x$t <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        season <- x
      } else {
        season <- rbind(season,x)
      }
    }
    # veidarfaeri
    tmp <- metier[stringr::str_detect(metier,"v")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("ldist",tmp[i],sep="/"))
      x$v <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        gear <- x
      } else {
        gear <- rbind(gear,x)
      }
    }
    gear <- gear[,c("vf","v")]
    metier <- expand.grid(v=unique(gear$v),
                          s=unique(area$s),
                          t=unique(season$t))
    metier <- metier %>% dplyr::mutate(index=paste("v",v,"s",s,"t",t,sep=""))
    
    hausar  <- fishvice::read_prelude("data/01sl2014.pre")
    # Set metier index to samples
    hausar <- hausar %>%
      dplyr::left_join(area,by="reit") %>%
      dplyr::left_join(season,by="man") %>%
      dplyr::left_join(gear,by="vf") %>%
      dplyr::mutate(index=paste("v",v,"s",s,"t",t,sep="")) %>%
      dplyr::filter(index %in% metier$index) %>%
      dplyr::select(lnr,index)
    
    # Set metier index to lengdir
    lengdir <- fishvice::read_prelude("data/01l2014.pre")
    lengdir <- dplyr::left_join(lengdir,hausar,by="lnr") %>%
      dplyr::filter(index %in% metier$index)
    
    syni <- lengdir %>%
      dplyr::group_by(index,lnr) %>%
      dplyr::summarise(fj=sum(fj))
    syni <- as.data.frame(syni)
    
    
    # write to file
    for (i in 1:nrow(metier)) {
      x <- dplyr::filter(syni,index %in% metier$index[i]) %>% 
        dplyr::select(lnr,fj)
      fishvice::write_prelude(x,file=paste("ldist/",metier$index[i],".syni",sep=""))
    }
    
    # Calclate length frequencies (5 cm interval)
    length_bins <- data.frame(le=c(5:199),
                              bin=rep(seq(7,197,by=5),each=5))
    lengdir <- dplyr::left_join(lengdir,length_bins,by="le") %>%
      dplyr::mutate(lemultfj=le*fj) %>%
      dplyr::group_by(index,bin) %>%
      dplyr::summarise(fj=sum(fj),lemultfj=sum(lemultfj)) %>%
      dplyr::select(index,bin,fj,lemultfj) %>%
      dplyr::rename(le=bin)
    
    lengdir <- as.data.frame(lengdir)
    lengdir$le <- as.integer(lengdir$le)
    lengdir <- lengdir[!is.na(lengdir$le),]
    lengdir$lemultfj <- as.integer(lengdir$lemultfj)
    # write to file
    # NOTE THE ERRORS HERE ARE OF MINOR IMPORTANCE
    #  seem to be associated with PAX more than the current algorith
    #  This may though cause further error message down the line
    for (i in 1:nrow(metier)) {
      x <- dplyr::filter(lengdir,index %in% metier$index[i]) %>% 
        dplyr::select(le,fj,lemultfj)
      fishvice::write_prelude(x,file=paste("ldist/",metier$index[i],".syni",sep=""))
    }
    return(invisible(NULL))
  }
  
}

#' @title Age and maturity
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
#' If "R" (not implemented yet) runs native R scripts.
pax_agematurity <- function(pax="shell") 
  {
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  v <- s <- index <- knr <- aldur <- le <- bin <- 
    kt <- kt0 <- kt1 <- ktcount <- 0
  
  if(pax=="shell") {  
  path <- paste(path.package("pax"),"pax_scripts",sep="/")
  system(paste(path,"05agematkey_5cm.kt.sh",sep="/"))
  
  tmpfile <- file("LOGFILE",open="a")
  cat("Called function: pax_agematurity\n",file=tmpfile,append=TRUE)
  cat(" invoked shell script 05agematkey_5cm.kt.sh\n",file=tmpfile,append=TRUE)
  cat(" \n",file=tmpfile,append=TRUE)
  close(tmpfile)
  return(invisible(NULL))
  }
  
  if(pax=="R") {
    
    # the metier specification in the keys directory 
    metier <- dir("keys")
    i <- stringr::str_detect(metier,".text") | 
      stringr::str_detect(metier,"key") | 
      stringr::str_detect(metier,".syni") |
      stringr::str_detect(metier,"nafn") |
      stringr::str_detect(metier,"ages") |
      stringr::str_detect(metier,"lengths") |
      stringr::str_detect(metier,"cond")
    metier <- metier[!i]
    # svæði
    tmp <- metier[stringr::str_detect(metier,"s")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("keys",tmp[i],sep="/"))
      x$s <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        area <- x
      } else {
        area <- rbind(area,x)
      }
    }
    # timi
    tmp <- metier[stringr::str_detect(metier,"t")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("keys",tmp[i],sep="/"))
      x$t <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        season <- x
      } else {
        season <- rbind(season,x)
      }
    }
    # veidarfaeri
    tmp <- metier[stringr::str_detect(metier,"v")]
    for (i in 1:length(tmp)) {
      x <- fishvice::read_prelude(paste("keys",tmp[i],sep="/"))
      x$v <- stringr::str_sub(tmp[i],2)
      if(i == 1) {
        gear <- x
      } else {
        gear <- rbind(gear,x)
      }
    }
    gear <- gear[,c("vf","v")]
    metier <- expand.grid(v=unique(gear$v),
                          s=unique(area$s),
                          t=unique(season$t))
    metier <- metier %>% 
      dplyr::mutate(index=paste("v",v,"s",s,"t",t,sep=""))
    
    hausar  <- fishvice::read_prelude("data/01sk2014.pre")
    # Set metier index to samples
    hausar <- hausar %>%
      dplyr::left_join(area,by="reit") %>%
      dplyr::left_join(season,by="man") %>%
      dplyr::left_join(gear,by="vf") %>%
      dplyr::mutate(index=paste("v",v,"s",s,"t",t,sep="")) %>%
      dplyr::filter(index %in% metier$index) %>%
      dplyr::select(knr,index)
    
    # Set metier index to lengdir
    kvarnir <- fishvice::read_prelude("data/01k2014.pre")
    kvarnir <- dplyr::left_join(kvarnir,hausar,by="knr") %>%
      dplyr::filter(aldur != -1) %>%
      dplyr::filter(le != -1) %>%
      dplyr::filter(index %in% metier$index)
    
    
    syni <- kvarnir %>%
      dplyr::group_by(index,knr) %>%
      dplyr::summarise(count=length(knr)) %>%
      dplyr::arrange(knr)
    syni <- as.data.frame(syni)
    # write to file
    for (i in 1:nrow(metier)) {
      x <- dplyr::filter(syni,index %in% metier$index[i]) %>% 
        dplyr::select(knr,count)
      if(nrow(x) > 0) {
        # EINAR - pretty sure this is supposed to key directory keys
        fishvice::write_prelude(x,file=paste("keys/",metier$index[i],".syni",sep=""))
      }
    }
    
    # Calclate length frequencies (5 cm interval)
    length_bins <- data.frame(le=c(5:199),
                              bin=rep(seq(7,197,by=5),each=5))
    tmp <- dplyr::left_join(kvarnir,length_bins,by="le") %>%
      dplyr::group_by(index,bin,aldur) %>%
      dplyr::select(-le) %>%
      dplyr::rename(le=bin) %>%
      dplyr::mutate(kt0 = kt %in% 1,kt1 = kt %in% c(2:32)) %>%
      dplyr::summarise(count=length(le),kt0=sum(kt0),kt1=sum(kt1),ktcount=kt0+kt1)
    
    tmp <- as.data.frame(tmp)
    # write to file
    for (i in 1:nrow(metier)) {
      x <- dplyr::filter(tmp,index %in% metier$index[i]) %>%
        dplyr::select(le,aldur,count,kt0,kt1,ktcount)
      x$le <- as.integer(x$le)
      fishvice::write_prelude(x,file=paste("keys/",metier$index[i],".key",sep=""))
    }
    return(invisible(NULL))
  }
}

#' @title Skitamix
#' 
#' @description Skitamix
#' 
#' @export
#' 

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
#' 
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scripts.

pax_agelength <- function(pax="shell") 
{
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  Kl <- fj <- Cl <- Kalk <- aldur <- kt0 <- kt1 <- 0

  if(pax=="shell") {
    
    path <- paste(path.package("pax"),"pax_scripts",sep="/")
    system(paste(path,"06agelen.kt.sh",sep="/"))
    
    tmpfile <- file("LOGFILE",open="a")
    cat("Called function: pax_agelength\n",file=tmpfile,append=TRUE)
    cat(" invoked shell script 06agelen.kt.sh\n",file=tmpfile,append=TRUE)
    cat(" \n",file=tmpfile,append=TRUE)
    close(tmpfile)
    
    return(invisible(NULL))
  }

  if(pax=="R") {
    
    key_files <- dir("keys",pattern=c(".key"))
    key_files <- key_files[nchar(key_files) %in% 10]
    le_files  <- dir("ldist",pattern=c(".len"))
    le_files <- le_files[nchar(key_files) %in% 10]
    
    for(j in 1:length(key_files)) {
      
      key <- fishvice::read_prelude(paste("keys/",key_files[j],sep=""))
      
      if(!is.null(key)) {
        
        le  <- fishvice::read_prelude(paste("ldist/",le_files[j],sep=""))
        index <- stringr::str_sub(key_files[j],1,6)
        
        tmp.Kl <- key %>%
          dplyr::select(le,count) %>%
          dplyr::rename(Kl=count) %>%
          dplyr::arrange(le) %>%
          dplyr::group_by(le) %>%
          dplyr::summarise(Kl=sum(Kl))
        
        tmp.Kalk <- key %>%
          dplyr::select(aldur, le, kt0, kt1, count) %>%
          dplyr::filter(aldur > 0) %>%
          dplyr::rename(Kalk = count) %>%
          dplyr::arrange(aldur)
        
        tmp1 <- le %>%
          dplyr::select(le, fj) %>%
          dplyr::rename(Cl=fj) #%>%
          #dplyr::left_join(tmp.Kl, by="le") %>%
          #dplyr::left_join(tmp.Kalk, by="le") %>%
          #dplyr::select(le,aldur,kt0,kt1,Kl,Cl,Kalk) %>%
          #dplyr::mutate(Calk=0,Calkt0=0,Calkt1=0) %>%
          #dplyr::filter(aldur %in% 1:14)
        
        tmp2 <- tmp1 %>%
          dplyr::left_join(tmp.Kl, by="le")
        
        tmp3 <- tmp2 %>%
          dplyr::left_join(tmp.Kalk, by="le")
        
        tmp4 <- tmp3 %>%
          dplyr::select(le,aldur,kt0,kt1,Kl,Cl,Kalk) %>%
          dplyr::mutate(Calk=0,Calkt0=0,Calkt1=0)
        
        tmp5 <- tmp4[tmp4$aldur %in% 1:14,]
        
        i <- tmp5$Kl > 0 & !is.na(tmp5$Kl)
        tmp5$Calk[i] <- tmp5$Kalk[i]/tmp5$Kl[i] * tmp5$Cl[i]
        
        i <- tmp5$kt0 + tmp5$kt1 > 0 #& !is.na(tmp5$kt0) & !is.na(tmp5$kt1)
        tmp5$Calkt0[i] <- tmp5$kt0[i]/(tmp5$kt0[i]+tmp5$kt1[i]) * (tmp5$Kalk[i]/tmp5$Kl[i])*tmp5$Cl[i]
        tmp5$Calkt1[i] <- tmp5$kt1[i]/(tmp5$kt0[i]+tmp5$kt1[i]) * (tmp5$Kalk[i]/tmp5$Kl[i])*tmp5$Cl[i]
        
        tmp5 <- dplyr::arrange(tmp5,le,aldur)
        
        fishvice::write_prelude(tmp5,file=paste("agelen/",index[j],".a_l_k",sep=""))
      }
    }
    return(invisible(NULL))
  }
  
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 07avelewt.kt.sh
#' 
#' @export
#'
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scripts.

pax_avelength <- function(pax="shell") 
{
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  Calk <- le <- aldur <- Cal <- wbara <- per_wt <- per_no <-
    lbara <- stdev <- Calkt0 <- Calkt1 <- kt0 <- kt1 <- per_mat <- 0
  
  
  if(pax=="shell") {
    path <- paste(path.package("pax"),"pax_scripts",sep="/")
    system(paste(path,"07avelewt.kt.sh",sep="/"))
    
    tmpfile <- file("LOGFILE",open="a")
    cat("Called function: pax_avelength\n",file=tmpfile,append=TRUE)
    cat(" invoked shell script 07avelewt.kt.sh\n",file=tmpfile,append=TRUE)
    cat(" \n",file=tmpfile,append=TRUE)
    close(tmpfile)
    return(invisible(NULL))
  }
  
  if(pax=="R") {
    alk_files <- dir("agelen",pattern=c(".a_l_k"))
    metier <- stringr::str_sub(alk_files,1,6)
    cond <- fishvice::read_prelude("keys/cond")
    
    for(j in 1:length(alk_files)) {
      
      #print(paste(j, metier[j]))
      
      alk <- fishvice::read_prelude(paste("agelen/",alk_files[j],sep=""))
      
      if(!is.null(alk)) {
        a <- cond$condition[cond$vst %in% metier[j]]
        b <- cond$power[cond$vst %in% metier[j]] 
        
        tmp1 <- alk %>%
          dplyr::rename(Cal=Calk) %>%
          dplyr::group_by(le,aldur) %>% #??
          dplyr::summarise(Cal=sum(Cal)) %>%
          dplyr::select(aldur, Cal, le) %>%
          dplyr::mutate(wbara = 0, lbara=0) %>%
          dplyr::arrange(aldur)
        
        
        tmp2 <- tmp1 %>%
          dplyr::mutate(wbara = Cal * a * le^b,
                        lbara = le * Cal)
        
        totfre <- sum(tmp2$Cal)
        totwt  <- sum(tmp2$wbara)
        
        tmp3 <- tmp2 %>%
          dplyr::select(aldur, Cal, wbara) %>%
          dplyr::mutate(per_wt = wbara / totwt,
                        per_no = Cal / totfre)
        
        tmp4 <- tmp3 %>%
          dplyr::group_by(aldur) %>%
          dplyr::summarise(Cal=sum(Cal),wbara=sum(wbara),per_wt=sum(per_wt),per_no=sum(per_no))
        
        tmp5 <- tmp4 %>%
          dplyr::select(aldur, per_wt, per_no)
        
        tmp6 <- tmp2 %>%
          dplyr::group_by(aldur) %>%
          dplyr::summarise(Cal=sum(Cal),wbara=sum(wbara),lbara=sum(lbara)) %>%
          dplyr::mutate(wbara=wbara/Cal,lbara=lbara/Cal)
        
        tmpstdev <- tmp1 %>%
          dplyr::select(aldur, Cal, le)
        tmpstdev1 <- tmp6 %>%
          dplyr::select(aldur, lbara)
        tmpstdev2 <- dplyr::left_join(tmpstdev,tmpstdev1,by="aldur")
        tmp7 <- tmp2 %>%
          dplyr::mutate(stdev = Cal * (le - lbara) * (le - lbara)) %>%
          dplyr::group_by(aldur) %>%
          dplyr::summarise(Cal=sum(Cal),stdev=sum(stdev)) %>%
          dplyr::mutate(stdev=ifelse(Cal>1,sqrt(stdev/(Cal-1)),0))
        
        tmp7$stdev <- ifelse(tmp7$Cal,sqrt(tmp7$stdev/(tmp7$Cal - 1)),0)
        
        tmp8 <- dplyr::left_join(tmp5,tmp6, by="aldur")
        tmp9 <- dplyr::left_join(tmp8,tmp7, by="aldur")
        tmp10 <- tmp9 %>%
          dplyr::select(aldur, wbara, lbara, stdev, per_no, per_wt)
        
        tmp11 <- alk %>%
          dplyr::select(aldur, Calkt0, Calkt1) %>%
          dplyr::rename(kt0=Calkt0,kt1=Calkt1) %>%
          dplyr::arrange(aldur) %>%
          dplyr::group_by(aldur) %>%
          dplyr::summarise(kt0=sum(kt0),kt1=sum(kt1))
        tmp12 <- tmp11 %>%
          dplyr::mutate(per_mat = ifelse(kt0+kt1 > 1,kt1/(kt0+kt1),-1))
        tmp13 <- tmp12 %>%
          dplyr::select(aldur, per_mat)
        tmp14 <- dplyr::left_join(tmp10,tmp13,by="aldur") %>%
          dplyr::mutate(meanwt=totwt/totfre)
        tmp14 <- as.data.frame(tmp14)
        fishvice::write_prelude(tmp14,file=paste("avelewt/",metier[j],".lewt",sep=""))
      }
    }
    return(invisible(NULL))
  }
  
}

#' @title Compute average lengths etc.
#' 
#' @description Runs 08catchnum.kt.sh
#' 
#' @export
#' 
#' @param pax character, "shell" (default) calls "original" shell scripts.
#' If "R" (not implemented yet) runs native R scipts.

pax_catchnum <- function(pax="shell") 
{
  
  if(pax != "shell" & pax != "R") stop('Specify either pax="shell" or pax="R"')
  
  if(pax=="shell") {
    path <- paste(path.package("pax"),"pax_scripts",sep="/")
    system(paste(path,"08catchnum.kt.sh",sep="/"))
    
    tmpfile <- file("LOGFILE",open="a")
    cat("Called function: pax_catchnum\n",file=tmpfile,append=TRUE)
    cat(" invoked shell script 08catchnum.kt.sh\n",file=tmpfile,append=TRUE)
    cat(" \n",file=tmpfile,append=TRUE)
    close(tmpfile)
    return(invisible(NULL))
  }
  
  if(pax=="R") {
    message("R native implementation not yet available")
    return(invisible(NULL))
  }
  
}