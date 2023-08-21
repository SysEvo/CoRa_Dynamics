# NOTE: ChanGe path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Delta/MinModelGi/MethodsDiff")

library(ggplot2)

Analysis1 <- "ExSSs_DynTrap"
Analysis2 <- "ExSSs_DynRect"
Model <- "MinModelGi_Ex01_Ge_Ge"
PlotDiff <- FALSE
IndVar <- sym("Ge")
xlim <- c(2.0,23.0)
ylim <- c()
no10 <- TRUE


CoRaDiffFile <- read.table(paste("./Diff_", Analysis1, "-", Analysis2, "_", Model, ".txt", sep = ""),
                           sep=" ", header=TRUE, row.names=NULL)[1:50,]
  
plot <- ggplot(CoRaDiffFile, aes({{IndVar}}, Diff_Any, color = "Any")) +
  geom_point(size = 4) +
  geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01, color = "0.01"), size = 5) +
  geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.1, color = "0.1"), size = 3) +
  geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_1.0, color = "1.0"), size = 2) +
  geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_10.0, color = "10.0"), size = 1) +
  scale_color_manual(values= c("black", "red", "blue", "green", "midnightblue")) + 
  labs(y = "Difference", color = "Delta t") +
  ggtitle(paste("Difference between", Analysis1, "and", Analysis2, sep = " ")) +
  theme(plot.title = element_text(size = 18),
        axis.title=element_text(size=15),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 15)) +
  coord_cartesian(xlim = xlim,
                  ylim = ylim,
                  expand = TRUE)
  
plot
ggsave(paste("../Diff_", Analysis1, "-", Analysis2, Model,".png", sep = ""), height = 5, width = 7, units = "in")
  