########## HOMEWORK ##############
require(sf)
require(adehabitatLT)
require(mapview)
gpx_data <- st_read("2022-01-09_14-00_Sun.gpx", layer = "track_points") 
head(gpx_data)
gpx_data$time

# создаём обьект линейной траектории
trek <- as.ltraj(st_coordinates(gpx_data)  
         ,date=gpx_data$time
         ,id=1
         ,proj4string=sp::CRS(st_crs(gpx_data)$proj4string))
trek
ld(trek) # get dataframe
plot(trek)
summary(trek)
hist(trek, "dt", freq = TRUE) # dTime
hist(trek, "dist", freq = TRUE) # dDist

lv_trek <- lavielle(trek, Lmin=5, Kmax=6, type="mean") # ищем идеальное разбиение
chooseseg(lv_trek) # количество сегментов
path_trek <- findpath(lv_trek, 3) # разбиение на сегменты!!!

plot(path_trek)

base::plot(path_trek[1]) # иду на трек
plot(path_trek[2]) # 2 круга бегаю
plot(path_trek[3]) # устал
plotltr(trek, "dist")


### Visualisation #####
# Convert ltraj to a data frame
df <- ld(path_trek)

# Convert to sf points object first
trek_point_sf <- st_as_sf(df, coords = c("x", "y"), crs = 4326)  # Adjust coords and CRS as needed
print(trek_point_sf)
# convert sf point to three sf lines
trek_lines_sf <- st_cast(summarise(group_by(trek_point_sf, burst), do_union = F), "LINESTRING")

# to compute length of each
lengths_m <- st_length(trek_lines_sf)
print(lengths_m)  # Length in meters

library(maptiles)  # For basemap tiles
# Download basemap tiles (e.g., OpenStreetMap)
# загружаем баземап и обрезаем
trek_ext <- st_bbox(trek_point_sf) + c(-0.001, -0.001, 0.001, 0.001)
basemap <- get_tiles(trek_ext, provider = "OpenStreetMap", crop = TRUE, zoom = 16)

# Plot basemap and points
plot(basemap, axes = TRUE)  # Base map with axes
# Define colors for the 3 lines
colors <- c("blue", "green", "orange")  # One color per line
# Plot the lines with different colors
plot(trek_lines_sf$geometry, add = TRUE, col = colors, lwd = 3)
plot(trek_point_sf$geometry, add = TRUE, col = "red", pch = 16, cex = 1)  # Add points


## mapview visualisation ###
loc <- trek_lines_sf
'plottraj' <- function(lt,desc=c("burst", "id")) {
  desc <- match.arg(desc)
  lt <- na.omit(lt)
  id <- sapply(lt,attr,desc)
  bt_loc <- st_as_sf(ld(lt),coords=c("x","y"),crs=st_crs(loc)
  )[c(desc,"date")]
  bt_ext <- by(st_geometry(bt_loc),bt_loc[[desc]],function(x) {
    st_sf(onset=c("begin","end")
          ,geometry=rbind(head(x,1),tail(x,1)))
  })
  bt_ext <- do.call(rbind,bt_ext)
  st_crs(bt_ext) <- st_crs(bt_loc)
  xy <- lapply(lt,function(obj) {
    as.matrix(obj[,c("x","y")]) |> st_linestring()
  })
  bt_track <- st_sf(dummy=id,geometry=st_sfc(xy,crs=st_crs(loc)))
  colnames(bt_track)[grep("dummy",colnames(bt_track))] <- desc
  with(list(loc=bt_loc,track=bt_track,ext=bt_ext)
       ,mapview(ext,zcol="onset",cex=6,layer="Period"
                ,col.regions=c("blue","red"),legend=F,home=F)+
         mapview(track,layer="Track",zcol=desc,home=F,legend=F)+
         mapview(loc,zcol=desc,layer="Locations",cex=3,home=T,label="date")
  )
}
(m1 <- plottraj(path_trek,"burst"))


### ищем характеристики двух кругов ##
# этот тупой пакет для анализа треков ничего не может!!!!
# нужно всё переводить в сф блин, нахер он нужен тогда вообще
df2 <- ld(path_trek[2])
round1 <- df2[1:300,] # на глазок первый круг

# Convert to sf object first
trek_point_sf <- st_as_sf(round1, coords = c("x", "y"), crs = 4326) 
plot(trek_point_sf)
sf_line <- st_sf(st_cast(st_combine(trek_point_sf$geometry), "LINESTRING"), crs = st_crs(trek_point_sf))
plot(sf_line)
st_length(sf_line)
