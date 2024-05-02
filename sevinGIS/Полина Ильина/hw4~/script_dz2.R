library(sf)
library(sp)
library(ggplot2)

root<-getwd()
list.files()
baikal_polygon<- sf::st_read("baikal_polygon.shp")
land<- sf::st_read("ne_10m_admin_1_states_provinces.shp")
river<-sf::st_read("rivers.shp")
sf_use_s2(FALSE)
land_lables<- sf::st_read("ne_10m_admin_1_label_points_details.shp")
land_lables_crop<-st_crop(land_lables, xmin=100, ymin=49, xmax=116, ymax=60)
land_crop<-st_crop(land, xmin=100, ymin=49, xmax=116, ymax=60)
baikal_main_points<-sf::st_read("baikal_main_points.shp")

ggplot()+
  geom_sf(data=land_crop, fill=land_crop$mapcolor9,alpha = 0.5)+
  geom_sf(data=river, col="#0099FF", linewidth = 0.2)+
  geom_sf_text(data = land_lables_crop, mapping = aes (label = name_ru),
                                                         size = 4)+
  geom_sf(data=baikal_polygon,fill="#3399CC",col="black", linewidth = 0.3)+
  geom_sf_text(data=baikal_main_points, mapping = aes (label = name),
               size = 2)+
  xlim (103,112)+ylim(50,57)



