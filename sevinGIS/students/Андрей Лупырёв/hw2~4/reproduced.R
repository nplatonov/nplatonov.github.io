library(sf)
library(ggplot2)
library(dplyr)
library(ggspatial)
library(ursa)

root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"

countries <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_0_countries_arg.shp.zip"))
states <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_1_states_provinces_lines.shp.zip"))
provinces <- st_read(file.path(root, "10m_cultural", "ne_10m_admin_1_states_provinces.shp.zip"))
marine <- st_read(file.path(root, "10m_physical", "ne_10m_geography_marine_polys.shp.zip"))
rivers <- st_read(file.path(root, "10m_physical", "ne_10m_rivers_australia.shp.zip"))
cities <- st_read(file.path(root, "10m_cultural", "ne_10m_populated_places.shp.zip"))
lakes <- st_read(file.path(root, "10m_physical", "ne_10m_lakes_australia.shp.zip"))
graticules <- st_read(file.path(root, "10m_physical", "ne_10m_graticules_5.shp.zip"))

states <- states %>% filter(ADM0_NAME == "Australia" & !is.na(NAME) & NAME != "")
cities <- cities %>% filter(SOV0NAME == "Australia" & (FEATURECLA == "Admin-1 capital" |  FEATURECLA == "Admin-0 capital"))
provinces <- provinces %>% filter(admin == "Australia")
australia <- countries %>% filter(ADMIN == "Australia")

objects_to_reproject <- c("australia", "states", "provinces", "marine", "rivers", "cities", "lakes", "graticules")
if (!ursa:::.isKnitr()) {
   list2env(
     lapply(mget(objects_to_reproject), st_transform, crs = "EPSG:3112"),
     envir = .GlobalEnv
   )
} else {
   for (o in objects_to_reproject)
      assign(o, st_transform(get(o), crs = "EPSG:3112"))
}
xlim_4326 <- c(112, 156)
ylim_4326 <- c(-45, -7)
bbox_sf <- st_sfc(
  st_point(c(xlim_4326[1], ylim_4326[1])),  
  st_point(c(xlim_4326[2], ylim_4326[2])),  
  crs = "EPSG:4326" 
)
bbox_sf <- st_bbox(bbox_sf)
bbox_3112 <- st_transform(st_as_sfc(bbox_sf), crs = "EPSG:3112")
bbox_3112 <- st_bbox(bbox_3112)
xlim <- c(bbox_3112["xmin"], bbox_3112["xmax"])
ylim <- c(bbox_3112["ymin"], bbox_3112["ymax"])

step_x <- 5  
step_y <- 5  
longitudes <- seq(from = floor(xlim[1] / step_x) * step_x, to = ceiling(xlim[2] / step_x) * step_x, by = step_x)
latitudes <- seq(from = floor(ylim[1] / step_y) * step_y, to = ceiling(ylim[2] / step_y) * step_y, by = step_y)

ggplot() +
  geom_sf(data = marine, fill = "lightblue", color = NA) +
  geom_sf(data = australia, fill = "white", color = "black", linewidth = 0.2) +
  geom_sf(data = states, aes(fill = NOTE), color = "gray", linewidth = 0.5) +
  geom_sf(data = provinces, aes(fill = name_ru), color = "gray", linewidth = 0.5) + 
  theme(legend.position = "none")+
  geom_sf(data = rivers, color = "lightblue", linewidth = 0.2) +
  geom_sf(data = lakes, fill = "lightblue", linewidth = 0.2) +
  geom_sf(data = graticules, color = "white", linewidth = 0.1, linetype = "dotted") +
  geom_sf_text(data = marine,
               aes(label = ifelse(featurecla == "ocean" | featurecla == "sea", name_ru, "")),
               color = "blue", size = 4, fontface = "bold", nudge_x = 1.0) +
  geom_sf_text(data = provinces[order(spatial_area(provinces), decreasing=T)[1:7],], aes(label = name_ru),
               color = "white", size = 4, fontface = "italic", nudge_y = -0.5) +
  geom_sf(data = cities, color = "black", size = 1) +
  geom_sf_text(data = cities, aes(label = NAME_RU),
               color = "black", size = 4, fontface = "bold", nudge_y = 0.5) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE)+
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "tl", which_north = "true",
                         pad_x = unit(0.2, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering)+
  theme(axis.line = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank())

