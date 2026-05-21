library(sf)
library(tidyverse)
library(geosphere)
library(lubridate)
library(ggplot2)

file_path <- "../../../data/2022-01-09_14-00_Sun.gpx"
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

max_distance_point <- track[which.max(track$dist_from_base), ]
max_distance_value <- max_distance_point$dist_from_base

cat("\n--- МАКСИМАЛЬНО УДАЛЕННАЯ ТОЧКА ---")
cat("\nРасстояние от базы:", round(max_distance_value, 0), "метров")

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
  mutate(
    segment_name = case_when(
      row_number() <= real_hits[1] ~ "1. Подход",
      row_number() >= real_hits[1] & row_number() <= real_hits[2] ~ "2. Круг 1",
      row_number() >= real_hits[2] & row_number() <= real_hits[3] ~ "3. Круг 2",
      row_number() >= real_hits[3] ~ "4. Уход"
    )
  )

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

final_stats$Start_Time[2] <- final_stats$End_Time[1]
final_stats$Start_Time[3] <- final_stats$End_Time[2]
final_stats$Start_Time[4] <- final_stats$End_Time[3]

track_adj <- track %>%
  mutate(
    dist_diff_adj = dist_diff,
    time_diff_adj = time_diff
  )

first_circle1_row <- which(track$segment_name == "2. Круг 1")[1]
track_adj$dist_diff_adj[first_circle1_row] <- 0
track_adj$time_diff_adj[first_circle1_row] <- 0

first_circle2_row <- which(track$segment_name == "3. Круг 2")[1]
track_adj$dist_diff_adj[first_circle2_row] <- 0
track_adj$time_diff_adj[first_circle2_row] <- 0

first_exit_row <- which(track$segment_name == "4. Уход")[1]
track_adj$dist_diff_adj[first_exit_row] <- 0
track_adj$time_diff_adj[first_exit_row] <- 0

final_stats_adj <- track_adj %>%
  group_by(segment_name) %>%
  summarise(
    Start_Time = min(time),
    End_Time = max(time),
    Distance_m = round(sum(dist_diff_adj, na.rm = TRUE), 0),
    Avg_Speed_kmh = round(mean(ifelse(time_diff_adj > 0, (dist_diff_adj / time_diff_adj) * 3.6, 0), na.rm = TRUE), 2),
    Duration = paste0(sum(time_diff_adj, na.rm = TRUE) %/% 60, " мин ", round(sum(time_diff_adj, na.rm = TRUE) %% 60), " сек"),
    Irregularity = round(sd(ifelse(time_diff_adj > 0, (dist_diff_adj / time_diff_adj) * 3.6, 0), na.rm = TRUE) / 
                           mean(ifelse(time_diff_adj > 0, (dist_diff_adj / time_diff_adj) * 3.6, 0), na.rm = TRUE), 3)
  )

final_stats_adj$Start_Time[2] <- final_stats_adj$End_Time[1]
final_stats_adj$Start_Time[3] <- final_stats_adj$End_Time[2]
final_stats_adj$Start_Time[4] <- final_stats_adj$End_Time[3]

max_away <- max(track$dist_from_base)

print("--- СТАТИСТИКА ПО УЧАСТКАМ ---")
print(final_stats_adj)
cat("\nМаксимальное удаление от базы:", round(max_away, 0), "метров\n")

ggplot(track, aes(x = lon, y = lat, color = segment_name)) +
  geom_path(linewidth = 1.2) +
  annotate("point", x = base_coord[1], y = base_coord[2], 
           color = "black", size = 4, shape = 17) +
  annotate("point", x = gate_coord[1], y = gate_coord[2], 
           color = "yellow", size = 4, shape = 18) +
  annotate("point", x = max_distance_point$lon, y = max_distance_point$lat, 
           color = "red", size = 5, shape = 8) +
  annotate("text", x = max_distance_point$lon, y = max_distance_point$lat, 
           label = paste0("Макс. удаление\n", round(max_distance_value, 0), " м"),
           hjust = -0.2, vjust = -0.5, size = 3, color = "red") +
  coord_fixed(ratio = 1.3) +
  scale_color_manual(values = c(
    "1. Подход" = "#D1E9FF",
    "2. Круг 1" = "#6AB7FF", 
    "3. Круг 2" = "#0059B3", 
    "4. Уход" = "#FF6347"  
  )) +
  labs(
    title = "Анализ лыжной прогулки: 2 круга",
    x = "Долгота", y = "Широта", color = "Участок"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")