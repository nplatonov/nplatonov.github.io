#' ---
#' echo: true
#' ---
#'
#' Загружаем нужные библиотеки (нужно их предварительно установить через меню Packages)
library(sf)
library(tmap)
#' Прописываем папку, куда складываем все материалы с сайта Natural Earth
root="D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"
#' Загружаем провинции
provinces=ursa::spatial_read(file.path(root, "10m_cultural/ne_10m_admin_1_states_provinces.shp"))
#' Обрезаем провинции до вьетнамских широт...
provinces_VIE=provinces[provinces$latitude >= 0 & provinces$latitude <= 40, ]
#' ... и долгот
provinces_VIE=provinces[provinces_VIE$longitude >= 100 & provinces_VIE$longitude <= 115, ]
#' Переводим в изометрическую проекцию с провинциями только для Вьетнама
provinces_VIE_iso=provinces[provinces$iso_a2 == "VN", ]
#' Добавляем рифы (на данном участке геоданных их нет)
reefs=ursa::spatial_read(file.path(root, "10m_physical/ne_10m_reefs.shp"))
#' Добавляем дороги
roads=ursa::spatial_read(file.path(root, "10m_cultural/ne_10m_roads.shp"))
#' Добавляем моря
seas=ursa::spatial_read(file.path(root, "10m_physical/ne_10m_geography_marine_polys.shp"))
#' Добавляем реки
rivers_lakes=ursa::spatial_read(file.path(root, "10m_physical/ne_10m_rivers_lake_centerlines.shp"))
#' Включаем режим графика
tmap_mode("plot")
sf_use_s2(FALSE)
#' Увеличиваем лимит выдаваемых названий (во Вьетнаме 58 провинций и 5 городов центрального подчинения, итого 63)
tmap_options(max.categories = 63)
#' Единая строка со всеми данными (по каким-то причинам при попытке переноса на следующую строку выдаёт ошибку е2)
tm_shape(provinces_VIE_iso)+
      tm_fill(col = "name", alpha = 0.8, legend.show = FALSE)+
      tm_polygons(col = "white", alpha = 0.1, legend.show = FALSE)+
      tm_text("name_en",size = 0.25, alpha = 0.6)+
   tm_shape(seas)+
      tm_fill(col = "blue", alpha = 0.2, legend.show = FALSE)+
      tm_text("name_en", col = "white", alpha = 0.6, size = 0.4, ymod = -0.6)+
   tm_shape(roads)+
      tm_lines(col = "black", alpha = 0.2)+
   tm_shape(reefs)+
      tm_lines(col = "blue", alpha = 0.7)+
   tm_shape(rivers_lakes)+
      tm_lines(col = "blue",alpha = 0.2)+
   tm_compass(type = "8star", size = 0.8, text.size = 0.5, show.labels = 2, position=c(0.8, 0))+
      tm_grid(alpha = 0.6)+
      tm_scale_bar(text.size = 15, width = 0.15, lwd = 0.25, position = c(0.016, 0.015))
#' Часть диакритических знаков вьетнамской латиницы компьютер не видит. Кириллицу тоже отображать отказался
#' Увеличить размер шрифта в шкале масштаба не удалось, как и сдвинуть км относительно координатной сетки
#' Название моря на юго-западе сдвинуть не удалось
#'
#' :::comment
#' Ещё одно сообщение:
#' ```
#' Error: no layer elements defined after tm_shape
#' ```
#' :::
