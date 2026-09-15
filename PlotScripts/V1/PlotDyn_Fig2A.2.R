# NOTE: Change path 
setwd("~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/")

library(ggplot2)
library(dplyr)
library(sjPlot)

# NOTE: Change file name 
FileName <- "~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/Fig2/OUT_ExCoRaDyn_tspan_PID_Ex01_bC_tspan1.0-1000.0.txt"
OutDynFile <- read.table(FileName, 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change control variable
Var <- sym("XC")
units <- "[nM]"
colors <- c("#B22222", "black") 
xlim <- c(3000-125, 3000+125)
ylim <- c(2.985,3.025)

#-------------------------------------------------------------------------------
colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]
OutDynFile$time <- OutDynFile$time - 500 
# Delete rows where time = Inf
#OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),]

DynFB <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"1"
DynNF <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"0"
#-------------------------------------------------------------------------------
plot <- ggplot(DynFB, mapping = aes(time, log10({{Var}}))) +
  geom_line(aes(color = "FB"), linewidth = 1.8) +
  geom_line(DynNF, mapping = aes(time, log10({{Var}}), color = "NF"), linetype = "dashed", linewidth = 1.8) +
  geom_vline(xintercept = 30, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 250, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 3000, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  coord_cartesian(xlim = xlim,
                  ylim = ylim,
                  expand = TRUE) +
  labs(x = "Time (min)", y = paste("log10(",Var,units,")"), color = "", caption = FileName) +
  ggtitle(" ") +
  scale_color_manual(values= colors) +
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 1.8),
        axis.ticks.y = element_blank(),
        axis.ticks.x = element_line(color = 'black', size = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.line.y = element_line(colour = "white", 
                                   size = 2, linetype = "solid"),
        axis.text.y = element_blank(),
        axis.text.x = element_text(size = 18, 
                                   margin = margin(t = 5, r = 0, b = 0, l = 0)),
        axis.title = element_blank(), 
        legend.text = element_text(size = 17),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")) +
  scale_x_continuous(breaks = seq(3000, 3000, by = 1))

plot 

# Save plot image 
params <- strsplit(sub("\\.txt$", "", FileName), "_")[[1]][c(6,7)]

#save_plot(paste("../Plots/Fig2A.2_",params[1], "_", params[2],".svg", sep = ""), fig = plot, height = 5*3, width = 2.5*3)

