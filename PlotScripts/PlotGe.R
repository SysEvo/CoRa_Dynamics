# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/MinModel/")

library(ggplot2)

# NOTE: Change file name 
OutDynFile <- read.table("./OUT_File.txt", 
                         sep="\t", header=TRUE, row.names=NULL)

# Plot CoRa values 
## Colors: yellow3, coral, midnightblue
ggplot(OutDynFile, aes(1:length(Ge), Ge, label = round(Ge, digits = 3))) +
  geom_point(color = "yellow3") +
  coord_cartesian(xlim = c(x1,x2), ylim = c(y1,y2), expand = TRUE) +
  labs(y = "[Ge]") +
  geom_text(size = 3.5, hjust=1, vjust=-0.9, check_overlap = TRUE) +
  ggtitle("Ge concentration range") +
  theme(axis.title.x=element_blank())

# Save plot image 
# NOTE: Change the image name  
ggsave("./CoRa/Plot.png", height = 5, width = 7, units = "in")