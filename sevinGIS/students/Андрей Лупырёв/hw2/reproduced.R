#' ---
#' echo: true
#' ---
#'
library(sf)
library(plotly)
library(sf)
library(dplyr)
library(ggplot2)
library(leaflet)

dsn <- "../../../data/2022-01-09_14-00_Sun.gpx"
loc <- sf::st_read(dsn,layer="track_points")

#поиск начала круга 1

base_point <- loc[1,]
loc$distance_to_base <- st_distance(loc, base_point)
speed_jump_threshold <- 23 
skip_first_n_points <- 90  
jump_point_index <- which(loc$hdop[(skip_first_n_points + 1):nrow(loc)] >= speed_jump_threshold)[1]
if (!is.na(jump_point_index)) {
  jump_point_index <- jump_point_index + skip_first_n_points
}
if (!is.na(jump_point_index)) {
  jump_point <- loc[jump_point_index,] 
  print(sf::st_coordinates(jump_point))
  print(jump_point)
  loc$row_number <- 1:nrow(loc)
  ggplot() +
    geom_sf(data = loc, aes(color = ifelse(row_number == jump_point_index, "red", "blue"))) +
    scale_color_manual(values = c("blue", "red"), labels = c("Остальные", "Найденная точка")) +
    labs(title = "Точка скачка скорости (>= 20)", color = "Легенда") +
    theme_bw()
} else {
  print("Точка не найдена")
}

#поиск конца круга 2

base_point <- loc[1,]
loc$distance_to_base <- st_distance(loc, base_point)
min_speed_threshold <- 19  
skip_last_n_points <- 130 
slowdown_point_index <- NA
for (i in (nrow(loc) - 1 - skip_last_n_points):1) {
  if (loc$hdop[i] > min_speed_threshold && loc$hdop[i + 1] <= min_speed_threshold) {
    slowdown_point_index <- i
    break 
  }
}
if (!is.na(slowdown_point_index)) {
  slowdown_point <- loc[slowdown_point_index,]
  print(sf::st_coordinates(slowdown_point))
  print(slowdown_point)
  loc$row_number <- 1:nrow(loc)
  ggplot() +
    geom_sf(data = loc, aes(color = ifelse(row_number == slowdown_point_index, "red", "blue"))) +
    scale_color_manual(values = c("blue", "red"), labels = c("Остальные", "Найденная точка")) +
    labs(title = "Точка начала замедления", color = "Легенда") +
    theme_bw()
} else {
  print("Точка не найдена")
}

# поиск конца 1 и начала 2

start_id <- 96  
end_id <-  690   
start_index <- which(loc$track_seg_point_id == start_id)
end_index <- which(loc$track_seg_point_id == end_id)
if (length(start_index) == 0 || length(end_index) == 0) {
  stop("Не найдены track_seg_point_id начала или конца")
}
start_index <- start_index[1]
end_index <- end_index[1]
subset_loc <- loc[start_index:end_index, ]
distances <- numeric(nrow(subset_loc))
for (i in 2:nrow(subset_loc)) {
  distances[i] <- as.numeric(st_distance(subset_loc$geometry[i], subset_loc$geometry[i-1]))
}
distances[1] <- 0  
subset_loc$distance_to_prev <- distances
subset_loc <- subset_loc %>%
  mutate(cumulative_distance = cumsum(distance_to_prev))
halfway_distance <- max(subset_loc$cumulative_distance) / 2
split_point <- subset_loc %>%
  slice(which.min(abs(cumulative_distance - halfway_distance)))
split_id <- split_point$track_seg_point_id
original_split_index <- which(loc$track_seg_point_id == split_id)
if (length(original_split_index) == 0) {
  stop("Не удалось найти")
}
original_split_index <- original_split_index[1]
cat("Номер строки исходной точки разделения в loc:", original_split_index, "\n")
cat("Номер track_seg_point_id точки разделения (конец первого и начало второго круга):", split_id, "\n")

#длина

start_index <- 396  
end_index <- 690   
track_segment <- loc[start_index:end_index,]
if (st_geometry_type(track_segment)[1] != "LINESTRING") {
  track_segment_linestring <- st_combine(track_segment) %>% st_cast("LINESTRING")
} else {
  track_segment_linestring <- track_segment
}
track_length <- st_length(track_segment_linestring)
cat("Длина трека:", track_length, "\n")
#скорость

track_segment <- loc[start_index:end_index,]
speeds <- track_segment$hdop
average_speed <- mean(speeds)
cat("Средняя скорость на участке трека:", average_speed, "\n")

#удаление

base_point <- loc[1,]
track_segment <- loc[start_index:end_index,]
distances <- st_distance(track_segment, base_point)
max_distance <- max(distances)
cat("Максимальное расстояние от базовой точки до точек на участке трека:", max_distance, "\n")

#графики

create_segments_map <- function(loc, ranges) {
  leaflet() %>%
    addProviderTiles("OpenStreetMap.DE") %>%
    addTiles() -> map
  for (i in 1:(nrow(loc) - 1)) {
    segment_range_index <- which(loc$track_seg_point_id[i] >= ranges$start & loc$track_seg_point_id[i] <= ranges$end)
    if (length(segment_range_index) > 0) {
      segment_color <- ranges$color[segment_range_index]
    } else {
      segment_color <- "gray"
    }
    segment <- st_union(loc[i:(i+1),])
    segment <- st_cast(segment, "LINESTRING")
    map <- addPolylines(
      map,
      data = segment,
      color = segment_color,
      weight = 3,
      opacity = 0.8
    )
  }
  map <- addLegend(map, colors = ranges$color, labels = c("Подход", "Круг 1", "Круг 2", "Уход"), title = "Участок", position = "topright")
  return(map)
}
create_speed_map <- function(loc) {
  pal <- colorNumeric(
    palette = colorRampPalette(c("white", "blue"))(256),
    domain = loc$hdop
  )
  leaflet() %>%
    addProviderTiles("OpenStreetMap.DE") %>%
    addTiles() -> map
  for (i in 1:(nrow(loc) - 1)) {
    segment <- st_union(loc[i:(i+1),])
    segment <- st_cast(segment, "LINESTRING")
    segment_color_speed <- pal(loc$hdop[i])
    map <- addPolylines(
      map,
      data = segment,
      color = segment_color_speed,
      weight = 3,
      opacity = 0.8
    )
  }
  map <- addLegend(map, pal = pal, values = loc$hdop, title = "Скорость", position = "bottomright")
  return(map)
}
create_elevation_map <- function(loc) {
  pal <- colorNumeric(
    palette = colorRampPalette(c("white", "blue"))(256),
    domain = loc$ele
  )
  leaflet() %>%
    addProviderTiles("OpenStreetMap.DE") %>%
    addTiles() -> map
  for (i in 1:(nrow(loc) - 1)) {
    segment <- st_union(loc[i:(i+1),])
    segment <- st_cast(segment, "LINESTRING")
    segment_color_elevation <- pal(loc$ele[i])
    map <- addPolylines(
      map,
      data = segment,
      color = segment_color_elevation,
      weight = 3,
      opacity = 0.8
    )
  }
  map <- addLegend(map, pal = pal, values = loc$ele, title = "Высота", position = "bottomright")
  return(map)
}
loc <- loc[order(loc$track_seg_point_id), ]
ranges <- data.frame(
  start = c(0, 96, 396, 690),
  end = c(96, 396, 690, 834),
  color = c("yellow", "red", "blue", "green")
)
segments_map <- create_segments_map(loc, ranges)
speed_map <- create_speed_map(loc)
elevation_map <- create_elevation_map(loc)
segments_map
speed_map
elevation_map

#3d график

loc <- sf::st_read(dsn,layer="track_points")
n <- nrow(loc)
start_indices <- c(1, 97, 397, 691)  
end_indices <- c(97, 397, 691, 835)  
loc <- st_transform(loc, crs = 32637)  
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
    color = loc$hdop,  
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
