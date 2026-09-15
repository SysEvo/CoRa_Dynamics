# ============================================================
# Plot CoRaDyn(bC) vs tspan, overlaying the four model variants:
# PID, PID_P, PID_D, PID_PD
#
# Also plots the difference:
# PID_P - PID_D
#
# The model each file belongs to is inferred automatically from
# its file name (no need to hard-code file -> model mapping).
# ============================================================
# Uses only base R (no external packages needed)

# ---- 1. Locate the input files --------------------------------------------

data_dir <- "~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/Fig5/"
tag <- "Fig5E"

files <- list.files(
  data_dir,
  pattern = paste0("^", tag, "_OUT_ExCoRaDyn_tspan_.*\\.txt$"),
  full.names = TRUE
)

cat("Files found:\n")
print(basename(files))

if (length(files) == 0) {
  stop("No matching files found in: ", data_dir)
}


# ---- 2. Determine model from filename -------------------------------------

get_model <- function(filename) {
  
  bn <- basename(filename)
  
  if (grepl("_tspan_PID_PD_", bn, fixed = TRUE)) {
    return("PID_PD")
  }
  
  if (grepl("_tspan_PID_P_", bn, fixed = TRUE)) {
    return("PID_P")
  }
  
  if (grepl("_tspan_PID_D_", bn, fixed = TRUE)) {
    return("PID_D")
  }
  
  if (grepl("_tspan_PID_", bn, fixed = TRUE)) {
    return("PID")
  }
  
  warning("Could not detect model from: ", bn)
  return(NA_character_)
}


# Test model detection
cat("\nDetected models:\n")

for (f in files) {
  cat(
    basename(f),
    "  -->  ",
    get_model(f),
    "\n"
  )
}

# ---- 3. Read every file and tag it with its model --------------------------

data_list <- lapply(files, function(f) {

  d <- read.table(
    f,
    header = TRUE,
    sep = "\t",
    stringsAsFactors = FALSE
  )

  names(d)[names(d) == "CoRaDyn.bC."] <- "CoRaDyn_bC"

  d$model <- get_model(f)

  d
})


# Desired plotting order / legend order
model_order <- c("PID", "PID_P", "PID_D", "PID_PD")

names(data_list) <- sapply(
  data_list,
  function(d) d$model[1]
)

data_list <- data_list[
  model_order[model_order %in% names(data_list)]
]


# ---- 4. Calculate PID_P - PID_D --------------------------------------------

if (all(c("PID_P", "PID_D") %in% names(data_list))) {

  p_data <- data_list[["PID_P"]]
  d_data <- data_list[["PID_D"]]

  # Match rows using tspan.
  # This is safer than assuming the rows are in exactly the same order.
  diff_data <- merge(
    p_data[, c("tspan", "CoRaDyn_bC")],
    d_data[, c("tspan", "CoRaDyn_bC")],
    by = "tspan",
    suffixes = c("_P", "_D")
  )

  # Calculate PID_P - PID_D
  diff_data$CoRaDyn_bC <-
    (diff_data$CoRaDyn_bC_P) -
    (diff_data$CoRaDyn_bC_D - diff_data$CoRaDyn_bC_P)

  diff_data$model <- "PID_P - PID_D"

} else {

  warning(
    "Could not calculate PID_P - PID_D because ",
    "PID_P and/or PID_D are missing."
  )

  diff_data <- NULL
}


# ---- 5. Plot styling per model ---------------------------------------------

model_colors <- c(
  PID            = "black",
  PID_P          = "steelblue",
  PID_D          = "darkorange",
  PID_PD         = "firebrick",
  "PID_P - PID_D" = "purple"
)

model_pch <- c(
  PID            = 15,
  PID_P          = 16,
  PID_D          = 17,
  PID_PD         = 18,
  "PID_P - PID_D" = 19
)


# ---- 6. Build the plot ------------------------------------------------------

png(
  paste(
    data_dir,
    tag,
    "_CoRaDyn_vs_tspan_models_5.png",
    sep = ""
  ),
  width = 900,
  height = 650,
  res = 120
)


# Common x-axis range
all_tspan <- unlist(
  lapply(data_list, function(d) d$tspan)
)


# Common y-axis range for original models
all_y <- unlist(
  lapply(data_list, function(d) d$CoRaDyn_bC)
)

# Include PID_P - PID_D when determining y-axis limits
if (!is.null(diff_data)) {
  all_y <- c(all_y, diff_data$CoRaDyn_bC)
}


par(mar = c(5, 5, 3, 1))

plot(
  NA, NA,
  xlim = range(all_tspan),
  ylim = range(all_y, na.rm = TRUE),
  log  = "x",
  xlab = "tspan",
  ylab = "CoRaDyn(bC)",
  main = "CoRaDyn(bC) dynamics across models"
)


# ---- Plot original four models ---------------------------------------------

for (mod in names(data_list)) {

  d <- data_list[[mod]]

  d <- d[order(d$tspan), ]

  lines(
    d$tspan,
    d$CoRaDyn_bC,
    type = "b",
    pch = model_pch[mod],
    col = model_colors[mod],
    lwd = 2
  )
}


# ---- Plot PID_P - PID_D ----------------------------------------------------

if (!is.null(diff_data)) {

  diff_data <- diff_data[
    order(diff_data$tspan),
  ]

  lines(
    diff_data$tspan,
    diff_data$CoRaDyn_bC,
    type = "b",
    pch = model_pch["PID_P - PID_D"],
    col = model_colors["PID_P - PID_D"],
    lwd = 2
  )

  # Optional horizontal zero reference line
  abline(
    h = 0,
    lty = 2,
    col = "grey50"
  )
}


# ---- Legend ----------------------------------------------------------------

legend_names <- names(data_list)

if (!is.null(diff_data)) {
  legend_names <- c(
    legend_names,
    "PID_P - PID_D"
  )
}

legend(
  "bottomleft",
  legend = legend_names,
  col = model_colors[legend_names],
  pch = model_pch[legend_names],
  lwd = 2,
  bty = "n"
)


dev.off()

cat(
  "Plot saved as ",
  paste(tag, "_CoRaDyn_vs_tspan_models_5.png", sep = ""),
  "\n"
)
