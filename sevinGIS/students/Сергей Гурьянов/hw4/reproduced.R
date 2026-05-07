require(ursa)
glance("Слой суши Гурьянов .gpkg")
pol <- spatial_read("Полыньи Гурьянов (ред.3).gpkg")
glance(pol[,grep("(Полын|area)",spatial_colnames(pol),ignore.case=TRUE)]
      ,resetGrid=TRUE,border=0,coast.col="black",legend=list("left","right"))
'plotdig' <- function(fname) {
   res <- ursa_read("Оцифровка Гурьянов (версия 2).tif")
   session_grid(res)
   compose_open(legend=NULL)
   panel_new()
   panel_raster(res)
   panel_decor(coast.fill="#00000010"
              ,graticule.lon=seq(0,350,by=10),graticule.lat=seq(0,80,by=10),col="black")
   compose_close()
}
plotdig("Оцифровка Гурьянов (версия 2).tif")
plotdig("Оцифровка Гурьянов (версия 3).tif")
