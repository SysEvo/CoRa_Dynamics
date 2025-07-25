library(ggplot2)
library(dplyr)
library(ggrepel)
library(sjPlot)

# Set working directory and read files
setwd("/home/atamayo/Desktop/Mariana/Final/OutFinal/Fig3B/")

OutCoRaDynFile <- read.table("./OUT_ExMultiSSs_Dyn_PID_bP_bD_bI_bC_tspan-15-20-25-30-50-75-100-250-500-750-1000-3000.txt", sep="\t", header=TRUE)

OutCoRaDynFile <- OutCoRaDynFile[((OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.10000000) |
                 (OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.40000000) |
                 (OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.70000000) |
                 (OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.10000000) |
                 (OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.40000000) |
                 (OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.70000000) |
                 (OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.10000000) |
                 (OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.40000000) |
                 (OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.70000000)) & OutCoRaDynFile$tspan == 3000,] 


Labels <- c("bI = 0.03 bD = 0.1", "bI = 0.03 bD = 0.4", "bI = 0.03 bD = 0.7", 
            "bI = 0.06 bD = 0.1", "bI = 0.06 bD = 0.4", "bI = 0.06 bD = 0.7", 
            "bI = 0.09 bD = 0.1", "bI = 0.09 bD = 0.4", "bI = 0.09 bD = 0.7")

ylim <- c(0, 1)
xlim <- c(0, 0.8)

# Add label column to each dataframe
OutCoRaDynFile$Label <- rep(NA, nrow(OutCoRaDynFile))
OutCoRaDynFile[OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.10000000,]$Label <- Labels[1]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.40000000,]$Label <- Labels[2]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.03000000 & OutCoRaDynFile$bD == 0.70000000,]$Label <- Labels[3]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.10000000,]$Label <- Labels[4]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.40000000,]$Label <- Labels[5]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.06000000 & OutCoRaDynFile$bD == 0.70000000,]$Label <- Labels[6]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.10000000,]$Label <- Labels[7]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.40000000,]$Label <- Labels[8]
OutCoRaDynFile[OutCoRaDynFile$bI == 0.09000000 & OutCoRaDynFile$bD == 0.70000000,]$Label <- Labels[9]


OutCoRaDynFile$Label <- factor(OutCoRaDynFile$Label, levels = Labels)

# Define symbolic variable for perturbation and time
PertVar <- sym("bC")
Condition <- sym("bP")
CoRaDyn <- sym(paste("CoRaDyn.", PertVar,".", sep = ""))

# Plot
plot <- ggplot(OutCoRaDynFile, aes(x = {{Condition}}, y = {{CoRaDyn}}, color = Label)) +
  geom_line(linewidth = 1) 

plot 

