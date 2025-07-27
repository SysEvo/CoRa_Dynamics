library(ggplot2)
library(dplyr)
library(ggrepel)
library(sjPlot)

# Set working directory and read files
setwd("/home/atamayo/Desktop/Mariana/Final/OutputFiles/")

OutCoRaDynFile1 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_Ex01_bC_bP0.4_bD0.15_tspan1-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile2 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_P_Ex01_bC_bP0.4_bD0.15_tspan1-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile3 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_D_Ex01_bC_bP0.4_bD0.15_tspan1-4000.txt", sep="\t", header=TRUE)
OutCoRaDynFile4 <- read.table("./OUT_ExSSs_Dyn_tspan_PID_PD_Ex01_bC_bP0.4_bD0.15_tspan1-4000.txt", sep="\t", header=TRUE)

Labels <- c("PID", "P", "D", "P + D")
Colors <- c("PID" = "orange1", "P" = "#9ACD32", "D" = "#8B0A50", "P + D" = "#27408B")
ylim <- c(0, 1)
xlim <- c(0, 30) #c(-18, 1020) c(0, 100)

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
  geom_line(linewidth = 1.8) + # 1.8 
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
        axis.ticks = element_line(color = 'black', linewidth = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.line.y.right = element_line(colour = "white", 
                                         size = 3, linetype = "solid"),
        axis.text = element_text(size = 20),  # 20 12
        axis.title = element_text(size = 25), # 25 17
        axis.text.y.right = element_blank(),
        axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
        axis.text.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
        legend.position = "none",
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"),)

plot 

# Save plot image 
save_plot(paste("../Plots/Fig4A_xlim",paste(xlim, collapse = "-"),".svg", sep = ""), fig = plot, height = 3*3, width = 3*3) # 3*3 3*3 7*7 7*7
