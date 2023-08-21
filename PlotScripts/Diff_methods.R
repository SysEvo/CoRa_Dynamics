# NOTE: Chantspan path 
setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Delta/CoRaDynFiles/")

library(ggplot2)

Analysis1 <- "ExSSs_DynTrap"
Analysis2 <- "ExSSs_DynRect"
Model <- "MinModelGi_Ex01_Ge_Ge"
Specs <- "2.0-23.0_tmax600.0"
CalcDiff <- TRUE
IndVar <- "Ge"
Condition <- "Ge"
CoRaName <- paste("CoRa.", Condition, ".", sep = "")

# NOTE: Chantspan file name 
OutCoRaFileAny_1 <- read.table(paste("./OUT", Analysis1, Model, Specs, "saveatAny[].txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.01_1 <- read.table(paste("./OUT", Analysis1, Model, Specs, "saveat0.01.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.1_1 <- read.table(paste("./OUT", Analysis1, Model, Specs, "saveat0.1.txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile1.0_1 <- read.table(paste("./OUT", Analysis1, Model, Specs, "saveat1.0.txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile10.0_1 <- read.table(paste("./OUT", Analysis1, Model, Specs, "saveat10.0.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)

OutCoRaFileAny_2 <- read.table(paste("./OUT", Analysis2, Model, Specs, "saveatAny[].txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.01_2 <- read.table(paste("./OUT", Analysis2, Model, Specs, "saveat0.01.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile0.1_2 <- read.table(paste("./OUT", Analysis2, Model, Specs, "saveat0.1.txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile1.0_2 <- read.table(paste("./OUT", Analysis2, Model, Specs, "saveat1.0.txt", sep = "_"),
                             sep="\t", header=TRUE, row.names=NULL)
OutCoRaFile10.0_2 <- read.table(paste("./OUT", Analysis2, Model, Specs, "saveat10.0.txt", sep = "_"),
                              sep="\t", header=TRUE, row.names=NULL)


df <- data.frame(IndVar = OutCoRaFileAny[[IndVar]],
                 Diff_Any = OutCoRaFileAny_1[[CoRaName]] - OutCoRaFileAny_2[[CoRaName]],
                 Diff_0.01 = OutCoRaFile0.01_1[[CoRaName]] - OutCoRaFile0.01_2[[CoRaName]],
                 Diff_0.1 = OutCoRaFile0.1_1[[CoRaName]] - OutCoRaFile0.1_2[[CoRaName]],
                 Diff_1.0 = OutCoRaFile1.0_1[[CoRaName]] - OutCoRaFile1.0_2[[CoRaName]],
                 Diff_10.0 = OutCoRaFile10.0_1[[CoRaName]] - OutCoRaFile10.0_2[[CoRaName]])

colnames(df)[1] <- IndVar

write.table(df, paste("../",strsplit(Model, "_")[[1]][1],"/MethodsDiff/Diff_", Analysis1, "-", Analysis2, "_", Model, ".txt", sep = ""), row.names=FALSE)

