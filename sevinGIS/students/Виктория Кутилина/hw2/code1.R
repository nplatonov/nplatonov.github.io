library(sf)
library(ggplot2)
library(leaflet)
library(leaflet.providers)
library(mapview)
library(V8)
library(ursa)
library(ggrepel)
library(dplyr)
library(scales)

options(warn = -1)

root <- "D:/ИПЭЭ РАН/Аспирантура/QGIS/R"

australia_admin <- st_read(dsn = root, layer = "ne_10m_admin_0_countries", quiet = TRUE)

australia_states <- st_read(dsn = root, layer = "ne_10m_admin_1_states_provinces", quiet = TRUE)

oceans <- st_read(dsn = root, layer = "ne_10m_geography_marine_polys", quiet = TRUE)

rivers <- st_read(dsn = root, layer = "ne_10m_rivers_lake_centerlines", quiet = TRUE)

roads <- st_read(dsn = root, layer = "ne_10m_roads", quiet = TRUE)

cities <- st_read(dsn = root, layer = "ne_10m_populated_places", quiet = TRUE)

aus_proj <- 3577

state_colors <- c(
  "New South Wales" = "#FFCCCC",
  "Victoria" = "#FFE5CC",
  "Queensland" = "#FFFFCC",
  "South Australia" = "#CCFFCC",
  "Western Australia" = "#CCE5FF",
  "Tasmania" = "#CCCCFF",
  "Northern Territory" = "#E5CCFF"
)

state_labels <- australia_states %>%
  filter(admin == "Australia") %>%
  mutate(label = case_when(
    name == "New South Wales" ~ "Новый Южный Уэльс",
    name == "Victoria" ~ "Виктория",
    name == "Queensland" ~ "Квинсленд",
    name == "South Australia" ~ "Южная Австралия",
    name == "Western Australia" ~ "Западная Австралия",
    name == "Tasmania" ~ "Тасмания",
    name == "Northern Territory" ~ "Северная Территория"
  )) %>%
  st_make_valid() %>%
  mutate(geometry = st_transform(geometry, aus_proj) %>%
           st_point_on_surface() %>%
           st_transform(st_crs(australia_states))) %>%
  filter(!st_is_empty(geometry))

# ИСПРАВЛЕНО: добавлена фильтрация городов по списку
australia_cities <- cities %>%
  filter(ADM0NAME == "Australia" | SOV0NAME == "Australia") %>%
  filter(NAME %in% c("Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", 
                     "Gold Coast", "Canberra", "Newcastle", "Wollongong", 
                     "Hobart", "Darwin")) %>%
  mutate(name_ru = case_when(
    NAME == "Sydney" ~ "Сидней",
    NAME == "Melbourne" ~ "Мельбурн",
    NAME == "Brisbane" ~ "Брисбен",
    NAME == "Perth" ~ "Перт",
    NAME == "Adelaide" ~ "Аделаида",
    NAME == "Gold Coast" ~ "Голд-Кост",
    NAME == "Canberra" ~ "Канберра",
    NAME == "Newcastle" ~ "Ньюкасл",
    NAME == "Wollongong" ~ "Вуллонгонг",
    NAME == "Hobart" ~ "Хобарт",
    NAME == "Darwin" ~ "Дарвин"
  ))

sea_labels <- oceans %>%
  filter(name %in% c("Timor Sea", "Coral Sea", "Tasman Sea", "Arafura Sea")) %>%
  mutate(sea_name_ru = case_when(
    name == "Timor Sea" ~ "Тиморское море",
    name == "Coral Sea" ~ "Коралловое море",
    name == "Tasman Sea" ~ "Тасманово море",
    name == "Arafura Sea" ~ "Арафурское море"
  )) %>%
  st_make_valid() %>%
  mutate(geometry = st_transform(geometry, aus_proj) %>%
           st_point_on_surface() %>%
           st_transform(st_crs(oceans))) %>%
  filter(!st_is_empty(geometry))

river_labels <- rivers %>%
  filter(name %in% c("Murray River", "Darling River", "Murrumbidgee River")) %>%
  mutate(river_name_ru = case_when(
    name == "Murray River" ~ "Муррей",
    name == "Darling River" ~ "Дарлинг",
    name == "Murrumbidgee River" ~ "Маррамбиджи"
  )) %>%
  st_make_valid() %>%
  mutate(geometry = st_transform(geometry, aus_proj) %>%
           st_point_on_surface() %>%
           st_transform(st_crs(rivers))) %>%
  filter(!st_is_empty(geometry))

p <- ggplot() +
  geom_sf(data = oceans, fill = "lightblue", color = "darkblue", linewidth = 0.2, alpha = 0.7) +
  geom_sf(data = australia_states %>% 
            filter(admin == "Australia") %>%
            filter(name %in% names(state_colors)),
          aes(fill = name), 
          color = "black", linewidth = 0.8, linetype = "solid") +
  scale_fill_manual(values = state_colors, guide = "none") +
  geom_sf(data = rivers, color = "blue", linewidth = 0.3, alpha = 0.7) +
  geom_sf(data = roads, color = "brown", linewidth = 0.2, alpha = 0.5, linetype = "solid") +
  geom_sf(data = australia_cities, color = "darkred", alpha = 0.5) +
  
  geom_text_repel(
    data = sea_labels,
    aes(label = sea_name_ru, geometry = geometry), stat = "sf_coordinates",
    size = 4, fontface = "bold", color = "darkblue",
    box.padding = 1, point.padding = 0.2, force = 2,
    max.overlaps = 15, segment.color = "NA", min.segment.length = 0, 
    max.time = 2, max.iter = 20000,
    direction = "both"
  ) +
  
  geom_text_repel(
    data = river_labels,
    aes(label = river_name_ru, geometry = geometry), stat = "sf_coordinates",
    size = 3, fontface = "italic", color = "blue",
    box.padding = 1.0, point.padding = 0.6, force = 3,
    max.overlaps = 15, segment.color = "blue", segment.size = 0.2,
    min.segment.length = 0.3, max.time = 1.5, max.iter = 15000
  ) +
  
  geom_text_repel(
    data = australia_cities,
    aes(label = name_ru, geometry = geometry), stat = "sf_coordinates",
    size = 4, fontface = "bold.italic", box.padding = 0.4, point.padding = 0.6, force = 2,
    max.overlaps = 20, segment.color = "NA", min.segment.length = 0, 
    max.time = 2, max.iter = 20000,
    direction = "both"
  ) +
  
  geom_text_repel(
    data = state_labels,
    aes(label = label, geometry = geometry), stat = "sf_coordinates",
    size = 5, fontface = "bold.italic", color = "black",
    box.padding = 2.0, point.padding = 0.6, force = 4,
    max.overlaps = 10, segment.color = "NA", min.segment.length = 0.6, 
    max.time = 2.5, max.iter = 25000,
    direction = "both"
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "lightblue", color = NA),
    legend.position = "none"
  ) +
  
  labs(title = "Австралия") +
  
  coord_sf(xlim = c(110, 160), ylim = c(-50, -7), expand = FALSE)

print(p)

ggsave(filename = "D:/ИПЭЭ РАН/Аспирантура/QGIS/Australia_map.png", 
       plot = p, width = 14, height = 10, dpi = 300, bg = "white")