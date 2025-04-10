library(terra)
library(sf)
library(s2)
#Загрузка данных 
cont_shape<-st_read("C:/Jane/Учёба/ГИСы/110m_physical/ne_110m_coastline.shp")
st_agr(cont_shape) = "constant"
cities<-st_read("C:/Jane/Учёба/ГИСы/110m_cultural/ne_110m_populated_places.shp")
st_agr(cities)="constant"
adm_bound<-st_read("C:/Jane/Учёба/ГИСы/50m_cultural/ne_10m_admin_1_sel.shp")
st_agr(adm_bound)= "constant"
adm_names<-st_read("C:/Jane/Учёба/ГИСы/10m_cultural/ne_10m_admin_1_states_provinces.shp")
st_agr(adm_names)= "constant"
filling<-raster::stack("C:/Jane/Учёба/ГИСы/HYP_HR_SR_OB_DR.tif")|> as("SpatRaster")


#Обрезка 
cont_austr<-sf::st_crop(cont_shape, xmin = 105.83, ymin = -47.53, 
                        xmax = 160.56, ymax = -9)
cities_austr<-sf::st_crop(cities, xmin = 105.83, ymin = -47.53, 
                          xmax = 160.56, ymax = -15)
adm_bound_austr<-sf::st_crop(adm_bound, xmin = 105.83, ymin = -47.53, 
                          xmax = 160.56, ymax = -9)
sf_use_s2(FALSE)
adm_names_austr<-sf::st_crop(adm_names, xmin = 105.83, ymin = -47.53, 
                             xmax = 160.56, ymax = -15)

adm_names_austr_main<-(adm_names_austr[-c(6,9,11),])
sf_use_s2(TRUE)
filling_austr<-crop(filling, ext(95,180,-50,0))

#отрисовка 
library(tmap)
tmap_mode("plot")
aust_map<-tm_shape(filling_austr,crs=3112, bbox=c(xmin=110,xmax=160,ymin=-45,ymax=-10))+ tm_rgb()+
  tm_shape(cont_austr, crs=3112)+tm_lines(cont_austr, col="black")+
  tm_shape(adm_names_austr_main,crs=3112, bbox=c(xmin=110,xmax=160,ymin=-45,ymax=-10))+tm_polygons(fill=NULL)+tm_text(text="name_ru",col="red", size=0.5, just="center")+
  tm_shape(cities_austr,crs=3112, bbox=c(xmin=110,xmax=160,ymin=-45,ymax=-10))+tm_dots(cities_austr,fill="black")+tm_text(text="NAME_RU",size =0.5, xmod=2.3)+
  tm_shape(adm_bound_austr,crs=3112, bbox=c(xmin=110,xmax=160,ymin=-45,ymax=-10))+tm_lines(adm_bound_austr, col="red")+
  tm_graticules(col="gray", alpha=0.5)+
  tm_scalebar(position = c("left","bottom"))

#Вывод результата
fileout <- "C:/Jane/Учёба/ГИСы/aust_map.png"
if (!dir.exists(dirname(fileout)))
  dir.create(dirname(fileout),recursive=TRUE)
png(fileout, res=300, width=1600, height=1200,
    type="cairo", pointsize=12, family="sans")
print(aust_map)
dev.off()
