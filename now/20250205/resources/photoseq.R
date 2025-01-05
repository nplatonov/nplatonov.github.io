source("common.R")
Sys.setenv(TZ="UTC")
#str(a)
list1 <- dir(path="./2023-07-18",pattern="\\d{4}\\.jpg$",full.names=TRUE)
list2 <- basename(list1)
photo <- a[["Точка трека"]]
ind <- grep("\\D*\\d{4}\\D*",photo)
ph <- gsub("[А-Я]\\d{3}\\D*","",photo[ind])
ph <- gsub("\\s+","",ph)
ph <- gsub("^\\D|\\D$","",ph)
ph <- strsplit(ph,split="(\\s+|,\\s*)")
ph <- lapply(ph,\(x) {
   y <- strsplit(x,split="\\s*-\\s*")[[1]]
   if (length(y)==1)
      return(y)
   y <- as.integer(y)
   y <- sprintf("%04d",sort(seq(y[1],y[2])))
})
d3 <- a[["Дата"]][ind]
found <- vector("list",length(d3))
for (i in seq_along(d3) |> sample()) {
   patt <- paste0(format(d3[i],"%Y%m%d"),"-\\d{6}-",ph[[i]],"\\.jpg")
   ind2 <- unlist(lapply(patt,grep,list2))
   if (!length(ind2))
      next
   if (length(ind2)>1)
      ind2 <- sample(ind2,1)
   found[[i]] <- as.POSIXct(gsub(".*(\\d{8}-\\d{6}).*","\\1",list2[ind2])
                           ,format="%Y%m%d-%H%M%S")
   a[["time"]][ind][i] <- found[[i]]
}
ind2 <- which(sapply(found,\(x) length(x)>0))
ind3 <- ind[ind2] 
a[ind3,c("Дата","Точка трека","Вид","Субстрат","time","lon","lat")]
src <- "Track_2023-07-18 082447.gpx"
print(sf::st_layers(src))
trk <- sf::st_read(src,layer="track_points")[c("time","ele")]
for (i2 in ind2) {
   ind4 <- which(trk$time-a$time[ind[i2]]>0) |> head(1)
   trk2 <- trk[ind4+c(-1,0),]
   trk2 <- ursa:::spatialize(trk2,style="stere")
   print(trk2$time)
   print(a$time[ind3])
  # sc <- (a$time[ind[i2]]-trk2$time[1])/(trk2$time[2]-trk2$time[1])
   sc <- as.numeric(a$time[ind[i2]]-trk2$time[1],units="secs")/
         as.numeric(trk2$time[2]-trk2$time[1],units="secs")
  # sc <- (trk2$time[2]-trk2$time[1])
   xy2 <- ursa::spatial_coordinates(trk2)
   xy <- data.frame(lon=xy2[1,1]+sc*(xy2[2,1]-xy2[1,1])
              ,lat=xy2[1,2]+sc*(xy2[2,2]-xy2[1,2]))
   xy <- sf::st_as_sf(xy,coords=c("lon","lat"),crs=sf::st_crs(trk2))
   xy <- ursa::spatial_coordinates(sf::st_transform(xy,4326))
  # print(xy2)
   print(xy)
   a$lon[ind3] <- xy[,1]
   a$lat[ind3] <- xy[,2]
}
a[ind3,c("Дата","Точка трека","Вид","Субстрат","time","lon","lat")]
