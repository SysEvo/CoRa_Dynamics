# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Model")

library(ggplot2)

# NOTE: Change file name 
OutDynFile <- read.table("./OUT_File.txt", 
                         sep="\t", header=TRUE, row.names=NULL)

# NOTE: Change parameters (Var, xlim, colors, log)
Var <- sym("Y")
xlim <- c(498, 1000)
ylim <- c()
colors <- c("seagreen2", "deepskyblue4")

# Data cleansing
colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]
## Delete rows where time = Inf
OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),]

ggplot(OutDynFile, aes(x = time, y = Y)) +
  geom_line(aes(linetype = FB, color = FB), linewidth = 1) +
  coord_cartesian(xlim = xlim, 
                  ylim = ylim, 
                  expand = TRUE) +
  scale_color_manual(values= colors, labels = c("FB", "NF")) +
  scale_linetype_manual(values=c("solid", "dashed")) +
  labs(x = "Time", y = "Output") +
  ggtitle("Perturbation response of the systems with and without feedback") +
  guides(color = guide_legend("Legend"), linetype = "none") +
  geom_ribbon(aes(ymin = min(OutDynFile[[Var]]), ymax = Y, fill = FB), position = "identity", show.legend = FALSE, alpha = 0.2) +
  scale_fill_manual(values = colors)

# Save plot image 
# ggsave("./Dyn/ExDyn_Area_ATFv1_mY_0.480.png", height = 5, width = 7, units = "in")