source("common.R")
src <- "Waypoints_18-JUL-23.gpx"
(layers <- sf::st_layers(src))
wpt <- sf::st_read(src,layer="waypoints")[,c("time","name","ele","sym")]
head(wpt$time,2)
Sys.setenv(TZ="UTC")
head(wpt$time,2)
wpt
wpt$name <- paste0("О",wpt$name)
str(a)
patt <- ".*([A-ZА-Я]\\d{3}).*"
pt <- a[["Точка трека"]]
ind <- grep(patt,pt)
pt[ind] <- gsub(patt,"\\1",pt[ind])
ind2 <- match(wpt$name,pt[ind])
ind2pt <- ind[na.omit(ind2)]
ind2w <- which(!is.na(ind2))
print(wpt[ind2w,])
a[ind2pt,c("lon","lat")] <- ursa::spatial_coordinates(wpt[ind2w,])
a[["time"]][ind2pt] <- wpt[["time"]][ind2w]
print(a[ind2pt,c("Время UTC","time","Точка трека","Вид")])
