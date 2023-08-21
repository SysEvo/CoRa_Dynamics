# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/MinModel/")

library(ggplot2)

# NOTE: Change file name 
OutMultiDynFile <- read.table("./OUT_ExMultiDyn_ATFv1_0.001-1000.0_Fig2B_mY_mY_10.txt", 
                              sep="\t", header=TRUE, row.names=NULL)

# NOTE: Change condition variable 
Condition <- sym("mY")
# NOTE: Change controlled variable 
Var <- sym("Y")

# Data cleansing
## Adjust column names
colnames(OutMultiDynFile) <- c(colnames(OutMultiDynFile),"NaN")[-1]
## Delete rows where time = Inf
OutMultiDynFile <- OutMultiDynFile[-which(OutMultiDynFile$time == "Inf"),]

y <- c()
for (i in unique(OutMultiDynFile[[Condition]])){
  y <- c(y, OutMultiDynFile[which(OutMultiDynFile[[Condition]] == i)[1], ][[Var]])
}

df <- data.frame(Condition = unique(OutMultiDynFile[[Condition]]), 
                 x = as.numeric(unique(OutMultiDynFile[[Condition]])), 
                 y = y)

ggplot(df, aes(x, y, color = Condition)) +
  geom_point() +
  labs(x = paste(Condition, "value"), y = paste(Var, "ss")) +
  scale_colour_discrete(labels = as.character(round(as.numeric(df$Condition), digits = 3))) +
  ggtitle(paste("Initial stationary state of the variable of interest according to the", Condition, "value"))

# Save plot image 
ggsave("./MultiDyn/MinModelGi_ATFv1/SS_ATFv1_mY0.001-1000_10_nolog.png", height = 5, width = 7, units = "in")
