#' ---
#' echo: true
#' ---
#'
#+
library(sf)
library(s2)
library(terra)
library(tidyterra)
library(ggplot2)
library(ggrepel)

root <- "D:/users/platt/shapefile/auxiliary/naturalearth/5.1.2"

shpname <- file.path(root,"10m_physical","ne_10m_ocean.shp.zip")
ocean.sf <- sf::st_read(shpname)
sf::sf_use_s2(FALSE) ## После обрезки лучше включить обратно
australia <- sf::st_crop(ocean.sf, xmin=110, xmax=160, ymin=-45, ymax=-8) # обрезанный полигон океана

grat5 <- file.path(root,"10m_physical","ne_10m_graticules_5.shp.zip")
grat5.sf <- sf::st_read(grat5)
grat5_cropped<-sf::st_crop(grat5.sf, xmin=110, xmax=160, ymin=-45, ymax=-8)

rivers <- file.path(root,"10m_physical","ne_10m_rivers_lake_centerlines.shp.zip")
rivers.sf <- sf::st_read(rivers)
rivers_cropped<-sf::st_crop(rivers.sf, xmin=110, xmax=160, ymin=-45, ymax=-8)

lakes <- file.path(root,"10m_physical","ne_10m_lakes.shp.zip")
lakes.sf <- sf::st_read(lakes)
lakes_cropped<-sf::st_crop(lakes.sf, xmin=110, xmax=160, ymin=-45, ymax=-8)

states <- file.path(root,"10m_cultural","ne_10m_admin_1_states_provinces.shp.zip")
states.sf <- sf::st_read(states)
states_cropped<-sf::st_crop(states.sf, xmin=110, xmax=160, ymin=-45, ymax=-8)
states_scalerank3<-states_cropped[states_cropped$scalerank<"3",]
states_austr<-states_scalerank3[states_scalerank3$admin=="Australia",]
states_austr_state<-states_austr[states_austr$type=="State",]
states_austr_terr<-states_austr[states_austr$type=="Territory",]
state_northern<-states_austr_terr[states_austr_terr$name_ru=="Северная территория",]

cities <- file.path(root,"10m_cultural","ne_10m_populated_places.shp.zip")
cities.sf <- sf::st_read(cities)
cities_austr<-cities.sf[cities.sf$ADM0NAME=="Australia",]
cities_scalerank6<-cities_austr[cities_austr$SCALERANK<6,]

tifname<- file.path(root,"../../naturalearth.raster","NE1_LR_LC.tif")
file.exists(tifname)
physical <- raster::stack(tifname) |> as("SpatRaster")
phys_cropped<-crop(physical, ext(110, 160, -45, -8)) ## сперва обе координаты по x, потом по y

(state_size <- seq(7))
state_size[state_size>0]<-15
state_alpha<-state_size
state_alpha[state_alpha>0]<-0.6

(city_size <- seq(36))
city_size[city_size>0]<-12
city_alpha<-city_size
city_alpha[city_alpha>0]<-1

#######################

Australia1<-ggplot()+
scale_x_continuous(breaks=seq(110,160, by=5)) +
ggplot2::theme(
	legend.position="none",
	axis.text.x = element_text(size = 30),
	axis.text.y = element_text(size = 30),
	panel.grid = ggplot2::element_line(color = "darkgrey", linewidth=0.5, linetype = 1)) +
tidyterra::geom_spatraster_rgb(
  mapping=aes(),
  phys_cropped,
  interpolate = FALSE) +
geom_sf(data=australia, fill="lightblue") +
geom_sf(data=rivers_cropped, color="darkblue", size=0.2) +
geom_sf(data=lakes_cropped, fill="lightblue", size=0.2) +
geom_sf(data=states_cropped, fill=ggplot2::alpha("white", 0.05), color="#717171", linewidth=1) +
ggplot2::geom_sf(data=grat5_cropped, color="darkgrey", linewidth=0.5) +
ggplot2::geom_point(
	x=cities_scalerank6$LONGITUDE,
	y=cities_scalerank6$LATITUDE,
	data=cities_scalerank6,
	colour="black", size=10) +
ggplot2::geom_point(
	x=cities_scalerank6$LONGITUDE,
	y=cities_scalerank6$LATITUDE,
	data=cities_scalerank6,
	colour="red", size=8) +
ggrepel::geom_text_repel(
	x=c(states_austr_state$longitude, state_northern$longitude, cities_scalerank6$LONGITUDE),
	y=c(states_austr_state$latitude, state_northern$latitude, cities_scalerank6$LATITUDE),
	aes(label=c(states_austr_state$name_ru, "Северная Территория", cities_scalerank6$NAME_RU)),
	size=c(state_size, city_size), alpha=c(state_alpha, city_alpha))

##############################

ggsave(
"Australia4.png",
device="png",
plot=last_plot(),
path=NULL,
dpi=300, width=40, height=36)

#+
# browseURL("Australia4.png")
#+
knitr::include_graphics("Australia4.png")
#+
Australia1
