# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/MinModel/")

library(ggplot2)

# NOTE: Change file name 
OutMultiDynFile <- read.table("./OUT_ExMultiDyn_MinModelGi_2.0-23.0_Ex01_Ge_Ge.txt", 
                         sep="\t", header=TRUE, row.names=NULL)
xlim <- c(0,10)
ylim <- c(2,24)
# NOTE: Change condition variable 
Condition <- sym("Ge")
# NOTE: Change controlled variable 
Var <- sym("Gi")

# Data cleansing
## Adjust column names
colnames(OutMultiDynFile) <- c(colnames(OutMultiDynFile),"NaN")[-1]
## Delete rows where time = Inf
OutMultiDynFile <- OutMultiDynFile[-which(OutMultiDynFile$time == "Inf"),]

df <- data.frame(Condition = unique(OutMultiDynFile[[Condition]]),
                 x = 1:length(unique(OutMultiDynFile[[Condition]])),
                 y = as.numeric(unique(OutMultiDynFile[[Condition]])))

# Plot CoRa values 
## Colors: yellow3, coral, midnightblue
ggplot(df, aes(x, log10(y), label = round(as.numeric(Condition), digits = 3))) +
  geom_point(color = "yellow3") +
  #coord_cartesian(xlim = xlim, ylim = ylim, expand = TRUE) +
  labs(y = paste("[", Condition, "]")) +
  geom_text(size = 3.5, hjust=1, vjust=-0.9, check_overlap = TRUE) +
  ggtitle(paste(Condition , "range")) +
  theme(axis.title.x=element_blank())

# Save plot image 
# NOTE: Change the image name  
ggsave("./MultiDyn/MinModelGi_ATFv1/GeRange_MinModelGi_Ge2-24_10.png", height = 5, width = 7, units = "in")
