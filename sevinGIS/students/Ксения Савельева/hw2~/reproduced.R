# ==============================================================================
# Карта Австралии со штатами и городами
# ==============================================================================

# --- Директория ------------------------------------------------------------
# root <- "/Users/ksusasaveleva/R_projects/Modeling/Modeling/ne_10m_countries"
root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"
output_dir <- "." # file.path(root, "output")
options(warn=1)

if (F & !dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  message("Done")
}
# --- Библиотеки -------------------------------------------------------------
# library(sf)
library(tmap)
library(ggplot2)
library(ggrepel)
# library(rnaturalearth)
# plutil::pluglibrary(rnaturalearthdata)
library(dplyr)

# Загрузка данных ---------------------------------------------------------------
countries <- ursa::spatial_read(file.path(root, paste0("10m_cultural/ne_10m_admin_0_countries.shp")))
states <- ursa::spatial_read(file.path(root,paste0("10m_cultural/ne_10m_admin_1_states_provinces.shp")))
cities <- ursa::spatial_read(file.path(root,paste0("10m_cultural/ne_10m_populated_places.shp")))
aus_states <- states[states$admin == "Australia", ]
cities_aus <- cities[cities$ADM0NAME == "Australia" & 
                       cities$POP_MAX > 200000, ]

cities_aus$NAME <- case_when(
  cities_aus$NAME == "Perth" ~ "Перт",
  cities_aus$NAME == "Melbourne" ~ "Мельбурн",
  cities_aus$NAME == "Brisbane" ~ "Брисбен",
  cities_aus$NAME == "Adelaide" ~ "Аделаида",
  cities_aus$NAME == "Canberra" ~ "Канберра",
  cities_aus$NAME == "Hobart" ~ "Хобарт",
  cities_aus$NAME == "Sydney" ~ "Сидней",
  cities_aus$NAME == "Newcastle" ~ "Ньюкастл",
  cities_aus$NAME == "Cranbourne" ~ "Кранборн",
  cities_aus$NAME == "Townsville" ~ "Таунсвилл",
  cities_aus$NAME == "Geelong" ~ "Джелонг",
  cities_aus$NAME == "Gold Coast" ~ "Голд-Кост",
  cities_aus$NAME == "Cairns" ~ "Кэрнс",
  cities_aus$NAME == "Wollongong" ~ "Вуллонгонг",
  TRUE ~ cities_aus$NAME
)

# --- Карта ---------------------------------------------------------------
map_plot <- ggplot() +
  geom_sf(data = aus_states, 
          aes(fill = name),
          color = "black", size = 0.2, alpha = 0.7) +
  geom_sf(data = cities_aus, color = "darkblue", size = 2, alpha = 0.8) +
  geom_text_repel(
    data = cities_aus,
    aes(label = NAME, geometry = geometry),
    stat = "sf_coordinates",
    min.segment.length = 0,
    box.padding = 0.5,
    point.padding = 0.3,
    force = 2,
    size = 4,
    color = "darkblue",
    bg.color = "white",
    bg.r = 0.1
  ) +
  labs(title = "Карта Австралии") +
  theme_minimal()+
  xlab("Долгота") + ylab("Широта")+
  theme(
    legend.position = "none"  # полностью убирает легенду
  )
#+ map1
print(map_plot)

#+
ggsave("./australia1_reproduced.png", plot = map_plot, width = 12, height = 10, 
       dpi = 100, bg = "white", units = "in")
