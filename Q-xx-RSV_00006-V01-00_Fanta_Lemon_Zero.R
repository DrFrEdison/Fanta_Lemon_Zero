# beverage parameter ####
setwd(this.path::this.dir())
dir( pattern = "Rsource" )
source.file <- print(dir( pattern = "Rsource" )[ length( dir( pattern = "Rsource" ))])
source( paste0(getwd(), "/", source.file) )

# spectra ####
setwd(dt$wd)
setwd("./Modellvalidierung")
setwd("./Produktionsdaten")

dt$para$files <- dir(pattern = ".csv$")
dt$para$files <- grep("validated", dt$para$files, invert = T, value = T)
dt$para$txt <- .txt.file(dt$para$files)

dt$raw <- lapply(dt$para$files, \(x) fread(x, sep = ";", dec = ","))
names(dt$raw) <- paste0(dt$para$txt$loc.line, "_", dt$para$txt$type)

dt$para$ppp <- lapply(dt$raw, .transfer_csv.num.col)

dt$raw  <- mapply(function(x , y) y[ , c(1 : (min(x$numcol) - 1), x$numcol[ x$wl %in% dt$para$wl[[1]] ]), with = F]
                  , x = dt$para$ppp
                  , y = dt$raw)

dt$para$ppp <- lapply(dt$raw, .transfer_csv.num.col)
dt$trs <- lapply(dt$raw, .transfer_csv)
names(dt$trs) <- names(dt$raw)

# validate drk ####
par(mfrow = c(length( grep("drk", names(dt$para$ppp)) ), 1))
for(i in grep("drk", names(dt$para$ppp)))
matplot(dt$para$ppp[[ i ]]$wl
        , t(dt$raw[[ i ]][ , dt$para$ppp[[ i ]]$numcol, with = F])
        , lty = 1, type = "l"
        , xlab = .lambda, ylab = "Counts", main = paste( dt$para$txt$location[[ i ]], dt$para$txt$type[[ i ]]))

for(i in grep("drk", names(dt$para$ppp)))
  dt$val[[ i ]] <-   apply(dt$raw[[ i ]][ , dt$para$ppp[[ i ]]$numcol, with = F], 1, spectra.validation.drk)
  
for(i in grep("drk", names(dt$para$ppp))) print(unique(dt$val[[ i ]]))
  
for(i in 1:length(grep("drk", names(dt$para$ppp)))){
  dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]] <- dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]][ spectra.validation.range(valid.vector = dt$val[[ grep("drk", names(dt$para$ppp))[ i ]]]
                                                    , drkref.datetime = dt$raw[[ grep("drk", names(dt$para$ppp))[ i ]]]$datetime
                                                    , spc.datetime = dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]]$datetime
                                                    , pattern = "invalid") , ]
}

for(i in grep("drk", names(dt$para$ppp)))
  dt$val[[ i ]] <-   apply(dt$raw[[ i ]][ , dt$para$ppp[[ i ]]$numcol, with = F], 1, spectra.validation.drk)
for(i in 1:length(grep("drk", names(dt$para$ppp)))){
  dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]] <- dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]][ spectra.validation.range(valid.vector = dt$val[[ grep("drk", names(dt$para$ppp))[ i ]]]
                                                                                                                               , drkref.datetime = dt$raw[[ grep("drk", names(dt$para$ppp))[ i ]]]$datetime
                                                                                                                               , spc.datetime = dt$raw[[ grep("spc", names(dt$para$ppp))[ i ]]]$datetime
                                                                                                                               , pattern = "empty") , ]
}

# validate ref ####
par(mfrow = c(length( grep("ref", names(dt$para$ppp)) ), 1))
for(i in grep("ref", names(dt$para$ppp)))
  matplot(dt$para$ppp[[ i ]]$wl
          , t(dt$raw[[ i ]][ , dt$para$ppp[[ i ]]$numcol, with = F])
          , lty = 1, type = "l"
          , xlab = .lambda, ylab = "Counts", main = paste( dt$para$txt$location[[ i ]], dt$para$txt$type[[ i ]]))

# validate spc ####
par(mfrow = c(length( grep("spc", names(dt$para$ppp)) ), 1))
for(i in grep("spc", names(dt$para$ppp)))
  matplot(dt$para$ppp[[ i ]]$wl
          , t(dt$raw[[ i ]][ , dt$para$ppp[[ i ]]$numcol, with = F])
          , lty = 1, type = "l"
          , xlab = .lambda, ylab = "Counts", main = paste( dt$para$txt$location[[ i ]], dt$para$txt$type[[ i ]]))

par(mfrow = c(length( grep("spc", names(dt$para$ppp)) ), 1))
for(i in grep("spc", names(dt$para$ppp)))
  matplot(dt$para$ppp[[ i ]]$wl
          , t(dt$trs[[ i ]]$spc1st[ , ])
          , lty = 1, type = "l"
          , xlab = .lambda, ylab = "Counts", main = paste( dt$para$txt$location[[ i ]], dt$para$txt$type[[ i ]]))

# plot(dt$raw$spc$X279)
# dt$raw$spc <- dt$raw$spc[ dt$raw$spc$X279 > .3 , ]
# dt$raw$spc <- dt$raw$spc[ dt$raw$spc$X279 < .44, ]

# export clean spc csv ####
for(i in 1:length(grep("spc", names(dt$para$ppp))))
  fwrite(dt$raw[[ grep("_spc.csv", dt$para$files)[ i ] ]]
         , gsub("_spc.csv", "_spc_validated.csv", dt$para$files[ grep("_spc.csv", dt$para$files) ][ i ])
         , sep = ";", dec = ",")


