library(ggplot2)

setwd("~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/Fig2/OUT_Files/")

OutCoRaDynFile <- read.table("./OUT_ExCoRaDyn_PID_Ex01_bC_bC_0.01-0.11.txt", sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile <- read.table("./OUT_ExCoRa_PID_Ex01_bC_[:bC]_0.01-0.11.txt", sep="\t", header=TRUE, row.names=NULL)

# Plot params 
xlim <- c(0.01 , 0.11)
ylim <- c(-0.1, 1)
pertVar <- "bC"
condition <- sym("bC")

depVar_CoRaDyn <- sym(paste("CoRaDyn.",pertVar,".", sep = ""))
depVar_CoRa <- sym(paste("CoRa.",pertVar,".", sep = ""))

ggplot(OutCoRaDynFile, aes({{condition}}, {{depVar_CoRaDyn}}, label = round({{depVar_CoRaDyn}}, digits = 3))) +
  geom_line(color = "darkorchid2", size = 2) +
  geom_line(OutCoRaFile, mapping = aes(x = {{condition}}, y = {{depVar_CoRa}}, label = round({{depVar_CoRa}}, digits = 3)), 
            color = "darkseagreen3", size = 2) +
  geom_vline(xintercept = 0.01, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 0.01, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 0.06, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 0.06, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  geom_vline(xintercept = 0.105, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 0.105, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  labs(x = condition, y = analysis) +
  coord_cartesian(xlim = xlim, ylim = ylim, expand = FALSE) +
  theme(line = element_blank(),
        panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
        axis.ticks.y.right = element_blank(),
        axis.ticks = element_line(color = 'black', size = 1),
        axis.ticks.length = unit(.15, "cm"),
        axis.text = element_text(size = 20),
        axis.title = element_text(size = 25), 
        axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
        axis.text.x = element_text(
          margin = margin(t = 5, r = 0, b = 0, l = 0)),
        legend.text = element_text(size = 17), 
        legend.title = element_text(size = 17),
        plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm"))

# Save plot image 
# NOTE: Change the image name  
#ggsave(paste("../CoRaDynATF_bC0.01-0.3len7.png", sep = ""), height = 5, width = 7, units = "in")

