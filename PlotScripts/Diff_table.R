# NOTE: Chantspan path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Delta/CoRaDynFiles/")

library(ggplot2)

Analysis <- "ExSSs_Dyn"
Model <- "MinModelGp_Ex01_Ge_Ge"
Specs <- "2.0-23.0_tmax600.0"
CalcDiff <- TRUE
IndVar <- "Ge"
Condition <- "Ge"
CoRaName <- paste("CoRa.", Condition, ".", sep = "")

# NOTE: Chantspan file name 
OutCoRaFileAny <- read.table(paste("./OUT", Analysis, Model, Specs, "saveatAny[].txt", sep = "_"),
                          sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.01 <- read.table(paste("./OUT", Analysis, Model, Specs, "saveat0.01.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.1 <- read.table(paste("./OUT", Analysis, Model, Specs, "saveat0.1.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile1.0 <- read.table(paste("./OUT", Analysis, Model, Specs, "saveat1.0.txt", sep = "_"),
                            sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile10.0 <- read.table(paste("./OUT", Analysis, Model, Specs, "saveat10.0.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)

if (CalcDiff == TRUE) { 
  df <- data.frame(IndVar = OutCoRaFileAny[[IndVar]],
                     Diff_Any_0.01 = OutCoRaFileAny[[CoRaName]] - OutCoRaFile0.01[[CoRaName]],
                     Diff_Any_0.1 = OutCoRaFileAny[[CoRaName]] - OutCoRaFile0.1[[CoRaName]],
                     Diff_Any_1.0 = OutCoRaFileAny[[CoRaName]] - OutCoRaFile1.0[[CoRaName]],
                     Diff_Any_10.0 = OutCoRaFileAny[[CoRaName]] - OutCoRaFile10.0[[CoRaName]],
                     Diff_0.01_0.1 = OutCoRaFile0.01[[CoRaName]] - OutCoRaFile0.1[[CoRaName]],
                     Diff_0.01_1.0 = OutCoRaFile0.01[[CoRaName]] - OutCoRaFile1.0[[CoRaName]],
                     Diff_0.01_10.0 = OutCoRaFile0.01[[CoRaName]] - OutCoRaFile10.0[[CoRaName]],
                     Diff_0.1_1.0 = OutCoRaFile0.1[[CoRaName]] - OutCoRaFile1.0[[CoRaName]],
                     Diff_0.1_10.0 = OutCoRaFile0.1[[CoRaName]] - OutCoRaFile10.0[[CoRaName]],
                     Diff_1.0_10.0 = OutCoRaFile0.1[[CoRaName]] - OutCoRaFile10.0[[CoRaName]])
  colnames(df)[1] <- IndVar
  
  write.table(df, paste("../",strsplit(Model, "_")[[1]][1],"/Diff_", Analysis, "_vals_", Model, ".txt", sep = ""), row.names=FALSE)
} else {
  df <- data.frame(IndVar = OutCoRaFileAny[[IndVar]],
                          CoRa_Any = OutCoRaFileAny[[CoRaName]],
                          CoRa_0.01 = OutCoRaFile0.01[[CoRaName]],
                          CoRa_0.1 = OutCoRaFile0.1[[CoRaName]],
                          CoRa_1.0 = OutCoRaFile1.0[[CoRaName]],
                          CoRa_10.0 = OutCoRaFile10.0[[CoRaName]])
  colnames(df)[1] <- IndVar
  
  write.table(df, paste("../",strsplit(Model, "_")[[1]][1],"/", Analysis, "_vals_", Model, ".txt", sep = ""), row.names=FALSE)
}


