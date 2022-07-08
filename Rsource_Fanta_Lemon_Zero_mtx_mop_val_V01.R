# Package update and initialization ####
library(devtools)
suppressMessages(install_github("DrFrEdison/r4dt", dependencies = T, upgrade = "always", quiet = T) )
suppressPackageStartupMessages(library(r4dt))

# general parameters ####
dt <- list()
dt$para$customer = "CCEP"
dt$para$beverage = "Fanta_Lemon_Zero"

setwd(paste0(dt$wd <- paste0(r4dt::wd$fe[[ grep(dt$para$customer, names(r4dt::wd$fe)) ]]$Mastermodelle, dt$para$beverage)))
setwd( print( this.path::this.dir() ) )
dt$wd.git <- print( getwd() )

# location, line, main ####
dt$para$location = print(dt_customer[dt_customer$customer == dt$para$customer, "location"])
dt$para$line = print(dt_customer[dt_customer$customer == dt$para$customer, "line"])
dt$para$main = paste0(dt$para$beverage, " in ", dt$para$location, ", line ", dt$para$line)

# Modellerstellung
dir( paste0( dt$wd, "/", "/Modellerstellung"))
dir()
dt$para$model.raw.date <- c("220530")
dt$para$model.raw.pl <- c("00300")
dt$para$wl1 <- c(190)
dt$para$wl2 <- c(598)
dt$para$wl[[1]] <- seq(dt$para$wl1, dt$para$wl2, 1)

# Parameter ####
dir()
dir( paste0( dt$wd, "/", "/Modellerstellung", "/", dt$para$model.raw.date, "_", dt$para$model.raw.pl, "/spc"))
dt$para$substance <- c("TTA", "Acesulfam", "Aspartam", "T1", "T2B", "T2")

# Unit ####
dt$para$unit <- c( bquote("%"),  bquote("%"),  bquote("%"), bquote("%"), bquote("%"), bquote("%"))
dt$para$ylab <- c( bquote("TTA in %"), bquote("Acesulfam in %"), bquote("Aspartam in %"), bquote("T1 in %"), bquote("T2B in %"), bquote("T2 in %") )

# Rezept und SOLL-Werte ####
setwd( paste0( dt$wd, "/", "/Rezept") )
dt$rez <- read.xlsx(grep(".xlsx", dir( paste0( dt$wd, "/", "/Rezept")), value = T)[ length(grep(".xlsx", dir( paste0( dt$wd, "/", "/Rezept")), value = F))])
dt$rez[ grep("Messparameter", dt$rez[ , 3]): nrow(dt$rez) , ]
dt$para$SOLL <- c(596, 231, 60, NA, NA, NA)
dt$para$eingriff <- data.frame( TA = c(596 * 98 / 100, 596 * 102 /100)
                                , Acesulfam = c(NA, NA)
                                , Aspartam = c(NA, NA)
)

dt$para$sperr <- data.frame( TA = c(NA, NA)
                             , Acesulfam = c(NA, NA )
                             , Aspartam = c(NA, NA)
)
#
# # Modelloptimierung
dir( paste0( dt$wd, "/", "/Modelloptimierung") )
dt$para$mop.date <- "220602"

# Model Matrix Ausmischung ####
setwd(dt$wd)
setwd("./Modellerstellung")
setwd(paste0("./", dt$para$model.raw.date[1], "_", dt$para$model.raw.pl[1]))
setwd("./csv")

dt$model.raw <- read.csv2( print(grep( "Modellspektren_Ausmischung_match.csv", dir(), value = T)), dec = ",", sep = ";")
head10(dt$model.raw)
dt$model.raw$TTA <- dt$model.raw$TA * 100

for(i in 1){
  # if(dt$para$substance[i] == "TA" | dt$para$substance[i] == "TTA" | dt$para$substance[i] == "Acid") next
  dt$model.raw[ , colnames(dt$model.raw) %in% dt$para$substance[i]] <- dt$model.raw[ , colnames(dt$model.raw) %in% dt$para$substance[i]] / dt$para$SOLL[i] * 100
}

dt$SL <- dt$model.raw[which(dt$model.raw$Probe_Anteil == "SL") , ]
dt$model.raw <- dt$model.raw[which(dt$model.raw$Probe_Anteil != "SL") , ]

# VAS
setwd(dt$wd)
setwd("./Modellerstellung")
setwd(paste0("./", dt$para$model.raw.date[1], "_", dt$para$model.raw.pl[1]))
setwd("./csv")

dt$vas$raw <- read.csv2( print(grep( "VASspektren_Ausmischung_match", dir(), value = T)), dec = ",", sep = ";")
dt$vas$raw <- dt$vas$raw[ dt$vas$raw$TA != 0 , ]

dt$vas$raw$TTA <- dt$vas$raw$TA * 100

for(i in 1){
  # if(dt$para$substance[i] == "TA" | dt$para$substance[i] == "TTA" | dt$para$substance[i] == "Acid") next
  dt$vas$raw[ , colnames(dt$vas$raw) %in% dt$para$substance[i]] <- dt$vas$raw[ , colnames(dt$vas$raw) %in% dt$para$substance[i]] / dt$para$SOLL[i] * 100
}
head(dt$vas$raw)

# Modellvalidierung ####
dir( paste0( dt$wd, "/", "/Modellvalidierung") )
dt$para$val.date <- "220609"
#
# # Linearity
# setwd(dt$wd)
# setwd("./Modellvalidierung")
# setwd("./Linearitaet")
# dir()
# dt$lin$raw <- read.csv2( "220602_Schwip_Schwap_Light_Linearitaet_TA_Coffein_Aspartam_Acesulfam.csv" , sep = "\t")
# dt$lin$raw <- dt$lin$raw[ order(dt$lin$raw$Dilution) , ]
# dt$lin$trs <- transfer_csv(dt$lin$raw)
#
dt$para$Charge.val <- c("0010905033", "0010987125", "0010873303", "0010987125")
dt$para$Charge.val.Sirup <- "2206010745"

# rename R files (run only once)
setwd(dt$wd.git)

# dt$para$Rfiles <- list.files(getwd(), pattern = ".R$", recursive = T)
# file.rename(dt$para$Rfiles, gsub("beverage", dt$para$beverage, dt$para$Rfiles))

