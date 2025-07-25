library(ggplot2)
library(dplyr)
library(ggrepel)
library(sjPlot)

# Set working directory and read files
setwd("/home/atamayo/Desktop/Mariana/Final/OutputFiles/")

OutCoRaDynFile1 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_Ex01_bC_bP0.0_bD0.0_501-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile2 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_Ex01_bC_bP0.0_bD0.8_501-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile3 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_Ex01_bC_bP0.5_bD0.0_501-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile4 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_Ex01_bC_bP0.5_bD0.185_501-4000.txt", sep="\t", header=TRUE)

Labels <- c("bP = 0.0 bD = 0.0", "bP = 0.0 bD = 0.8", "bP = 0.5 bD = 0.0", "bP = 0.5 bD = 0.185")
Colors <- c("bP = 0.0 bD = 0.0" = "#27408B", "bP = 0.0 bD = 0.8" = "#9ACD32", "bP = 0.5 bD = 0.0" = "orange1", "bP = 0.5 bD = 0.185" = "#8B0A50")
ylim <- c(0, 1)
xlim <- c(0, 100)

# Add label column to each dataframe
OutCoRaDynFile1$Label <- Labels[1]
OutCoRaDynFile2$Label <- Labels[2]
OutCoRaDynFile3$Label <- Labels[3]
OutCoRaDynFile4$Label <- Labels[4]

# Combine all data frames
OutCoRaDynAll <- bind_rows(OutCoRaDynFile1, OutCoRaDynFile2, OutCoRaDynFile3, OutCoRaDynFile4)
OutCoRaDynAll$Label <- factor(OutCoRaDynAll$Label, levels = Labels)

# Define symbolic variable for perturbation and time
PertVar <- sym("bC")
Condition <- sym("tspan")
CoRa <- sym(paste("CoRaDyn.", PertVar,".", sep = ""))

# Plot
plot <- ggplot(OutCoRaDynAll, aes(x = {{Condition}}, y = {{CoRa}}, color = Label)) +
  geom_hline(yintercept = 1, linetype = "solid", color = "grey", linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey", linewidth = 0.5) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey", linewidth = 0.5) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 30, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 250, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 1000, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  geom_vline(xintercept = 3000, linetype = "solid", color = "#FFFF00", linewidth = 0.5) +
  scale_color_manual(values = Colors) +
  coord_cartesian(ylim = ylim, 
                  xlim = xlim,
                  expand = TRUE) +
  labs(x = "Time (min)", y = "CoRaDyn", color = "") +
  ggtitle(" ") +
  #guides(y.sec = "axis") + 
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
        axis.ticks.y.right = element_blank(),
        axis.ticks = element_line(color = 'black', size = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.line.y.right = element_line(colour = "white", 
                                         size = 3, linetype = "solid"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 17), 
        axis.text.y.right = element_blank(),
        axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
        axis.text.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
        legend.position = "none",
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"),)

plot 

# Save plot image 
#save_plot(paste("../Plots/Fig2B_xlim",paste(xlim, collapse = "-"),".svg", sep = ""), fig = plot, height = 3*3, width = 3*3)
