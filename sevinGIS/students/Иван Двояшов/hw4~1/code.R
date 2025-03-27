library(sf)        
library(tmap)       
root <- "../naturearth"
marines <- st_read(file.path(root, "ne_10m_geography_marine_polys.shp"))
marines$geometry
sum(!st_is_valid(marines))  # Count invalid geometries
marines <- marines[st_is_valid(marines), ] # Keep only valid geometries
admin <- st_read(file.path(root, "ne_10m_admin_1_states_provinces.shp"))
lakes <- st_read(file.path(root, "ne_10m_lakes.shp"))
lakes <- lakes[st_is_valid(lakes), ]
rivers <- st_read(file.path(root, "ne_10m_rivers_lake_centerlines.shp"))
countries <- st_read(file.path(root, "ne_10m_admin_0_countries.shp"))
cities <- st_read(file.path(root, "ne_10m_populated_places.shp"))
cities <- cities[cities$SCALERANK <= 3, ]
cities <- st_filter(cities, aus_bord)

aus_bord <- countries[countries$NAME == "Australia", 1]

aus_admin <- admin[admin$admin == "Australia", ]

my_map <- tm_shape(aus_bord) +
  tm_polygons(alpha = 0, border.col = "black") +
  tm_shape(marines) +
  tm_polygons(col = "lightblue", border.col = "lightblue") +
  # tm_text("name", size = 0.6, col = "darkblue", remove.overlap = TRUE) +
  tm_shape(aus_admin) +
  tm_polygons(border.col = "black") +
  tm_text("name", size = 0.8, col = "black", shadow = TRUE, remove.overlap = TRUE) + 
  tm_shape(rivers) +
  tm_lines(col = "blue", border.col = "blue") +
  tm_shape(lakes) +
  tm_polygons(col = "blue", border.col = "blue") +
  tm_shape(cities) + 
  tm_dots(size = 0.3) +
  tm_text("NAME", size = 0.8, just = c("left"), col = "black", xmod = 0.5) +
  tm_layout(title = "Australia Map")

tmap_save(my_map, filename = "australia_map.png", dpi = 300)
