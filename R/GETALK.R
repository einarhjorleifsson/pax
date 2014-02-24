#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param kvarnir XXX
#' @param tegund XXX
#' @param kyn XXX
#' @param kynth  XXX
#' @param okynth.gildi XXX
#' @param kynth.gildi XXX
#' @param lengd XXX
#' @param aldur XXX
#' @param Stodvar XXX
#' @param FilterAldurLengd XXX
#' @param NAOkynthAge XXX

MakeAlk <- function (kvarnir, tegund, kyn = F, kynth = F, okynth.gildi = 1, 
                     kynth.gildi = c(2:4), lengd, aldur, Stodvar, FilterAldurLengd = T, 
                     NAOkynthAge = 3) 
{
  medalle <- (lengd[-length(lengd)] + lengd[-1])/2
  if (missing(kvarnir)) 
    kvarnir <- lesa.kvarnir(Stodvar$synis.id, tegund, c("kyn", 
                                                        "kynthroski"))
  else if (is.na(match("kynthroski", names(kvarnir)))) 
    kvarnir$kynthroski <- rep(1, nrow(kvarnir))
  if (is.na(match("kyn", names(kvarnir)))) 
    kvarnir$kyn <- rep(1, nrow(kvarnir))
  kvarnir <- kvarnir[!is.na(kvarnir$aldur), ]
  kvarnir <- kvarnir[!is.na(match(kvarnir$aldur, aldur)), ]
  if (FilterAldurLengd) {
    kvarnir <- kv.filter(kvarnir, tegund)
  }
  if (kyn) 
    kvarnir <- kvarnir[!is.na(match(kvarnir$kyn, c(1, 2))), 
                       ]
  if (kynth) {
    i <- kvarnir$aldur <= NAOkynthAge & is.na(kvarnir$kynthroski)
    kvarnir$kynthroski[i] <- okynth.gildi
    kvarnir <- kvarnir[!is.na(kvarnir$kynthroski) & !is.na(match(kvarnir$kynthroski, 
                                                                 c(kynth.gildi, okynth.gildi))), ]
    i <- !is.na(match(kvarnir$kynthroski, okynth.gildi))
    kvarnir$Kynth[i] <- 0
    i <- !is.na(match(kvarnir$kynthroski, kynth.gildi))
    kvarnir$Kynth[i] <- 1
  }
  else kvarnir$Kynth <- rep(0, nrow(kvarnir))
  if (is.na(match("fjoldi", names(kvarnir)))) 
    kvarnir$fjoldi <- rep(1, nrow(kvarnir))
  kvarnir$lenfl <- cut(kvarnir$lengd, breaks = lengd)
  kvarnir <- kvarnir[!is.na(match(kvarnir$aldur, aldur)) & 
                       !is.na(kvarnir$lenfl), ]
  n <- length(medalle)
  n1 <- length(aldur)
  tmp.data <- data.frame(aldur = rep(aldur[1], n), lengd = medalle, 
                         Kynth = rep(0, n), kyn = rep(1, n), fjoldi = rep(0, n))
  tmp.data <- rbind(tmp.data, data.frame(aldur = aldur, lengd = rep(medalle[1], 
                                                                    n1), Kynth = rep(1, n1), kyn = rep(2, n1), fjoldi = rep(0, 
                                                                                                                            n1)))
  tmp.data <- rbind(tmp.data, kvarnir[, names(tmp.data)])
  tmp.data$lenfl <- cut(tmp.data$lengd, breaks = lengd)
  OTH.TOT <- tapply(tmp.data$fjoldi, list(tmp.data$lenfl, tmp.data$aldur), 
                    sum)
  OTH.TOT[is.na(OTH.TOT)] <- 0
  ALK.TOT <- Calc.ALK(OTH.TOT, kvarnir, aldur, lengd)
  if (kynth) {
    i <- tmp.data$Kynth == 1
    OTH.KYNTH <- tapply(tmp.data$fjoldi[i], list(tmp.data$lenfl[i], 
                                                 tmp.data$aldur[i]), sum)
    OTH.KYNTH[is.na(OTH.KYNTH)] <- 0
    ALK.KYNTH <- Calc.ALK.KYNTH(OTH.KYNTH, OTH.TOT, ALK.TOT, 
                                kvarnir, aldur, lengd)
  }
  if (kyn) {
    i <- tmp.data$kyn == 2
    OTH.FEMALE <- tapply(tmp.data$fjoldi[i], list(tmp.data$lenfl[i], 
                                                  tmp.data$aldur[i]), sum)
    OTH.FEMALE[is.na(OTH.FEMALE)] <- 0
    ALK.FEMALE <- Calc.ALK.KYN(OTH.FEMALE, OTH.TOT, ALK.TOT, 
                               kvarnir, aldur, lengd)
  }
  utkoma <- list()
  utkoma$ALK.TOT <- ALK.TOT
  utkoma$OTH.TOT <- OTH.TOT
  class(utkoma) <- c("ALK1", "list")
  if (kynth) {
    utkoma$ALK.KYNTH <- ALK.KYNTH
    utkoma$OTH.KYNTH <- OTH.KYNTH
    class(utkoma) <- c(class(utkoma), "ALK.KYNTH")
    attr(utkoma, "KYNTH") <- T
  }
  if (kyn) {
    utkoma$ALK.FEMALE <- ALK.FEMALE
    utkoma$OTH.FEMALE <- OTH.FEMALE
    utkoma$ALK.MALE <- utkoma$ALK.TOT - utkoma$ALK.FEMALE
    utkoma$OTH.MALE <- utkoma$OTH.TOT - utkoma$OTH.FEMALE
    attr(utkoma, "KYN") <- T
    class(utkoma) <- c(class(utkoma), "ALK.KYN")
  }
  attr(utkoma, "lengd") <- lengd
  attr(utkoma, "aldur") <- aldur
  attr(utkoma, "medalle") <- medalle
  attr(utkoma, "get.alk.call") <- match.call()
  return(utkoma)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param tegund XXX
#' @param kyn XXX
#' @param kynth XXX
#' @param okynth.gildi XXX
#' @param kynth.gildi XXX
#' @param lengd XXX
#' @param Stodvar XXX
#' @param lengd.thyngd.data XXX
#' @param lengdir XXX
#' @param numer XXX
#' @param talid XXX
#' @param afli XXX
#' @param std.toglengd XXX
#' @param trollbreidd XXX
#' @param area XXX

MakeLdist <-
function (tegund, kyn = F, kynth = F, okynth.gildi = 1, kynth.gildi = 2, 
          lengd, Stodvar, lengd.thyngd.data, lengdir, numer, talid = T, 
          afli = NULL, std.toglengd = NULL,
          trollbreidd, area)  # EH added 
{
  medalle <- (lengd[-length(lengd)] + lengd[-1])/2
  col.names <- c("lengd", "synis.id", "fjoldi")
  if (kynth) 
    col.names <- c(col.names, "kynthroski")
  if (kyn) 
    col.names <- c(col.names, "kyn")
  if (!missing(lengd.thyngd.data)) 
    WT <- T
  else WT <- F
  if (missing(lengdir)) 
    lengdir <- lesa.lengdir(Stodvar$synis.id, tegund, col.names)
  else if (!missing(Stodvar)) 
    lengdir <- lengdir[!is.na(match(lengdir$synis.id, Stodvar$synis.id)), 
                       ]
  lengdir <- lengdir[!is.na(cut(lengdir$lengd, lengd)), ]
  if (talid) {
    if (missing(numer)) 
      numer <- lesa.numer(Stodvar$synis.id, tegund)
    lengdir <- Skala.med.toldum(lengdir, numer)
  }
  else lengdir$fj.alls <- lengdir$fjoldi
  if (is.na(match("kyn", names(lengdir)))) 
    lengdir$kyn <- rep(1, nrow(lengdir))
  if (is.na(match("kynth", names(lengdir)))) 
    lengdir$kynth <- rep(1, nrow(lengdir))
  lengdir$wt <- rep(1, nrow(lengdir))
  if (!is.null(afli)) {
    lengdir <- Reikna.thyngd(lengdir, lengd.thyngd.data)
    lengdir <- Skala.med.afla(lengdir, afli)
  }
  if (!is.null(std.toglengd)) 
    lengdir <- Skala.med.toglengd(lengdir, trollbreidd, area)
  col.names <- c(col.names, "fj.alls")
  tmp.data <- data.frame(synis.id = rep(lengdir$synis.id[1], 
                                        length(medalle)), lengd = medalle, fjoldi = rep(0, length(medalle)), 
                         fj.alls = rep(0, length(medalle)), kynth = rep(0, length(medalle)), 
                         kyn = rep(1, length(medalle)), wt = rep(0, length(medalle)))
  tmp.data$kyn[1] <- 2
  tmp.data$kynth[1] <- 1
  tmp.data <- tmp.data[, col.names]
  tmp.data <- rbind(tmp.data, lengdir[, names(tmp.data)])
  tmp.data$lenfl <- cut(tmp.data$lengd, lengd)
  tmp.data <- tmp.data[!is.na(tmp.data$lenfl), ]
  utkoma <- list()
  if (WT) {
    tmp.data <- Reikna.thyngd(tmp.data, lengd.thyngd.data)
    attr(utkoma, "WT") <- T
  }
  else attr(utkoma, "WT") <- F
  Calc.tot.ldist <- function(tmp.data) {
    utkoma <- list()
    utkoma$LDIST.MAELT <- as.vector(tapply(tmp.data$fjoldi, 
                                           tmp.data$lenfl, sum))
    utkoma$LDIST.ALLS <- as.vector(tapply(tmp.data$fj.alls, 
                                          tmp.data$lenfl, sum))
    utkoma$MEANWT.ALLS <- as.vector(tapply(tmp.data$fj.alls * 
                                             tmp.data$wt, tmp.data$lenfl, sum)/tapply(tmp.data$fj.alls, 
                                                                                      tmp.data$lenfl, sum))
    utkoma$MEANLE <- as.vector(tapply(tmp.data$fj.alls * 
                                        tmp.data$lengd, tmp.data$lenfl, sum)/tapply(tmp.data$fj.alls, 
                                                                                    tmp.data$lenfl, sum))
    return(utkoma)
  }
  utkoma <- as.vector(Calc.tot.ldist(tmp.data))
  if (kyn) {
    i <- tmp.data$kyn == 1
    utkoma$LDIST.MALE <- as.vector(Calc.tot.ldist(tmp.data[i, 
                                                           ]))
    i <- tmp.data$kyn == 2
    utkoma$LDIST.FEMALE <- as.vector(Calc.tot.ldist(tmp.data[i, 
                                                             ]))
  }
  if (kyn && kynth) 
    class(utkoma) <- c("ldist", "list")
  attr(utkoma, "medalle") <- medalle
  attr(utkoma, "get.alk.call") <- match.call()
  return(utkoma)
}

#' @title XXX
#'  
#' @description XXX
#' 
#' @export
#' 
#' @param kv XXX
#' @param tegund XXX
#' @param maxage XXX
kv.filter <- 
function (kv, tegund, maxage) 
{
  all.teg <- c(1, 2, 3)
  if (is.na(match(tegund, all.teg))) {
    print("G\xf6gn ekki til fyrir tegund")
    return(kv)
  }
  minl <- vikmork[[as.character(tegund)]]$minl
  maxl <- vikmork[[as.character(tegund)]]$maxl
  kv <- kv[!is.na(kv$aldur) & !is.na(kv$lengd), ]
  nullgr <- kv[kv$aldur == 0 & kv$lengd < maxl[1], ]
  kv1 <- kv[1:2, ]
  for (i in 1:length(maxl)) {
    tmp <- kv[kv$aldur == i, ]
    if (nrow(tmp) > 0) 
      tmp <- tmp[tmp$lengd > minl[i] & tmp$lengd < maxl[i], 
                 ]
    if (nrow(tmp) > 0) 
      kv1 <- rbind(kv1, tmp)
  }
  if (nrow(nullgr) > 0) 
    kv1 <- rbind(kv1, nullgr)
  kv1 <- kv1[-c(1:2), ]
  return(kv1)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param OTH.TOT XXX
#' @param kfile XXX
#' @param aldur XXX
#' @param lengd XXX

Calc.ALK <-
function (OTH.TOT, kfile, aldur, lengd) 
{
  ALK.TOT <- OTH.TOT/apply(OTH.TOT, 1, sum)
  ALK.TOT[is.na(ALK.TOT)] <- 0
  i <- apply(ALK.TOT, 1, sum) == 0
  if (any(i)) {
    i1 <- 1:length(i)
    i1 <- i1[i]
    x <- smooth.spline(kfile$lengd, kfile$aldur, df = 2)
    meana <- round(predict.smooth.spline(x, lengd[i])$y)
    i <- meana > max(aldur)
    if (any(i)) 
      meana[i] <- max(aldur)
    i <- meana < min(aldur)
    if (any(i)) 
      meana[i] <- min(aldur)
    for (j in 1:length(i1)) ALK.TOT[i1[j], as.character(meana[j])] <- 1
  }
  return(ALK.TOT)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param OTH.KYNTH XXX
#' @param OTH.TOT XXX
#' @param ALK.TOT XXX
#' @param kfile XXX
#' @param aldur XXX
#' @param lengd XXX

Calc.ALK.KYNTH <- 
function (OTH.KYNTH, OTH.TOT, ALK.TOT, kfile, aldur, lengd) 
{
  ALK.KYNTH <- OTH.KYNTH/apply(OTH.TOT, 1, sum)
  ALK.KYNTH[is.na(ALK.TOT)] <- 0
  i <- apply(OTH.TOT, 1, sum) == 0
  if (any(i)) {
    tmp <- kfile[, c("Kynth", "lengd")]
    pred.data <- data.frame(Kynth = rep(0, length(lengd)), 
                            lengd = lengd)
    x <- glm(Kynth ~ lengd, data = tmp, family = binomial)
    kynth.lengd <- predict(x, pred.data, type = "response")
    i1 <- 1:length(i)
    i1 <- i1[i]
    for (j in i1) ALK.KYNTH[j, ] <- ALK.TOT[j, ] * kynth.lengd[j]
  }
  return(ALK.KYNTH)
}


#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param OTH.KYN XXX
#' @param OTH.TOT XXX
#' @param ALK.TOT XXX
#' @param kfile XXX
#' @param aldur XXX
#' @param lengd XXX
#' 
Calc.ALK.KYN <- 
function (OTH.KYN, OTH.TOT, ALK.TOT, kfile, aldur, lengd) 
{
  ALK.KYN <- OTH.KYN/apply(OTH.TOT, 1, sum)
  ALK.KYN[is.na(ALK.TOT)] <- 0
  i <- apply(OTH.TOT, 1, sum) == 0
  if (any(i)) {
    tmp <- kfile[, c("Kyn", "lengd")]
    pred.data <- data.frame(Kyn = rep(0, length(lengd)), 
                            lengd = lengd)
    x <- glm(Kyn ~ lengd, data = tmp, family = binomial)
    kyn.lengd <- predict(x, pred.data, type = "response")
    i1 <- 1:length(i)
    i1 <- i1[i]
    for (j in i1) ALK.KYN[j, ] <- ALK.TOT[j, ] * kyn.lengd[j]
  }
  print(length(ALK.KYN))
  return(ALK.KYN)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param lengdir XXX
#' @param l.th.gogn XXX
Reikna.thyngd <- 
function (lengdir, l.th.gogn) 
{
  if (is.data.frame(l.th.gogn)) {
    lengdir <- join(lengdir, l.th.gogn[, c("lengd", "oslaegt")], 
                    "lengd")
    n <- ncol(lengdir)
    names(lengdir)[n] <- "wt"
    lengdir <- lengdir[!is.na(lengdir$wt), ]
  }
  else lengdir$wt <- l.th.gogn[1] * lengdir$lengd^l.th.gogn[2]
  return(lengdir)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param lengdir XXX
#' @param afli XXX
Skala.med.afla <- 
function (lengdir, afli) 
{
  rat <- afli/sum(lengdir$wt * lengdir$fjoldi/1000)
  lengdir$fj.alls <- lengdir$fjoldi * rat
  return(lengdir)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param lengdir XXX
#' @param Stodvar XXX
#' @param std.toglengd XXX
Skala.med.toglengd <-
function (lengdir, Stodvar, std.toglengd) 
{
  if (is.na(match("fj.alls", names(lengdir)))) {
    cat("D\xe1lkur fj.alls ver\xf0ur a\xf0 vera til \xed lengdir")
    return(invisible())
  }
  i <- is.na(Stodvar$toglengd) | Stodvar$toglengd > 0
  if (any(i)) 
    Stodvar$toglengd[i] <- std.toglengd
  tmp <- join(lengdir, Stodvar[, c("synis.id", "toglengd")], 
              "synis.id")
  lengdir$fj.alls <- lengdir$fj.alls * std.toglengd/lengdir$toglengd
  return(lengdir)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param object XXX
#' @param x XXX
#' @param deriv XXX
predict.smooth.spline <-
function (object, x, deriv = 0) 
{
  if (missing(x)) {
    if (deriv == 0) 
      return(object[c("x", "y")])
    else x <- object$x
  }
  fit <- object$fit
  if (is.null(fit)) 
    stop("not a valid smooth.spline object")
  else predict(fit, x, deriv)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param sfile XXX
calcgear <-
function (sfile) 
{
  j <- match(sfile$veidarfaeri, gearlist$veidarfaeri)
  sfile$vf <- gearlist$geartext[j]
  return(sfile)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param ALK XXX
#' @param LDIST XXX

Calc.fj <- 
function (ALK, LDIST) 
{
  utkoma <- list()
  utkoma$FjPerAldur <- LDIST$LDIST.ALLS %*% ALK$ALK.TOT
  utkoma$ALD <- ALK$ALK.TOT * LDIST$LDIST.ALLS
  i <- is.na(LDIST$MEANWT.ALLS)
  if (any(i)) 
    LDIST$MEANWT.ALLS[i] <- 0
  utkoma$BiomassPerAldur <- (LDIST$LDIST.ALLS * LDIST$MEANWT.ALLS) %*% 
    ALK$ALK.TOT
  utkoma$WtPerAldur <- utkoma$BiomassPerAldur/utkoma$FjPerAldur
  tmp <- (LDIST$LDIST.ALLS * LDIST$MEANLE)
  tmp[is.na(tmp)] <- 0
  utkoma$MeanlePerAldur <- tmp %*% ALK$ALK.TOT/utkoma$FjPerAldur
  if (!is.na(match("KYNTH", names(attributes(ALK))))) {
    utkoma$FjKynthPerAldur <- LDIST$LDIST.ALLS %*% ALK$ALK.KYNTH
    utkoma$KynthHlutfall <- utkoma$FjKynthPerAldur/utkoma$FjPerAldur * 
      100
    utkoma$ALD.KYNTH <- ALK$ALK.KYNTH * LDIST$LDIST.ALLS
    utkoma$BiomassKynthPerAldur <- (LDIST$LDIST.ALLS * LDIST$MEANWT.ALLS) %*% 
      ALK$ALK.KYNTH
    tmp <- (LDIST$LDIST.ALLS * LDIST$MEANLE)
    tmp[is.na(tmp)] <- 0
    utkoma$MeanleKynthPerAldur <- tmp %*% ALK$ALK.KYNTH/utkoma$FjKynthPerAldur
    utkoma$WtKynthPerAldur <- utkoma$BiomassKynthPerAldur/utkoma$FjKynthPerAldur
  }
  if (!is.na(match("KYN", names(attributes(ALK))))) {
    utkoma$FjKynPerAldur <- LDIST$LDIST.ALLS %*% ALK$ALK.KYN
    utkoma$KynHlutfall <- utkoma$FjKynPerAldur/utkoma$FjPerAldur * 
      100
    utkoma$ALD.KYN <- ALK$ALK.KYN * LDIST$LDIST.ALLS
    utkoma$BiomassKynPerAldur <- (LDIST$LDIST.ALLS * LDIST$MEANWT.ALLS) %*% 
      ALK$ALK.KYN
    # utkoma$WtKynPerAldur <- BiomassKynPerAldur/FjKynPerAldur # Einar: should be:
    utkoma$WtKynPerAldur <- utkoma$BiomassKynPerAldur/utkoma$FjKynPerAldur
  }
  return(utkoma)
}

#' @title XXX
#' 
#' @description XXX
#' 
#' @export
#' 
#' @param fj1 XXX
#' @param fj2 XXX
rbind.alk1 <- 
function (fj1, fj2) 
{
  if (length(fj1) == 0) 
    return(fj2)
  else if (length(fj2) == 0) 
    return(fj1)
  else {
    fj3 <- list()
    fj3$FjPerAldur <- fj1$FjPerAldur + fj2$FjPerAldur
    fj3$BiomassPerAldur <- fj1$BiomassPerAldur + fj2$BiomassPerAldur
    fj3$ALD <- fj1$ALD + fj2$ALD
    fj3$WtPerAldur <- fj3$BiomassPerAldur/fj3$FjPerAldur
    if (!is.na(match("MeanlePerAldur", names(fj1)))) {
      tmp <- (fj1$MeanlePerAldur * fj1$FjPerAldur)
      tmp[is.na(tmp)] <- 0
      tmp1 <- (fj2$MeanlePerAldur * fj2$FjPerAldur)
      tmp1[is.na(tmp1)] <- 0
      fj3$MeanlePerAldur <- (tmp + tmp1)/fj3$FjPerAldur
    }
    if (!is.na(match("FjKynthPerAldur", names(fj1)))) 
      fj3$FjKynthPerAldur <- fj1$FjKynthPerAldur + fj2$FjKynthPerAldur
    if (!is.na(match("KynthHlutfall", names(fj1)))) 
      fj3$KynthHlutfall <- (fj1$KynthHlutfall * fj1$FjPerAldur + 
                              fj2$KynthHlutfall * fj2$FjPerAldur)/fj3$FjPerAldur
    if (!is.na(match("ALD.KYNTH", names(fj1)))) 
      fj3$ALD.KYNTH <- fj1$ALD.KYNTH + fj2$ALD.KYNTH
    if (!is.na(match("MeanleKynthPerAldur", names(fj1)))) {
      tmp <- (fj1$MeanleKynthPerAldur * fj1$FjKynthPerAldur)
      tmp[is.na(tmp)] <- 0
      tmp1 <- (fj2$MeanleKynthPerAldur * fj2$FjKynthPerAldur)
      tmp1[is.na(tmp1)] <- 0
      fj3$MeanlePerAldur <- (tmp + tmp1)/fj3$FjKynthPerAldur
    }
    if (!is.na(match("BiomassKynthPerAldur", names(fj2)))) {
      fj3$BiomassKynthPerAldur <- fj1$BiomassKynthPerAldur + 
        fj2$BiomassKynthPerAldur
      fj3$WtKynthPerAldur <- fj3$BiomassKynthPerAldur/fj3$FjKynthPerAldur
    }
    return(fj3)
  }
}