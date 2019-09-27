 
options(width=80)
if (!exists("h1"))
   h1 <- function(hdr,...) paste("#",hdr)
if (!exists("h2"))
   h2 <- function(hdr,...) paste("##",hdr)
if (!exists("h3"))
   h3 <- function(hdr,...) paste("###",hdr)
 
pkgList <- c("rgdal","sf","raster","ggplot2","leaflet","mapview","mapedit"
            ,"knitr","rmarkdown","jpeg","png","ursa")
whoisready <- sapply(pkgList,function(pkg) {
   if (pkg=="ursa") {
      v <- try(packageVersion("ursa"))
      if ((inherits(v,"try-error"))||(v<"3.8.15"))
         install.packages("ursa", repos="http://R-Forge.R-project.org")
   }
   if (requireNamespace(pkg))
      return(TRUE)
   install.packages(pkg,repos="https://cloud.r-project.org/")
   requireNamespace(pkg)
})
 
whoisready
 
c('Everything is ready?'=all(whoisready))
 
rmarkdown::pandoc_available()
 
pi
 
getwd()
 
set.seed(353)
sample(10)
 
if (.Platform$OS.type=="windows")
   Sys.setlocale("LC_CTYPE","Russian")
 
print(c('Здесь кириллица?'="Да!"),quote=FALSE)
 
image(volcano)
 
try(ursa::glance("Mount Eden",place="park",dpi=80))
 
class(volcano)
 
dim(volcano)
 
str(volcano)
 
volcano[1:6,1:12]
 
(a1 <- seq(7))
 
str(a1)
 
a2 <- a1
names(a2) <- format(Sys.Date()+a1-1,"%A")
a2
 
str(a2)
 
str(a2+0L)
 
str(a2+0)
 
typeof(a2+0L)
 
typeof(a2+0)
 
(a3 <- sample(c(TRUE,FALSE),length(a2),replace=TRUE))
 
class(a3)
 
str(a3)
 
(a4 <- names(a2))
 
class(a4)
 
str(a4)
 
(a5 <- list(num=a1[c(1,3:7)],char=a4[-2]))
 
str(a5)
 
class(a5)
 
length(a5)
 
sapply(a5,length)
 
(a6 <- data.frame(num=a1[c(1,3:7)],char=a4[-2]))
 
str(a6)
 
class(a6)
 
dim(a6)
 
(a7 <- list(x=sample(a1,3),y=sample(a1,5)))
 
str(a7)
 
class(a7)
 
length(a7)
 
sapply(a7,length)
 
(a8 <- array(sample(24),dim=c(3,4,2)))
 
str(a8)
 
class(a8)
 
(a9 <- factor(sample(a4),levels=a4))
 
str(a9)
 
class(a9)
 
(a10 <- factor(sample(a4),levels=a4,ordered=TRUE))
 
str(a10)
 
class(a10)
 
 
(shpname <- system.file("vectors","scot_BNG.shp",package="rgdal"))
file.exists(shpname)
 
(tifname <- system.file("pictures/cea.tif",package="rgdal"))
file.exists(tifname)
 
ursa::session_grid(NULL)
ursa::glance(shpname,coast=FALSE,field="(NAME|AFF)",blank="white"
            ,legend=list("left","right"),dpi=88)
 
ursa::session_grid(NULL)
ursa::glance(tifname,coast=FALSE,pal.from=0,pal=c("black","white"),dpi=96)
 
rgdal::ogrInfo(shpname)
 
b.sp <- rgdal::readOGR(shpname)
 
str(head(b.sp,2))
 
isS4(b.sp)
 
slotNames(b.sp)
 
b.sf <- sf::st_read(shpname)
 
str(b.sf)
 
d1 <- rgdal::readGDAL(tifname)
 
str(d1)
 
summary(d1@data[[1]])
 
md <- rgdal::GDALinfo(tifname)
mdname <- names(md)
attributes(md) <- NULL
names(md) <- mdname
md
 
dset <- methods::new("GDALReadOnlyDataset",tifname)
d2 <- rgdal::getRasterData(dset,offset=c(0,0),region.dim=md[c("rows","columns")])
str(d2)
summary(c(d2))
 
(d3 <- raster::brick(tifname))
 
 
v3 <- d3[] ## 'd3[]' то же, что и 'raster::getValues(d3)'
c(d3=object.size(d3),v3=object.size(v3))
 
str(v3)
 
summary(c(v3))
 
head(slot(b.sp,"data"))
 
head(sf::st_set_geometry(b.sf,NULL))
 
g.sp <- sp::geometry(b.sp)
 
g.sp ## Не показано: много строк
 
str(head(g.sp,2))
 
(head(g.sf <- sf::st_geometry(b.sf),2))
 
str(g.sf)
 
sp::proj4string(b.sp)
 
sf::st_crs(b.sf)
 
sp::bbox(b.sp)
 
sf::st_bbox(b.sf)
 
pt0 <- data.frame(lon=33.24529,lat=57.97012)
sp::coordinates(pt0) <- ~lon+lat
sp::proj4string(pt0) <- sp::CRS("+init=epsg:4326")
 
ursa::glance(pt0,style="mapnik",basemap.order="before",basemap.alpha=1,dpi=91)
 
str(pt0)
 
pt0 <- sp::spTransform(pt0,"+proj=laea +lat_0=58 +lon_0=35 +datum=WGS84")
 
xy <- sp::coordinates(pt0)
 
n <- 60
 
loc <- data.frame(step=seq(0,n),look=pi/2,x=xy[,1],y=xy[,2])
 
segment <- runif(n,min=5,max=80)
str(segment)
 
angle <- sapply(1-segment/100,function(x) runif(1,min=-x*pi,max=x*pi))
str(angle)
 
for (i in seq(n)) {
   loc$look[i+1] <- (loc$look[i]+angle[i]) %% (2*pi)
   loc$x[i+1] <- loc$x[i]+segment[i]*cos(loc$look[i+1])
   loc$y[i+1] <- loc$y[i]+segment[i]*sin(loc$look[i+1])
}
head(loc)
 
tr <- vector("list",n)
 
for (i in seq(n))
   tr[[i]] <- sf::st_linestring(matrix(c(loc$x[i],loc$y[i],loc$x[i+1],loc$y[i+1])
                               ,ncol=2,byrow=TRUE))
str(tr)
 
tr <- sf::st_sfc(tr,crs=sp::proj4string(pt0))
str(tr)
 
tr <- sf::st_sf(step=seq(n),segment=segment,geometry=tr)
str(tr)
 
ursa::session_grid(NULL)
ursa::glance(tr,style="mapnik",legend=list("left",list("bottom",2)),las=1,dpi=96)
 
plot(tr)
 
plot(b.sf["AFF"])
 
plot(sf::st_geometry(b.sf),col=sf::sf.colors(12,categorical=TRUE)
    ,border='grey',axes=TRUE)
 
require(ggplot2)
 
ggplot()+geom_sf(data=b.sf,aes(fill=AFF))+coord_sf(crs=sf::st_crs(3857))
 
mapview::mapview(b.sf) ## Не отобразится в Jupyter R Notebook.
 
require(leaflet)
 
b <- sf::st_transform(b.sf,4326)
b$category <- factor(b$AFF,ordered=TRUE)
fpal <- colorFactor(topo.colors(5),b$category)
provList <- c("CartoDB.Positron","CartoDB.DarkMatter","Esri.OceanBasemap")
m <- leaflet()
for (p in c(provList)) m <- addProviderTiles(m,providers[[p]],group=p)
m <- m %>% 
   addPolygons(data=b,fillColor=~fpal(category),fillOpacity=0.5
              ,weight=1.6,color=~fpal(category),opacity=0.75
              ,label=~paste0("AFF: ",AFF," (",NAME,")")
              ,popup=~sprintf("Например, поле COUNT, равное %.1f",COUNT)
              ) %>%
   addMeasure("topright",primaryLengthUnit="meters"
             ,primaryAreaUnit="sqmeters") %>%
   addScaleBar("bottomright"
             # ,options = scaleBarOptions(imperial=FALSE,maxWidth=400)
              ) %>%
   addLayersControl(position="topleft"
                   ,baseGroups=c(provList)
                   ,options=layersControlOptions(collapsed=TRUE)
                   ) %>%
   addLegend("bottomright",pal=fpal,values=b$category,opacity=0.6
            ,title="AFF")
 
m ## Не отобразится в Jupyter R Notebook.
 
pt <- loc
sp::coordinates(pt) <- ~x+y
sp::proj4string(pt) <- sp::proj4string(pt0)
pt <- sp::spTransform(pt,"+init=epsg:4326")
fileout1 <- "afterTrain.geojson"
rgdal::writeOGR(pt,fileout1,gsub("\\..+","",basename(fileout1)),driver="GeoJSON"
                 ,overwrite_layer=TRUE,morphToESRI=FALSE)
 
dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*")))
 
try(ursa::glance(fileout1,style="mapnik",las=1,size=200,dpi=99))
 
b.sf <- b.sf[,c("NAME","COUNT")]
b.sf$'категория' <- b$category
b.sf <- sf::st_transform(b.sf,3857)
fileout2 <- "scotland.sqlite"
sf::st_write(b.sf,dsn=fileout2,layer=gsub("\\..+","",basename(fileout2))
            ,driver="SQLite",layer_options=c("LAUNDER=NO"),quiet=TRUE
            ,delete_layer=file.exists(fileout2),delete_dsn=file.exists(fileout2))
 
dir(pattern=paste0(gsub("\\..+","",basename(fileout2),".*")))
 
try(ursa::glance(fileout2,style="mapnik",las=1,dpi=90,size=200))
 
 
fileout3 <- "track.shp"
sf::st_write(tr,dsn=fileout3,layer=gsub("\\..+","",basename(fileout2))
            ,driver="ESRI Shapefile",quiet=TRUE
            ,delete_layer=file.exists(fileout3),delete_dsn=file.exists(fileout3))
 
dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*")))
 
try(ursa::glance(fileout3,style="mapnik",las=1,dpi=90,size=200))
 
track <- sf::st_linestring(cbind(loc$x,loc$y))
track <- sf::st_sf(data.frame(desc="walk"
                  ,sf::st_sfc(track,crs=sp::proj4string(pt0))))
paint <- mapview::viewExtent(track,alpha=0.01) %>% mapedit::editMap("track")
result <- NULL
if (!is.null(paint$finished)) {
   result <- paint$finished
   mapview::mapview(result)
   ursa::session_grid(NULL)
   ursa::glance(result,style="mapnik")
}
 
sfile <- "main.R"
rfile <- "lesson.R"
{
   if (file.exists(sfile))
      file.copy(sfile,rfile,overwrite=TRUE,copy.date=TRUE)
   else
      download.file(file.path("https://nplatonov.github.io/SCGIS2019",sfile)
                   ,rfile)
}
 
mdfile <- knitr::spin(rfile,knit=FALSE)
mdfile
 
if (rmarkdown::pandoc_available()) {
   htmlfile <- rmarkdown::render(mdfile,output_format="html_document"
                                ,output_options=list(toc=TRUE))
   print(basename(htmlfile))
}
 
if ((rmarkdown::pandoc_available())&&(file.exists(htmlfile))) 
   browseURL(basename(htmlfile))
 
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout2),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*"))))
