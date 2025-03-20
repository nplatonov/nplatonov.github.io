plutil::ursula(3)
pt1 <- spatialize("Волхов")
pt2 <- spatialize("Киркенес")
pt <- spatial_bind(pt1,pt2)
glance(pt,resetGrid=TRUE,style="Positron",basemap.order="before",dim=c(750,400),scalebar.w=75)




