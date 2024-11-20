library(terra)      
library(sf)         

# Read the spatial boundary (polygon) from a GeoPackage file
hexagon <- st_read(dsn = "data/flying_mission.gpkg") |>
  subset(village %in% 'QUISTOCOCHA') |>  
  st_transform(crs = 32718)             

# Load the original raster dataset
village <- rast("data/Quistococha_D.tif") |> 
  crop(y = hexagon, mask = TRUE)        

# Extract RGB bands from the raster
blue <- village[[1]] 
green <- village[[2]] 
red <- village[[3]]  

# Rename bands for better identification
names(blue) <- "blue"
names(green) <- "green"
names(red) <- "red"

# Function to resample a raster to a specified pixel size
resample_image <- function(input, size_pixel) {
  base <- rast(ext(input), resolution = size_pixel, crs = crs(input))
  output <- resample(input, base, method = "near") 
  return(output)
}

# Group RGB bands into a list for processing
bands <- list(blue = blue, green = green, red = red)

# Specify the desired pixel resolutions (in meters)
size <- c(0.3, 1, 5, 10)

# Apply resampling for each resolution and each band
resampled_bands <- lapply(size, function(pixel_size) {
  lapply(bands, function(band) resample_image(input = band, size_pixel = pixel_size))
})

# Save the resampled RGB layers to files
for (i in seq_along(size)) {
  resolution <- size[i]
  rgb_layer <- c(
    resampled_bands[[i]]$red, 
    resampled_bands[[i]]$green, 
    resampled_bands[[i]]$blue)
  output_path <- paste0("data/rgb_", resolution, "m.tif")
  writeRaster(rgb_layer, filename = output_path, overwrite = TRUE)
  cat("Saved RGB:", output_path, "\n")
}
