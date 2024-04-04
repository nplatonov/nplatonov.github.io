# (!) - означает, что что-то не получилось
library(sf)
library(tmap)

# root <- "/Users/nataliasopilko/Desktop/SIEE/Aspirantura/QGIS_class/Rgis/0229class/hw_Sopilko_Australia" 
root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"

#Скачиваем исходные данные из папки
# provinces <- sf::st_read(file.path(root, "ne_10m_admin_1_states_provinces/ne_10m_admin_1_states_provinces.shp"))
provinces <- ursa::spatial_read(file.path(root,"10m_cultural/ne_10m_admin_1_states_provinces.shp"))
  ##вырезаем данные, касаемые только Австралии + Север (если лишнее -- взять _iso)
  prov_AU <- provinces[provinces$latitude >= -50 & provinces$latitude <= -5, ]
  prov_AU <- prov_AU[prov_AU$longitude >= 110 & prov_AU$longitude <= 160, ]
  ##Внутри госудраства Австралия
  prov_AU_iso <- provinces[provinces$iso_a2 == "AU", ]
  ##Исключим Macquarine island из-за его отдалённости от материковой Австралии
  prov_AU_iso_MI <- prov_AU_iso[prov_AU_iso$name != "Macquarie Island",]
# places <- sf::st_read(file.path(root, "ne_10m_populated_places/ne_10m_populated_places.shp"))
places <- ursa::spatial_read(file.path(root,"10m_cultural/ne_10m_populated_places.shp"))
  #Места в Австралии
  places_AU <- places[places$SOV0NAME == "Australia", ]
  ##Столицы штатов
  places_AU_cap <- places_AU[places_AU$FEATURECLA == "Admin-1 capital" | places_AU$FEATURECLA == "Admin-0 capital", ]
##~ reefs <- sf::st_read(file.path(root, "ne_10m_reefs/ne_10m_reefs.shp"))
##~ sea <- sf::st_read(file.path(root, "ne_10m_geography_marine_polys/ne_10m_geography_marine_polys.shp")) 
##~ rivers <- sf::st_read(file.path(root, "ne_10m_rivers_australia/ne_10m_rivers_australia.shp"))
reefs <- ursa::spatial_read(file.path(root,"10m_physical/ne_10m_reefs.shp"))
sea <- ursa::spatial_read(file.path(root,"10m_physical/ne_10m_geography_marine_polys.shp")) 
rivers <- ursa::spatial_read(file.path(root,"10m_physical/ne_10m_rivers_australia.shp"))
#Создаём карту
tmap_mode("plot")
sf_use_s2(FALSE) #иначе ошибка при добавдении моря
tm_shape(prov_AU_iso_MI) +
  tm_polygons(col = "white", legend.show = FALSE) +
  #Добавим моря
  tm_shape(sea) +
  tm_fill(col = "lightblue", alpha = 0.5) +
  #реки
  tm_shape(rivers) +
  tm_lines(col = "blue", alpha = 0.3) +
  #задаем названия штатов
  tm_shape(prov_AU_iso) +
  tm_fill(col = "name", alpha = 0.4, legend.show = FALSE) +
  tm_text("name", size = "AREA") +
  tm_layout(fontface = "bold", between.margin=9) + #(!) не получилось добавить белую обводку
  tm_borders(col="black", alpha = 0.01) +
    #добавим столицы штатов
    tm_shape(places_AU_cap) +
    tm_dots(group ="NAME", size = .1, alpha = 0.9) +
    tm_text("NAME",
            size =0.7,  remove.overlap = T, xmod = -.2, ymod =-.5,
            just = "left",
            fontface = "bold", fontfamily = "serif"
            ) + #(!) не получилось изменить шрифт и его font face 
  tm_legend()+
  #добавим рифы
  tm_shape(reefs) +
  tm_lines(col="black", alpha = 0.5) +
  #красота
  tm_scale_bar(position = c("left", "bottom"), lwd = 1) + #(!) не получается оторвать числа от шкаты
  tm_compass(position=c("right","bottom")) +
  tm_graticules(alpha = 0.15)
