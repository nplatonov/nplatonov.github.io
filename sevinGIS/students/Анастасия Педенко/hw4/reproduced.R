#' ---
#' echo: true
#' ---
#+
library(sf)
library(tmap)
library(ggplot2)
plutil::pluglibrary(ggrastr,dependencies=TRUE)
#подключаем пакеты 

# Указываю с данными Natural Earth, они у меня в разных папках поэтому указываю 2 пути

root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"


# Загружаю данные о странах,провинциях, реках и городов
countries <- ursa::spatial_read(file.path(root, "10m_cultural" ,"ne_10m_admin_0_countries.shp"))
states <- ursa::spatial_read(file.path(root, "10m_cultural", "ne_10m_admin_1_states_provinces.shp"))
rivers <- ursa::spatial_read(file.path(root, "10m_physical", "ne_10m_rivers_lake_centerlines.shp"))
cities <- ursa::spatial_read(file.path(root, "10m_cultural", "ne_10m_populated_places_simple.shp"))

# Фильтрую данные для Австралии, указывая нужный атриюут в табличке

australia <- countries[countries$NAME == "Australia", ]
australian_states <- states[states$admin == "Australia", ]
#australian_rivers <- rivers[rivers$ == , ] не знаю каким образом отфильтровать реки
australian_cities <- cities[cities$adm0name == "Australia", ]
australian_capital <- australian_cities [australian_cities$featurecla == "Admin-1 capital",]

# Добавляю русские названия для штатов и городов
state_labels <- data.frame(
  name = c("New South Wales", "Victoria", "Queensland", "South Australia", "Western Australia", "Tasmania", "Northern Territory", "Australian Capital Territory"),
  label = c("Новый Южный Уэльс", "Виктория", "Квинсленд", "Южная Австралия", "Западная Австралия", "Тасмания", "Северная территория", "Австралийская столичная территория"),
  stringsAsFactors = FALSE
)

city_labels <- data.frame(
  name = c("Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Hobart", "Darwin", "Canberra"),
  label = c("Сидней", "Мельбурн", "Брисбен", "Перт", "Аделаида", "Хобарт", "Дарвин", "Канберра"),
  stringsAsFactors = FALSE
)
# соединяю ру названия для штатов и городов с их английскими значениями
australian_states <- merge(australian_states, state_labels, by.x = "name", by.y = "name", all.x = TRUE)
australian_cities <- merge(australian_cities, city_labels, by.x = "name", by.y = "name", all.x = TRUE)


ggplot() +
  geom_sf(data = australian_states, aes(fill = name), color = "black") +
  scale_fill_manual(values = c("New South Wales" = "#FFDEAD", "Victoria" = "#EE82EE",
                               "Queensland" = "#FF6347", "South Australia" = "#9ACD32",
                               "Western Australia" = "#FFD700", "Tasmania" = "#00CED1",
                               "Northern Territory" = "#20B2AA", "Australian Capital Territory" = "#DC143C")) +
  geom_sf_text(data = australian_states, aes(label = label), ize = 5, color = "black", family = "serif", hjust = 0.5, vjust = 0, check_overlap = TRUE) +
  geom_sf(data = australian_capital, color = "red", size = 2) +
  geom_sf_text(data = australian_cities, aes(label = label), size = 3, color = "black", family = "serif", hjust = 1, vjust = 1, check_overlap = TRUE) +
  ggtitle("Австралия") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),  # Центрирование заголовка
    legend.position = "none"  # Расположение легенды
  ) 

#_______________________________________________________________
# Визуализация с использованием tmap, "включаем" 
tmap_mode("view")

# Добавляю русские названия для столиц для tmap?
capitals <- data.frame(
  state = c("New South Wales", "Victoria", "Queensland", "South Australia", "Western Australia", "Tasmania", "Northern Territory", "Australian Capital Territory"),
  capital = c("Сидней", "Мельбурн", "Брисбен", "Аделаида", "Перт", "Хобарт", "Дарвин", "Канберра"),
  lat = c(-33.8688, -37.8136, -27.4698, -34.9285, -31.9505, -42.8821, -12.4634, -35.2809),
  lon = c(151.2093, 144.9631, 153.0251, 138.6007, 115.8605, 147.3272, 130.8456, 149.1300)
)
# Преобразу. столицы в sf объект для tmap
capitals_sf <- st_as_sf(capitals, coords = c("lon", "lat"), crs = 4326)

#  не выходит наслаивать объекты без перекрытия...даже если ставить +
tm_shape(australia) + tm_polygons(col = "black", fill.legend = tm_legend_hide)
tm_shape(australian_states) + tm_polygons(col = "black", fill.legend = tm_legend_hide)
tm_shape(capitals_sf) + tm_dots(col = "red", size = 0.4) 

#стилистику текста настроить, пыталась сделать обводку через halo - не вышло

#для публикации - это только через tmap???
#fileout4 <- "assets/general/firstmap.png"
#if (!dir.exists(dirname(fileout4)))
#  dir.create(dirname(fileout4),recursive=TRUE)
#png(fileout4, res=300, width=1600, height=1200,
#   type="cairo", pointsize=12, family="sans")
#print(tm1)
#dev.off()
