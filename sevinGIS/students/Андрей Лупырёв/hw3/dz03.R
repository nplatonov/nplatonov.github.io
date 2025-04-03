library(sf)
library(plotly)
library(sf)
library(dplyr)
library(ggplot2)
library(leaflet)
library(units)

dsn <- "2022-01-09_14-00_Sun.gpx"
loc <- sf::st_read(dsn,layer="track_points")

#вычисляем скорость

loc_proj <- st_transform(loc, crs = "EPSG:32637") 
calculate_3d_distance <- function(point1, point2) {
  coords1 <- st_coordinates(point1)
  coords2 <- st_coordinates(point2)
  z1 <- point1$ele
  z2 <- point2$ele
  dx <- coords2[1] - coords1[1]
  dy <- coords2[2] - coords1[2]
  dz <- z2 - z1
  distance_3d <- sqrt(dx^2 + dy^2 + dz^2)
  return(distance_3d)
}
distances_3d <- numeric(nrow(loc_proj) - 1)
for (i in 1:(nrow(loc_proj) - 1)) {
  distances_3d[i] <- calculate_3d_distance(loc_proj[i,], loc_proj[i+1,])
}
time_diffs <- difftime(loc_proj$time[2:nrow(loc_proj)], loc_proj$time[1:(nrow(loc_proj) - 1)], units = "secs")
time_diffs_numeric <- as.numeric(time_diffs)
speeds_ms <- units::set_units(distances_3d / time_diffs_numeric, "m/s")
loc_proj$speed_ms <- c(NA, speeds_ms) 
loc_proj$speed_kmh <- loc_proj$speed_ms * 3.6  # 1 м/с = 3.6 км/ч
loc_proj$speed_kmh <- units::set_units(loc_proj$speed_kmh, "km/h")
loc_proj$speed_kmh[1] <- units::set_units(0, "km/h") 
View(loc_proj)

#поиск начала круга 1

base_point <- loc_proj[1,]
loc_proj$distance_to_base <- st_distance(loc_proj, base_point)
speed_jump_threshold <- units::set_units(8, "km/h") 
skip_first_n_points <- 0
jump_point_index <- which(loc_proj$speed_kmh[(skip_first_n_points + 1):nrow(loc_proj)] >= speed_jump_threshold, arr.ind = TRUE)[1]
if (!is.na(jump_point_index)) {
  jump_point_index <- jump_point_index + skip_first_n_points
}
if (!is.na(jump_point_index)) {
  jump_point <- loc_proj[jump_point_index,]
  print("Координаты точки скачка:")
  print(sf::st_coordinates(jump_point))
  print("Данные точки скачка:")
  print(jump_point)
  loc_proj$row_number <- 1:nrow(loc_proj)
  print(jump_point_index)
  ggplot() +
    geom_sf(data = loc_proj, aes(color = ifelse(row_number == jump_point_index, "red", "blue"))) +
    scale_color_manual(values = c("blue", "red"), labels = c("Остальные", "Найденная точка")) +
    labs(title = paste0("Точка скачка (speed_kmh >= ", speed_jump_threshold, " km/h)"), color = "Легенда") +
    theme_bw()
} else {
  print("Точка скачка не найдена")
}

#поиск конца круга 2

min_speed_threshold <- units::set_units(8, "km/h")
skip_last_n_points <- 130
slowdown_point_index <- NA
for (i in (nrow(loc_proj) - skip_last_n_points):1) {
  if (loc_proj$speed_kmh[i] > min_speed_threshold) { 
    slowdown_point_index <- i
    break 
  }
}
if (!is.na(slowdown_point_index) && slowdown_point_index >= 1 && slowdown_point_index <= nrow(loc_proj)) {
  slowdown_point <- loc_proj[slowdown_point_index,]
  print("Координаты точки замедления (начала возрастания скорости):")
  print(sf::st_coordinates(slowdown_point))
  print("Данные точки замедления:")
  print(slowdown_point)
  ggplot() +
    geom_sf(data = loc_proj %>% mutate(row_number = dplyr::row_number()), #Создаем row_number внутри ggplot
            aes(color = ifelse(row_number == slowdown_point_index, "red", "blue"))) +
    scale_color_manual(values = c("blue", "red"), labels = c("Остальные", "Найденная точка")) +
    labs(title = paste0("Точка замедления (speed_kmh > ",  units::drop_units(min_speed_threshold), " km/h)"), color = "Легенда") +
    theme_bw()
} else {
  print("Точка замедления не найдена")
}

# поиск конца 1 и начала 2

start_id <- 94
end_id <-  690
start_index <- which(loc_proj$track_seg_point_id == start_id)
end_index <- which(loc_proj$track_seg_point_id == end_id)
if (length(start_index) == 0 || length(end_index) == 0) {
  stop("Не найдены track_seg_point_id начала или конца")
}
start_index <- start_index[1]
end_index <- end_index[1]
subset_loc <- loc_proj[start_index:end_index, ]
subset_loc <- subset_loc %>%
  mutate(distance_to_prev = as.numeric(st_distance(geometry, lag(geometry), by_element = TRUE)))
subset_loc$distance_to_prev[1] <- 0
subset_loc <- subset_loc %>%
  mutate(cumulative_distance = cumsum(distance_to_prev))
halfway_distance <- max(subset_loc$cumulative_distance) / 2
split_point <- subset_loc %>%
  slice(which.min(abs(cumulative_distance - halfway_distance)))
split_id <- split_point$track_seg_point_id
original_split_index <- which(loc_proj$track_seg_point_id == split_id)
if (length(original_split_index) == 0) {
  stop("Не удалось найти split_id в loc_proj")
}
original_split_index <- original_split_index[1]
cat("Номер строки исходной точки разделения в loc_proj:", original_split_index, "\n")
cat("Номер track_seg_point_id точки разделения (конец первого и начало второго круга):", split_id, "\n")

#длина

start_index <- 94
end_index <- 396

track_segment <- loc_proj[start_index:end_index, ]
if (st_geometry_type(track_segment)[1] != "LINESTRING") {
  track_segment_linestring <- st_combine(track_segment) %>% st_cast("LINESTRING")
} else {
  track_segment_linestring <- track_segment
}
track_length <- st_length(track_segment_linestring)
cat("Длина трека:", track_length, "\n") 

# 2. Скорость

if ("speed_kmh" %in% names(track_segment)) {
  speeds <- track_segment$speed_kmh
  average_speed <- mean(speeds, na.rm = TRUE)
  cat("Средняя скорость на участке трека:", average_speed, "km/h\n")
} else {
  cat("Невозможно рассчитать среднюю скорость.\n")
}

# 3. Удаление
base_point <- loc_proj[1, ]
distances <- st_distance(track_segment, base_point)
max_distance <- max(distances, na.rm = TRUE)
cat("Максимальное расстояние от базовой точки до точек на участке трека:", max_distance, "\n")

#графики

create_segments_map <- function(loc_proj, ranges) {
  leaflet() %>%
    addTiles() -> map 
  for (i in 1:(nrow(loc_proj) - 1)) {
    mid_track_seg_point_id <- (loc_proj$track_seg_point_id[i] + loc_proj$track_seg_point_id[i+1]) / 2
    segment_range_index <- which(mid_track_seg_point_id >= ranges$start & mid_track_seg_point_id <= ranges$end)
    if (length(segment_range_index) > 0) {
      segment_color <- ranges$color[segment_range_index[1]]
    } else {
      segment_color <- "gray"
    }
    segment <- st_union(loc_proj[i:(i+1),])
    segment <- st_cast(segment, "LINESTRING")
    map <- addPolylines(
      map,
      data = segment,
      color = segment_color,
      weight = 3,
      opacity = 0.8
    )
  }
  map <- addLegend(
    map,
    colors = ranges$color,
    labels = c("Подход", "Круг 1", "Круг 2", "Уход"),
    title = "Участок",
    position = "topright"
  )
  return(map)
}
create_speed_map <- function(loc_proj) {
  if("speed_kmh" %in% names(loc_proj)) {
    pal <- colorNumeric(
      palette = colorRampPalette(c("white", "blue"))(256),
      domain = units::drop_units(loc_proj$speed_kmh)
    )
    leaflet() %>%
      addTiles() -> map
    for (i in 1:(nrow(loc_proj) - 1)) {
      segment <- st_union(loc_proj[i:(i+1),])
      segment <- st_cast(segment, "LINESTRING")
      segment_color_speed <- pal(units::drop_units(loc_proj$speed_kmh[i]))
      map <- addPolylines(
        map,
        data = segment,
        color = segment_color_speed,
        weight = 3,
        opacity = 0.8
      )
    }
    map <- addLegend(map, pal = pal, values = units::drop_units(loc_proj$speed_kmh), title = "Скорость (км/ч)", position = "bottomright")
  } else {
    stop("Нет данных о скорости (speed_kmh).")
  }
  return(map)
}
create_elevation_map <- function(loc_proj) {
  pal <- colorNumeric(
    palette = colorRampPalette(c("white", "blue"))(256),
    domain = loc_proj$ele
  )
  leaflet() %>%
    addTiles() -> map
  for (i in 1:(nrow(loc_proj) - 1)) {
    segment <- st_union(loc_proj[i:(i+1),])
    segment <- st_cast(segment, "LINESTRING")
    segment_color_elevation <- pal(loc_proj$ele[i])
    map <- addPolylines(
      map,
      data = segment,
      color = segment_color_elevation,
      weight = 3,
      opacity = 0.8
    )
  }
  map <- addLegend(map, pal = pal, values = loc_proj$ele, title = "Высота", position = "bottomright")
  return(map)
}
loc_proj <- loc_proj[order(loc_proj$track_seg_point_id), ]
utm37n <- 32637
wgs84 <- 4326
loc_proj_utm37n <- st_transform(loc_proj, utm37n)
loc_proj_wgs84 <- st_transform(loc_proj_utm37n, wgs84)
ranges <- data.frame(
  start = c(0, 94, 396, 690),
  end = c(94, 396, 690, 834),
  color = c("yellow", "red", "blue", "green")
)
segments_map <- create_segments_map(loc_proj_wgs84, ranges) 
speed_map <- create_speed_map(loc_proj_wgs84)               
elevation_map <- create_elevation_map(loc_proj_wgs84)         
segments_map
speed_map
elevation_map

#3d график

n <- nrow(loc_proj)
start_indices <- c(1, 95, 397, 691)  
end_indices <- c(95, 397, 691, 835)  
loc <- st_transform(loc_proj, crs = 32637)  
coords <- st_coordinates(loc)
loc$X <- coords[, "X"]
loc$Y <- coords[, "Y"]
create_segments <- function(loc, start_indices = NULL, end_indices = NULL, segment_colors = NULL, segment_names = NULL) {
  segments <- list() 
  add_segment <- function(data, color = "gray", name = "Track") {
    segments <<- append(segments, list(
      list(  
        x = data$X,
        y = data$Y,
        z = data$ele,
        mode = "lines", 
        line = list(color = color),
        type = "scatter3d",
        name = name  
      )
    ))
  } 
  if (is.null(start_indices)) {
    add_segment(loc, color = "gray", name = "Track")
  } else {
    last_index <- 1
    for (i in 1:length(start_indices)) {
      if (start_indices[i] > last_index) {
        add_segment(loc[last_index:(start_indices[i] - 1), ], color = "gray", name = "Track")
      }
      segment_color <- segment_colors[i]
      segment_name <- segment_names[i]
      add_segment(loc[start_indices[i]:end_indices[i], ], color = segment_color, name = segment_name)    
      last_index <- end_indices[i] + 1
    }
    if (last_index <= nrow(loc)) {
      add_segment(loc[last_index:nrow(loc), ], color = "gray", name = "Track")
    }
  }
  return(segments)
}
segment_colors <- c("yellow", "red", "blue", "green")  
segment_names <- c("Приход", "Круг 1", "Круг 2", "Уход")  
segments <- create_segments(loc, start_indices, end_indices, segment_colors, segment_names)
p <- plot_ly()
for (i in 1:length(segments)) {
  segment <- segments[[i]]
  p <- add_trace(p,
                 x = segment$x,
                 y = segment$y,
                 z = segment$z,
                 mode = segment$mode,
                 line = segment$line,
                 type = segment$type,
                 name = segment$name,
                 visible = TRUE)
}
p <- add_trace(
  p,
  x = loc$X,
  y = loc$Y,
  z = loc$ele,
  mode = "markers",  
  marker = list(
    size = 5,
    color = loc$speed_kmh,  
    colorscale =  list(c(0, "white"), c(1, "blue")), 
    colorbar = list(title = "Скорость")
  ),
  type = "scatter3d",
  name = "Скорость",
  visible = TRUE 
)
p <- layout(
  p,
  scene = list(
    xaxis = list(title = "X"),
    yaxis = list(title = "Y"),
    zaxis = list(title = "Высота"),
    aspectratio = list(x = 1, y = 1, z = 0.5)
  ),
  legend = list(
    x = 0.95,  
    y = 0.05,  
    orientation = "v", 
    font = list(size = 10),  
    columns = 2  
  )
)
p
