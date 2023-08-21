# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/CoRaDyn/MinModelGp/Files/")

library(ggplot2)

Var <- sym("Gp")
pts <- format(seq(500.0,650.0, by = 2.0), nsmall = 1)[1]
xlim <- c(1990,1995) #505, 555, 1000
ylim <- c(NaN, NaN)

# NOTE: Change file namet 
#for(i in pts){
  FileName <- "./OUT_ExDynOsc2_MinModelGp_Ex01_Ge_31.52631578947368_Ge_31.52631578947368_tspan_2000_saveat_Any[]_pt_500.txt"
  OutDynFile <- read.table(FileName, 
                           sep="\t", header=TRUE, row.names=NULL)
  
  ggplot(OutDynFile, aes(Time, {{Var}}, color = factor(Syst))) +
    geom_line(linewidth = 0.5) +
    coord_cartesian(xlim = xlim, ylim = ylim, expand = TRUE) +
    ggtitle("Oscillatory dynamics of the FB and NF systems") +
    labs(color = "System")
   ggsave(paste("../ExDynOsc_MinModelGp_Ge31.52631578947368_CoRaDyn0.99.png", sep = ""), height = 7, width = 10, units = "in")
#}

