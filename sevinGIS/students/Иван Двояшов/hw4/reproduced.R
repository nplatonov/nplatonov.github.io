require(ursa)
options(ursaProj4Legacy=TRUE)
p <- spatial_read("kara_pol_fin.shz")
spatial_crs(p)
spatial_data(p)
p$area <- spatial_area(p)*1e-6
p <- ursa:::spatialize(p,resetProj=TRUE)
pc <- spatial_centroid(p)
pc$area <- sprintf("%.0f",pc$area)
session_grid(p)
compose_open(height=2000,pointsize=12)
panel_new("layout")
# panel_raster(a3)
cname <- "descriptio"
panel_plot(p[cname],col=palettize(p[[cname]],pal.bright=191,pal.rotate="circle"),alpha=0.6)
panel_decor(coast.fill="#00000010"
           ,graticule.lon=seq(0,350,by=10),graticule.lat=seq(0,80,by=10),col="black")
panel_annotation(pc["area"],buffer=1.4)
compose_close()
