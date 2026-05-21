# plutil::pluglibrary("gpx")
library(sf)
# library(gpx)
library(adehabitatLT)
library(mapview)
require(dplyr)

# setwd("/Users/ksusasaveleva/R_projects/Modeling/Ski")

loc <- st_read("../../../data/2022-01-09_14-00_Sun.gpx", layer = "track_points") |>
  st_transform(32637)
loc$time <- as.POSIXct(loc$time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
head(loc)
print(class(loc))
print(st_crs(loc))
# Извлеките координаты как обычные числа
coords <- st_coordinates(loc)
x_coords <- coords[, "X"]  # долгота
y_coords <- coords[, "Y"]  # широта

# Проверьте, что координаты - числа
print(class(x_coords))
print(head(x_coords))
lt1 <- as.ltraj(
  xy = cbind(x_coords, y_coords),  # важно: матрица, а не data.frame
  date = loc$time,                  # время POSIXct
  id = loc$track_seg_id,            # ID сегмента
  typeII = TRUE,                    # явно указываем тип II
  proj4string = sp::CRS(st_crs(loc)$proj4string)
)
plot(lt1) # полный трек из точек

df <- ld(lt1)
df$speed_kmh <- df$dist / df$dt * 3.6
df$cum_dist  <- cumsum(df$dist)/1000

# расчет 1-го круга
dist_1 <- df[["dist"]][94:395]
sum(dist_1)
# 1 круг с начинается с разгона 8.87 км/ч
t1 <- df[94:395,]
dlt1 <- dl(t1)
df_t1 <- ld(dlt1)
time_1 <- df_t1 |>
  summarise(finish1 = max(date, na.rm = TRUE),
            start1 = min(date, na.rm = TRUE))
# расчет по 2-му кругу
dist_2 <- df[["dist"]][396:690]
sum(dist_2)
# 2 круг заканчивается максимальной скоростью 11.87 км/ч
t2 <- df[396:690,]
dlt2 <- dl(t2)
df_t2 <- ld(dlt2)
time_2 <- df_t2 |>
  summarise(finish2 = max(date, na.rm = TRUE),
            start2 = min(date, na.rm = TRUE))

# расстояние от базы до начала круга
b_start <- df[["dist"]][1:93]
sum(b_start)
b_start <- df[1:93,]
b_start <- dl(b_start)
df_b_start <- ld(b_start)

# и наоборот
start_b <- df[["dist"]][691:834]
sum(start_b)

# получилось 258.7 туда и 432.9 обратно 
# (скорее 258.7 м, потому что на обратном пути появляется крюк)

# всего
all_dist <- df[["dist"]][1:834]
sum(all_dist)
# всего минус путь от и до базы
track_dist <- df[["dist"]][94:690]
sum(track_dist)

plot(df_t1$x, df_t1$y, type = "l", col = "red", lwd = 2,
     xlim = c(388500, 389100),
     ylim = c(6289500, 6290250),
     xlab = "X",
     ylab = "Y")
lines(df_t2$x, df_t2$y, col = "blue", lwd = 2)
lines(df_b_start$x, df_b_start$y, col = "green", lwd = 2)
legend ("bottomright",
  legend = c("Путь от/до базы", "1-ый круг","2-ой круг"),
  col = c("green", "red", "blue"),
  lty = c(1, 1, 1),
  lwd = c(2, 2, 2))



# поиск удаленной точки ---------------------------------------------------

base_point <- df[1,] 
points_sf <- st_as_sf(df, coords = c("x", "y"), crs = st_crs(base_point))
base_point <- st_as_sf(base_point, coords = c("x", "y"), crs = st_crs(points_sf))
# Вычисляем расстояния до базы
distances <- st_distance(points_sf, base_point)

# Находим точку с максимальным расстоянием
max_dist_idx <- which.max(distances)
max_point <- points_sf[max_dist_idx, ]
max_distance <- distances[max_dist_idx]

# Результат
cat("Максимальное расстояние:", round(max_distance, 2), "метров\n")
cat("Координаты максимально удаленной от базы точки:", st_coordinates(max_point))

df_sf <- st_as_sf(df, coords = c("x", "y"), crs = 3572)
st_write(df_sf, "df_reproduced.shp")
ursa::glance(df_sf[c("speed_kmh")],resetGrid=TRUE)
original <- sf::st_read("df.shz")
ursa::glance(original[c("speed_kmh")],resetGrid=TRUE)
sf::st_crs(df_sf)$proj4string
sf::st_crs(original)$proj4string
