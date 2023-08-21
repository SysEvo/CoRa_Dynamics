# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/OutputFiles/")

library(ggplot2)

# NOTE: Change file name 
OutMultiDynFile <- read.table("./OUT_ExMultiDyn_ATF_0.01-0.106_Ex01_bC_bC.txt", 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change controlled variable 
Var <- sym("XC")

# Data cleansing
## Adjust column names
colnames(OutMultiDynFile) <- c(colnames(OutMultiDynFile),"NaN")[-1]
## Delete rows where time = Inf
OutMultiDynFile <- OutMultiDynFile[-which(OutMultiDynFile$time == "Inf"),]
## Convert data type to factor while keeping original order
OutMultiDynFile$bC <- factor(OutMultiDynFile$bC, levels = unique(OutMultiDynFile$bC))
## Split the data set according to the initial value of the perturbed parameter
SplitDynFile <- split(OutMultiDynFile, OutMultiDynFile$bC, drop = FALSE)

# Plot data
## Initialize plot
plot <- ggplot() +
  coord_cartesian(xlim = c(498, NaN), expand = TRUE) 

for(dataSet in SplitDynFile){
  
  ## Split FB and NF data
  DynFB <- split(dataSet, dataSet$FB, drop = FALSE)$"1"
  DynNF <- split(dataSet, dataSet$FB, drop = FALSE)$"0"
  
  plot <- plot + 
    geom_line(DynFB, mapping = aes(time, log10({{Var}}), color = bC)) +
    geom_line(DynNF, mapping = aes(time, log10({{Var}}), color = bC), linetype = "dashed")
}

plot <- plot +
  scale_colour_discrete(limits = levels(OutMultiDynFile$bC), 
                        labels= as.character(round(as.numeric(levels(OutMultiDynFile$bC)), digits = 3))) +
  labs(x = "Time", y = "log10(Output)", color = "bC value") +
  guides(color = guide_legend(ncol = 1)) +
  ggtitle("Difference in the system dynamics according to the initial value\nof the perturbed parameter")

# Save plot image 
#ggsave("./MultiDyn/Plot.png", height = 5, width = 7, units = "in")


 