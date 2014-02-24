################################################################################
# A quick fix for 2012 - getting rid of synaflokkur 71
ar  <- 2012
teg <- '01'
setwd('/net/hafkaldi/export/home/haf/einarhj/01/batch/')

################################################################################
# temporary function
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

################################################################################
# Temporary fix
u2path <- '/net/hafkaldi/u2/data'
Sfile   <- read.prelude(paste(u2path,'/stodvar/s',ar,'.pre',sep=''))
require(fjolst)
require(geo)
st <- lesa.stodvar(ar=2012,oracle=TRUE)
st$afli <- 10
st <- st[st$synaflokkur != 71,c('synis.id','ar','man','dags','reitur','smareitur','veidarfaeri','afli')]
names(st) <- c('record_id','ar','man','dag','reit','smrt','vf','afli')
st <- st[st$record_id %in% Sfile$record.id,]
write.prelude2(st,file='../data/SfileDoctored.pre')
