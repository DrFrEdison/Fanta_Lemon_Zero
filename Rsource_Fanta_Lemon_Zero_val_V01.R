library(devtools); suppressMessages(install_github("DrFrEdison/r4dt", dependencies = T) ); library(r4dt); dt <- list()

# general parameters ####
dt$para$customer = "CCEP"
dt$para$beverage = "Fanta_Lemon_Zero"

setwd(paste0(dt$wd <- paste0(wd$fe$CCEP$Mastermodelle, dt$para$beverage)))
setwd( print( this.path::this.dir() ) )
setwd("..")
dt$wd.git <- print( getwd() )

dt$para$location = c("Moenchengladbach", "Genshagen")
dt$para$line = c("G9", "G6")
dt$para$main = paste0(dt$para$beverage, " in ", dt$para$location, ", line ", dt$para$line)
dt$para$model.date <- c("220530")
dt$para$model.pl <- c("00300")
dt$para$wl1 <- c(190)
dt$para$wl2 <- c(598)
dt$para$wl[[1]] <- seq(dt$para$wl1, dt$para$wl2, 1)

dt$para$substance <- c("TTA", "Acesulfam", "Aspartam", "T1", "T2B", "T2")
dt$para$unit <- c( bquote("%"),  bquote("%"),  bquote("%"), bquote("%"), bquote("%"), bquote("%"))
dt$para$ylab <- c( bquote("TTA in %"), bquote("Acesulfam in %"), bquote("Aspartam in %"), bquote("T1 in %"), bquote("T2B in %"), bquote("T2 in %") )
# dt$para$mop.date <- "220522"
dt$para$SOLL <- c(100, 100,100,100,100,100)

dt$para$val.date <- "220609"

# Linearity
# setwd(dt$wd)
# setwd("./Modellvalidierung")
# setwd("./Linearitaet")
# dt$lin$raw <- read.csv2( "220602_Max_Cherry_Linearitaet_TA_Acesulfam_Aspartam_Coffein.csv" , sep = "\t")
# dt$lin$raw <- dt$lin$raw[ order(dt$lin$raw$Dilution) , ]
# dt$lin$trs <- transfer_csv(dt$lin$raw)

dt$para$eingriff <- c(2, 2, 2, 2)
dt$para$sperr <- c(3, 3, 3, 3)

dt$para$Charge <- c("0010905033", "0010987125", "0010873303", "0010987125")
dt$para$Charge.Sirup <- "2206010745"
# rename R files (run only once)
# dt$para$Rfiles <- list.files(getwd(), pattern = ".R$", recursive = T)
# file.rename(dt$para$Rfiles, gsub("beverage", dt$para$beverage, dt$para$Rfiles))

