library(animation)

setwd("/home/atamayo/Desktop/Mariana/CoRa/Curves/Oscillations/ExDynOsc/ATF/Png/CoRa1000-25650/")
  
paths <- paste("CoRaDynOverPt_tspan", format(seq(1000,25650, by = 1450.0), nsmall = 1, trim = TRUE), ".png", sep = "")
  
#paste(1:67,".png", sep = "")

# Create a blank animation canvas
saveGIF({
  for (path in paths) {
    # Read each image and add it to the canvas
    img <- imager::load.image(path)
    plot(as.raster(img))
  }
}, movie.name = "./CoRaDynOverPt_tspan1000-25650.gif", interval = 0.4, ani.width = 1000, ani.height = 800)
