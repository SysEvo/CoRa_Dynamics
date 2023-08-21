# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/CoRaDyn/MinModelGp/Files/")

library(ggplot2)

# NOTE: Change file name 
OutMultiDynFile <- read.table("./OUT_ExMultiDynOsc2_MinModelGp_Ex01_Ge_Ge_5-35_tspan_2000_saveat_Any[]_pt_500.txt", 
                              sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change controlled variable 
Var <- sym("Gp")
param <- sym("Ge")
analysis <- "CoRaDyn"
xlim <- c(498,510)
ylim <- c(NaN,NaN)

## Convert data type to factor while keeping original order
OutMultiDynFile$bC <- factor(OutMultiDynFile$Ge, levels = unique(OutMultiDynFile$Ge))
# OutMultiDynFile$XC <- OutMultiDynFile$XC + rep(2.7**c(0:6), unname(table(OutMultiDynFile$bC)))
OutMultiDynFile$inter <- interaction(OutMultiDynFile$Ge, OutMultiDynFile$Syst)

ggplot(OutMultiDynFile, aes(Time, {{Var}}, color = factor(inter))) +
  geom_line(linewidth = 0.8) +
  coord_cartesian(xlim = xlim, ylim = ylim, expand = TRUE) +
  ggtitle("Oscillatory dynamics of the FB and NF systems") +
  labs(color = "Ge & sys") +
  guides(color = guide_legend(ncol = 1))

ggsave("../MultiDynOscMinModelGp_bC5:5:35_Gp.png", height = 7, width = 10, units = "in")
