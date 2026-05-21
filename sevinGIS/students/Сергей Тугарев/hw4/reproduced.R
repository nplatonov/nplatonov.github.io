require(ursa)
# display("atlas_biol_ros_arkt_web_modified.tif",coast.fill="#00000010"
#               ,graticule.lon=seq(0,350,by=10),graticule.lat=seq(0,80,by=10),col="blue",lwd=1)
prelim <- spatial_read("Тугарев отрисовка полыньи.shz")
pol <- spatial_read("Тугарев готовые полыньи V1.shz")
spatial_area(prelim) |> sum()
spatial_area(pol) |> sum()
# glance(prelim,resetGrid=TRUE,border=0,coast.col="black")
# glance(pol[,grep("(name|площа)",spatial_colnames(pol),ignore.case=TRUE)]
#       ,resetGrid=TRUE,border=0,coast.col="black",legend=list("left","right"))
