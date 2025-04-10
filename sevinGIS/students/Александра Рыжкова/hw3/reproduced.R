
# --------------------------------- Предоперации -------------------------------------------

library(sf)
library(ggplot2)
library(adehabitatHR)
library(mapview)
library(dplyr)
library(leaflet)
library(plotly)
library(units) #Работа с физическими единицами измерения
library(geosphere) #Альтернатива расчета расстояния и скорости
library(htmlwidgets) #Сохранение как HTML-файл (интерактивная карта)
library(webshot) #Создание статичных png- и jpeg-изображений через HTML (для презентации)
# webshot::install_phantomjs()


# Чтение GPX как пространственного объекта
# dir <- "C:/GIS/3 homework"
dir <- "../../../data"
st_layers(file.path(dir, "2022-01-09_14-00_Sun.gpx")) |> print()
ski <- st_read(file.path(dir, "2022-01-09_14-00_Sun.gpx"), layer = "track_points")
ski_track <- st_read(file.path(dir, "2022-01-09_14-00_Sun.gpx"), layer = "tracks")

# Проверяем структуру данных
print(st_geometry_type(ski))  # Тип геометрии (POINT)
print(colnames(ski))          # Показывает доступные столбцы
sf::st_crs(ski)$epsg

print(st_geometry_type(ski_track))  # Тип геометрии (MULTILINESTRING),
                                    #может пригодится для QGIS, сейчас будет
                                    #использован тип POINT
print(colnames(ski_track))          # Показывает доступные столбцы
sf::st_crs(ski_track)$epsg

# Проверяем часовой пояс
attr(ski_track$time, "tzone") #не задано, значит время локальное
# Преобразуем UTC в московское время (UTC+3)
ski$time <- as.POSIXct(ski$time, tz = "UTC")  # Сначала явно указываем UTC
attr(ski$time, "tzone") <- "Europe/Moscow"    # Затем меняем часовой пояс,
#поэтому неправильно интерпретировалось у ребят (в Москве UTC+3)
#принудительно ставим Москву, чтобы не запутаться на картах в дальнейшем
head(ski$time)

# Проверяем текущую CRS (должна быть WGS84, EPSG:4326)
st_crs(ski)
st_crs(ski_track)
head(st_coordinates(ski))
head(st_coordinates(ski_track))

# Трансформируем в EPSG:32637 (UTM Zone 37N)
ski_37N <- st_transform(ski, 32637)
ski_track_37N <- st_transform(ski_track, 32637)

# Проверяем результат
st_crs(ski_37N)
sf::st_crs(ski_37N)$epsg
head(st_coordinates(ski_37N)) # Координаты теперь в метрах

# Преобразование в обычную таблицу и извлечение координат + сокращение столбцов
ski_table <- ski_37N %>%
  mutate(
    lon = st_coordinates(.)[,1],
    lat = st_coordinates(.)[,2]
  ) %>%
  as.data.frame() %>%
  dplyr::select(track_seg_point_id, ele, time, hdop, lon, lat)

# Для линейного трека (ski_track) — извлекаем координаты (дополнительные
# операции, если первое недоступно, отмечаю - #)
#ski_track_coords <- st_coordinates(ski_track) %>% 
  #as.data.frame() %>%
  #rename(lon = X, lat = Y, line_id = L1)

# Просмотр структуры
if (F)
   View(ski_table)
head(ski_table)
nrow(ski_table) #835 строк
print(ski_table$time[1]) #записываем начало движения - 14:00:18
tail(ski_table, n = 10)
print(ski_table$time[835]) #записываем конец движения - 15:16:08

# Удаляем полные дубликаты точек (дубли всех стобцов)
nrow_original <- nrow(ski_table)
ski_table <- ski_table %>%
  distinct(lon, ele, lat, hdop, .keep_all = TRUE)
ski <- ski %>%
  distinct(ele, geometry, .keep_all = TRUE)
nrow(ski_table) #829 строк
nrow(ski)
removed <- nrow_original - nrow(ski_table)
message("Удалено дубликатов: ", removed)

# Экспорт в CSV (для просмотра данных отдельно)
dir <- "."
# setwd("C:/GIS/3 homework")
getwd() #просмотр рабочей директории R
# write.csv(ski_table, file.path(dir, "ski_track.csv"), row.names = FALSE, fileEncoding = "UTF-8")
#write.csv(ski_track_coords, "C:/GIS/3 homework/ski_track_line.csv", row.names = FALSE, fileEncoding = "UTF-8")


# file.exists("ski_track.csv") #файл существует?
#file.exists("ski_track_line.csv") #файл существует?

# Чтение файла (если что-то меняли в csv)
#ski_data <- read.csv(file.path(dir, "ski_track.csv"), encoding = "UTF-8",
                     #row.names = 1)
#head(ski_data)
#ski_data1 <- read.csv(file.path(dir, "ski_track_line.csv"), encoding = "UTF-8",
                     #row.names = NULL)
#head(ski_data1)

# Быстрая первоначальная визуализация
#leaflet не работает ни с чем, кроме 4326, пришлось помучаться
#используем первоначальныt ski и ski_track для визуализации, а ski_37N/ski_table и ski_track_37N для расчётов

# Проверяем, совпадает ли система координат (CRS) с EPSG:4326 (WGS84))
if(st_crs(ski) != st_crs(4326)) {
  # Если нет - преобразуем оба объекта в WGS84
  ski <- st_transform(ski, 4326)  # Преобразуем основной объект
  ski_track <- st_transform(ski_track, 4326)  # Преобразуем трек
}

# Рассчитываем общее пройденное расстояние
total_distance <- sum(as.numeric(st_length(ski_track)))

# Выводим общее расстояние
print(paste("Общее пройденное расстояние:", total_distance, "метров")) #9719 метров

# Создаем первоначальную карту с основными параметрами в точках
map01 <- leaflet() %>%
  addTiles() %>%
  addPolylines(
    data = st_coordinates(ski_track) %>% as.data.frame(),
    lng = ~X, 
    lat = ~Y, 
    color = "green",
    weight = 3,
    popup = paste("Длина:", round(as.numeric(st_length(ski_track)), 1), "м")
  ) %>%
      addCircleMarkers(
        data = ski %>% cbind(st_coordinates(ski) %>% as.data.frame()) %>% 
                                                    st_drop_geometry(),
        lng = ~X, 
        lat = ~Y, 
        radius = 3,
        color = "yellow",
        popup = ~paste(
          "Время:", format(time, "%H:%M:%S MSK"), "<br>",
          "Высота:", round(ele, 1), "м<br>",
          "HDOP:", hdop
        )
      ) %>%
  addMarkers(
    lng = (ski %>% st_coordinates() %>% as.data.frame())$X[1],
    lat = (ski %>% st_coordinates() %>% as.data.frame())$Y[1],
    popup = "Начало"
  ) %>%
  addMarkers(
    lng = (ski %>% st_coordinates() %>% as.data.frame())$X[nrow(ski)],
    lat = (ski %>% st_coordinates() %>% as.data.frame())$Y[nrow(ski)],
    popup = "Конец"
  ) %>%
  addControl(
    position = "topright",
    html = paste0("<div style='background: white; padding: 5px;'>",
                  "<b>Общее расстояние:</b> ",
                  round(total_distance), " м</div>")
  )

# Выводим карту
print(map01)

# Создаем HTML и скриншот для презентации
if (F)
   htmlwidgets::saveWidget(map01, file.path(dir, "ski_track_map01.html"), selfcontained = TRUE)
if (F)
   webshot::webshot(file.path(dir, "ski_track_map01.html"), file = file.path(dir, "ski_track_map01.png"), 
                    vwidth = 1000, vheight = 800, delay = 5)

#--------------------------------------- Анализ ---------------------------------------------
# Расчет расстояния и скорости (в метрической системе)
ski_table <- ski_table %>%
  mutate(
    # Расстояние векторов (dist) в метрах
    dist_v = sqrt((lon - lag(lon))^2 + (lat - lag(lat))^2),
    # Разница высот (delta_h) в метрах
    delta_h = ele - lag(ele),
    # Расстояние (dist) с учётом высоты в метрах
    dist = sqrt(dist_v^2 + delta_h^2),
    # Временной интервал в секундах
    time_diff_sec= as.numeric(difftime(time, lag(time), units = "secs")),
    # Скорость в м/с
    speed_ms = dist / time_diff_sec,
    # Временной интервал в часах
    time_diff_hour = as.numeric(difftime(time, lag(time), units = "hours")),
    # Скорость в км/ч
    speed_kmh = (dist/1000) / time_diff_hour,
    )

# Проверяем результат
glimpse(ski_table)
summary(ski_table$dist)  # Статистика по расстояниям
summary(ski_table$speed_ms)   # Статистика по скоростям
summary(ski_table$speed_kmh)
summary(ski_table)

hist(ski_table$speed_kmh, main = "Частота скоростей\nпо всему маршруту", xlab = "Скорость, км/ч", ylab = "Частота (по точкам)")
if (F) {
   png("hist01.png", width = 40, height = 20, units = "cm", res = 300, bg = "white")
   hist(ski_table$speed_kmh, main = "Частота скоростей\nпо всему маршруту", xlab = "Скорость, км/ч", ylab = "Частота (по точкам)", cex.main = 2,    # Увеличиваем заголовок в 2 раза
        cex.lab = 1.5,
        cex.axis = 1.3)
   dev.off()
}
plot(ski_table$time, ski_table$speed_kmh, main = "Распределение скорости\nпо всему маршруту", xlab = "Время маршрута", ylab = "Скорость,км/ч")
if (F) {
   png("plot01.png", width = 40, height = 20, units = "cm", res = 300, bg = "white")
   plot(ski_table$time, ski_table$speed_kmh, main = "Распределение скорости\nпо всему маршруту", xlab = "Время маршрута", ylab = "Скорость,км/ч")
   dev.off()
}

# Ищем точку начала движения на лыжах------------------------------------------
print(ski_table$speed_kmh[1:110])

# Предлагаю решение в двух вариантах
# 1. Найдем точку резкого возрастания скорости (начало катания), исходя из средней скорости движения
walking_threshold <- mean(ski_table$speed_kmh, na.rm = TRUE) # км/ч
cat("Автоматически рассчитанный порог скорости:", walking_threshold, "км/ч\n")

# Найдем первую точку, где скорость превышает порог и остается высокой
start_skiing_index <- which(ski_table$speed_kmh > walking_threshold)[1]
start_skiing_time <- ski_table$time[start_skiing_index]
start_skiing_point <- ski_table[start_skiing_index, ]
start_skiing_index #точка 94. Запоминаем пока что.
start_skiing_time

# 2. Уточненный анализ с определением порога по устойчивому превышению скорости (без случайных вбросов)
# Определим порог скорости для пешего хода (обычно до 5 км/ч)
# Параметры анализа
min_high_speed_points <- 5  # Минимальное количество точек с высокой скоростью подряд
speed_threshold <- 5        # Порог скорости в км/ч для определения начала катания

# Найдем все последовательности, где скорость превышает порог
high_speed_segments <- rle(ski_table$speed_kmh > speed_threshold)

# Отберем только последовательности, где достаточно точек подряд
valid_segments <- which(high_speed_segments$values & high_speed_segments$lengths >= min_high_speed_points)

# Найдем первый такой сегмент (начало катания)
if (length(valid_segments) > 0) {
  start_pos <- sum(high_speed_segments$lengths[1:(valid_segments[1]-1)]) + 1
  start_skiing_index <- start_pos
  start_skiing_time <- ski_table$time[start_skiing_index]
  start_skiing_point <- ski_table[start_skiing_index, ]
  
  cat("Начало катания определено в точке:", start_skiing_index, 
      "\nВремя:", format(start_skiing_time, "%H:%M:%S"), 
      "\nСкорость:", round(ski_table$speed_kmh[start_skiing_index], 1), "км/ч\n")
} else {
  stop("Не найдено подходящих сегментов с высокой скоростью")
}

# Сравниваем результаты двух методов
cat("Сравнение методов определения точки начала катания:\n")
cat("По среднему значению:", c(start_skiing_index, "точка - "), format(start_skiing_time, "%H:%M:%S"), "\n")
cat("По устойчивому ускорению:", c(start_skiing_index, "точка - "), format(start_skiing_time, "%H:%M:%S"))

#Итого: и первый, и второй способ дали одинаковые результаты!
#Начало первого круга - точка 94. Время: 14:09:03.

# Ищем конец кругов :) Лыжник мог ехать просто медленно устав, поэтому без среднего порога----------
# Ищем сразу порог через стабильное снижение скорости
# Уточненный анализ с устойчивым замедлением (без случайных вбросов и с устойчивым замедления движения)
min_low_speed_points <- 5  # Минимальное количество точек с низкой скоростью подряд
speed_threshold <- 5       # Тот же порог скорости

# Найдем все последовательности после начала катания, где скорость ниже порога
low_speed_segments <- rle(ski_table$speed_kmh[start_skiing_index:nrow(ski_table)] < speed_threshold)

# Отберем только последовательности, где достаточно точек подряд
valid_slow_segments <- which(low_speed_segments$values & low_speed_segments$lengths >= min_low_speed_points)

# Найдем первый такой сегмент после начала катания (окончание катания)
if (length(valid_slow_segments) > 0) {
  end_pos <- sum(low_speed_segments$lengths[1:(valid_slow_segments[1]-1)]) + start_skiing_index
  end_skiing_index <- end_pos
  end_skiing_time <- ski_table$time[end_skiing_index]
  end_skiing_point <- ski_table[end_skiing_index, ]
  
  cat("Окончание катания определено в точке:", end_skiing_index, 
      "\nВремя:", format(end_skiing_time, "%H:%M:%S"), 
      "\nСкорость:", round(ski_table$speed_kmh[end_skiing_index], 1), "км/ч\n")
} else {
  stop("Не найдено подходящих сегментов с низкой скоростью")
}

# Записываем время конца 2 круга (точка 701) - 15:03:48. Позже сравним визуально (вдруг подгон - наш лучший друг).
ski_table$speed_kmh[650:730]

# Поиск точки перехода-------------------------------------------------------
# Предлагаю находить точку перехода кругов, не просто деля пополам, а через геометрию (то есть точки наиближайшие к точкам начала и конца катания)
# Окончательный алгоритм поиска точки перехода между кругами (чисто геометрический)
find_circle_transition <- function(ski_table, start_index, end_index) {
  # Преобразуем в пространственный объект
  coords <- st_as_sf(ski_table, coords = c("lon", "lat"), crs = 32637)
  
  # 1. Разделяем маршрут на две равные части по времени
  time_diff <- as.numeric(ski_table$time[end_index] - ski_table$time[start_index])
  mid_time <- ski_table$time[start_index] + time_diff/2
  mid_index <- which.min(abs(as.numeric(ski_table$time - mid_time)))
  
  # 2. Определяем первый и второй круги
  first_circle <- coords[start_index:mid_index, ]
  second_circle <- coords[mid_index:end_index, ]
  
  # 3. Находим точку в конце первого круга, ближайшую к началу маршрута
  dist_to_start <- st_distance(first_circle, coords[start_index, ])
  end_first_circle_idx <- which.min(dist_to_start) + start_index - 1
  
  # 4. Находим точку в начале второго круга, ближайшую к концу маршрута
  dist_to_end <- st_distance(second_circle, coords[end_index, ])
  start_second_circle_idx <- which.min(dist_to_end) + mid_index - 1
  
  # 5. Точка перехода - середина между этими точками
  transition_index <- round((end_first_circle_idx + start_second_circle_idx)/2)
  
  # 6. Проверяем, чтобы точка была в разумных пределах
  min_valid_idx <- start_index + 0.2*(end_index - start_index)
  max_valid_idx <- start_index + 0.8*(end_index - start_index)
  
  if (transition_index < min_valid_idx | transition_index > max_valid_idx) {
    transition_index <- round((start_index + end_index)/2)
  }
  
  # Возвращаем результат
  list(
    point_id = ski_table$track_seg_point_id[transition_index],
    index = transition_index,
    time = ski_table$time[transition_index],
    lon = ski_table$lon[transition_index],
    lat = ski_table$lat[transition_index],
    dist_to_start = as.numeric(st_distance(coords[transition_index,], coords[start_index,])),
    dist_to_end = as.numeric(st_distance(coords[transition_index,], coords[end_index,]))
  )
}

transition <- find_circle_transition(ski_table, start_skiing_index, end_skiing_index)

# Вывод результатов
result <- paste(
  "\nРезультаты поиска точки перехода между кругами:\n",
  sprintf("%-25s: %d\n", "Номер точки", transition$point_id),
  sprintf("%-25s: %s\n", "Время", format(transition$time, "%H:%M:%S")),
  sprintf("%-25s: %.1f км/ч\n", "Скорость в точке", transition$speed),
  sprintf("%-25s: %.0f м\n", "Расстояние до старта", transition$dist_to_start),
  sprintf("%-25s: %.0f м\n", "Расстояние до конца круга", transition$dist_to_end),
  sprintf("%-25s: %.5f, %.5f\n", "Координаты (lon, lat)", transition$lon, transition$lat),
  sep = ""
)
cat(result) #точка 398 - переход Записываем 14:36:24

# Поиск точки максимального удаления от базы------------------------------------
find_max_distance_from_base <- function(ski_table) {
  # Преобразуем данные в пространственный объект
  coords <- st_as_sf(ski_table, coords = c("lon", "lat"), crs = 32637)
  
  # Базовая точка (первая точка маршрута)
  base_point <- coords[1, ] 
  # Вычисляем расстояния от всех точек до базы
  distances <- st_distance(coords, base_point)
  # Находим индекс точки с максимальным расстоянием
  max_dist_index <- which.max(distances)
  
  list(
    point_id = ski_table$track_seg_point_id[max_dist_index],
    index = max_dist_index,
    time = ski_table$time[max_dist_index],
    lon = ski_table$lon[max_dist_index],
    lat = ski_table$lat[max_dist_index],
    distance_from_base = as.numeric(distances[max_dist_index]),
    speed = ski_table$speed_kmh[max_dist_index]
  )
}

max_dist_point <- find_max_distance_from_base(ski_table)

# Вывод результатов
cat("\nТОЧКА МАКСИМАЛЬНОГО УДАЛЕНИЯ ОТ ПЕРВОЙ ТОЧКИ МАРШРУТА\n")
cat(sprintf("%-25s: %d\n", "Номер точки", max_dist_point$point_id))
cat(sprintf("%-25s: %s\n", "Время", format(max_dist_point$time, "%H:%M:%S")))
cat(sprintf("%-25s: %.1f км/ч\n", "Скорость", max_dist_point$speed))
cat(sprintf("%-25s: %.2f м\n", "Расстояние от базы", max_dist_point$distance_from_base))
cat(sprintf("%-25s: %.5f\n", "Долгота", max_dist_point$lon))
cat(sprintf("%-25s: %.5f\n", "Широта", max_dist_point$lat))

#Записываем максимальное удаление от базы: 764.38 м

# Определяем минимальную и максимальную высоту------------------
min_elevation <- min(ski_table$ele, na.rm = TRUE) #min - 191.1 м
max_elevation <- max(ski_table$ele, na.rm = TRUE) #max - 159.9 м

# Находим точки с экстремальными высотами
min_elev_point <- ski_table[which.min(ski_table$ele), ]
max_elev_point <- ski_table[which.max(ski_table$ele), ]

# Вывод результатов в консоль
cat("\nАНАЛИЗ ВЫСОТ МАРШРУТА\n")
cat(sprintf("%-30s: %.1f м\n", "Минимальная высота", min_elevation))
cat(sprintf("%-30s: %s (точка %d)\n", "Время минимальной высоты", 
            format(min_elev_point$time, "%H:%M:%S"), min_elev_point$track_seg_point_id))
cat(sprintf("%-30s: %.5f, %.5f\n", "Координаты мин. высоты", 
            min_elev_point$lon, min_elev_point$lat))
cat(sprintf("\n%-30s: %.1f м\n", "Максимальная высота", max_elevation))
cat(sprintf("%-30s: %s (точка %d)\n", "Время максимальной высоты", 
            format(max_elev_point$time, "%H:%M:%S"), max_elev_point$track_seg_point_id))
cat(sprintf("%-30s: %.5f, %.5f\n", "Координаты макс. высоты", 
            max_elev_point$lon, max_elev_point$lat))
cat(sprintf("\n%-30s: %.1f м\n", "Средняя высота", mean(ski_table$ele, na.rm = TRUE)))
cat(sprintf("%-30s: %.1f м\n", "Общий перепад высот", max_elevation - min_elevation))

#Средние скорости сегментов-------------------------------------
# 1. Определяем сегменты маршрута
# Имеем:
# - start_skiing_index (начало катания)
# - end_skiing_index (конец катания)
# - transition (точка перехода между кругами)
# - max_dist_point (макс. удаление от базы)

# Создаем колонку с типами сегментов
ski_table$segment <- "approach" # подход по умолчанию
ski_table$segment[start_skiing_index:end_skiing_index] <- "skiing"
ski_table$segment[(end_skiing_index+1):nrow(ski_table)] <- "return"

ski <- ski %>%
  mutate(
    speed_kmh = ski_table$speed_kmh,  # Добавляем скорость из ski_table
    special_point = case_when(
      track_seg_point_id == 1 ~ "start",
      track_seg_point_id == start_skiing_index ~ "ski_start",
      track_seg_point_id == transition$point_id ~ "transition",
      track_seg_point_id == end_skiing_index ~ "ski_end",
      track_seg_point_id == max_dist_point$point_id ~ "max_dist",
      track_seg_point_id == max(ski$track_seg_point_id) ~ "end",
      TRUE ~ NA_character_
    ))

# Рассчитываем средние скорости
mean_speeds <- list(
  approach = mean(ski_table$speed_kmh[1:(start_skiing_index-1)], na.rm = TRUE),
  skiing = mean(ski_table$speed_kmh[start_skiing_index:end_skiing_index], na.rm = TRUE),
  return = mean(ski_table$speed_kmh[(end_skiing_index+1):nrow(ski_table)], na.rm = TRUE),
  approach_return = mean(ski_table$speed_kmh[c(1:(start_skiing_index-1), (end_skiing_index+1):nrow(ski_table))], na.rm = TRUE)
)
  
# Карта градиента скоростей лыжника
ski_coords <- st_coordinates(ski) %>% as.data.frame()

ski_plot <- ski %>%
  st_drop_geometry() %>%
  select(-any_of(c("lon", "lat"))) %>%
  bind_cols(ski_coords) %>%
  rename(lon = X, lat = Y)

fig <- plot_ly() %>%
  add_trace(
    type = 'densitymapbox',
    data = ski_plot,
    lat = ~lat,
    lon = ~lon,
    z = ~speed_kmh,
    radius = 20,
    opacity = 0.7,
    coloraxis = 'coloraxis'
  ) %>%
  layout(
    mapbox = list(
      style = "open-street-map",
      center = list(lon = mean(ski_plot$lon, na.rm = TRUE),
                    lat = mean(ski_plot$lat, na.rm = TRUE)),
      zoom = 14
    ),
    coloraxis = list(
      colorscale = "Viridis",
      colorbar = list(title = "Скорость (км/ч)"),
      cmin = 0,
      cmax = 25
    ),
    title = "Градиент скоростей лыжного маршрута"
  )

fig

cat("\nАНАЛИЗ СЕГМЕНТОВ МАРШРУТА\n")
cat(sprintf("%-25s: %.1f км/ч\n", "Средняя скорость подхода", mean_speeds$approach))
cat(sprintf("%-25s: %.1f км/ч\n", "Средняя скорость катания", mean_speeds$skiing))
cat(sprintf("%-25s: %.1f км/ч\n", "Средняя скорость возврата", mean_speeds$return))
cat(sprintf("%-25s: %.1f км/ч\n", "Ср. скорость подход+возврат", mean_speeds$approach_return))

html_file <- file.path(dir, "map_fig.html")

# Рассчитываем длину каждого круга катания----------------------
# У нас уже есть:
# - start_skiing_index (начало катания)
# - transition$index (переход между кругами)
# - end_skiing_index (конец катания)

# Функция расчета длины сегмента
calculate_segment_length <- function(df, start_idx, end_idx) {
  # Преобразуем данные в sf-объект
  segment_sf <- st_as_sf(df[start_idx:end_idx, ], coords = c("lon", "lat"), crs = 32637)
  
  # Рассчитываем расстояния между последовательными точками
  distances <- st_distance(
    segment_sf, 
    lag(segment_sf), 
    by_element = TRUE
  )
  
  # Суммируем расстояния (исключая NA для первой точки)
  sum(as.numeric(distances), na.rm = TRUE)
}

# Проверяем и преобразуем данные в правильную CRS
if (!inherits(ski_table, "sf")) {
  ski_table_sf <- st_as_sf(ski_table, coords = c("lon", "lat"), crs = 32637)
} else {
  ski_table_sf <- st_transform(ski_table, 32637)
}

# Пересчитываем длины с правильной CRS
first_circle_length <- calculate_segment_length(ski_table, start_skiing_index, transition$index)
second_circle_length <- calculate_segment_length(ski_table, transition$index, end_skiing_index)
mean_circle_length <- mean(c(first_circle_length, second_circle_length))

# Вывод результатов (в метрах)
cat("\nДЛИНА КРУГОВ КАТАНИЯ\n")
cat(sprintf("%-30s: %.2f м\n", "Длина первого круга", first_circle_length))
cat(sprintf("%-30s: %.2f м\n", "Длина второго круга", second_circle_length))
cat(sprintf("%-30s: %.2f м\n", "Средняя длина круга", mean_circle_length))

# Обновляем визуализацию профиля
# Создаем данные для вертикальных линий на графике
vlines <- data.frame(
  x = c(ski_table$time[start_skiing_index], 
        ski_table$time[transition$index],
        ski_table$time[end_skiing_index]),
  label = c("Начало катания", "Переход", "Конец катания")
)

ggplot(ski_table, aes(x = time, y = ele)) +
  geom_line(color = "blue") +
  geom_vline(data = vlines, aes(xintercept = x), linetype = "dashed") +
  geom_text(data = vlines, aes(x = x, y = max(ski_table$ele), label = label),
            vjust = -0.5, hjust = 0.5, angle = 90) +
  labs(title = paste("Профиль высот с кругами катания",
                     "\nСредняя длина круга:", round(mean_circle_length), "м"),
       x = "Время",
       y = "Высота (м)") +
  theme_minimal()

#-------------------------------------Визуализация------------------------------------

# Визуализация
# Создаем базовый график маршрута
# Получаем координаты всех точек маршрута из объекта ski
if (F)
   png("key_points.png", width = 40, height = 20, units = "cm", res = 300, bg = "white")

plot(ski_table$lon, ski_table$lat, type = "l", col = "gray", 
     main = "Ключевые точки маршрута", xlab = "Долгота", ylab = "Широта")

# 1. Начало всего маршрута (первая точка, темно-зеленый квадрат)
points(ski_table$lon[1], ski_table$lat[1],  # Исправлено: lon и lat
       col = "darkgreen", pch = 15, cex = 1.5)

# 2. Конец всего маршрута (последняя точка, темно-синий квадрат)
points(ski_table$lon[nrow(ski_table)], ski_table$lat[nrow(ski_table)],  # Исправлено: lon и lat
       col = "darkblue", pch = 15, cex = 1.5)

# 3. Начало катания (ярко-зеленый круг)
points(ski_table$lon[start_skiing_index], ski_table$lat[start_skiing_index], 
       col = "green", pch = 16, cex = 1.5)

# 4. Точка перехода между кругами (красный круг)
points(transition$lon, transition$lat, 
       col = "red", pch = 16, cex = 1.5)

# 5. Конец катания (синий круг)
points(ski_table$lon[end_skiing_index], ski_table$lat[end_skiing_index], 
       col = "blue", pch = 16, cex = 1.5)

# 6. Точка максимального удаления от базы (фиолетовый треугольник)
points(max_dist_point$lon, max_dist_point$lat, 
       col = "purple", pch = 17, cex = 1.8)

# Улучшенная легенда
legend("bottomright", 
       legend = c("Начало всего маршрута", 
                  "Конец всего маршрута",
                  "Начало катания", 
                  "Переход между кругами", 
                  "Конец катания",
                  "Макс. удаление от базы"),
       col = c("darkgreen", "darkblue", "green", "red", "blue", "purple"), 
       pch = c(15, 15, 16, 16, 16, 17),
       pt.cex = 1.5,
       title = "Точки маршрута")
if (F)
   dev.off()

# Подготовка данных для 3D визуализации в UTM 32637
da <- ski_table %>%
  mutate(
    X = lon,  # Уже в метрах (UTM 37N)
    Y = lat,   # Уже в метрах (UTM 37N)
    z = ele,
    time_norm = as.numeric(time - min(time)),
    color = time_norm / max(time_norm),
    text = paste0(
      "Точка: ", track_seg_point_id, "<br>",
      "Координаты UTM37N: ", round(X), "E, ", round(Y), "N<br>",
      "Высота: ", round(z, 1), " м<br>",
      "Скорость: ", round(speed_kmh, 1), " км/ч<br>",
      "Время: ", format(time, "%H:%M:%S")
    )
  )

# Создаем 3D визуализацию с правильными подписями осей
s3d <- plot_ly(
  da,
  x = ~X,
  y = ~Y,
  z = ~z,
  type = 'scatter3d',
  mode = 'lines+markers',
  opacity = 1,
  hoverinfo = 'text',
  text = ~text,
  line = list(
    width = 4,
    color = ~color,
    colorscale = list(c(0, '#BA52ED'), c(1, '#FCB040')),
    reverscale = FALSE
  ),
  marker = list(
    size = 3,
    color = ~color,
    colorscale = list(c(0, '#BA52ED'), c(1, '#FCB040')),
    showscale = TRUE,
    colorbar = list(title = "Прогресс по времени")
  )
) %>%
  layout(
    title = "3D визуализация в UTM Zone 37N (EPSG:32637)",
    scene = list(
      xaxis = list(title = 'Восточная (Easting, м)'),
      yaxis = list(title = 'Северная (Northing, м)'),
      zaxis = list(title = 'Высота (м)'),
      camera = list(
        eye = list(x = 0.8, y = -1.8, z = 0.6),
        up = list(x = 0, y = 0, z = 1)
      ),
      aspectmode = 'data'  # Сохраняем реальные пропорции
    )
  )

# Добавляем ключевые точки с UTM-координатами
key_points <- list(
  list(index = 1, color = '#2E8B57', name = "Начало маршрута", symbol = 'diamond'),
  list(index = start_skiing_index, color = '#00FF00', name = "Начало катания", symbol = 'circle'),
  list(index = transition$index, color = '#FF0000', name = "Переход между кругами", symbol = 'x'),
  list(index = end_skiing_index, color = '#0000FF', name = "Конец катания", symbol = 'circle'),
  list(index = which.max(sqrt((ski_table$lon - ski_table$lon[1])^2 + 
                                (ski_table$lat - ski_table$lat[1])^2)), 
       color = '#9400D3', name = "Макс. удаление", symbol = 'triangle-up'),
  list(index = nrow(da), color = '#1E90FF', name = "Конец маршрута", symbol = 'diamond')
)

for (point in key_points) {
  s3d <- s3d %>%
    add_markers(
      data = da[point$index, ],
      x = ~X,
      y = ~Y,
      z = ~z,
      marker = list(
        size = 8,
        color = point$color,
        symbol = point$symbol,
        line = list(width = 1, color = '#000000')
      ),
      text = ~paste0(
        point$name, "<br>",
        "Координаты: ", round(X), "E, ", round(Y), "N<br>",
        "Высота: ", round(z, 1), " м"
      ),
      hoverinfo = 'text',
      name = point$name,
      showlegend = TRUE
    )
}

# Настройка легенды и аннотаций
s3d <- s3d %>%
  layout(
    legend = list(
      orientation = 'h',
      x = 0.5,
      y = 1.05,
      xanchor = 'center'
    ),
    annotations = list(
      text = paste0("Система координат: UTM Zone 37N (EPSG:32637)<br>",
                    "Все единицы в метрах"),
      x = 0.5,
      y = 0.01,
      showarrow = FALSE,
      xref = 'paper',
      yref = 'paper',
      font = list(size = 10)
    )
  )
s3d
# Сохранение с указанием CRS в имени файла
if (F)
   htmlwidgets::saveWidget(
     s3d, 
     file.path(dir, "3d_track_UTM37N.html"), 
     selfcontained = TRUE,
     title = "3D Track in UTM37N"
   )

#Bonus - hdop
summary(ski_table$hdop) #hdop - Horizontal Dilution of Precision в GPX-файлах

# Сначала извлечем координаты из sf-объекта
ski_coords <- st_coordinates(ski) %>% as.data.frame()
ski <- ski %>% 
  mutate(
    lon = ski_coords$X,
    lat = ski_coords$Y
  )

# Создаем цветовую палитру
pal_hdop <- colorNumeric(
  palette = "RdYlGn", 
  domain = ski$hdop,
  reverse = TRUE  # Лучшие значения (меньшие) будут зелеными
)

# Создаем карту HDOP
hdop_map <- leaflet(ski) %>%
  addTiles() %>%
  addCircles(
    lng = ~lon, 
    lat = ~lat,
    radius = ~sqrt(hdop)*10,  # Увеличиваем коэффициент для лучшей видимости
    stroke = FALSE,
    fillOpacity = 0.8,
    color = ~pal_hdop(hdop),
    popup = ~paste(
      "HDOP:", round(hdop, 1), "<br>",
      "Координаты: ", round(lon, 5), ", ", round(lat, 5), "<br>",
      "Время: ", format(time, "%H:%M:%S")
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal_hdop, 
    values = ~hdop,
    title = "HDOP (точность GPS)",
    labFormat = labelFormat(
      transform = function(x) sort(x, decreasing = TRUE)  # Сортировка от худшего к лучшему
    )
  ) %>%
  addControl(
    html = "<b>Интерпретация HDOP:</b><br>
           1-2: Отлично<br>
           2-5: Хорошо<br>
           5-10: Удовлетворительно<br>
           >10: Плохо",
    position = "topleft"
  )

hdop_map
if (F)
   htmlwidgets::saveWidget(
     hdop_map, 
     file.path(dir, "hdop_map.html"), 
     selfcontained = TRUE
   )

#-----------------------------Сохранение для QGIS + откат ----------------------------------
# if (!dir.exists(file.path(dir, "gis_data"))) { #папка
#   dir.create(file.path(dir, "gis_data"))
# }

# Изначальный вариант сохранения шэйпа
dst_shp <- file.path(dir, "./ski_track_points.shp")
sf::st_write(
  obj = ski_table,
  dsn = dst_shp,
  driver = "ESRI Shapefile",
  encoding = "UTF-8",
  delete_layer = TRUE  # Перезаписать существующие файлы .shp/.dbf и т.д.
)

# Убедимся, что объект является sf-объектом
if (!inherits(ski_table, "sf")) {
  ski_table <- st_as_sf(ski_table, coords = c("lon", "lat"), crs = 32637)
}

# Упростим имена столбцов для Shapefile
ski_QGIS <- ski_table %>%
  rename(
    seg_id = track_seg_point_id,
    elevation = ele,
    time_txt = time
  )

#Shapefile не поддерживает полноценный тип DateTime
#Вариант 2 сохранения шэйпов - время как текст по столбцам
ski_QGIS$time_txt <- format(ski_QGIS$time, "%Y-%m-%d %H:%M:%S")

# Добавляем отдельные колонки с датой и временем
ski_QGIS <- ski_table %>%
  mutate(date = as.Date(time),
         hour = format(time, "%H"),
         minute = format(time, "%M"),
         second = format(time, "%S"))

dst_shp <- file.path(dir, "./ski_track_points_time.shp")
           sf::st_write(
                        obj = ski_QGIS,
                        dsn = dst_shp,
                        driver = "ESRI Shapefile",
                        encoding = "UTF-8",
                        delete_layer = TRUE  # Перезаписать существующие файлы .shp/.dbf и т.д.
           )

test <- st_read(file.path(dir, "./ski_track_points_time.shp"))
print(colnames(test))  # Посмотрим имена полей
test[c("hour", "minute", "second")] %>% head()       # Проверим сохраненное время

# Сохранение в формате GeoJSON (оптимальный)
dst_geojson <- file.path(dir, "./ski_track_points.geojson")
sf::st_write(
  ski, 
  dsn = dst_geojson,
  delete_dsn = TRUE  # Перезаписать, если файл существует
)

dst_geojson <- file.path(dir, "./ski_track_points_utm37.geojson")
sf::st_write(
  ski_QGIS, 
  dsn = dst_geojson,
  delete_dsn = TRUE 
)


dst_geojson <- file.path(dir, "./ski_track_line.geojson")
sf::st_write(
  ski_track_37N, 
  dsn = dst_geojson,
  delete_dsn = TRUE 
)

#для отката
dst_gpx <- file.path(dir, "./ski_track_processed.gpx")
sf::st_write(
  ski,
  dsn = dst_gpx,
  layer = "track_points",  # Указываем слой
  dataset_options = "GPX_USE_EXTENSIONS=yes",  # Сохранить все поля
  delete_dsn = TRUE
)

list1 <- list.files(file.path(dir, "."), pattern = "\\.geojson$|\\.(|dbf|prj|shp|shx)$|\\.gpx$")
file.remove(list1)
