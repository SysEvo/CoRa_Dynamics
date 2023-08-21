# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/CoRaDyn/ATF/Files/")

library(ggplot2)

#for(i in format(seq(1000,25650, by = 1450.0), nsmall = 1, trim = TRUE)){
  # NOTE: Change file name 
  FileName <- "./OUT_ExCoRaDyn_ATF_Ex01_bC_bC_0.01-0.3_tspan_2000_saveat_Any[]_pt_500.txt"
  OutCoRaFile <- read.table(FileName, sep="\t", header=TRUE, row.names=NULL)
  
  # Plot CoRa values 
  
  xlim <- c(0,0.32)
  ylim <- c(NaN,NaN)
  pertVar <- "bC"
  condition <- sym("bC")
  analysis <- "CoRaDyn"
  color <- "deeppink4" ## Colors: yellow3, coral, midnightblue, deeppink4, goldenrod3
  
  depVar <- sym(paste(analysis,".",pertVar,".", sep = ""))
  
  ggplot(OutCoRaFile, aes({{condition}}, {{depVar}}, label = round({{depVar}}, digits = 3))) +
    geom_point(color = color, size = 2.5) +
    labs(x = condition, y = analysis) +
    geom_text(size = 3.5, hjust=-0.1, vjust=-0.9, check_overlap = TRUE) +
    coord_cartesian(xlim = xlim, ylim = ylim, expand = TRUE) +
    ggtitle(paste(analysis, "with respect to the", condition)) +
    theme(plot.title = element_text(size = 18), axis.text = element_text(size=12), axis.title = element_text(size=13))

  # Save plot image 
  # NOTE: Change the image name  
  ggsave(paste("../CoRaDynATF_bC0.01-0.3len7.png", sep = ""), height = 5, width = 7, units = "in")
#}