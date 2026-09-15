# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/Final/OutputFiles/")

library(ggplot2)
library(dplyr)
library(sjPlot)
library(viridis)

# NOTE: Change file name
FileName <- "./OUT_ExMultiSSs_Dyn_PID_D_bP_bD_bI_bINaN_bC_tspan-15-20-25-30-50-75-100-250-500-750-1000-3000.txt"
OutFile <- read.table(FileName, 
                         sep="\t", header=TRUE, row.names=NULL)
VarX <- "bD"
VarY <- "bP"
Analisis <- "CoRaDyn"

#-------------------------------------------------------------------------------

colnames(OutFile)[ncol(OutFile)] <- Analisis
OutFile[,VarX] <- as.factor(round(OutFile[,VarX], 3))
OutFile[,VarY] <- as.factor(round(OutFile[,VarY], 3))

# Replace NAs with a placeholder (e.g., -1) instead of removing them
# OutFile <- OutFile[!is.na(OutFile[,Analisis]),]

VarX <- sym(VarX)
VarY <- sym(VarY)
Analisis <- sym(Analisis)

#-------------------------------------------------------------------------------

plot <- ggplot(OutFile, aes(x = !!VarX, y = !!VarY, fill = {{Analisis}})) +
  geom_tile() +
  scale_fill_gradientn(
    colors = turbo(100), 
    breaks = c(0, 0.25, 0.5, 0.75, 1), 
    labels = as.character(c("0", "0.25", "0.5", "0.75", "1")),
    limits = c(0, 1),  # Force the scale from 0 to 1
    na.value = "white",
    guide = guide_colorbar(barwidth = 1, barheight = 15, title = NULL)) +
  theme_classic() +
  geom_tile(color = NA) +
  scale_x_discrete(breaks = levels(OutFile[,as.character(VarX)])[seq(1, length(levels(OutFile[,as.character(VarX)])), by = 6)]) +
  scale_y_discrete(breaks = levels(OutFile[,as.character(VarY)])[seq(1, length(levels(OutFile[,as.character(VarY)])), by = 6)]) +
  theme(line = element_blank(),
        axis.ticks = element_line(color = 'black', size = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 15, 
                                 margin = margin(t = 5, r = 0, b = 0, l = 0),),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.text = element_text(size = 17),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

plot

#-------------------------------------------------------------------------------

# Save plot image 
params <- strsplit(FileName, "_")[[1]][c(4, 5, 8)]

#save_plot(paste("../Plots/Fig4Sup_2D_", params[1], "_", params[2], "_", params[3], ".svg", sep = ""), fig = plot, height = 5*2.5, width = 6*2.5)


