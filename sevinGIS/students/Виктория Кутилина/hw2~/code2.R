library(sf)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(scales)
library(ggspatial)
library(gridExtra)
library(grid)

options(warn = -1)

root <- "D:/ИПЭЭ РАН/Аспирантура/QGIS/R"

australia_admin <- st_read(dsn = root, layer = "ne_10m_admin_0_countries", quiet = TRUE)
coastline <- st_read(dsn = root, layer = "ne_10m_coastline", quiet = TRUE)
australia_states <- st_read(dsn = root, layer = "ne_10m_admin_1_states_provinces", quiet = TRUE)
oceans <- st_read(dsn = root, layer = "ne_10m_geography_marine_polys", quiet = TRUE)
rivers <- st_read(dsn = root, layer = "ne_10m_rivers_australia", quiet = TRUE)
lakes <- st_read(dsn = root, layer = "ne_10m_lakes_australia", quiet = TRUE)
roads <- st_read(dsn = root, layer = "ne_10m_roads", quiet = TRUE)
cities <- st_read(dsn = root, layer = "ne_10m_populated_places", quiet = TRUE)
reefs <- st_read(dsn = root, layer = "ne_10m_reefs", quiet = TRUE)
graticules <- st_read(dsn = root, layer = "ne_10m_graticules_5", quiet = TRUE)
bathy_0 <- st_read(dsn = root, layer = "ne_10m_bathymetry_L_0", quiet = TRUE)
bathy_200 <- st_read(dsn = root, layer = "ne_10m_bathymetry_K_200", quiet = TRUE)
bathy_1000 <- st_read(dsn = root, layer = "ne_10m_bathymetry_J_1000", quiet = TRUE)
bathy_2000 <- st_read(dsn = root, layer = "ne_10m_bathymetry_I_2000", quiet = TRUE)
bathy_3000 <- st_read(dsn = root, layer = "ne_10m_bathymetry_H_3000", quiet = TRUE)
bathy_4000 <- st_read(dsn = root, layer = "ne_10m_bathymetry_G_4000", quiet = TRUE)
bathy_5000 <- st_read(dsn = root, layer = "ne_10m_bathymetry_F_5000", quiet = TRUE)

aus_proj <- 3577

state_colors <- c(
  "New South Wales" = "#FFCCCC",
  "Victoria" = "#FFE5CC",
  "Queensland" = "#FFFFCC",
  "South Australia" = "#CCFFCC",
  "Western Australia" = "#CCE5FF",
  "Tasmania" = "#CCCCFF",
  "Northern Territory" = "#E5CCFF",
  "Australian Capital Territory" = "#FFCCFF"
)

state_labels <- australia_states %>%
  filter(admin == "Australia") %>%
  mutate(label = case_when(
    name == "New South Wales" ~ "Новый\nЮжный\nУэльс",
    name == "Victoria" ~ "Виктория",
    name == "Queensland" ~ "Квинсленд",
    name == "South Australia" ~ "Южная\nАвстралия",
    name == "Western Australia" ~ "Западная\nАвстралия",
    name == "Tasmania" ~ "Тасмания",
    name == "Northern Territory" ~ "Северная\nТерритория",
    name == "Australian Capital Territory" ~ "Австралийская\nстоличная\nтерритория"
  )) %>%
  st_make_valid() %>%
  mutate(geometry = st_transform(geometry, aus_proj) %>%
           st_point_on_surface() %>%
           st_transform(st_crs(australia_states))) %>%
  filter(!st_is_empty(geometry))

tasmania_label <- state_labels %>%
  filter(label == "Тасмания")

other_states_labels <- state_labels %>%
  filter(label != "Тасмания")

australia_cities <- cities %>%
  filter(ADM0NAME == "Australia" | SOV0NAME == "Australia") %>%
  filter(NAME %in% c("Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", 
                     "Canberra", "Newcastle", "Alice Springs", "Hobart", 
                     "Darwin", "Townsville")) %>%
  mutate(name_ru = case_when(
    NAME == "Sydney" ~ "Сидней",
    NAME == "Melbourne" ~ "Мельбурн",
    NAME == "Brisbane" ~ "Брисбен",
    NAME == "Perth" ~ "Перт",
    NAME == "Adelaide" ~ "Аделаида",
    NAME == "Canberra" ~ "Канберра",
    NAME == "Newcastle" ~ "Ньюкасл",
    NAME == "Alice Springs" ~ "Алис-Спрингс",
    NAME == "Hobart" ~ "Хобарт",
    NAME == "Darwin" ~ "Дарвин",
    NAME == "Townsville" ~ "Таунсвилл"
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

draw_legend <- function() {
  g <- gTree(children = gList(
    rectGrob(x = 0.5, y = 0.5, width = 0.5, height = 0.7,
             gp = gpar(fill = "grey", col = "black", lwd = 0.5)),
    textGrob("Глубина", x = 0.5, y = 0.78, 
             gp = gpar(fontsize = 9, fontface = "bold")),
    rectGrob(x = 0.45, y = 0.68, width = 0.08, height = 0.04,
             gp = gpar(fill = "#9ECAE1", col = NA)),
    textGrob("5000 м", x = 0.5, y = 0.68, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.61, width = 0.08, height = 0.04,
             gp = gpar(fill = "#C6DBEF", col = NA)),
    textGrob("4000 м", x = 0.5, y = 0.61, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.54, width = 0.08, height = 0.04,
             gp = gpar(fill = "#DEEBF7", col = NA)),
    textGrob("3000 м", x = 0.5, y = 0.54, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.47, width = 0.08, height = 0.04,
             gp = gpar(fill = "#EFF3FF", col = NA)),
    textGrob("2000 м", x = 0.5, y = 0.47, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.40, width = 0.08, height = 0.04,
             gp = gpar(fill = "#F7FBFF", col = NA)),
    textGrob("1000 м", x = 0.5, y = 0.40, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.33, width = 0.08, height = 0.04,
             gp = gpar(fill = "white", col = "black", lwd = 0.2)),
    textGrob("200 м", x = 0.5, y = 0.33, 
             gp = gpar(fontsize = 7), hjust = 0),
    rectGrob(x = 0.45, y = 0.26, width = 0.08, height = 0.04,
             gp = gpar(fill = "white", col = "black", lwd = 0.2)),
    textGrob("0 м", x = 0.5, y = 0.26, 
             gp = gpar(fontsize = 7), hjust = 0)
  ))
  return(g)
}

legend_grob <- draw_legend()

p <- ggplot() +
  geom_sf(data = bathy_0, fill = "white", color = NA, alpha = 0.5) +
  geom_sf(data = bathy_200, fill = "white", color = NA, alpha = 0.7) +
  geom_sf(data = bathy_1000, fill = "#F7FBFF", color = NA, alpha = 0.9) +
  geom_sf(data = bathy_2000, fill = "#EFF3FF", color = NA, alpha = 0.9) +
  geom_sf(data = bathy_3000, fill = "#DEEBF7", color = NA, alpha = 0.9) +
  geom_sf(data = bathy_4000, fill = "#C6DBEF", color = NA, alpha = 0.9) +
  geom_sf(data = bathy_5000, fill = "#9ECAE1", color = NA, alpha = 0.9) +
  geom_sf(data = coastline, color = "darkgreen", linewidth = 1.2, alpha = 1, linetype = "solid") +
  geom_sf(data = australia_states %>% 
            filter(admin == "Australia") %>%
            filter(name %in% names(state_colors)),
          aes(fill = name), 
          color = "darkgray", linewidth = 0.5, alpha = 0.5, linetype = "twodash") +
  scale_fill_manual(values = state_colors, guide = "none") +
  geom_sf(data = rivers, color = "blue", linewidth = 0.3, alpha = 0.7, linetype = "solid") +
  geom_sf(data = lakes, color = "skyblue", fill = "skyblue", linewidth = 0.3, alpha = 0.7, linetype = "solid") +
  geom_sf(data = roads, color = "brown", linewidth = 0.2, alpha = 0.6, linetype = "solid") +
  geom_sf(data = australia_cities, color = "darkred", alpha = 0.8, size = 2) +
  geom_sf(data = reefs, fill = "skyblue", color = "steelblue", linewidth = 0.3, alpha = 0.5,  linetype = "solid") +
  geom_sf(data = graticules, fill = "black", linewidth = 0.2, alpha = 0.2,  linetype = "solid") +
  
  geom_text_repel(
    data = other_states_labels,
    aes(label = label, geometry = geometry), stat = "sf_coordinates",
    size = 4, fontface = "bold.italic", color = "black",
    box.padding = 2.2, point.padding = 1, force = 3,
    max.overlaps = 5, segment.color = NA,
    max.time = 2.5, max.iter = 25000,
    direction = "both",
    point.size = NA,           
    nudge_x = 0, nudge_y = 0,
    hjust = 0.5, vjust = 0.5
  ) +
  
  geom_text_repel(
    data = tasmania_label,
    aes(label = label, geometry = geometry), stat = "sf_coordinates",
    size = 4, fontface = "bold.italic", color = "black",
    box.padding = 2.2, point.padding = 1, force = 3,
    max.overlaps = 5, segment.color = NA,
    max.time = 2.5, max.iter = 25000,
    direction = "both",
    point.size = NA,           
    nudge_x = 0, nudge_y = 0.5,
    hjust = 0.5, vjust = 0.5
  ) +
  
  geom_text_repel(
    data = australia_cities,
    aes(label = name_ru, geometry = geometry), stat = "sf_coordinates",
    size = 3, fontface = "bold", color = "darkred",
    box.padding = 0.5, point.padding = 0.2, force = 2.5,
    max.overlaps = 20, segment.color = NA, min.segment.length = 0, 
    max.time = 2, max.iter = 20000,
    direction = "both",
    point.size = NA,
    nudge_x = 0.2, nudge_y = -0.2,
    hjust = 0, vjust = 1
  ) +
  
  geom_text_repel(
    data = sea_labels,
    aes(label = sea_name_ru, geometry = geometry), stat = "sf_coordinates",
    size = 3, fontface = "bold", color = "darkblue",
    box.padding = 1.2, point.padding = 0.3, force = 2.5,
    max.overlaps = 15, segment.color = NA, min.segment.length = 0, 
    max.time = 2, max.iter = 20000,
    direction = "both",
    point.size = NA,           
    nudge_x = 0, nudge_y = 0,
    hjust = 0.5, vjust = 0.5
  ) +
  
  annotation_custom(legend_grob, 
                    xmin = 110, xmax = 120, 
                    ymin = -50, ymax = -42) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5, color = "black"),
    panel.grid.major = element_line(color = "lightgray", linewidth = 0.2),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "lightblue", color = NA),
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(color = "black", size = 8),
    axis.text.y = element_text(color = "black", size = 8)
  ) +
  
  labs(title = "Австралия") +
  
  coord_sf(xlim = c(110, 160), ylim = c(-50, -7), expand = FALSE) +
  
  annotation_scale(
    location = "br", width_hint = 0.3, bar_cols = c("black", "white"), text_col = "black", 
    text_cex = 0.9, line_width = 1.2, line_col = "black", unit = "km"
  )

print(p)

ggsave(filename = "D:/ИПЭЭ РАН/Аспирантура/QGIS/Australia_map.png",
       plot = p, width = 14, height = 10, dpi = 300, bg = "white")