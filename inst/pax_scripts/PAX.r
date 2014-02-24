################################################################################
# This is an attempt to mimic PAX, including generating the standard output
# files
ar  <- 2012
teg <- '01'
setwd('/net/hafkaldi/export/home/haf/einarhj/01/batch/')

################################################################################
# Temporary fix
tmpStod <- read.prelude('../data/stod')
require(fjolst)
require(geo)
st <- lesa.stodvar(ar=2012,oracle=TRUE)
st <- st[st$synis.id %in% tmpStod$record.id,]
st <- st[st$synaflokkur != 71,c('synis.id','ar','dags','man','reitur','smareitur','veidarfaeri')]
names(st) <- names(tmpStod)
write.prelude2 <- function (data, file = "splus.pre", na.replace = "") 
{
  if (is.data.frame(data)) 
    data <- as.matrix.data.frame(data)
  data[is.na(data) | data == "NA"] <- na.replace
  col.names <- dimnames(data)[[2]]
  if (is.null(col.names) || length(col.names) == 0) 
    col.names <- paste("dalkur", 1:ncol(data), sep = "")
  row.names <- dimnames(data)[[1]]
  #if (!is.null(row.names) && length(row.names) > 0) {
  #  col.names <- c("linu_nofn", col.names)
  #  data <- cbind(row.names, data)
  #}
  n.of.col <- length(col.names)
  cat(col.names, sep = c(rep("\t", n.of.col - 1), "\n"), file = file)
  strika.lina <- rep("", n.of.col)
  for (i in 1:n.of.col) strika.lina[i] <- paste(rep("-", nchar(col.names[i])), 
                                                collapse = "")
  cat(strika.lina, sep = c(rep("\t", n.of.col - 1), "\n"), 
      file = file, append = T)
  cat(t(data), sep = c(rep("\t", n.of.col - 1), "\n"), file = file, 
      append = T)
  return(invisible(NULL))
}
names(st)[1] <- 'record_id'
write.prelude2(st,file='../data/stod2')


dim(tmpStod)
dim(st)
################################################################################
# 00copyScripts.sh
cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/ldist    /net/hafkaldi/export/home/haf/einarhj/01/
cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/keys     /net/hafkaldi/export/home/haf/einarhj/01/
cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/agelen   /net/hafkaldi/export/home/haf/einarhj/01/
cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/avelewt  /net/hafkaldi/export/home/haf/einarhj/01/
cp -r /net/hafkaldi/export/home/haf/einarhj/src/Setup/catch_no /net/hafkaldi/export/home/haf/einarhj/01/

################################################################################

u2path <- '/net/hafkaldi/u2/data'
Stod   <- read.prelude(paste(u2path,'/stodvar/s',ar,'.pre',sep=''))
Kfile  <- read.prelude(paste(u2path,'/',teg,'/',teg,'k',ar,'.pre',sep=''))
Lfile  <- read.prelude(paste(u2path,'/',teg,'/',teg,'l',ar,'.pre',sep=''))
Nfile  <- read.prelude(paste(u2path,'/',teg,'/',teg,'n',ar,'.pre',sep=''))

# stodvarskra
Stod <- Stod[,c('record.id','ar','dag','man','reit','smrt','vf')]
Stod <- Stod[order(Stod$record.id),]
# lengdarskra
#echo "Er ad gera lengdarskra"
#project record_id lnr lfj < $nfile |\
#sorttable > t
#jointable -a1 t stod |\
#project lnr dag man ar reit smrt vf lfj |\
#select 'lnr > 0' |\
#sorttable -n > $teg'sl'$ar.pre
#project lnr < $teg'sl'$ar.pre |\
#sorttable -n > l
#plokk l < $lfile > $teg'l'$ar.pre
tmp <- Nfile[,c('record.id','lnr','lfj')]
tmp <- tmp[order(tmp$record.id),]
tmp <- join(tmp,Stod)
tmp <- tmp[,c('lnr','dag','man','ar','reit','smrt','vf','lfj')]
tmp <- tmp[tmp$lnr > 0,]
L <- data.frame(lnr=tmp$lnr)

Kfile <- Kfile[Kfile$]
stod <- read.prelude('../data/stod')
k <-    read.prelude('../data/k')
l <-    read.prelude('../data/l')
t <-    read.prelude('../data/t')

k01 <-  read.prelude('../data/01k2012.pre')
l01 <-  read.prelude('../data/01l2012.pre')
sk01 <- read.prelude('../data/01sk2012.pre')
sl01 <- read.prelude('../data/01sk2012.pre')


