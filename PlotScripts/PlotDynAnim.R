# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/MinModel")

library(ggplot2)
library(gganimate)

# NOTE: Change file name 
OutDynFile <- read.table("./OUT_ExDyn_MinModelGi_Ex01_Ge_Ge_17.txt", 
                         sep="\t", header=TRUE, row.names=NULL)
# NOTE: Change parameters
Var <- sym("Gi")                          # Parameter whose range is used to calculate CoRa
colors <- c("coral", "turquoise3", "red") # Colors: yellow3, coral, midnightblue, turquoise3
xlim <- c()
ylim <- c()

# Data cleansing
colnames(OutDynFile) <- c(colnames(OutDynFile),"NaN")[-1]
OutDynFile <- OutDynFile[-which(OutDynFile$time == "Inf"),] # Delete rows where time = Inf

DynFB <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"1"[4950:5200,]
DynNF <- split(OutDynFile, OutDynFile$FB, drop = FALSE)$"0"[4950:5200,]

# Plot dynamic 
plot <- ggplot(DynFB, mapping = aes(time, log10({{Var}}))) +
  geom_line(aes(color = "Con retroalimentación"), linewidth = 1) +
  geom_line(DynNF, mapping = aes(time, log10({{Var}}), color = "Sin restroalimentación"), linetype = "dashed", linewidth = 1) +
  geom_point(aes(x = 500, y = log10(11.47045), shape = "Perturbación"), size = 3, color = "red") + 
  coord_cartesian(xlim = xlim, 
                  ylim = ylim, 
                  expand = TRUE) +
  labs(x = "Tiempo", y = "Respuesta", color = " ", shape = NULL) +
  ggtitle("Respuesta de los sistemas a una perturbación") +
  scale_color_manual(values = c("Con retroalimentación" = "coral", "Sin restroalimentación" = "turquoise3")) +
  scale_shape_manual(values = c("Perturbación" = 8)) +
  guides(shape = guide_legend(order = 2), col = guide_legend(order = 1)) +
  theme(legend.margin = margin(-0.7,0,0,0, unit="cm"),
        plot.title = element_text(size = 18),
        axis.title=element_text(size=15),
        legend.text = element_text(size = 13),
        legend.title = element_text(size = 15))

# Animate figure
anim <- plot + 
 transition_reveal(time)
animate(anim, width = 1000, height = 500, res = 110, nframes = 200, detail = 4, duration = 8)

# Save animation
anim_save("../Figs/Anim.gif")
