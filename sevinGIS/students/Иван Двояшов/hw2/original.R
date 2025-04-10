 #######HOMEWORK 2, map of australia######

library(sf)        
library(tmap)       

# Define the data source folder
root <- "../naturearth"

# Load shapefiles
marines <- st_read(file.path(root, "ne_10m_geography_marine_polys.shp"))
marines <- marines[st_is_valid(marines), ] # Keep only valid geometries
sea_for_labels <- marines[marines$name  %in% c("Tasman Sea", "Coral Sea", "Timor Sea"), ]


countries <- st_read(file.path(root, "ne_10m_admin_0_countries.shp"))
aus_bord <- countries[countries$NAME == "Australia", 1]

admin <- st_read(file.path(root, "ne_10m_admin_1_states_provinces.shp"))
aus_admin <- admin[admin$admin == "Australia", ]

lakes <- st_read(file.path(root, "ne_10m_lakes.shp"))
lakes <- lakes[st_is_valid(lakes), ]
st_agr(lakes) = "constant"
lakes <- st_crop(lakes, aus_bord)

rivers <- st_read(file.path(root, "ne_10m_rivers_lake_centerlines.shp"))
st_agr(rivers) = "constant"
rivers <- st_crop(rivers, aus_bord)

cities <- st_read(file.path(root, "ne_10m_populated_places.shp"))
cities <- cities[cities$SCALERANK <= 2, ]
cities <- st_filter(cities, aus_bord)  # Keep cities within Australia

# Define your bounding box (xmin, ymin, xmax, ymax)
crop_extent <- st_bbox(c(xmin = 100, ymin = -63, xmax = 190, ymax = 0), crs = st_crs(marines))
st_agr(marines) = "constant"
marine2 <- st_crop(marines, crop_extent)

#### Manually adjust label positions
aus_admin$xmod <- 0  # Default no shift
aus_admin$ymod <- 0  # Default no shift
# Shift the label for Australian Capital Territory (adjust these values as needed)
aus_admin$xmod[which(aus_admin$name == "Australian Capital Territory")] <- 5.5  # Move right
aus_admin$ymod[which(aus_admin$name == "Australian Capital Territory")] <- -1  # Move up
aus_admin$xmod[which(aus_admin$name == "Jervis Bay Territory")] <- 5
aus_admin$ymod[which(aus_admin$name == "Lord Howe Island")] <- -0.5 
aus_admin$ymod[which(aus_admin$name == "Macquarie Island")] <- -0.5 

# Calculate centroids for the line (if not already available)
centroids <- st_centroid(aus_admin$geometry)  # Get centroids of polygons
aus_admin$centroid_x <- st_coordinates(centroids)[,1]  # X coordinate of centroid
aus_admin$centroid_y <- st_coordinates(centroids)[,2]  # Y coordinate of centroid

# Calculate shifted label positions
aus_admin$label_x <- aus_admin$centroid_x + aus_admin$xmod
aus_admin$label_y <- aus_admin$centroid_y + aus_admin$ymod

### creating lines for labels
act <- aus_admin[aus_admin$name == "Australian Capital Territory", ]
jbt <- aus_admin[aus_admin$name == "Jervis Bay Territory", ]
# extract coordinates
act_coor <- matrix(c(act$centroid_x, act$centroid_y, act$label_x, act$label_y),  nrow = 2, byrow = TRUE)
jbt_coor <- matrix(c(jbt$centroid_x, jbt$centroid_y, jbt$label_x, jbt$label_y),  nrow = 2, byrow = TRUE)
coor_list <- list(act_coor, jbt_coor)
# creating sf lines
lines <- st_sf(
  name = c("ACT", "JBT"),
  geometry = st_sfc(lapply(coor_list, st_linestring)),
  crs = 4326
)

crop_map <- crop_extent - c(-15,-7,27,10)
#### CREATE MAP
my_map <- 
  tm_shape(marine2, bbox = crop_map)+
  tm_polygons(fill = "lightblue", col = "lightblue") +
  
  tm_shape(aus_admin) +
  tm_polygons(fill = "pink",col = "black") +
  tm_graticules(n.x = 20, n.y = 5, col = "gray50", labels.size = 0.7) +
  tm_text("name", size = 0.8, xmod = "xmod", ymod = "ymod") +
  
  tm_shape(sea_for_labels) +
  tm_text("name", col = "blue", size = 0.7) + 
  
  tm_shape(lines) +
  tm_lines(col = "black", lwd = 1) +
  
  tm_shape(rivers) +
  tm_lines(col = "blue") +
  
  tm_shape(lakes) +
  tm_polygons(col = "blue", fill = "blue") +
  
  tm_shape(cities) + 
  tm_dots(size = 0.5) +
  
  tm_scalebar(position = c("left", "bottom")) + 
  tm_title("Australia administrative map") +
  tm_crs(3112) 


# Export to PNG with 300 DPI
tmap_save(my_map, filename = "australia_map.png", dpi = 300)
