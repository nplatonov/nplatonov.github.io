source("common.R")
Sys.setenv(TZ="UTC")
t3 <- a[["Точка трека"]]
ind <- which(grepl("^\\d{1,2}\\:\\d{2}(\\:\\d{2})*$",t3))
if (length(ind2 <- grep("^\\d{1,2}\\:\\d{2}$",t3[ind])))
   t3[ind][ind2] <- paste0(t3[ind][ind2],":30")
a$time[ind] <- paste(format(a[["Дата"]][ind],"%Y-%m-%d"),t3[ind])
#a$time[ind]
# a[which(ind),c("Дата","Точка трека","Вид")] |> as.data.frame()
src <- "Track_2023-07-18 082447.gpx"
trk <- sf::st_read(src,layer="track_points")[c("time","ele")]
ind3 <- which(a$time[ind]>=head(trk$time,1) & a$time[ind]<=tail(trk$time,1))
# a$time[ind][ind3]
a[ind[ind3],c("Дата","Точка трека","Вид","time","lon","lat")]
