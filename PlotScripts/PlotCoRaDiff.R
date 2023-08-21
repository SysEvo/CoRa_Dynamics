# NOTE: ChanGe path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Delta/MinModelGp/NoPoints")

library(ggplot2)

Analysis <- "ExSSs_Dyn"
Model <- "MinModelGp_Ex01_Ge_Ge"
PlotDiff <- FALSE
IndVar <- sym("Ge")
xlim <- c(2.0,23.0)
ylim <- c()
no10 <- TRUE

# Plot differences 
if (PlotDiff == TRUE & no10 == FALSE){
  CoRaDiffFile <- read.table(paste("./Diff_", Analysis, "_vals_", Model, ".txt", sep = ""),
                             sep=" ", header=TRUE, row.names=NULL)
  
  CoRaDiffFile <- abs(CoRaDiffFile)
  
  plot <- ggplot(CoRaDiffFile, aes({{IndVar}}, Diff_Any_10.0, color = "[] - 10.0")) +
     geom_point(size = 4) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_1.0, color = "[] - 1.0"), size = 3) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_0.1, color = "[] - 0.1"), size = 4) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_0.01, color = "[] - 0.01"), size = 3) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_0.1, color = "0.01 - 0.1"), size = 2.2) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_1.0, color = "0.01 - 1.0"), size = 3.5) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_10.0, color = "0.01 - 10.0"), size = 2.5) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_1.0_10.0, color = "1.0 - 10.0"), size = 1.5) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.1_1.0, color = "0.1 - 1.0"), size = 1.5) +
     geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.1_10.0, color = "0.1 - 10.0"), size = 0.5) +
     scale_color_manual(values= c("black", "red", "blue", "green", "midnightblue", "coral", "purple", "yellow", "gray", "cyan")) + 
     #geom_vline(xintercept = 0.4641589, color = "red") +
     labs(y = "Difference", color = "Legend") +
     ggtitle("Difference between CoRaDyn values") +
     theme(plot.title = element_text(size = 18),
           axis.title=element_text(size=15),
           legend.text = element_text(size = 13),
           legend.title = element_text(size = 15)) +
     coord_cartesian(xlim = xlim,
                     ylim = ylim,
                     expand = TRUE)
  
  ggsave(paste("./Diff_", Analysis, "_vals_", Model,".png", sep = ""), height = 5, width = 7, units = "in")
} else if (PlotDiff == TRUE & no10 == TRUE) {
  CoRaDiffFile <- read.table(paste("./Diff_", Analysis, "_vals_", Model, ".txt", sep = ""),
                             sep=" ", header=TRUE, row.names=NULL)
  
  CoRaDiffFile <- abs(CoRaDiffFile)
  
  plot <- ggplot(CoRaDiffFile, aes({{IndVar}}, Diff_Any_1.0, color = "[] - 1.0")) +
    geom_point(size = 4) +
    # geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_10.0, color = "[] - 10.0"), size = 3) +
    geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_0.1, color = "[] - 0.1"), size = 4) +
    geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_Any_0.01, color = "[] - 0.01"), size = 3) +
    geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_0.1, color = "0.01 - 0.1"), size = 2.2) +
    geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_1.0, color = "0.01 - 1.0"), size = 3.5) +
    # geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.01_10.0, color = "0.01 - 10.0"), size = 2.5) +
    # geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_1.0_10.0, color = "1.0 - 10.0"), size = 1.5) +
    geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.1_1.0, color = "0.1 - 1.0"), size = 1.5) +
    # geom_point(CoRaDiffFile, mapping = aes({{IndVar}}, Diff_0.1_10.0, color = "0.1 - 10.0"), size = 0.5) +
    scale_color_manual(values= c("black", "red", "blue", "midnightblue", "coral", "yellow")) +
    #geom_vline(xintercept = 0.4641589, color = "red") +
    labs(y = "Difference", color = "Legend") +
    ggtitle("Difference between CoRaDyn values") +
    theme(plot.title = element_text(size = 18),
          axis.title=element_text(size=15),
          legend.text = element_text(size = 13),
          legend.title = element_text(size = 15)) +
    coord_cartesian(xlim = xlim,
                    ylim = ylim,
                    expand = TRUE)
  
  ggsave(paste("./Diff_", Analysis, "_vals_", Model, "_no10.png", sep = ""), height = 5, width = 7, units = "in")
} else if (PlotDiff == FALSE & no10 == FALSE) {
  CoRaValsFile <- read.table(paste("./", Analysis, "_vals_", Model, ".txt", sep = ""),
                             sep=" ", header=TRUE, row.names=NULL)

  plot <- ggplot(CoRaValsFile, aes({{IndVar}}, CoRa_Any, color = "[]")) +
     geom_point(size = 5) +
     geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_0.01, color = "0.01"), size = 4) +
     geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_0.1, color = "0.1"), size = 3) +
     geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_1.0, color = "1.0"), size = 2) +
     geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_10.0, color = "10.0"), size = 1) +
     scale_color_manual(values= c("black", "red", "blue", "green", "purple")) +
     labs(y = "CoRa", color = "Legend") +
     ggtitle("CoRaDyn values") +
     #geom_vline(xintercept = 0.4641589, color = "red") +
     theme(plot.title = element_text(size = 18),
           axis.title=element_text(size=15),
           legend.text = element_text(size = 13),
           legend.title = element_text(size = 15)) +
     coord_cartesian(xlim = xlim,
                     ylim = ylim,
                     expand = TRUE)
  
  # Save plot 
  ggsave(paste("./", Analysis, "_vals_", Model, ".png", sep = ""), height = 5, width = 7, units = "in")
} else {
  CoRaValsFile <- read.table(paste("./", Analysis, "_vals_", Model, ".txt", sep = ""),
                             sep=" ", header=TRUE, row.names=NULL)
  
  plot <- ggplot(CoRaValsFile, aes({{IndVar}}, CoRa_Any, color = "[]")) +
    geom_point(size = 5) +
    geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_0.01, color = "0.01"), size = 4) +
    geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_0.1, color = "0.1"), size = 3) +
    geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_1.0, color = "1.0"), size = 2) +
    #geom_point(CoRaValsFile, mapping = aes({{IndVar}}, CoRa_10.0, color = "10.0"), size = 1) +
    scale_color_manual(values= c("black", "red", "blue", "green")) +
    labs(y = "CoRa", color = "Legend") +
    ggtitle("CoRaDyn values") +
    #geom_vline(xintercept = 0.4641589, color = "red") +
    theme(plot.title = element_text(size = 18),
          axis.title=element_text(size=15),
          legend.text = element_text(size = 13),
          legend.title = element_text(size = 15)) +
    coord_cartesian(xlim = xlim,
                    ylim = ylim,
                    expand = TRUE)
  
  # Save plot 
  ggsave(paste("./", Analysis, "_vals_", Model, "_no10.png", sep = ""), height = 5, width = 7, units = "in")
}

plot
