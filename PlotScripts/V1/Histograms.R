library(ggplot2)
library(dplyr)
library(ggrepel)
library(sjPlot)

# Set working directory and read files
setwd("/home/atamayo/Desktop/Mariana/Final/OutFinal/Fig3B/")

OutCoRaDynFile <- read.table("./OUT_ExMultiSSs_Dyn_PID_bP_bD_bI_bC_tspan-15-20-25-30-50-75-100-250-500-750-1000-3000.txt", sep="\t", header=TRUE)
OutCoRaDynFile <- OutCoRaDynFile[OutCoRaDynFile$tspan == 100,]
OutCoRaDynFile <- OutCoRaDynFile[order(OutCoRaDynFile$bP, OutCoRaDynFile$bI, OutCoRaDynFile$bD),]

Param <- "bD"
CoRaDyn <- "CoRaDyn.bC."

vec <- rep(length(unique(OutCoRaDynFile[, Param])), 
           nrow(OutCoRaDynFile) / length(unique(OutCoRaDynFile[, Param]))) * 
  1:length(rep(length(unique(OutCoRaDynFile[, Param])), 
               nrow(OutCoRaDynFile) / length(unique(OutCoRaDynFile[, Param]))))
vec <- vec[-length(vec)]

getDelta <- function(Param) {
  delta <- OutCoRaDynFile[,Param][2:nrow(OutCoRaDynFile)] - OutCoRaDynFile[,Param][1:nrow(OutCoRaDynFile)-1]
  delta <- delta[-vec]
  return(delta)
}

dBeta <- getDelta(Param)
dCoRaDyn <- getDelta(CoRaDyn)
sensibilities <- dCoRaDyn/dBeta 

hist(sensibilities,
     main = "Frequency of Sensibility Ranges",
     xlab = "Sensibility",
     ylab = "Frequency",
     col = "skyblue",
     border = "white",
     breaks = 100)

sensibilities <- as.data.frame(sensibilities)
#write.table(sensibilities, file = "sensibilities_bP15.txt", sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)



