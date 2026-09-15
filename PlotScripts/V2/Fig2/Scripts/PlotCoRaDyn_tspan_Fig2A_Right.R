# NOTE: Change path 
setwd("~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/Fig2/OUT_Files/")

library(ggplot2)
library(dplyr)
library(sjPlot)

# NOTE: Change file name 
FileName <- "./OUT_ExCoRaDyn_tspan_PID_Ex01_bC_tspan1.0-1157.0.txt"
OutCoRaDynFile <- read.table(FileName, 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change control variable
color <- "deepskyblue3"
xlim <- c(43, 1010)
ylim <- c(-0.00000001, 1)

plot <- ggplot(OutCoRaDynFile, mapping = aes(tspan, CoRaDyn.bC.)) +
  geom_line(color = color, linewidth = 2) +
  geom_vline(xintercept = 30, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 30, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 250, linetype = "solid",color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 250, linetype = "solid",color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 750, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 750, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  coord_cartesian(xlim = xlim,
                  ylim = ylim,
                  expand = TRUE) +
  labs(x = "Time (min)", y = "CoRaDyn", caption = FileName) +
  ggtitle(" ") +
  scale_color_manual(values= colors) +
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
        axis.ticks.y.right = element_blank(),
        axis.ticks = element_line(color = 'black', size = 1),
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
ggsave("../Fig2A_Right.svg",
       plot = plot, width = 7, height = 5)

