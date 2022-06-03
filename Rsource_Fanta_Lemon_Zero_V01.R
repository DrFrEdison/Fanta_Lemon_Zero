dt <- list(); dt$R <- paste0(Sys.getenv("OneDriveCommercial"), "/FE_Methoden/", "Allgemein/R_dt_project/")
source(paste0(dt$R,"R/source_spc_files.R"))
source(paste0(dt$R,"R/source_pls.R"))
source(paste0(dt$R,"R/source_read.R"))

# general parameters ####
dt$para$customer = "CCEP"
dt$para$beverage = "Fanta_Lemon_Zero"

setwd(paste0(dt$wd <- paste0(wd$fe$CCEP$Mastermodelle, dt$para$beverage)))
setwd( print( this.path::this.dir() ) )
setwd("..")
dt$wd.git <- print( getwd() )

# .opendir(dt$wd)

dt$para$location = "Moenchengladbach"
dt$para$line = "G9"
dt$para$main = paste0(dt$para$beverage, " in ", dt$para$location, ", line ", dt$para$line)
dt$para$model.date <- c("220530")
dt$para$model.pl <- c("00300")
dt$para$wl1 <- c(190)
dt$para$wl2 <- c(598)
dt$para$wl[[1]] <- seq(dt$para$wl1, dt$para$wl2, 1)

dt$para$substance <- c("Acid", "Acesulfam", "Aspartam", "T1", "T2B", "T2")
dt$para$unit <- c( bquote("%"),  bquote("%"),  bquote("%"), bquote("%"), bquote("%"), bquote("%"))
dt$para$ylab <- c( bquote("Acid in %"), bquote("Acesulfam in %"), bquote("Aspartam in %"), bquote("T1 in %"), bquote("T2B in %"), bquote("T2 in %") )
# dt$para$mop.date <- "220522"
dt$para$SOLL <- c(100, 100,100,100,100,100)

# #rename R files (run only once)
# dt$para$Rfiles <- list.files(getwd(), pattern = ".R$", recursive = T)
# file.rename(dt$para$Rfiles, gsub("beverage", dt$para$beverage, dt$para$Rfiles))
# 
