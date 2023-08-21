# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/OutputFiles/")

library(ggplot2)

# NOTE: Change file name 
OutDynFile <- read.table("./OUT_ExDyn_ATF_Ex01_bC_bC.txt", 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change control variable
Var <- sym("XC")

colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]

# Delete rows where time = Inf
OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),]

DynFB <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"1"
DynNF <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"0"

colors <- c("midnightblue", "yellow3")

ggplot(DynFB, mapping = aes(time, log10({{Var}}))) +
  geom_point(aes(color = "FB"), linewidth = 1) +
  geom_point(DynNF, mapping = aes(time, log10({{Var}}), color = "NF"), linetype = "dashed", linewidth = 1) +
  coord_cartesian(xlim = c(498, 650), 
  #                ylim = c(n1, n2), 
                  expand = TRUE) +
  labs(x = "Time", y = "Output", color = "Legend") +
  ggtitle("Perturbation response of the systems with and without feedback") +
  scale_color_manual(values= colors) 

# Save plot image 
# ggsave("./Dyn/Plot.png", height = 5, width = 7, units = "in")
