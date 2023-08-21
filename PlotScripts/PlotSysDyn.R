# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/MinModel/")

library(ggplot2)

# NOTE: Change file name 
OutDynFile <- read.table("./OUT_file.txt", 
                         sep="\t", header=TRUE, row.names=NULL)

colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]

# Delete rows where time = Inf
OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),]

DynFB <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"1"
DynNF <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"0"

ggplot(DynFB, mapping = aes(time, log10(A))) +
  geom_line(aes(color = "A")) +
  geom_line(DynNF, mapping = aes(time, log10(A), color = "A"), linetype = "dashed") +
  geom_line(DynFB, mapping = aes(time, log10(Gp), color = "Gp")) +
  geom_line(DynNF, mapping = aes(time, log10(Gp), color = "Gp"), linetype = "dashed") +
  geom_line(DynFB, mapping = aes(time, log10(Gi), color = "Gi")) +
  geom_line(DynNF, mapping = aes(time, log10(Gi), color = "Gi"), linetype = "dashed") +
  coord_cartesian(xlim = c(498, 520), 
                  #                ylim = c(n1, n2), 
                  expand = TRUE) +
  labs(x = "Time", y = "log10(Output)", color = "Legend") +
  ggtitle("Perturbation response of the systems with and without feedback") +
  scale_color_manual(values= c("A" = "yellow3", "Gp" = "midnightblue", "Gi" = "coral")) 

# Save plot image 
ggsave("./SysDyn/plot.png", height = 5, width = 7, units = "in")