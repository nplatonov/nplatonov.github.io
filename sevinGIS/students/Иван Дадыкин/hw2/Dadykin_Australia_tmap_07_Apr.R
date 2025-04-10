library(sf)
library(s2)
library(terra)
library(raster)
library(tmap)

# Операции с вектором океана
australia<-sf::st_read("D:/GIS/27_Feb/ne_10m_ocean/ne_10m_ocean.shp")
st_agr(australia) = "constant"
sf::sf_use_s2(FALSE)
australia_cr<-sf::st_crop(australia, xmin = 100, ymin = -55, xmax = 170, ymax = -2)
australia_3112 <- st_transform(australia_cr, crs = "EPSG:3112")
st_crs(australia_3112) # Это будет слой, который мы визуализируем на карте

xmin <- st_bbox(australia_3112)["xmin"]
xmax <- st_bbox(australia_3112)["xmax"]
ymin <- st_bbox(australia_3112)["ymin"]
ymax <- st_bbox(australia_3112)["ymax"]

xmin_new <- as.numeric(xmin + (xmax - xmin) * 0.2)
xmax_new <- as.numeric(xmax - (xmax - xmin) * 0.22)
ymin_new <- as.numeric(ymin + (ymax - ymin) * 0.2)
ymax_new <- as.numeric(ymax - (ymax - ymin) * 0.12)

st_agr(australia_3112) = "constant"
australia_3112_cr<-sf::st_crop(australia_3112, xmin=xmin_new, ymin=ymin_new, xmax=xmax_new, ymax=ymax_new) # Это будет слой, задающий охват карты

# Прочие векторные слои
rivers.sf<-sf::st_read("D:/GIS/27_Feb/ne_10m_rivers_lake_centerlines/ne_10m_rivers_lake_centerlines.shp")
rivers.sf <- rivers.sf[st_is_valid(rivers.sf),]
st_agr(rivers.sf) = "constant"
rivers_cr<-sf::st_crop(rivers.sf, xmin=xmin_new, ymin=ymin_new, xmax=xmax_new, ymax=ymax_new)

lakes<-sf::st_read("D:/GIS/Australia_06_march/ne_10m_lakes/ne_10m_lakes.shp")
lakes.sf <- lakes[st_is_valid(lakes),]
st_agr(lakes.sf) = "constant"

# Фильтрация регионов
states.sf<-sf::st_read("D:/GIS/Australia_06_march/ne_10m_admin_0_states_provinces/ne_10m_admin_1_states_provinces.shp")
states.sf$name_ru <- as.character(states.sf$name_ru)
states.sf$name_ru <- trimws(states.sf$name_ru)
states <- states.sf[!is.na(states.sf$name_ru) & states.sf$name_ru != "", ]
state.au <- states[states$admin == "Australia", ]
state.st <- state.au[state.au$type == "State", ]
state.tr <- state.au[state.au$type == "Territory" & state.au$name== "Northern Territory", ]
states.au <- rbind(state.st, state.tr)
table(states.au$name_ru, useNA = "ifany") # Проверяем, что не осталось NA

# Фильтрация городов
cities.sf<-sf::st_read("D:/GIS/Australia_06_march/ne_10m_populated_places/ne_10m_populated_places.shp")
cities.au<-cities.sf[cities.sf$ADM0NAME=="Australia",]
cities.cap<-cities.au[cities.au$SCALERANK<4,]

# Операции с растром
physical<-raster::stack("D:/GIS/Australia_06_march//NE2_50M_SR/NE2_50M_SR.tif")|> as("SpatRaster")
phys_cropped<-crop(physical, ext(110, 160, -45, -8)) # Обрежем, чтобы быстрее перепроецировалось
phys_cropped_albers<-terra::project(phys_cropped, "+init=epsg:3112")

# Визуализация
tmap_mode("plot")
dev.new(width = 8, height = 8, unit = "in")

(tm1<-tm_shape(australia_3112_cr) +
tm_shape(phys_cropped_albers) +
	tm_rgb() +
tm_shape(australia_3112) +
	tm_polygons(fill="lightblue") +
tm_shape(rivers.sf) +
	tm_lines(col="darkblue")+
tm_shape(lakes.sf) +
	tm_polygons(fill="lightblue") +
tm_shape(states.au) +
	tm_borders(col="#600c1a", lwd=0.5) +
	tm_text(text="name_ru", size=0.8, col="#595959")+
tm_shape(cities.cap) +
	tm_symbols(cities.cap, size=0.4, lwd=1, fill="black") +
	tm_symbols(cities.cap, size=0.38, lwd=1, fill="orange") +
	tm_text(text="NAME_RU", size=0.5, xmod=0.48, ymod=-0.77, col="white") +
	tm_text(text="NAME_RU", size=0.5, xmod=0.5, ymod=-0.7, col="black") +
tm_scalebar(position=c("left", "bottom")) +
tm_graticules(lwd=0.5, alpha=0.7, col="black")+
tm_layout()
)

fileout <- "D:/GIS/Australia_06_march/australia_tmap_07_Apr_5.png"
if (!dir.exists(dirname(fileout)))
  dir.create(dirname(fileout),recursive=TRUE)
png(fileout, res=300, width=1600, height=1200,
    type="cairo", pointsize=10, family="arial")
print(tm1)
dev.off()
