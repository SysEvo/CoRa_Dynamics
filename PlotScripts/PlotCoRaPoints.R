# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/OutputFiles/")

library(ggplot2)

# NOTE: Change file name 
OutCoRaFile <- read.table("./OUT_ExPertTimeTest_MinModelGp_Ex01_Ge_24.150000000000002_Ge_24.150000000000002_tspa_1000.0_saveat_Any[]_pt_500.0-502.0.txt",
                          sep="\t", header=TRUE, row.names=NULL)

# NOTE: Change parameters 
## Condition variable 
Condition <- sym("Ge") 
CoRa <- sym(paste("CoRa.", Condition,".", sep = ""))
Condition <- sym("pt")
xlim <- c(NaN, NaN)
ylim <- c(NaN, NaN)
## Colors: yellow3, coral, midnightblue
colors <- c("deepskyblue4", "seagreen2") 

# Plot CoRa_points or CoRa_points values 
ggplot(OutCoRaFile, aes({{Condition}}, {{CoRa}}, label = round({{CoRa}}, digits = 3), size = 3.5, hjust=1.3, vjust=-0.9, check_overlap = TRUE)) +
  geom_point(aes(color = "CoRaDyn"), size = 2) +
  coord_cartesian(xlim = xlim, ylim = ylim, expand = TRUE) +
  labs(x = paste("[", Condition,"]"), y = "CoRa") +
  geom_text(size = 3.5, hjust=-0.1, vjust=-0.9, check_overlap = TRUE) +
  ggtitle("CoRaDyn value of the system over a parameter range") +
  geom_point(OutCoRaFile, mapping = aes({{Condition}}, {{CoRa}}, color = "CoRa"), size = 2) +
  scale_color_manual(values = colors)

# Save plot image 
# NOTE: Change the image name  
# ggsave("./CoRa/ExSSs_Dyn_points_&_ExSSs_points_ATFv1_tspan5-500.png", height = 5, width = 7, units = "in")