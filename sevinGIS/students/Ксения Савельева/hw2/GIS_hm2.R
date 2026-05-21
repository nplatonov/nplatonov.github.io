# ==============================================================================
# Карта Австралии со штатами и городами
# ==============================================================================

# --- Директория ------------------------------------------------------------
root <- "/Users/ksusasaveleva/R_projects/Modeling/Modeling/ne_10m_countries"

output_dir <- file.path(root, "output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  message("Done")
}
# --- Библиотеки -------------------------------------------------------------
library(sf)
library(tmap)
library(ggplot2)
library(ggrepel)
library(ggspatial)
library(dplyr)
library(ursa)

# Загрузка данных ---------------------------------------------------------------
countries <- st_read(file.path(root, paste0("ne_10m_admin_0_countries.shp")))
states <- st_read(file.path(root,paste0("ne_10m_admin_1_states_provinces.shp")))
cities <- st_read(file.path(root,paste0("ne_10m_populated_places.shp")))

aus_states <- states[states$admin == "Australia", ]
cities_aus <- cities[cities$ADM0NAME == "Australia" & cities$POP_MAX > 200000, ]
state_labels <- states[states$admin == "Australia", c("name_ru")]

aus_states_proj <- st_transform(aus_states, 3577)
aus_city_proj <- st_transform(cities_aus, 3577)

state_labels_proj <- st_transform(state_labels, 3577) %>%
  mutate(
    label_point = st_point_on_surface(geometry),
    name_label = gsub(" ", "\n", name_ru)
  ) %>%
  filter(!name_ru %in% c("Виктория", "Маккуори", "Тасмания", "остров Лорд-Хау"))
# --- Карта ---------------------------------------------------------------
map_plot <- ggplot() +
  geom_sf(data = aus_states_proj, aes(fill = name), 
          color = "darkslategrey", size = 1, alpha = 0.7) +
  geom_sf(data = aus_city_proj, color = "deeppink4", size = 3) +
  geom_text_repel(data = state_labels_proj, 
                  aes(label = name_label, geometry = geometry),
                  color = "bisque3", 
                  stat = "sf_coordinates",
                  size = 5,
                  bg.color = "white")+
  geom_text_repel(data = aus_city_proj,
    aes(label = NAME_RU, geometry = geometry),
    stat = "sf_coordinates",
    min.segment.length = 0,box.padding = 0.5,
    point.padding = 0.3,force = 2,
    size = 6,color = "darkblue",
    bg.color = "white", bg.r = 0.1) +
  labs(title = "Карта Австралии") +
  theme_bw()+
  theme(title = element_text(size = 20))+
  xlab(" ") + ylab(" ")+
  theme(legend.position = "none") +
  coord_sf(crs = 3577,
           xlim = c(-2000000, 2500000),
           ylim = c(-4500000, -1000000),
           expand = FALSE) +
  scale_x_continuous(breaks = seq(110, 160, by = 10)) +
  scale_y_continuous(breaks = seq(-45, -10, by = 10)) +
  annotation_scale(location = "bl", width_hint = 0.2)
print(map_plot)

ggsave(file.path(root, "output/australia_final2.png"), 
       plot = map_plot, width = 12, height = 10, 
        dpi = 300, bg = "white", units = "in")

