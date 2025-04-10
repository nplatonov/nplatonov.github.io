library(sf)
library(tmap)
library(ggplot2)
library(ggrepel)
library(ggspatial)

root <- "C:/GIS/2 homework/data"

states <- sf::st_read(file.path(root, "ne_10m_admin_1_states_provinces.shp"))
cities <- sf::st_read(file.path(root, "ne_10m_populated_places.shp"))
oceans <- sf::st_read(file.path(root, "ne_10m_ocean.shp"))
marine_labels <- sf::st_read(file.path(root, "ne_10m_geography_marine_polys.shp"))
rivers <- sf::st_read(file.path(root, "ne_10m_rivers_australia.shp"))

#Для проверки данных:
#head(oceans)
#head(marine_labels)
#head(australia_states)
#head(australia_cities)
#colnames(states)
#colnames(cities)
#colnames(marine_labels)
#sf::st_crs(oceans)
#sf::st_crs(marine_labels)
#sf::st_crs(australia_states)
#sf::st_crs(australia_cities)
#sf::st_crs(australia_cities)$proj4string
#sf::st_bbox(australia_cities)

australia_states <- states[states$admin == "Australia", ]
australia_cities <- cities[cities$ADM0NAME == "Australia", ]

centroids <- st_centroid(australia_cities)

selected_cities <- australia_cities[australia_cities$NAME %in% c("Darwin", "Alice Springs", "Adelaide", "Melbourne", "Townsville", "Brisbane", "Newcastle", "Sydney", "Canberra"), ]

australia_bbox <- st_bbox(c(xmin = 110, xmax = 155, ymin = -45, ymax = -10), crs = st_crs(australia_states))

ggplot() +
  geom_sf(data = oceans, fill = "lightblue", color = "lightblue") +
  geom_sf(data = australia_states, aes(fill = name), color = "black") +
  scale_fill_manual(
    values = colorRampPalette(c("lightyellow", "yellow", "orange", "lightgreen"))(nrow(australia_states)),
    labels = australia_states$name_ru) + 
  geom_sf(data = rivers, color = "lightblue3", size = 0.2) +
  geom_sf(data = selected_cities, color = "red", size = 2) +
    geom_text_repel(data = selected_cities, aes(x = st_coordinates(geometry)[,1], y = st_coordinates(geometry)[,2], label = NAME_RU),
                  color = "black", box.padding = 0.3, point.padding = 0.3) +
  geom_sf(data = st_make_grid(australia_bbox, n = c(5,10)), color = "gray45", alpha = 0.1) +
  ggtitle("Штаты Австралии") +
  annotation_scale(location = "bl", width_hint = 0.3, height = unit(0.1, "cm")) +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "white"),  
        panel.grid.major = element_line(color = "black", linetype = "dashed"),
        axis.title.x = element_blank(),  
        axis.title.y = element_blank(),
        legend.title = element_blank()) + 
        coord_sf(xlim = c(110, 155), ylim = c(-45, -10), expand = FALSE,label_axes = list(bottom = "E", left = "N"))
