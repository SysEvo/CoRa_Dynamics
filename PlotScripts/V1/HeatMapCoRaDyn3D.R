# NOTE: Change path 
setwd("/home/atamayo/Desktop/Mariana/Final/OutFinal/Fig3A/")

library(plotly)
library(viridis)
library(htmlwidgets)
library(webshot2)

# NOTE: Change file name
FileName <- "./OUT_ExMultiSSs_Dyn_PID_bP_bD_bI_bC_tspan-500-500.txt"
OutFile <- read.table(FileName, sep="\t", header=TRUE, row.names=NULL)

OutFile <- na.omit(OutFile)  # Remove rows with NA values
turbo_colors <- turbo(100)
colorscale <- lapply(0:99, function(i) list(i/99, turbo_colors[i + 1]))

fig <- plot_ly(OutFile, x = ~bD, y = ~bI, z = ~bP,
               marker = list(
                 color = ~CoRaDyn.bC.,
                 colorscale = colorscale,
                 showscale = TRUE,
                 cmin = 0,
                 cmax = 1,
                 colorbar = list(
                   tickfont = list(size = 18),  # (optional) tick text size
                   thickness = 17,              # width of the color bar in px (default is ~30)
                   len = 1,                    # height of the color bar relative to plot (0–1)
                   x = 0.85,  # move left/right: lower = closer to center
                   y = 0.5, 
                   color = "black"
                 )
               ))

fig <- fig %>% add_markers()

fig <- fig %>% layout(scene = list(
                        yaxis = list(
                          tickvals = c(0, 0.02, 0.04, 0.06, 0.08, 0.1),
                          tickfont = list(size = 13),
                          title = list(text = "bI", font = list(size = 20, color = "black"))
                        ),
                        xaxis = list(
                          tickvals = c(0,0.2, 0.4, 0.6, 0.8),
                          tickfont = list(size = 13),
                          title = list(text = "bD", font = list(size = 18, color = "black"))
                        ),
                        zaxis = list(
                          tickvals = c(0.1, 0.2, 0.3, 0.4, 0.5),
                          tickfont = list(size = 13),
                          title = list(text = "bP", font = list(size = 18, color = "black"))
                        ),
                        camera = list(
                          eye = list(x = 2, y = 1.25, z = 0.75)  # Change these values to tilt/rotate the view
                        )))

fig

saveWidget(fig, "temp_plot.html")
webshot("temp_plot.html", file = "../../Plots/Fig3A_2.2.png", zoom = 2, vwidth = 1600/2, vheight = 900/2)  # zoom = 2 for higher res

