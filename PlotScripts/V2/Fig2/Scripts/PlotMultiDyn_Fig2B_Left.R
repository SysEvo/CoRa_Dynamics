library(ggplot2)
library(dplyr)

# NOTE: Change path
setwd("~/Desktop/CoRaDyn/CoRaDyn_Paper/OutputFiles/")

# NOTE: Change file name
OutMultiDynFile <- read.table(
  "./Fig2/OUT_Files/OUT_ExMultiDyn_PID_0.01-0.11_Ex01_bC_[:bC].txt",
  sep = "\t", header = TRUE, row.names = NULL
)

# NOTE: Change controlled variable
Var  <- "XC"
xlim <- c(-80, 1080)

# --- Data cleansing ---
colnames(OutMultiDynFile) <- c(colnames(OutMultiDynFile), "NaN")[-1]

OutMultiDynFile <- OutMultiDynFile %>%
  filter(is.finite(time), time < max(xlim) + 1000) %>%
  mutate(bC = factor(bC, levels = unique(bC)),
         time = time - 500)

DynFB <- OutMultiDynFile %>% filter(FB == 1) %>% 
  mutate(bC = factor(bC, levels = rev(c("0.01", "0.06", "0.11"))))

## Only one NF trajectory is drawn, since NF runs are theoretically
## identical across bC and plotting all of them causes dashed-line
## offset artifacts (near-solid appearance from overlapping dashes)
DynNF <- OutMultiDynFile %>% filter(FB == 0, bC == first(bC))

# --- Plot ---
plot <- ggplot() +
  coord_cartesian(xlim = xlim, expand = FALSE) +
  geom_line(data = DynFB,
            aes(time, log10(.data[[Var]]), color = bC, linetype = "FB"),
            linewidth = 1.8) +
  geom_line(data = DynNF,
            aes(time, log10(.data[[Var]]), linetype = "NF"),
            linewidth = 1.8, color = "black") +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FF8247", linewidth = 0.4) +
  geom_vline(xintercept = 500, linetype = "solid", color = "#FF8247", linewidth = 1.8, alpha = 0.5) +
  labs(x = "Time (min)", y = "log10(XC [nM])", color = "bC") +
  scale_color_manual(
    values = c("#009ACD", "darkorchid2", "darkolivegreen3"),
    limits = levels(OutMultiDynFile$bC),
    labels = round(as.numeric(levels(OutMultiDynFile$bC)), 3)) +
  scale_linetype_manual(
    name = "System",
    values = c(FB = "solid", NF = "dashed"),
    breaks = c("FB", "NF")) +
  guides(
    color = guide_legend(ncol = 1, order = 1),
    linetype = guide_legend(ncol = 1, order = 2,
                            override.aes = list(color = c("grey30", "black")))) +
  theme(
    line = element_blank(),
    panel.background = element_rect(fill = 'white', color = 'black', linewidth = 2),
    axis.ticks.y.right = element_blank(),
    axis.ticks = element_line(color = 'black', linewidth = 1),
    axis.ticks.length = unit(.15, "cm"),
    axis.text = element_text(size = 20),
    axis.title = element_text(size = 25),
    axis.text.y.right = element_blank(),
    axis.text.y = element_text(margin = margin(t = 0, r = 5, b = 0, l = 0)),
    axis.text.x = element_text(margin = margin(t = 5, r = 0, b = 0, l = 0)),
    legend.text = element_text(size = 17),
    legend.title = element_text(size = 17),
    legend.key = element_rect(color = NA),
    plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")
  )

plot

# Save plot image 
ggsave("./Fig2/Fig2B_Left.svg", height = 5, width = 7, units = "in")


 