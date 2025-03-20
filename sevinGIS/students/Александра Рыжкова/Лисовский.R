Вот код как итоговая работа, что на выходе примерно должны были получить
library(sp)
library(raster)
library(sf)
library(maxnet) 
library(stringr)
library(ENMeval)
library(rgeos)
library(RStoolbox)
library(ncf)
library(spdep)
library(dismo)
library(rgdal)
library(terra)
library(ecospat)
library(rJava)

base_dir <- "C:/abc/"
csv.file <- "Martes_martes.csv"
# bias.file <- "bias.csv" ## extra file
env.file <- list.files(
  path = "C:/abc/layers/",
  pattern = ".asc$",
  full.names = T,
  include.dirs = F
)
prj              <- CRS(
  "+proj=moll +lon_0=30 +x_0=3335846.22854 +y_0=-336410.83237 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
)
prj_ll           <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

csv.dat          <- read.csv(paste(base_dir, csv.file, sep = ""))
csv.spp          <- SpatialPoints(cbind(csv.dat[, 1], csv.dat[, 2]), prj)

model.name       <- csv.dat[1,3]

env.stack        <- lapply(env.file,raster)
env.stack        <- stack(env.stack)
crs(env.stack)   <- prj
one.ras          <- env.stack[[1]]/env.stack[[1]]

#plot(env.stack) #визуализация слоёв

#Создание SpatialPointsDataFrame для sp1
sp1 <- SpatialPointsDataFrame(csv.spp, data.frame(species = rep(model.name, length(csv.spp))))

# Разделение точек на две группы
num_points <- length(csv.spp)
half_points <- floor(num_points / 2)

# Создание SpatialPointsDataFrame для sp2
sp2_points <- shift(csv.spp[1:half_points], 10000, 10000)
sp2_data <- data.frame(species = rep('test', half_points))
sp2 <- SpatialPointsDataFrame(sp2_points, sp2_data)

# Создание SpatialPointsDataFrame для sp3
sp3_points <- shift(csv.spp[(half_points + 1):num_points], -100000, -80000)
sp3_data <- data.frame(species = rep('test', num_points - half_points))
sp3 <- SpatialPointsDataFrame(sp3_points, sp3_data)

# Присвоение имен столбцам
names(sp1@data) <- 'species'
names(sp2@data) <- 'species'
names(sp3@data) <- 'species'


bias.spp         <- rbind(sp1,
                         sp2,
                         sp3)

plot(one.ras)
plot(bias.spp, add=T)

#обрезаем точки по данным растров
csv.out          <- extract(one.ras, csv.spp)
csv.spp          <- csv.spp[which(csv.out>0)]
plot(one.ras)
plot(csv.spp, add=T)

bias.out        <- extract(one.ras, bias.spp)
bias.spp        <- bias.spp[which(bias.out>0),]
plot(one.ras)
plot(bias.spp, add=T)

#исключаем обучающую выборку из фона
one.ras[cellFromXY(one.ras, csv.spp@coords)] <- NA
#еще умнее исключить не обучающую выборку, а все точки находок

#создаём фоновую выборку
buffer.val       <- c(200)
range.buf        <- 50000
cut.buf          <- 700000
bias.range       <- 0.5000

bias.buf         <- buffer(bias.spp, width=buffer.val, dissolve=F)

plot(one.ras)
plot(bias.buf, add = T) # добавление на карту созданных буферов на карту

bias_strict.buf  <- buffer(bias.spp[which(bias.spp$species == model.name),], width=range.buf)

crop.buf         <- buffer(SpatialPoints(csv.spp), width=cut.buf)
one.ras          <- one.ras*0.01
one.ras          <- rasterize(crop.buf, one.ras, 1, update = T, updateValue = '!NA')
bg.ras           <- rasterize(bias.buf, one.ras, "species", fun='count', update = T, updateValue = '!NA')
bg2.ras          <- rasterize(bias.buf, one.ras, "species",
                              fun=function(x,...){length(unique(x))}, update = T, updateValue = '!NA')
bg3.ras          <- rasterize(bias_strict.buf, one.ras, field=bias.range, update = T, updateValue = '!NA')
bg.ras           <- bg3.ras*log(bg.ras*0.1 + bg2.ras)
plot(bg.ras)

bg.ras[which(values(bg.ras)<0)] <- 0
bg.num           <- 10000

bg               <- as.data.frame(randomPoints(bg.ras, bg.num, prob = T, lonlatCorrection = T))
plot(one.ras, main=paste("Background points"))
plot(bg.ras, add=T)
bg.spp           <- SpatialPoints(cbind(bg[,1],bg[,2]),prj)
plot(bg.spp, add=T)
# Rs               <- c(0.75, 1)
# Pred.fs          <- c("L", "LQ")
# max.bckg         <- 10000
# dist.threshold   <- 40000
NCores           <- 2
modm             <- maxent(env.stack, csv.spp, a=bg, args=c('linear=true', 'quadratic=true', 'product=false', 'hinge=false', 'threshold=false', 'betamultiplier=1.0'))
sdm.ras          <- predict(modm, env.stack, args=c("outputformat=cloglog"), progress='text')
plot(sdm.ras)

modm