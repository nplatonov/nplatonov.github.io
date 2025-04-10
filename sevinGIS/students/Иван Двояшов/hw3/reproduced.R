########## HOMEWORK  АНАЛИЗ ТРАЕКТОРИЙ##############
require(sf)
require(adehabitatLT)
require(mapview)
require(tidyverse)
require(sp)
gpx <- st_read("../../../data/2022-01-09_14-00_Sun.gpx", layer="track_points") |> as("Spatial") 
gpx <- sp::spTransform(gpx,"+proj=aeqd +lat_0=90 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs") 
gpx <-st_as_sf(gpx)
ursa::spatial_write(gpx,"res1.sqlite")
q()

# создаём обьект линейной траектории
trek <- as.ltraj(st_coordinates(gpx)  
         ,date=gpx$time
         ,id=1
         ,proj4string=sp::CRS(st_crs(gpx)$proj4string))

lv_trek <- lavielle(trek, Lmin=5, Kmax=6, type="mean") # ищем идеальное разбиение
chooseseg(lv_trek) # выбираем количество сегментов
path_trek <- findpath(lv_trek, 3) # разбиение на сегменты

# длина отрезков
len <- sum(ld(path_trek[1])$dist, na.rm = T) # Путь до стадиона 
len[2] <- sum(ld(path_trek[2])$dist, na.rm = T) # Длина кругов
len[3] <- sum(ld(path_trek[3])$dist, na.rm = T) # Путь обратно
circle_length <- len[2] / 2

# средняя скорость на каждом из отрезков
time <- sum(ld(path_trek[1])$dt, na.rm = T) / 3600
time[2] <- sum(ld(path_trek[2])$dt, na.rm = T) / 3600
time[3] <- sum(ld(path_trek[3])$dt, na.rm = T) / 3600
speed <- 0
for (f in 1:length(len)) {
  speed[f] <- (len[f]/1000/time[f])
}

# время начала и конца
time_start <- ld(path_trek[2])[1,]$date
time_end <- ld(path_trek[2])[597,]$date
distv <- ld(path_trek[2])$dist
for (f in 1:length(distv)) {
  if (circle_length > sum(distv[1:f])) {
    next 
  } else {
    middle_p <- f
    break 
  }
}
time_middle <- ld(path_trek[2])[middle_p,]$date   
  
# максимальное удаление
distance <- function(data) {
  X <- data[, 1]
  Y <- data[, 2]
  
  delta_X <- X-data[1,]$x
  delta_Y <- Y-data[1,]$y
  
  dist <- round(sqrt(delta_X^2 + delta_Y^2), digits=1)
  return(dist)
}

point_d<-distance(ld(trek))
max(point_d)
# Узнаем номер этой точки
which(point_d == max(point_d))

### ОТВЕТЫ ####
# длина круга
circle_length
# средняя скорость прохождения круга
speed[2]
# время начала и окончания кругов
time_start
time_middle
time_end
# неравномерность перемещения
findpath(lv_trek, 3)
# максимально удалённая точка
max(point_d)
which(point_d == max(point_d))
