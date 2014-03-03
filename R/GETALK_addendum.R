#' @title XXX
#' 
#' @export
#' 
#' @param mat XXX
#' @param fullmat XXX
#' @param add XXX

add.to.matrix <- 
  function(mat, fullmat, add = F)
  {
    tmpmat <- matrix(0., nrow(mat), ncol(fullmat))
    i <- match(dimnames(mat)[[2.]], dimnames(fullmat)[[2.]])
    tmpmat[, i] <- mat
    dimnames(tmpmat) <- list(dimnames(mat)[[1.]], dimnames(fullmat)[[2.]])
    i <- match(dimnames(tmpmat)[[1.]], dimnames(fullmat)[[1.]])
    if(add)
      fullmat[i,  ] <- fullmat[i,  ] + tmpmat
    else fullmat[i,  ] <- tmpmat
    return(fullmat)
  }
#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param dat XXX
#' @param gear XXX
#' @param Land.gear XXX
#' @param area XXX
#' @param month XXX

catch_by_month_and_bormicon <- function(dat,gear,Land.gear,area=c(1:10),month=c(1:12)) {
  
  tmp <- matrix(0,length(month),length(area))
  dimnames(tmp) <- list(month,area)
  
  i <- dat$area %in% area & dat$veman %in% month & dat$veidarf %in% gear

  res <- tapply(dat[,4][i],list(dat$area[i],dat$veman[i]),sum)
  res[is.na(res)] <- 0
  res <- add.to.matrix(t(res),tmp)
  res <- round(res*Land.gear[as.character(gear)]/sum(res))
  return(res)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param metier A character specifying the metier fro which to calculate catch at age.
#' @param catch A value, the total catch in the metier
#' @param stations A data.table containing station information
#' @param ages A data.table containing age readings
#' @param lengths A data.table containing length distributions
#' @param cond XXX
#' @param LE XXX
#' @param ALDUR XX
#' @param weight1 A value between 0 and 1. The weight in the alk given to otoliths from
#' other metiers within the regiona and time period. This shitmix can be turned
#' by setting value to zero.
#' @param weight2 A value between 0 and 1. The weight in the alk given to all otoliths
#' sampled in the year (including surveys). This shitmix can be turned
#' by setting value to zero.

calc_catch_at_age_by_metier <- function(metier,catch,
                                        stations,ages,lengths,
                                        cond,LE,ALDUR,weight1=0.01,weight2=0.0001)
{
  
  # dummy, just to pass R CMD check (always happens when using ddply)
  synis.id <- fjoldi <- NULL
  
  gear <- substr(metier,1,2)
  area <- substr(metier,3,4)
  period <- substr(metier,5,6)

  # Get data
  st <- stations[stations$index %in% metier,]
  ag <- ages[!is.na(match(ages$synis.id,st$synis.id)),]
  le <- lengths[!is.na(match(lengths$synis.id,st$synis.id)),]
  
  # Compile sample informations
  info <- ddply(st,"synaflokkur",summarise,samples=length(synis.id))
  if(nrow(ag) > 0) {
    x <- join(ag[,c("synis.id","fjoldi")],st[,c("synis.id","synaflokkur")],by="synis.id")
    x <- ddply(x,"synaflokkur",summarise,n.ages=sum(fjoldi,na.rm=T))
    info <- join(info,x,by="synaflokkur")
  } else {
    info$n.ages <- 0
  }
  
  if(nrow(le) > 0) {
    x <- join(le[,c("synis.id","fjoldi")],st[,c("synis.id","synaflokkur")],by="synis.id")
    x <- ddply(x,"synaflokkur",summarise,n.lengths=sum(fjoldi,na.rm=T))
    info <- join(info,x,by="synaflokkur")
  } else {
    info$n.lengths <- 0
  }
  
  # For otoliths some shitmix is done
  # Include samples from other gears within this period and region
  id.other.gear <- stations$synis.id[stations$reg %in% area &
                                     stations$time %in% period &
                                     stations$index != metier]
  ag.other.gear <- ages[!is.na(match(ages$synis.id,id.other.gear)),]
  ag.other.gear$fjoldi <- weight1
  
  # Include ALL otoliths from all areas and all gear with very low weight
  ag.all <- ages
  ag.all <- weight2
  
  ag <- rbind(ag,ag.other.gear,ag.all)
  
  
  keys <- MakeAlk(ag,1,kynth=F,lengd=LE,aldur=ALDUR,Stodvar=st,FilterAldurLengd=F)
  res <- MakeLdist(1,lengd=LE,Stodvar=st,lengdir=le,lengd.thyngd.data=cond,talid=F,afli=catch)
  
  
  res <- Calc.fj(keys,res)
  res$info <- info
  return(res)
}

#' @title XXX
#' 
#' @export
#' 
#' @param Year Year
#' @param Species Species code
#' @param Gear data.frame containg gear and metier specifications
#' @param Region data.frame containg bormicon area number and metier specifications
#' @param Period data.frame containing months and metier specifications
#' @param synaflokkur Numerical vector. Containing sampleclass to use.
read_pax_data <- function(Year,Species,Gear,Region,Period,synaflokkur) {
  
  stodvar <- lesa.stodvar(ar = Year, veidarfaeri = Gear$vf)

  
  if(!missing(synaflokkur)) {
    stodvar <- stodvar[stodvar$synaflokkur %in% synaflokkur,]
  }
  
  #inside.reg.bcbreytt is in StdHBlib includes shallow water samples else ignored.  
  stodvar <- inside.reg.bc(stodvar)

  stodvar <- stodvar[stodvar$area %in% Region$area,]
  stodvar$gear <- mapvalues(stodvar$veidarf, from=Gear$vf, to=Gear$metier)
  stodvar$region <- mapvalues(stodvar$area, from=Region$area, to=Region$metier)
  stodvar$period <- mapvalues(stodvar$man, from=Period$month, to=Period$metier)
  stodvar$index <- paste(stodvar$gear,stodvar$region,stodvar$period,sep="")
  
  kvarnir <- lesa.kvarnir(stodvar$synis.id, Species, c("kyn", "kynthroski","slaegt","oslaegt"))

  kvarnir <- kvarnir[!is.na(kvarnir$aldur),  ]
  kvarnir$fjoldi <- 1
  kvarnir <- join(kvarnir,stodvar[,c("synis.id","index")],"synis.id")
  
  # Ekki nota lengdir úr netaralli
  lengdir_synis.id <- stodvar$synis.id[stodvar$synaflokkur != 34]

  lengdir <- lesa.lengdir(lengdir_synis.id, Species)

  
  
  stodvar <- stodvar[!is.na(match(stodvar$synis.id,c(lengdir$synis.id,kvarnir$synis.id))),]
  
  return(list(stodvar=stodvar,lengdir=lengdir,kvarnir=kvarnir))
}