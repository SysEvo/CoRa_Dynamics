# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/Final/OutputFiles/")

library(ggplot2)
library(dplyr)
library(sjPlot)

# NOTE: Change file name 
FileName <- "./OUT_ExDyn_PID_PD_Ex01_bC_bP0.25_bD0.4.txt"
OutDynFile <- read.table(FileName, 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change control variable
Var <- sym("XC")
units <- "[nM]"
colors <- c("orange1", "#27408B") # c("orange1", "black"), c("orange1", "#9ACD32"), c("orange1", "#8B0A50"), c("orange1", "#27408B")
xlim <- c(0, 1000)
ylim <- c(2.985,3.025)

#-------------------------------------------------------------------------------
colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]
OutDynFile$time <- OutDynFile$time - 500 
# Delete rows where time = Inf
#OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),]

DynFB <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"1"
DynNF <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"0"
#-------------------------------------------------------------------------------
plot <- ggplot(DynNF, mapping = aes(time, log10({{Var}}))) +
  geom_line(aes(color = "NF"), linewidth = 1.8) +
  geom_line(DynFB, mapping = aes(time, log10({{Var}}), color = "FB"), linetype = "solid", linewidth = 1.8, alpha = 0.8) +
  coord_cartesian(xlim = xlim,
                  ylim = ylim,
                  expand = TRUE) +
  labs(x = "Time (min)", y = paste("log10(",Var,units,")"), color = "", caption = FileName) +
  ggtitle(" ") +
  scale_color_manual(values= colors) +
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
        axis.ticks = element_line(color = 'black', linewidth = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.text = element_text(size = 20),
        axis.title = element_text(size = 25),
        axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
        axis.text.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
        legend.text = element_text(size = 17), 
        legend.title = element_text(size = 17),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

plot 

# Save plot image 
params <- strsplit(sub("\\.txt$", "", FileName), "_")[[1]][c(4,7,8)]

#save_plot(paste("../Plots/Fig4B_PID_", params[1], "_", params[2], "_", params[3],".svg", sep = ""), fig = plot, height = 5*3, width = 7.7*3)
