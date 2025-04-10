library(terra)
library(sf)
library(s2)
#Загрузка данных 
root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"
cont_shape <- st_read(file.path(root,"110m_physical","ne_110m_coastline.shp.zip"))
cities <- st_read(file.path(root,"110m_cultural","ne_110m_populated_places.shp.zip"))
adm_bound <- st_read(file.path(root,"50m_cultural","ne_10m_admin_1_sel.shp.zip"))
adm_names <- st_read(file.path(root,"10m_cultural","ne_10m_admin_1_states_provinces.shp.zip"))
filling<-raster::stack(file.path(root,"../../naturalearth.raster","HYP_HR_SR_OB_DR.tif")) |> as("SpatRaster")


#Обрезка 
cont_austr<-sf::st_crop(cont_shape, xmin = 105.83, ymin = -47.53, 
                        xmax = 160.56, ymax = -9)
cities_austr<-sf::st_crop(cities, xmin = 105.83, ymin = -47.53, 
                          xmax = 160.56, ymax = -9)
adm_bound_austr<-sf::st_crop(adm_bound, xmin = 105.83, ymin = -47.53, 
                          xmax = 160.56, ymax = -9)
sf_use_s2(FALSE)
adm_names_austr<-sf::st_crop(adm_names, xmin = 105.83, ymin = -47.53, 
                             xmax = 160.56, ymax = -15)

adm_names_austr_main<-(adm_names_austr[-c(6,9,11),])
sf_use_s2(TRUE)
filling_austr<-crop(filling, ext(105.83,160.56,-47.53,-9))

#отрисовка 
library(tmap)
tmap_mode("plot")
aust_map<-tm_shape(cont_austr)+tm_lines(cont_austr, col="black")+
  tm_shape(filling_austr)+ tm_rgb()+
  tm_shape(adm_names_austr_main)+tm_polygons(fill=NULL)+tm_text(text="name_ru",col="red", size=0.5, just="center")+
  tm_shape(adm_bound_austr)+tm_lines(adm_bound_austr, col="red")+
  tm_shape(cities_austr)+tm_dots(cities_austr,fill="black")+tm_text(text="NAME_RU",size =0.5, xmod=2.3)+
  tm_graticules(col="gray", alpha=0.5)+
  tm_scalebar(position = c("left","bottom"))

#Вывод результата
fileout <- "aust_map_reproduced.png"
if (!dir.exists(dirname(fileout)))
  dir.create(dirname(fileout),recursive=TRUE)
png(fileout, res=300, width=1600, height=1200,
    type="cairo", pointsize=12, family="sans")
print(aust_map)
dev.off()

#extention
#xmin 105.83
#xmax 160.56
#ymin -47.53
#ymax -9

knitr::include_graphics(fileout)
