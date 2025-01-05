Sys.setenv(TZ="UTC")
dpath <- c(".","resources")[1]
a <- readxl::read_excel(file.path(dpath,"marmam.xlsx"),sheet="mammals")
ind <- is.na(a[["Повтор"]])
a <- a[ind,]
d3 <- a[["Дата"]] |> as.Date()
a[["Дата"]] <- tidyr::fill(data.frame(d3=d3),"d3",.direction="down")[[1]]
a$time <- Sys.time()
a$time[] <- NA
a$lon <- NA_real_
a$lat <- NA_real_
trkFname <- file.path(dpath,"Track_2023-07-18 082447.gpx")
# print(sf::st_layers(trkFname))
trk <- sf::st_read(trkFname,layer="track_points",quiet=TRUE)[c("time","ele")]
# print(trk)
wptFname <- file.path(dpath,"Waypoints_18-JUL-23.gpx")
# print(sf::st_layers(wptFname))
wpt <- sf::st_read(wptFname,layer="waypoints",quiet=TRUE)[,c("time","name","ele","sym")]
wpt$name <- paste0("О",wpt$name)
# print(wpt)
'wptTime' <- function(a,wpt) {
   patt <- ".*([A-ZА-Я]\\d{3}).*"
   pt <- a[["Точка трека"]]
   ind <- grep(patt,pt)
   pt[ind] <- gsub(patt,"\\1",pt[ind])
   ind2 <- match(wpt$name,pt[ind])
   ind2pt <- ind[na.omit(ind2)]
  # print(ind2pt)
   ind2w <- which(!is.na(ind2))
  # print(wpt[ind2w,])
  # a[ind2pt,c("lon","lat")] <- ursa::spatial_coordinates(wpt[ind2w,])
   a[["time"]][ind2pt] <- wpt[["time"]][ind2w]
  # print(a[ind2pt,c("Время UTC","time","Точка трека","Вид")])
   a
}
a <- wptTime(a,wpt)
'photoTime' <- function(a,photoDir) {
   list1 <- dir(path=file.path(dpath,photoDir)
               ,pattern="\\d{4}\\.jpg$",full.names=TRUE)
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
      if (!is.na(a[["time"]][ind][i]))
         next
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
  # print(a[ind3,c("Дата","Точка трека","Вид","Субстрат","time")])
   a
}
a <- photoTime(a,"2023-07-18")
'manualTime' <- function(a) {
   t3 <- a[["Точка трека"]]
   ind <- which(grepl("^\\d{1,2}\\:\\d{2}(\\:\\d{2})*$",t3))
   if (length(ind2 <- grep("^\\d{1,2}\\:\\d{2}$",t3[ind])))
      t3[ind][ind2] <- paste0(t3[ind][ind2],":30")
   ind3 <- is.na(a$time[ind])
   a$time[ind[ind3]] <- paste(format(a[["Дата"]][ind[ind3]],"%Y-%m-%d"),t3[ind[ind3]])
  # ind3 <- which(a$time[ind]>=head(trk$time,1) & a$time[ind]<=tail(trk$time,1))
  # print(a[ind[ind3],c("Дата","Точка трека","Вид","time","lon","lat")])
   a
}
a <- manualTime(a)
# dim(a)
a <- a[!is.na(a$time),]
# dim(a)
a <- a[a$time>=head(trk$time,1) & a$time<=tail(trk$time,1),]
# dim(a)
# print(a[,c("Точка трека","Вид","time","lon","lat")])
'getCoordsFromPoint' <- function(a,gpx) {
   ind <- match(a$time,gpx$time)
   if (all(is.na(ind)))
      return(a)
   ind1 <- na.omit(ind)
   ind2 <- which(!is.na(ind))
   ind2 <- ind2[is.na(a$lon[ind2]) | is.na(a$lat[ind2])]
   xy <- ursa::spatial_coordinates(gpx)[ind1,]
   a$lon[ind2] <- xy[,1]
   a$lat[ind2] <- xy[,2]
   a
}
'getCoordsBetweenPoints' <- function(a,gpx) {
   if (!length(ind <- which(is.na(a$lon) | is.na(a$lat))))
      return(a)
   for (i in ind |> sample()) {
      ind4 <- which(trk$time-a$time[i]>0) |> head(1)
      trk2 <- trk[ind4+c(-1,0),]
      trk2 <- ursa:::spatialize(trk2,style="stere")
      sc <- as.numeric(a$time[i]-trk2$time[1],units="secs")/
            as.numeric(trk2$time[2]-trk2$time[1],units="secs")
      xy2 <- ursa::spatial_coordinates(trk2)
      xy <- data.frame(lon=xy2[1,1]+sc*(xy2[2,1]-xy2[1,1])
                 ,lat=xy2[1,2]+sc*(xy2[2,2]-xy2[1,2]))
      xy <- sf::st_as_sf(xy,coords=c("lon","lat"),crs=sf::st_crs(trk2))
      xy <- ursa::spatial_coordinates(sf::st_transform(xy,4326))
      a$lon[i] <- xy[,1]
      a$lat[i] <- xy[,2]
   }
   a
}
'getcoords' <- function(a,gpx,exact) {
   if (missing(exact))
      exact <- all(c("name","ele") %in% ursa::spatial_colnames(gpx))
   if (exact)
      return(getCoordsFromPoint(a,gpx))
   getCoordsBetweenPoints(a,gpx)
}
# a <- getcoords(a,wpt)
# a <- getcoords(a,trk)
a <- getCoordsFromPoint(a,wpt)
a <- getCoordsBetweenPoints(a,trk)
'getbearing' <- function(device,time,distance,bearing) {
   bearing1 <- bearing
   bearing2 <- NA
   if (!is.na(bearing)) {
      pattHHMM <- "(\\d{1,2})\\:(\\d{2})"
      if (grepl("\\d+(T|Т)$",bearing)) {
         bearing2 <- as.numeric(gsub("\\D","",bearing))
      }
      else if (grepl(pattHHMM,bearing)) {
         hh <- as.numeric(gsub(pattHHMM,"\\1",bearing))
         mm <- as.numeric(gsub(pattHHMM,"\\2",bearing))
         bearing <- 30*(hh+mm/60)
      }
      else {
         bearing <- as.numeric(gsub("\\s*ч$","",bearing))
         if ((bearing>=0)&&(bearing<=24))
            bearing <- bearing*30
      }
   }
   else
      bearing <- 0
   if (is.na(distance))
      distance <- 0
   g <- device
   ind <- match(time,g$time)
   if (is.na(ind)) {
      ind <- which(g$time>time)[1]
      if (is.na(ind))
         stop("out of temporal range?")
   }
   g3 <- ursa:::spatialize(g[ind+seq(-2,2),"time"],resetGrid=TRUE,style="stere")
   xy <- ursa::spatial_coordinates(g3)
   pca <- prcomp(xy,scale=FALSE)
   direction <- unname(pca$rotation[,1])
   if (direction[1]==0)
      theta <- pi/2*sign(direction[2])
   else
      theta <- atan(direction[2]/direction[1])
  # print(theta*180/pi)
   if (direction[1]<0) {
      theta <- pi+theta
   }
   theta <- pi/2-theta
   x <- as.numeric(g3$time)
   y <- unname(predict(pca)[,1])
   n <- length(x)
   slope <- 3.6*(mean(x*y)-mean(x)*mean(y))/var(x)*n/(n-1)
   if (slope<0) {
      theta <- theta-pi
      slope <- -slope
   }
   g2 <- g[ind+c(-1,0),]
   tr <- ursa::trackline(g2)
   trlen <- ursa::spatial_length(tr)
   trdur <- as.numeric(difftime(g2$time[2],g2$time[1]),"secs")
   trspd <- trlen/trdur*3.6
   tr <- ursa::spatial_coordinates(sf::st_segmentize(tr,trlen/1000))[[1]]
   t3 <- as.numeric(g2$time)
   scale <- (as.numeric(time)-t3[1])/(t3[2]-t3[1])
   ind <- round((nrow(tr)-1)*scale+1)
   crd <- data.frame(t(tr[ind,]))
   heading <- lwgeom::st_geod_azimuth(g2)
   units(heading) <- "degrees"
   if (is.na(bearing2))
      bearing2 <- as.numeric(heading)+bearing
   ep <- geosphere::destPoint(crd,b=bearing2,d=distance)
   ret <- data.frame(time=time,observer_lon=crd[,1],observer_lat=crd[,2]
                    ,target_lon=ep[,1],target_lat=ep[,2]
                    ,in_strip=sin(as.numeric(bearing)*pi/180)*as.numeric(distance)
                    ,speed=slope,heading=theta*180/pi
                    ,check.names=FALSE
                    )
   rownames(ret) <- NULL
   ret$time <- NULL
   ret
}
'observationState' <- function(a,trk) {
   colBearing <- grep("(пеленг|азимут)",colnames(a),ignore.case=TRUE,value=TRUE)
   colDistance <- grep("дистанц|(расст.*набл)",colnames(a),ignore.case=TRUE,value=TRUE)
   lapply(seq(nrow(a)),\(i) {
      getbearing(device=trk,time=a$time[i]
                ,distance=a[[colDistance]][i],bearing=a[[colBearing]][i])
   }) |> do.call(rbind,args=_)
}
b <- observationState(a,trk)
a <- cbind(a[,c("Вид","time")],b)
print(a,digits=3)
