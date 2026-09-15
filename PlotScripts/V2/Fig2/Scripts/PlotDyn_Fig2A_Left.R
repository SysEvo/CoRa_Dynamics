# NOTE: Change path 
setwd("~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/Fig3/")

library(ggplot2)
library(dplyr)
library(sjPlot)

# NOTE: Change file name 
FileName <- "./Fig3C_OUT_ExDyn_PID_Fig3C_bC.txt"
OutDynFile <- read.table(FileName, 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change control variable
Var <- sym("XC")
units <- "[nM]"
colors <- c("#FF8247", "black")
xlim <- c(-20, 1000)
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
  geom_vline(xintercept = 30, linetype = "solid", color = "deepskyblue3", linewidth = 0.4) +
  geom_vline(xintercept = 30, linetype = "solid", color = "deepskyblue3", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 250, linetype = "solid", color = "deepskyblue3", linewidth = 0.4) +
  geom_vline(xintercept = 250, linetype = "solid",color = "deepskyblue3", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 500, linetype = "solid", color = "deepskyblue3", linewidth = 0.4) +
  geom_vline(xintercept = 500, linetype = "solid", color = "deepskyblue3", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 750, linetype = "solid", color = "deepskyblue3", linewidth = 0.4) +
  geom_vline(xintercept = 750, linetype = "solid", color = "deepskyblue3", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "deepskyblue3", linewidth = 0.4) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "deepskyblue3", linewidth = 1.8, alpha = 0.5) +
  coord_cartesian(xlim = xlim,
                  ylim = ylim,
                  expand = TRUE) +
  labs(x = "Time (min)", y = paste("log10(",Var,units,")"), color = "", caption = FileName) +
  ggtitle(" ") +
  scale_color_manual(values= colors) +
  guides(y.sec = "axis") + 
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
        axis.ticks.y.right = element_blank(),
        axis.ticks = element_line(color = 'black', linewidth = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.text = element_text(size = 20),
        axis.title = element_text(size = 25), 
        axis.text.y.right = element_blank(),
        axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
        axis.text.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
        legend.text = element_text(size = 17), 
        legend.title = element_text(size = 17),
        legend.key = element_rect(color = NA),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

plot 

# Save plot image 
#ggsave("../Fig2A_Left.svg",
 # plot = plot, width = 7, height = 5)

