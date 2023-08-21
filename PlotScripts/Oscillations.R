# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Oscillations/")

library(ggplot2)

# NOTE: Change file name 
OutDynFile <- read.table("./FBandNF_Oscillations.txt", 
                         sep="\t", header=TRUE, row.names=NULL)


ggplot(OutDynFile, aes(timeFB, solFBGp)) +
  geom_line(aes(color = "FB GP"), linewidth = 1) +
  geom_line(aes(timeFB, solNFGp, color = "NF Gp"), linewidth = 1) +
  geom_line(aes(timeFB, solFBGi, color = "FB Gi"), linewidth = 1) +
  geom_line(aes(timeFB, solNFGi, color = "NF Gi"), linewidth = 1) +
  geom_line(aes(timeFB, solFBA, color = "FB A"), linewidth = 1) +
  geom_line(aes(timeFB, solNFA, color = "NF A"), linewidth = 1) +
  coord_cartesian(xlim = c(1060, NaN), 
                  ylim = c(NaN, 50)) +
  labs(x = "Time", y = "Solution", color = "System")

  # Save plot image 
ggsave("./FBandNF_Oscillations.png", height = 5, width = 7, units = "in")
                  