# beverage parameter ####
setwd(this.path::this.dir())
dir( pattern = "Rsource" )
source.file <- print(dir( pattern = "Rsource" )[ length( dir( pattern = "Rsource" ))])
source( paste0(getwd(), "/", source.file) )

dt$para$mop.date <- "220602"
# spectra ####
dt$para$i = 1
dt$para$substance[dt$para$i]
setwd(dt$wd)
setwd("./Modellvalidierung")
setwd("./Produktionsdaten")

dt$para$files <- dir(pattern = "validated.csv$")
dt$para$txt <- .txt.file(dt$para$files)

dt$raw <- lapply(dt$para$files, \(x) fread(x, sep = ";", dec = ","))
names(dt$raw) <- paste0(dt$para$txt$loc.line, "_", dt$para$txt$type)

dt$para$trs <- lapply(dt$raw, .transfer_csv.num.col)
dt$trs <- lapply(dt$raw, .transfer_csv)

# Model Matrix ####
setwd(dt$wd)
setwd("./Modellerstellung")
setwd(paste0("./", dt$para$model.date[1], "_", dt$para$model.pl[1]))
setwd("./csv")

dt$model <- fread( print(grep( "match.csv", dir(), value = T)), dec = ",", sep = ";")

dt$SL <- dt$model[which(dt$model$Probe_Anteil == "SL") , ]
dt$model <- dt$model[which(dt$model$Probe_Anteil != "SL") , ]

setwd(dt$wd)
setwd("./Modelloptimierung")
dir.create(paste0("./", dt$para$mop.date, "_", dt$para$model.pl[1], "_", dt$para$substance[dt$para$i]), showWarnings = F)
setwd(paste0("./", dt$para$mop.date, "_", dt$para$model.pl[1], "_", dt$para$substance[dt$para$i]))
dir.create("Modellmatrix", showWarnings = F)
setwd("./Modellmatrix")

fwrite(dt$model, paste0(.datetime(), "_", dt$para$beverage, "_", dt$para$substance[dt$para$i], "_matrix.csv"), row.names = F, dec = ",", sep = ";")
dt$model <- .transfer_csv(csv.file = dt$model)
dt$SL <- .transfer_csv(csv.file = dt$SL)

# Plot ####
par(mfrow = c(1,1))
matplot(dt$para$wl[[1]]
        , t( dt$SL$spc[ grep("T1K", dt$SL$data$Probe) , ])
        , type = "l", lty = 1, xlab = .lambda, ylab = "AU", main = "SL vs Modellspektren"
        , col = "blue")
matplot(dt$para$wl[[1]]
        , t( dt$model$spc )
        , type = "l", lty = 1, xlab = .lambda, ylab = "AU", main = "SL vs Modellspektren"
        , col = "red", add = T)
legend("topright", c(paste0("SL ", dt$para$substance[ dt$para$i]), "Ausmischung"), lty = 1, col = c("blue", "red"))

dt$model$data$Probe == dt$para$substance[dt$para$i]
dt$para.pls$wlr <- .wlr_function(200:280, 200:280, 5)
nrow(dt$para.pls$wlr)
dt$para.pls$wlm <- .wlr_function_multi(200:280, 200:280, 5)
nrow(dt$para.pls$wlm)
dt$para.pls$wl <- rbind.fill(dt$para.pls$wlm, dt$para.pls$wlr)
nrow(dt$para.pls$wl)

dt$para.pls$ncomp <- 6

# RAM ####
gc()
memory.limit(99999)

# PLS and LM ####
dt$pls$pls <- pls_function(csv_transfered = dt$model
                           , substance = dt$para$substance[dt$para$i]
                           , wlr = dt$para.pls$wl 
                           , ncomp = dt$para.pls$ncomp)

dt$pls$lm <- pls_lm_function(dt$pls$pls
                             , csv_transfered = dt$model
                             , substance = dt$para$substance[dt$para$i]
                             , wlr = dt$para.pls$wl 
                             , ncomp = dt$para.pls$ncomp)
# Prediction ####
dt$pls$pred <- lapply(dt$trs, function( x ) produktion_prediction(csv_transfered = x, pls_function_obj = dt$pls$pls, ncomp = dt$para.pls$ncomp))

# Best model ####
dt$pls$merge <- lapply(dt$pls$pred, function( x ) .merge_pls(pls_pred = x, pls_lm = dt$pls$lm, mean = c(85, 115), R2=.8))
dt$pls$merge <- lapply(dt$pls$merge, function( x ) x[ order(x$sd) , ])
lapply(dt$pls$merge, head, 10)

dt$pls$mergesite <- .merge_pls_site(merge_pls_lm_predict_ls = dt$pls$merge, number = 2000, ncomp = dt$para.pls$ncomp)
tail(dt$pls$mergesite)

# Prediciton ####
dt$mop$ncomp <- 5
dt$mop$wl1 <- 215
dt$mop$wl2 <- 245
dt$mop$wl3 <- 255
dt$mop$wl4 <- 280
dt$mop$spc <- "2nd"
dt$mop$model <- pls_function(dt$model, dt$para$substance[ dt$para$i ], data.frame(dt$mop$wl1, dt$mop$wl2, dt$mop$wl3, dt$mop$wl4), dt$mop$ncomp, spc = dt$mop$spc)
dt$mop$model  <- dt$mop$model [[grep(dt$mop$spc, names(dt$mop$model))[1]]][[1]]

dt$mop$pred <- lapply(dt$trs, function(x) pred_of_new_model(dt$model
                                                            , dt$para$substance[ dt$para$i ]
                                                            , dt$mop$wl1 
                                                            , dt$mop$wl2
                                                            , dt$mop$wl3, dt$mop$wl4
                                                            , dt$mop$ncomp
                                                            , dt$mop$spc
                                                            , x))

dt$mop$pred <- lapply(dt$mop$pred, function( x ) as.numeric(ma( x, 5)))
dt$mop$bias <- lapply(dt$mop$pred, function( x ) round( .bias( median( x, na.rm = T), 0, dt$para$SOLL[ dt$para$i] ), 3))
dt$mop$pred <- mapply( function( x,y ) x - y
                       , x = dt$mop$pred
                       , y = dt$mop$bias)

par(mfrow = c(length( dt$mop$pred ), 1))
for(i in 1:length(dt$mop$pred)){
  plot(dt$mop$pred[[ i ]]
       , xlab = "", ylab = dt$para$ylab[ dt$para$i ], main = dt$para$txt$loc.line[ i ]
       , ylim = dt$para$SOLL[ dt$para$i] * c(85, 115) / 100, axes = F
       , sub = paste("Bias =", dt$mop$bias[ i ]))
  .xaxisdate(dt$trs[[ i ]]$data$datetime)
}

.keep.out.unsb(model = dt$model, dt$mop$wl1, dt$mop$wl2, dt$mop$wl3, dt$mop$wl4)

setwd(dt$wd)
setwd("./Modelloptimierung")
setwd(paste0("./", dt$para$mop.date, "_", dt$para$model.pl[1], "_", dt$para$substance[dt$para$i]))
dir.create("Analyse", showWarnings = F)
setwd("./Analyse")

for(i in 1:length(dt$mop$pred)){
  png(paste0(.datetime(), "_Prediction_"
             , dt$para$beverage, "_", dt$para$substance[ dt$para$i ], "_", dt$para$txt$loc.line[i]
             , "_PC"
             , dt$mop$ncomp, "_", dt$mop$wl1, "_", dt$mop$wl2, "_", dt$mop$wl3, "_", dt$mop$wl4, "_"
             , dt$mop$spc, ".png")
      , xxx<-4800,xxx/16*9,"px",12,"white",res=500,"sans",T,"cairo")
  plot(dt$mop$pred[[ i ]]
       , xlab = "", ylab = dt$para$ylab[ dt$para$i ], main = dt$para$txt$loc.line[ i ]
       , ylim = dt$para$SOLL[ dt$para$i] * c(95, 105) / 100, axes = F
       , sub = paste("Bias =", dt$mop$bias[ i ]))
  .xaxisdate(dt$trs[[ i ]]$data$datetime)
  dev.off()
}

pls_analyse_plot(pls_function_obj = dt$mop$model
                 , model_matrix = dt$model
                 , colp = "Probe"
                 , wl1 = dt$mop$wl1
                 , wl2 = dt$mop$wl2
                 , wl3 = dt$mop$wl3
                 , wl4 = dt$mop$wl4
                 , ncomp = dt$mop$ncomp
                 , derivative = dt$mop$spc
                 , pc_scores = c(1,2)
                 , var_xy = "y"
                 , val = F
                 , pngname = paste0(.datetime(), "_"
                                    , dt$para$beverage, "_", dt$para$substance[i]
                                    , "_PC"
                                    , dt$mop$ncomp, "_", dt$mop$wl1, "_", dt$mop$wl2, "_", dt$mop$wl3, "_", dt$mop$wl4, "_"
                                    , dt$mop$spc))

