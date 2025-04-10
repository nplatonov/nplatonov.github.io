library(sf)
library(ggplot2)
library(dplyr)
library(ggspatial)

root <- "C:/Users/Andrey Lupyryov/Documents/lis/naturalearth"

countries <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_0_countries_arg.shp"))
label <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_1_label_points_details.shp"))
states <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_1_states_provinces_lines.shp"))
provinces <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_1_states_provinces.shp"))
marine <- st_read(file.path(root, "10m_physical", "ne_10m_geography_marine_polys.shp"))
rivers <- st_read(file.path(root, "10m_physical", "ne_10m_rivers_australia.shp"))
cities <- st_read(file.path(root, "10m_cultural", "ne_10m_populated_places.shp"))
lakes <- st_read(file.path(root, "10m_physical", "ne_10m_lakes_australia.shp"))

label <- label %>% filter(admin == "Australia")
states <- states %>% filter(ADM0_NAME == "Australia")
cities <- cities %>% filter(SOV0NAME == "Australia" & (FEATURECLA == "Admin-1 capital" |  FEATURECLA == "Admin-0 capital"))
provinces <- provinces %>% filter(admin == "Australia")

xlim <- c(112, 156)
ylim <- c(-45, -10.5)
step_x <- 10  
step_y <- 5  
longitudes <- seq(from = floor(xlim[1] / step_x) * step_x, to = ceiling(xlim[2] / step_x) * step_x, by = step_x)
latitudes <- seq(from = floor(ylim[1] / step_y) * step_y, to = ceiling(ylim[2] / step_y) * step_y, by = step_y)

ggplot() +
  geom_sf(data = countries, fill = "white", color = "black", linewidth = 0.2) +
  geom_sf(data = states, aes(fill = NOTE), color = "gray", linewidth = 0.5) +
  geom_sf(data = provinces, aes(fill = name_ru), color = "gray", linewidth = 0.5) + 
  theme(legend.position = "none")+
  geom_sf(data = marine, fill = "lightblue", color = NA) +
  geom_sf_text(data = marine,
               aes(label = ifelse(featurecla == "ocean" | featurecla == "sea", name_ru, "")),
               color = "blue", size = 4, fontface = "bold", nudge_x = 1.0) +
  geom_sf(data = rivers, color = "lightblue", linewidth = 0.2) +
  geom_sf(data = lakes, fill = "lightblue", linewidth = 0.2) +
  geom_vline(xintercept = longitudes, color = "white", linewidth = 0.2, linetype = "dotted") +
  geom_hline(yintercept = latitudes, color = "white", linewidth = 0.2, linetype = "dotted") +
  geom_sf_text(data = label, aes(label = name_ru),
               color = "white", size = 4, fontface = "italic", nudge_y = -0.5) +
  geom_sf(data = cities, color = "black", size = 1) +
  geom_sf_text(data = cities_filtered, aes(label = NAME_RU),
               color = "black", size = 4, fontface = "bold", nudge_y = 0.5) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE)+
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "tl", which_north = "true",
                         pad_x = unit(0.2, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering)
