library(sf)
library(tidyverse)
library(geosphere)
library(lubridate)
library(ggplot2)

file_path <- "../../../data/2022-01-09_14-00_Sun.gpx"
file.exists(file_path)
points <- st_read(file_path, layer = "track_points")

track <- points %>%
  mutate(
    lon = st_coordinates(.)[,1],
    lat = st_coordinates(.)[,2],
    time = with_tz(as_datetime(time), tzone = "Europe/Moscow")
  ) %>%
  st_drop_geometry() %>%
  mutate(
    dist_diff = c(0, distHaversine(cbind(lon[-n()], lat[-n()]), cbind(lon[-1], lat[-1]))),
    time_diff = c(0, as.numeric(diff(time))),
    speed_kmh = ifelse(time_diff > 0, (dist_diff / time_diff) * 3.6, 0),
    cum_dist = cumsum(dist_diff)
  )

base_coord <- c(track$lon[1], track$lat[1])
track <- track %>% mutate(dist_from_base = distHaversine(cbind(lon, lat), base_coord))

gate_info <- track %>% slice(98)
gate_coord <- c(gate_info$lon, gate_info$lat)

track <- track %>% mutate(dist_to_gate = distHaversine(cbind(lon, lat), gate_coord))

gate_hits_indices <- which(track$dist_to_gate < 10)
real_hits <- c()

if(length(gate_hits_indices) > 0) {
  real_hits <- gate_hits_indices[1]
  for(i in 2:length(gate_hits_indices)) {
    last_hit_dist <- track$cum_dist[tail(real_hits, 1)]
    current_dist <- track$cum_dist[gate_hits_indices[i]]
    if(current_dist - last_hit_dist > 500) {
      real_hits <- c(real_hits, gate_hits_indices[i])
    }
  }
}

track <- track %>%
  mutate(segment_name = case_when(
    row_number() <  real_hits[1] ~ "1. Подход",
    row_number() >= real_hits[1] & row_number() < real_hits[2] ~ "2. Круг 1",
    row_number() >= real_hits[2] & row_number() < real_hits[3] ~ "3. Круг 2",
    row_number() >= real_hits[3] ~ "4. Уход",
    TRUE ~ "4. Уход"
  ))

final_stats <- track %>%
  group_by(segment_name) %>%
  summarise(
    Start_Time = min(time),
    End_Time = max(time),
    Distance_m = round(sum(dist_diff), 0),
    Avg_Speed_kmh = round(mean(speed_kmh, na.rm = TRUE), 2),
    Duration = paste0(sum(time_diff) %/% 60, " мин ", round(sum(time_diff) %% 60), " сек"),
    Irregularity = round(sd(speed_kmh, na.rm = TRUE) / mean(speed_kmh, na.rm = TRUE), 3)
  )

max_away <- max(track$dist_from_base)

print("--- СТАТИСТИКА ПО УЧАСТКАМ ---")
print(final_stats)
cat("\nМаксимальное удаление от базы:", round(max_away, 0), "метров\n")

ggplot(track, aes(x = lon, y = lat, color = segment_name)) +
  geom_path(linewidth = 1.2) +
  annotate("point", x = base_coord[1], y = base_coord[2], 
           color = "black", size = 4, shape = 17) +
  annotate("point", x = gate_coord[1], y = gate_coord[2], 
           color = "yellow", size = 4, shape = 18) +
  coord_fixed(ratio = 1.3) +
  scale_color_manual(values = c(
    "1. Подход" = "#D1E9FF",
    "2. Круг 1"    = "#6AB7FF", 
    "3. Круг 2"    = "#0059B3", 
    "4. Уход"   = "#FF6347"  
  )) +
  labs(
    title = "Анализ лыжной прогулки: 2 круга",
    x = "Долгота", y = "Широта", color = "Участок"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
