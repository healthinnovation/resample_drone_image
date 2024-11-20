library(tidyterra)  
library(terra)
library(ggplot2)
library(patchwork)

month <- "may"

list_rgb <- list.files(
  path = "data/",
  pattern = "rgb_may.*\\.tif",
  full.names = TRUE)

layers <- list(
  rgb_30cm = rast(list_rgb[[1]]),
  rgb_1m = rast(list_rgb[[3]]),
  rgb_5m = rast(list_rgb[[4]]),
  rgb_10m = rast(list_rgb[[2]])
  )

my_plot <- function(x, title = NULL){
  names <- gsub(".*_([0-9.]+m)\\.tif$", "\\1", sources(x))
  plt_rgb <- ggplot() + 
    geom_spatraster_rgb(data = x) + 
    theme_minimal(9) + 
    labs(title = sprintf("Spatial resolution: %s",names),
         subtitle = paste0('2023-',month))
  return(plt_rgb)
}

plots <- lapply(X = layers,FUN = my_plot)
combined_plot <- wrap_plots(plots)
ggsave(
  filename = paste0('outputs/rgb_plot_',month,'.png'),
  plot = last_plot(),
  dpi = 300)
