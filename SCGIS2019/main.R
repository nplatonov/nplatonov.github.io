#' ---
#' output1:
#'    revealjs::revealjs_presentation: default
#'    rmdformats::readthedown:
#'       toc: yes
#'       self_contained: yes
#'       thumbnails: yes
#'       lightbox: yes
#'       gallery: no
#'       highlight: tango
#'    prettydoc::html_pretty:
#'       toc: yes
#'       self_contained: yes
#'       theme: tactile
#' toc: true
#' pagetitle: R и пространственные данные
#' title: |
#'  |
#'  | Возможности R для работы с пространственными данными
#'  |
#' subtitle: |
#'  |
#'  | Мастер-класс на IV Конференции сообщества природоохранных ГИС в России
#'  | Национальный парк «Валдайский», 05 октября 2019 г.
#'  |
#' author: |
#'  |
#'  | Никита Платонов (ИПЭЭ РАН)
#'  |
#' date: "`r paste('Обновлено:',format(Sys.time(),'%Y-%m-%d %H:%M'))`"
#' abstract: Для желающих сделать первые шаги в освоении R демонстрация основ работы с интерфейсом командной строки в R, позволяющей создавать скрипты и получать воспроизводимые результаты. Узнаете, как пространственные векторные и растровые данные могут попасть в R и как они выглядят в R. Попробуете сделать обработку, анализ и визуализацию пространственных данных.
#' ---
#'
#+ include=FALSE
knitr::opts_chunk$set(comment="##",collapse=FALSE)
options(width=80)
if (!exists("h1"))
   h1 <- function(hdr,...) paste("#",hdr)
if (!exists("h2"))
   h2 <- function(hdr,...) paste("##",hdr)
if (!exists("h3"))
   h3 <- function(hdr,...) paste("###",hdr)
#'
#' `r h1("Планирование (до&nbsp;27&nbsp;сентября)",ref="intro",opt=".middle")`
#'
#' `r h2("Предлагаемый подход к формированию темы мастер-класса",ref="approach")`
#'
#' Планируется, что основные материалы для проведения мастер-класса появятся здесь к 27 сентября.
#' Предполагается, что некоторые дополнения могут быть внесены и в более поздний срок, но с учетом того, чтобы эти изменения не потребовали существенного заимствования времени от занятия.
#' Основной режим проведения мастер-класса - это копирование/вставка фрагмента кода, поэтому этот материал может быть использован дистанционными участниками.
#'
#' Факультативно задумывается и осваивается вариант занятия с использованием [Jupyter-R-Notebook](./main.ipynb). Установку необходимых пакетов нужно выполнить самостоятельно.
#'
#' Пожелания по затрагиванию какой-либо темы могут быть приняты [&#x2709;](mailto:platonov@sevin.ru) не позднее 27 сентября.
#'
#' `r h1("Подготовка (до&nbsp;05&nbsp;октября)",opt=".middle",ref="before")`
#'
#' `r h2("Операционные системы пользователя",ref="os")`
#'
#' Не для всех операционных систем есть скомпилированные модули (ядро R, пакеты). В таком случае модули компилируются, и на это уходит какое-то время. Поэтому если ОС не OS Windows, то этот этап нужно пройти заранее.
#'
#' `r h2("Установка базового R",ref="base")`
#'
#' Установить или обновить R, например, [отсюда](https://cran.rstudio.com/). Актуальная версия 3.6.1. Поддержка до версии 3.0 есть, но с большими ограничением.
#'
#' `r h2("Установка необходимых пакетов",entry="first",ref="contribute1")`
#+ class.source="height450"
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
#' `r h2("Установка необходимых пакетов",entry="next",ref="contribute2")`
#'
#+
whoisready
#'
#' Если отображается `TRUE` для всех пакетов, то подготовка к занятию осуществлена успешно.
#+
c('Everything is ready?'=all(whoisready))
#'
#' Если где-то выскочило `FALSE` (например, для пакета "foo"), то можно попробовать его установить заново функцией `install.packages("foo")`.
#'
#' `r h2("Установка дополнительного программного обеспечения",ref="pandoc",opt=".scale90")`
#'
#' Pandoc необходим для создания воспроизводимого результата. Этот шаг опциональный, и может быть пропущен, но в этом случае на занятии будет пропущен раздел по [публикации результатов](#report).
#'
#' [Ссылка](https://pandoc.org/installing.html) на страницу для скачивания. Для пользователей Windows достаточно перейти к [скачиванию актуального релиза](https://github.com/jgm/pandoc/releases/latest), и выбрать либо установщик (`*.msi`), либо архив (`*.zip`). Запомнить путь, куда произведена установка и где находится файл `pandoc.exe` и добавить этот путь в переменную окружения `%PATH%`, например: WindowsKey+Q, ввести "Переменные среды/Environment Variables", попасть в окошко "Свойства Системы/System Properties", нажать на кнопку "Переменные среды/Environment Variables" и отредактировать пользовательскую или системную переменную PATH, добавив путь к `pandoc.exe`.
#'
#' Чтобы проверить, правильно ли установлен Pandoc:
rmarkdown::pandoc_available()
#'
#' `r h2("Как использовать материал",ref="howto")`
#'
#' Предполагается, что во время занятий будет использоваться интерактивный режим: либо простая среда R (R, запущенный без команд), либо графическая среда R GUI, либо RStudio.
#' 
#' Блок исходного кода выделен моноширинным шрифтом с подсветкой синтаксиса, после которого либо приведен текстовый вывод (более бледный цвет шрифта), либо графический вывод (рисунок, таблица). В среде R нужно вводить код из верхнего блока и сравнивать полученный вывод с содержимым нижнего блока.
#' 
#' К примеру, ниже приведен пример вывода числа $\pi$: сверху -- команда, снизу -- выход. 
#' 
#+
pi
#' 
#' `r h2("Начало работы",ref="openR",opt=".scale97")`
#'
#' Текущий путь, где мы находимся. Здесь появятся файлы, созданные в процессе занятия.
getwd()
#' Его можно поменять через меню RGui/RStudio или с помощью `setwd()`.
#+
#' :::scale80

#' Зафиксируем генератор псевдослучайных чисел на определенную последовательность
#+
set.seed(353)
sample(10)
#' :::
#' Зададим кодировку
#'
#+ results="hide"
if (.Platform$OS.type=="windows")
   Sys.setlocale("LC_CTYPE","Russian")
#+ echo=TRUE
print(c('Здесь кириллица?'="Да!"),quote=FALSE)
#'
#' `r h1("Занятие (05&nbsp;октября)",opt=".middle",ref="openday")`
#'
#' `r h2("Пример",ref="volcano1",entry="first")`
#'
#' Пример пространственных данных в базовом R -- `data(volcano)`.

#+
image(volcano)
#'
#' `r h2("Пример",ref="volcano2",entry="last")`
#'
#' Это вулкан Maunga Whau (Mt Eden).

#+ volcano
ursa::glance("Mount Eden",place="park",dpi=80)
#'
#' `r h2("Типы данных",ref="typeof1",entry="first")`
#'
#' ### Матрицы
#'
#' Представление растровых данных в виде матрицы (как с `volcano`):
#+ 
class(volcano)
dim(volcano)
#'
#' Структура данных 
#+
str(volcano)
#'
volcano[1:6,1:12]
#'
#' `r h2("Типы данных",ref="typeof2",entry="next")`
#'
#' ### Числа и имена значений
#+ 
a1 <- seq(7)
a1
str(a1)
a2 <- a1
names(a2) <- format(Sys.Date()+a1-1,"%A")
a2
str(a2)
#'
#' `r h2("Типы данных",ref="typeof3",entry="next")`
#'
#' ### Целые числа, числа с плавающей точкой
#+ 
str(a2+0L)
str(a2+0)
typeof(a2+0L)
typeof(a2+0)
#'
#' `r h2("Типы данных",ref="typeof4",entry="next")`
#'
#' ### Логические значения, строки.
#+ 
(a3 <- sample(c(TRUE,FALSE),length(a2),replace=TRUE))
class(a3)
str(a3)
(a4 <- names(a2))
class(a4)
str(a4)
#'
#' `r h2("Типы данных",ref="typeof5",entry="next")`
#'
#' ### Списки одинаковой длины
#+ 
(a5 <- list(num=a1[c(1,3:7)],char=a4[-2]))
str(a5)
class(a5)
length(a5)
sapply(a5,length)
#'
#' `r h2("Типы данных",ref="typeof6",entry="next")`
#'
#' ### Таблицы
#+ 
(a6 <- data.frame(num=a1[c(1,3:7)],char=a4[-2]))
str(a6)
class(a6)
dim(a6)
#' 
#' `r h2("Типы данных",ref="typeof7",entry="next")`
#'
#' ### Списки различной длины
#+ 
(a7 <- list(x=sample(a1,3),y=sample(a1,5)))
str(a7)
class(a7)
length(a7)
sapply(a7,length)
#'
#' `r h2("Типы данных",ref="typeof8",entry="next")`
#'
#' ### Массивы
#+ 
(a8 <- array(sample(24),dim=c(3,4,2)))
str(a8)
class(a8)
#' `r h2("Типы данных",ref="typeof9",entry="last")`
#'
#' ### Факторы
#+ 
(a9 <- factor(sample(a4),levels=a4))
str(a9)
class(a9)
(a10 <- factor(sample(a4),levels=a4,ordered=TRUE))
str(a10)
class(a10)
#'
#'
#' `r h2("Импорт пространственных данных",ref="import1",entry="first")`
#'
#' Векторные данные
#' 
#' :::scale120
#' Пакет | Формат | Импорт | Описание 
#' -----|------|-----|---
#' `sp` | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) |**`rgdal`**`::readOGR()` | 
#' `sf` | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | `st_read()` | [URL](https://r-spatial.github.io/sf/)
#' <!--[`gdalUtuls`](https://cran.rstudio.com/web/packages/gdalUtils/)^*факультативно*^ | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | | оболочка системного GDAL -->
#' :::
#'
#'
#' Растровые данные
#'
#' :::scale120
#' Пакет | Формат | Импорт | Описание
#' ---|----|--------|----
#' `sp` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) |а**`rgdal`**`::readGDAL()` | 
#' `raster` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | `raster()`, `brick()`, `stack()` | 
#' [`ncdf4`](https://cran.rstudio.com/web/packages/ncdf4/)^*факультативно*^ | [NetCDF](https://gdal.org/drivers/raster/netcdf.html) | nc_open() | 
#' `ursa`| [ENVI](https://gdal.org/drivers/raster/envi.html) | `read_envi()` | 
#' :::
#'
#' `r h2("Импорт пространственных данных",ref="import2",entry="next")`
#' `r h3("Пример данных")`
(shpname <- system.file("vectors","scot_BNG.shp",package="rgdal"))
file.exists(shpname)
#' `r h2("Импорт пространственных данных",ref="import3",entry="next")`
#+ scotBNG
ursa::session_grid(NULL)
ursa::glance(shpname,coast=FALSE,field="(NAME|AFF)",blank="white"
            ,legend=list("left","right"),dpi=88)
#' `r h2("Импорт пространственных данных",ref="import4",entry="next")`
#'
#' `r h3("Векторные данные -- <code>rgdal</code>",entry="first")`
#'
rgdal::ogrInfo(shpname)
b.sp <- rgdal::readOGR(shpname)
#'
#' `r h2("Импорт пространственных данных",ref="import5",entry="next")`
#'
#' `r h3("Векторные данные -- <code>rgdal</code>",entry="next")`
#'
#+ class.output="height380"
str(head(b.sp,2))

isS4(b.sp)
slotNames(b.sp)
#'
#' `r h2("Импорт пространственных данных",ref="import6",entry="next")`
#' `r h3("Векторные данные -- <code>sf</code>",entry="first",ref="importExample")`
b.sf <- sf::st_read(shpname)
#' `r h2("Импорт пространственных данных",ref="import7",entry="last")`
#' `r h3("Векторные данные -- <code>sf</code>",entry="last")`
#+ class.output="height550"
str(b.sf)
#' `r h2("Характеристики пространственных данных",ref="extract1",entry="first")`
#' `r h3("Атрибутивная таблица",entry="first")`
#' `sp`:
head(slot(b.sp,"data"))
#'
#' `r h2("Характеристики пространственных данных",ref="extract2",entry="next")`
#' `r h3("Атрибутивная таблица",entry="next")`
#' `sf`:
head(sf::st_set_geometry(b.sf,NULL))
#'
#' `r h2("Характеристики пространственных данных",ref="extract3",entry="next")`
#' `r h3("Геометрия",entry="first")`
#' `sp`:
#+
g.sp <- sp::geometry(b.sp)
#+ eval=F
g.sp ## кто хочет глянуть на "простыню"?
#'
#+ class.output="height360"
str(head(g.sp,2))
#'
#' `r h2("Характеристики пространственных данных",ref="extract4",entry="next")`
#' `r h3("Геометрия",entry="last")`
#' `sf`:
(head(g.sf.geom <- sf::st_geometry(b.sf),2))
str(g.sf.geom)
#'
#' `r h2("Характеристики пространственных данных",ref="extract5",entry="next")`
#' `r h3("Проекция")`
#' В R данные проекции представляются в виде PROJ.4, поэтому при импорте/экспорте данных осуществляется двойное WKT&nbsp;->&nbsp;PROJ4&nbsp;->&nbsp;WKT преобразование
#'
#' `sp`:
sp::proj4string(b.sp)
#' `sf`:
sf::st_crs(b.sf)
#'
#' `r h2("Характеристики пространственных данных",ref="extract6",entry="next")`
#' `r h3("Пространственный охват")`
#' `sp`:
sp::bbox(b.sp)
#' `sf`:
sf::st_bbox(b.sf)
#'
#' `r h2("Создание пространственных данных",ref="create1",entry="first")`
#'
#' Выйдем из здания вокзала ст. Валдай:
pt0 <- data.frame(lon=33.24529,lat=57.97012)
#' Создадим точечный `Spatial`-объект:
#+
sp::coordinates(pt0) <- ~lon+lat
sp::proj4string(pt0) <- sp::CRS("+init=epsg:4326")
#+ Valdai
ursa::glance(pt0,style="mapnik",basemap.order="before",basemap.alpha=1,dpi=103)
#'
#' `r h2("Создание пространственных данных",ref="create2",entry="next")`
#'
#' Смотрим на структуру данных:
str(pt0)
#' Изменим проекцию для расчета расстояний по координатам:
pt0 <- sp::spTransform(pt0,"+proj=laea +lat_0=58 +lon_0=35 +datum=WGS84")
#' Извлечем координаты:
xy <- sp::coordinates(pt0)
#'
#' `r h2("Создание пространственных данных",ref="create3",entry="next")`
#'
#' Решаем перемещаться минутными сегментами в течение часа:
n <- 60
#' На основе координат создаем таблицу перемещения. По умолчанию весь период стоим на месте и смотрим на север:
loc <- data.frame(step=seq(0,n),look=pi/2,x=xy[,1],y=xy[,2])
#' Скорость перемещений (в м&nbsp;мин^-1^) в течение минуты случайна:
segment <- runif(n,min=5,max=80)
str(segment)
#' Задаем, что если следующий сегмент длинный, то отклонение направления от предыдущего сегмента будет меньше:
angle <- sapply(1-segment/100,function(x) runif(1,min=-x*pi,max=x*pi))
str(angle)
#'
#' `r h2("Создание пространственных данных",ref="create4",entry="next")`
#'
#' Заполняем последующие шаги на основе предыдущих:
for (i in seq(n)) {
   loc$look[i+1] <- (loc$look[i]+angle[i]) %% (2*pi)
   loc$x[i+1] <- loc$x[i]+segment[i]*cos(loc$look[i+1])
   loc$y[i+1] <- loc$y[i]+segment[i]*sin(loc$look[i+1])
}
head(loc)
#'
#' `r h2("Создание пространственных данных",ref="create5",entry="next")`
#'
#' Создадим линейный `sf`-объект
tr <- vector("list",n)
#' Матрица (с двумя столбцами) координат задается как LINESTRING:
for (i in seq(n))
   tr[[i]] <- sf::st_linestring(matrix(c(loc$x[i],loc$y[i],loc$x[i+1],loc$y[i+1])
                               ,ncol=2,byrow=TRUE))
#+ class.output="height340"
str(tr)
#'
#' `r h2("Создание пространственных данных",ref="create6",entry="last")`
#'
#' Набор сегментов объединяем в геометрию:
tr <- sf::st_sfc(tr,crs=sp::proj4string(pt0))
#+
str(tr)
#' С геометрией связываем атрибутивную таблицу.
tr <- sf::st_sf(step=seq(n),segment=segment,geometry=tr)
#+ class.output="height300"
str(tr)
#'
#' `r h2("Статическая визуализация",ref="plot1",entry="first")`
#'
#+ route
ursa::glance(tr,style="mapnik",legend=list("left",list("bottom",2)),dpi=96)
#'
#' `r h2("Статическая визуализация",ref="plot2",entry="next")`
#'
#' Графическое отображение переопределенной под класс объекта функцией `plot()` средствами пакетов `sp`^(факультативно)^ и `sf` развито слабо...
#+ out.width="80%"
plot(tr)
#'
#' `r h2("Статическая визуализация",ref="plot3",entry="next")`
#' [Возвращаясь](#importExample) к ранее загруженным данным:
plot(b.sf["AFF"])
#' `r h2("Статическая визуализация",ref="plot4",entry="next")`
plot(sf::st_geometry(b.sf),col=sf::sf.colors(12,categorical=TRUE)
    ,border='grey',axes=TRUE)
#'
#' `r h2("Статическая визуализация",ref="plot5",entry="next")`
#'
#' ... Поэтому используются возможности других пакетов.
#+ out.width="90%"
require(ggplot2)
ggplot()+geom_sf(data=b.sf,aes(fill=AFF))+coord_sf(crs=sf::st_crs(3857))
#'
#'
#' `r h2("Интерактивная визуализация",ref="mapview",entry="first")`
#'
mapview::mapview(b.sf)
#'
#' `r h2("Интерактивная визуализация",ref="leaflet1",entry="next")`
#'
require(leaflet)
#+ class.source="height650 scale45"
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
#'
#' `r h2("Интерактивная визуализация",ref="leaflet2",entry="next")`
m
#'
#'
#'
#'
#'
#'
#'
#' `r ## h2("Обработка векторных данных")`
#'
#'
#'
#' `r ## h2("Экспорт пространственных данных")`
#'
#'
#'
#' `r h2("Воспроизводимые вычисления и публикация результата",ref="report1",entry="first")`
#'
#' Ниже приведены фрагмента кода, которые не были выполнены при составлении программы занятия. Их предлагается выполнить самостоятельно. Также необходимо [установленный Pandoc](#pandoc).
#' 
#' Содержимое занятия сгенерировано из файла `main.R`. Загрузим его, переименовав:
#+ eval=F
sfile <- "main.R"
rfile <- "lesson.R"
{
   if (file.exists(sfile))
      file.copy(sfile,rfile,overwrite=TRUE,copy.date=TRUE)
   else
      download.file(file.path("https://nplatonov.github.io/SCGIS2019",sfile)
                   ,rfile)
}
#' <!-- file.copy("main.R","lesson.R",overwrite=TRUE,copy.date=TRUE) -->
#'
#' `r h2("Воспроизводимые вычисления и публикация результата",ref="report2",entry="last")`
#' На основе этого файла создадим markdown-документ:
#+ eval=FALSE
mdfile <- knitr::spin(rfile,knit=FALSE)
mdfile
#' Затем из markdown-документа сформируем html-документ:
#+ eval=FALSE
if (rmarkdown::pandoc_available()) {
   htmlfile <- rmarkdown::render(mdfile,output_format="html_document"
                                ,output_options=list(toc=TRUE))
   print(basename(htmlfile))
}
#' Полученный html-документ можно открыть в браузере.
#+ eval=FALSE
if ((rmarkdown::pandoc_available())&&(file.exists(htmlfile))) 
   browseURL(basename(htmlfile))
#' И можно скопировать на флешку на память:))
#'
#' `r h1("Успехов!",ref="thankyou",opt=".middle")`
#'
#' `r h2("Дополнительная информация",ref="extra",opt=".scale50")`
#'
#' :::left70
#'
#' `r h3("Как узнать об R поглубже",ref="deeplearn")`
#'
#' + [R-Bloggers](https://www.r-bloggers.com/) -- современные тенденции R
#'
#' + R's [Spatial](https://cran.rstudio.com/web/views/Spatial.html) and [SpatioTemporal](https://cran.rstudio.com/web/views/SpatioTemporal.html) Task Views 
#'
#' + [Stackoverflow](https://stackoverflow.com/feeds/tag/r) с тегом #R.
#' 
#' + [Stackexchange](https://gis.stackexchange.com/questions) о ГИС, в т.ч. с использованием R.
#'
#' + Package's vignettes -- обобщенное знакомство с пакетом. Обычно содержат воспроизводимый код.
#'
#' :::
#' :::right30
#'
#' `r h3("Автор и исполнитель",ref="affiliation",opt=".slide")`
#' 
#' - Платонов Никита Геннадьевич [&#x2709;](mailto:nikita.platonov@gmail.com) <a href='https://orcid.org/0000-0001-7196-7882'><img src='https://orcid.org/sites/default/files/images/orcid_32x32.png' style='box-shadow: none; max-height:20px;' alt='ORCID' class='inline'></a>
#' 
#' - [ИПЭЭ РАН](http://www.sev-in.ru) [-- 85 лет в 2019 г. &#127874;]{.scale80}
#' 
#' - [Постоянно действующая экспедиция РАН по изучению животных Красной книги Российской Федерации и других особо важных
#' животных фауны России](http://www.sevin-expedition.ru)
#' 
#' - [Программа изучения белого медведя в Российской Арктике](http://bear.sevin-expedition.ru)
#' :::
