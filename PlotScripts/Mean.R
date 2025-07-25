# Calculate IQR for each combination of Conditions and Tspan
# Set the working directory to the location of the output files
setwd("/home/atamayo/Desktop/Mariana/Final/OutFinal/Fig3B/")

# Load required libraries
library(ggplot2)
library(paletteer)

# Define the name of the data file to read
FileName <- "OUT_ExMultiSSs_Dyn_PID_bP_bD_bI_bC_tspan-15-20-25-30-50-75-100-250-500-750-1000-3000.txt"

# Read the tab-separated data file with column headers
OutFile <- read.table(FileName, sep = "\t", header = TRUE)

# Remove rows with any missing values (NA) to clean the data
OutFile <- na.omit(OutFile)

# Define the name of the parameter you want to analyze
Param <- "bP"

# Define the name of the variable whose IQR and mean you want to compute
Target <- "CoRaDyn.bC."  # replace if needed with another output variable

# Extract unique values for parameter and time span
Conditions <- unique(OutFile[[Param]])
Tspan <- unique(OutFile$tspan)

# Create a grid of all combinations of Conditions and Tspan (stringsAsFactors=FALSE to avoid factor issues)
Grid <- expand.grid(Conditions = Conditions, Tspan = Tspan, stringsAsFactors = FALSE)

# IMPORTANT: Convert Conditions to factor for discrete coloring and proper legend
Grid$Conditions <- factor(Grid$Conditions)

# Calculate IQR for each combination of Conditions and Tspan
# Grid$IQR <- mapply(function(i, j) {
#   IQR(OutFile[OutFile[[Param]] == i & OutFile$tspan == j, Target])
# }, Grid$Conditions, Grid$Tspan)

# Calculate mean for each combination of Conditions and Tspan
Grid$Mean <- mapply(function(i, j) {
  mean(OutFile[OutFile[[Param]] == i & OutFile$tspan == j, Target])
}, Grid$Conditions, Grid$Tspan)

my_colors <- as.character(paletteer::paletteer_c("ggthemes::Classic Blue", 25))

# Plot grouped bar chart with viridis discrete color scale
plot <- ggplot(Grid, aes(x = factor(Tspan), y = Mean, fill = Conditions)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.9)) +
  scale_fill_manual(values = my_colors) +
  labs(
    x = "tn (min)",
    y = paste("<CoRaDyn>", Param),
    fill = Param
  ) +
  coord_cartesian(ylim = c(0, 1),
                  expand = FALSE) +
  guides(fill = guide_legend(nrow = 1, byrow = TRUE)) +
  theme(line = element_blank(),
    panel.background = element_rect(fill = 'white'),
    axis.text = element_text(size = 18, color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.title.x = element_text(margin = margin(t = -8, r = 0, b = 0, l = 0)),
    axis.title = element_text(size = 25),
    axis.ticks = element_line(color = 'black', linewidth = 0.8),
    axis.ticks.length = unit(.15, "cm"),
    axis.line = element_line(colour = "black", 
                             linewidth = 0.5, linetype = "solid"),
    legend.title = element_text(size = 18,
                                margin = margin(t = 0, r = 20, b = 0, l = 0)),
    legend.justification = c(0.8, 0),
    legend.text = element_blank(),
    legend.position = "top",
    legend.direction = "horizontal",
    legend.box = element_blank(),
    legend.spacing.x = unit(-0.02, "lines"),    # reduce horizontal spacing between keys
    legend.margin = margin(0.25, 0.5, 1, 0.5, "cm"),
    plot.margin = margin(0.25, 1, 0.5, 0.5, "cm")) 

plot 

ggsave(
  filename = paste0("../../Plots/Fig3B_", Param, ".svg"),
  plot = plot,
  height = 5, 
  width = 7.7,   # in inches
  units = "in"
)

