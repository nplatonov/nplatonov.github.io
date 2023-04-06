#' ---
#' params:
#'   lesson: "05"
#' pagetitle: ГИС `r params$lesson`
#' output:
#'    html_document:
#'       toc: true
#'       toc_depth: 5
#' title: Возможности R для работы с пространственными данными
#' subtitle: ГИС технологии в биологических исследованиях
#' meeting: Занятие `r params$lesson`
#' author:
#'  - name: Никита Платонов
#'    affiliation: с.н.с. ИПЭЭ РАН
#' date: today
#' format-date: "DD MMMM YYYY"
#' lang: ru
#' abstract: Демонстрация основ работы с интерфейсом командной строки в R, позволяющей создавать скрипты и получать воспроизводимые результаты. Показано, как пространственные векторные и растровые данные могут попасть в R и как они выглядят в R. С возможностью сделать обработку, анализ и визуализацию пространственных данных.
#' ---

#+ hprint, include=FALSE
knitr::opts_chunk$set(comment="##",collapse=FALSE)
#options(width=60)
baseURL <- ifelse(T,".","https://nplatonov.github.io/SCGIS2019")
#'
#' ## Основы R
#'
#' ### Установка R
#'
#' #### Oперационные системы
#'
#' Не для всех операционных систем есть скомпилированные модули (ядро R, библиотеки). В таком случае модули компилируются, и на это уходит какое-то время. Поэтому если ОС не OS Windows, то этот этап нужно пройти заранее.
#'
#' #### Базовый R
#'
#' Установить или обновить R, например, [отсюда](https://cran.rstudio.org/). Актуальная версия 4.2.3. Не ниже версии 4.0.
#'
#' #### Библиотеки
#'
#+ require
pkgList <- c("rgdal","sf","terra","raster","ggplot2","leaflet","mapview"
            ,"mapedit","knitr","rmarkdown","jpeg","png","ursa","tmap")
whoisready <- sapply(pkgList,function(pkg) {
   if (requireNamespace(pkg))
      return(TRUE)
   install.packages(pkg,repos="https://cran.rstudio.com")
   requireNamespace(pkg)
})
#'
#' ---
#'
#+ ok
whoisready
#'
#' Если отображается `TRUE` для всех библиотек, то подготовка к занятию осуществлена успешно.
#+ allok
c('Everything is ready?'=all(whoisready))
#'
#' Если где-то выскочило `FALSE` (например, для библиотеки "foo"), то можно попробовать его установить заново функцией `install.packages("foo")`.
#'
#' #### Дополнительное ПО
#'
#' ##### RStudio IDE {.middle .center}
#' <sup>факультативно</sup>
#+ echo=FALSE
# knitr::include_url("https://www.rstudio.com/products/rstudio/download/",height=480)
#'
#' ##### Pandoc {#pandoc}
#' :::font90
#' Pandoc необходим для создания воспроизводимого результата. Этот шаг опциональный, и может быть пропущен, но в этом случае на занятии будет пропущен раздел по [публикации результатов](#report1).
#'
#' [Ссылка](https://pandoc.org/installing.html) на страницу для скачивания. Для пользователей Windows достаточно перейти к [скачиванию актуального релиза](https://github.com/jgm/pandoc/releases/latest), и выбрать либо установщик (`*.msi`), либо архив (`*.zip`). Запомнить путь, куда произведена установка и где находится файл `pandoc.exe` и добавить этот путь в переменную окружения `%PATH%`, например: WindowsKey+Q, ввести "Переменные среды/Environment Variables", попасть в окошко "Свойства Системы/System Properties", нажать на кнопку "Переменные среды/Environment Variables" и отредактировать пользовательскую или системную переменную PATH, добавив путь к `pandoc.exe`.
#'
#' Чтобы проверить правильно ли установлен Pandoc, в новой R-сессии:
#'
#+ pandoc
rmarkdown::pandoc_available()
#' :::
#' ##### Jupyter
#'
#' Jupyter Notebook для работы с R кодом в браузере.
#'
#' 1. [Загрузить](https://docs.conda.io/en/latest/miniconda.html) и установить менеджер Miniconda (проверено на Windows 64bit Python 3.7).
#'
#' 2. Запустить `conda` (На Windows попробовать WinKey+Q и начать вводить "Anaconda")
#'
#' 3. Последовательно выполнить команды (в среде Conda, не в среде R):
#'
#' Команда | Описание
#' ---|---
#' `conda install jupyter` | установка Jupyter Notebook
#' `conda install -c r r-recommended r-irkernel` | Установка R, базовых библиотек и библиотеки для использования R в Jupyter Notebook
#' `conda install -c conda-forge jupytext` | Установка преобразователя кода R в формат Jupyter Notebook
#'
#' <!--
#' Предварительно скачайте [`main.R`](`r baseURL`/main.R) или только код [`codeOnly.R`](`r baseURL`/codeOnly.R), если будете использовать на занятии Jupyter Notebook. Если проблема с кодировкой остается, попробуйте взять 
#' [`codeOnly1251.R`](`r baseURL`/codeOnly1251.R)
#' Предупреждение: описательный текст (markdown) местами не отформатирован, в частности, не будут отображаться таблицы; также не будут отображаться html-виджеты.
#' -->
#'
#' #### Как использовать материал
#'
#' Предполагается, что во время занятий будет использоваться интерактивный режим: либо простая среда R (R, запущенный без команд), либо графическая среда R GUI, либо RStudio.
#'
#' Блок исходного кода выделен моноширинным шрифтом с подсветкой синтаксиса, после которого либо приведен текстовый вывод (более бледный цвет шрифта), либо графический вывод (рисунок, таблица). В среде R нужно вводить код из верхнего блока и сравнивать полученный вывод с содержимым нижнего блока.
#'
#' К примеру, ниже приведен пример вывода числа $\pi$: сверху -- команда, снизу -- выход. 
#'
#+ pi
pi
#'
#' ### Начало работы
#'
#' Текущий путь, где мы находимся. Здесь появятся файлы, созданные в процессе занятия.
#+ getwd
getwd()
#' Его можно поменять через меню RGui/RStudio или с помощью `setwd()`.
#'
#' Зафиксируем генератор псевдослучайных чисел на определенную последовательность
#'
#+ seed
set.seed(353)
sample(10)
#'
#' ---
#'
#' :::font90
#' Команда для проверки кириллицы:
#+ russian, echo=TRUE
print(c('Здесь кириллица?'="Да!"),quote=FALSE)
#'
#' Если вывод не читаемый, то возможные пути решения:
#'
#' 1\. Задать кириллицу для символьной локали:
#'
#+ locale, results="hide"
if (.Platform$OS.type=="windows")
   Sys.setlocale("LC_CTYPE","Russian")
#'
#' 2\. Если скрипты подключаются через `source()`, то можно настроить запуск R через конфигурационные файлы. Например, скачать [.Rprofile](`r baseURL`/.Rprofile), разместить в рабочей директории, перегрузить R. Файл имеет следующую структуру:
#'
#'      local({
#'         options(encoding="UTF-8")
#'         Sys.setlocale("LC_CTYPE","Russian")
#'      })
#'
#' 3\. Если скрипт `bar.R` с кириллицей в кодировке UTF-8 запускается из командной строки, то использовать следующие параметры запуска.
#'    
#'      R --encoding UTF-8 -f bar.R
#' :::
#'
#' ### Представление данных
#'
#' #### Простые типы
#'
#' ##### Числа и имена значений
#+ a1
(a1 <- seq(7))
#+ stra1
str(a1)
#+ a2
a2 <- a1
names(a2) <- format(Sys.Date()+a1-1,"%A")
a2
#+ stra2
str(a2)
#'
#' ##### Целые числа, числа с плавающей точкой
#+ stra2int
str(a2+0L)
#+ stra2num
str(a2+0)
#+ typeofa2int
typeof(a2+0L)
#+ typeofa2num
typeof(a2+0)
#'
#' ##### Логические значения, строки
#'
#'  ##### Логические значения
#+ a3
(a3 <- sample(c(TRUE,FALSE),length(a2),replace=TRUE))
#+ classa3
class(a3)
#+ stra3
str(a3)
#'
#'  ##### Строки
#'
#+ a4
(a4 <- names(a2))
#+ classa4
class(a4)
#+ stra4
str(a4)
#'
#' #### Составные типы
#'
#' ##### Списки одинаковой длины
#+ a5
(a5 <- list(num=a1[c(1,3:7)],char=a4[-2]))
#+ stra5
str(a5)
#+ classa5
class(a5)
#+ lentgha5
length(a5)
#+ a5length
sapply(a5,length)
#'
#' ---
#'
#' ##### Таблицы
#+ a6
(a6 <- data.frame(num=a1[c(1,3:7)],char=a4[-2]))
#+ stra6
str(a6)
#+ classa6
class(a6)
#+ dima6
dim(a6)
#'
#' ---
#'
#' ##### Списки различной длины
#+ a7
(a7 <- list(x=sample(a1,3),y=sample(a1,5)))
#+ stra7
str(a7)
#+ classa7
class(a7)
#+ lengtha7
length(a7)
#+ a7length
sapply(a7,length)
#'
#' #### Матрицы
#'
#+ a11
(a11 <- matrix(sample(seq(24)),ncol=4,nrow=3))
#' Размерность массива
#+ dima11
dim(a11)
#'
#' Структура данных массива
#+ stra11
str(a11)
#'
#' ---
#'
#' #### Массивы
#+ a8
(a8 <- array(sample(24),dim=c(3,4,2)))
#+ stra8
str(a8)
#+ classa8
class(a8)
#'
#' #### Факторы
#+ a9
(a9 <- factor(sample(a4),levels=a4))
#+ stra9
str(a9)
#+ classa9
class(a9)
#+ a10
(a10 <- factor(sample(a4),levels=a4,ordered=TRUE))
#+ stra10
str(a10)
#+ classa10
class(a10)
#'
#' ## R как ГИС?
#'
#' + R устроен так, что можно реализовать сложные структуры данных, со средствами их инспектирования, что вполне применимо для пространственных данных и их метаданных
#'
#' + В R есть инструменты для анализа данных
#'
#' + В R есть инструменты для визуализации
#'
#' + *Как особенность развития до текущего момента*: воспроизводимость реализована лучше интерактивности
#'
#' + В R уже многое сделано по манипуляции с пространственными данными: пользователю не обязательно быть разработчиком
#'
#' ### Средства визуализации
#'
#' Базовые средства R для визуализации (библиотека `graphics`) пространственных данных:
#'
#' + `points()` -- отображение точек (геометрия POINT)
#'
#' + `lines()`, `segments()`, `contour()` -- отображение линий (геометрия LINESTRING)
#'
#' + `polygon()`, `polypath()` -- отображение полигонов (геометрия POLYGON)
#'
#' + `image()`, `rasterImage()` -- растровые изображения
#'
#' + `text()`, `legend()` -- аннотациии
#'
#' + `axis()`, `mtext()` -- рамочное оформление
#'
#' #### Пример путешествия мимо/через Спб
#'
n <- 60
seqx <- seq(20,40,by=5)
seqy <- seq(55,65,by=2)
x <- sort(runif(n,min=min(seqx),max=max(seqx)))
y <- sort(runif(n,min=min(seqy),max=max(seqy)))
#'
#' ---
#'
#+ spb1, fig.width=6, fig.height=4, out.height="450px", out.width="600px"
plot(x,y,type="n",asp=NA,axes=FALSE,xlab="",ylab="")
lines(x,y,lwd=4,col="black")
lines(x,y,lwd=3,col="orange")
box()
axis(1,at=seqx,lab=paste0(seqx,"°E"),lwd=0,lwd.ticks=1,las=1)
axis(2,at=seqy,lab=paste0(seqy,"°N"),lwd=0,lwd.ticks=1,las=1)
#'
#' ---
#'
#+ spb2
e <- sf::st_sfc(sf::st_linestring(cbind(x,y)),crs=4326)
ursa::session_grid(NULL)
ursa::glance(e,blank="white",coast.fill="#00000010",pointsize=12
            ,col="black",plot.lwd=5)
#'
#' ---
#'
#' #### `data(volcano)`
#'
#+ imgvolcano, fig.height=6, fig.width=8
image(volcano)
#'
#' ---
#'
#' Это вулкан Maunga Whau (Mt Eden).
#'
#+ include=FALSE
ursa::session_grid(NULL)
#+ glancevolcano
ursa:::spatialize("Mount Eden",place="park",style="web") |>
   ursa::glance(basemap.alpha=1,style="mapnik")
#+ eval=F, echo=F
try(ursa::glance("Mount Eden",place="park",dpi=90))
#'
#' ### Пространст&shy;вен&shy;ные данные
#'
#' #### Векторы
#'
#' Библиотека | Формат | Импорт | Экспорт 
#' -----|------|-----|---
#' `sp` | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | **`rgdal`**`::readOGR()` | **`rgdal`**`::writeOGR()`
#' [`sf`](https://r-spatial.github.io/sf/) | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | `st_read()` | `st_write()`
#' [`gdalUtuls`](https://cran.rstudio.com/web/packages/gdalUtils/)<sup>*факультативно*<sup> | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | | оболочка системного GDAL
#'
#'
#' #### Растры
#'
#' Библиотека | Формат | Импорт | Экспорт
#' ---|----|--------|----
#' `sp` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | **`rgdal`**`::readGDAL()` | **`rgdal`**`::writeGDAL()`
#' `raster` | [RRASTER – R Raster](https://gdal.org/drivers/raster/rraster.html) | `raster()`, `brick()`, `stack()` | `writeRaster()`
#' `terra` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | `rast()` | `writeRaster()`
#' `stars` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | `read_stars()` | `write_stars()`
#' [`ncdf4`](https://cran.rstudio.com/web/packages/ncdf4/) | [NetCDF](https://gdal.org/drivers/raster/netcdf.html) | `nc_open()` | `nc_create()`
#' `ursa`| [ENVI - ENVI .hdr Labelled Raster](https://gdal.org/drivers/raster/envi.html) | `read_envi()` | `write_envi()`
#'
#' #### Визуализация
#'
#'  Статическая, экспортируемая в обычные форматы изображений. PNG, JPG поддерживают DPI.
#'
#' + `ggplot2` и надстройки (префикс `gg*`)
#'
#' + `ursa` 
#'
#' Интерактивная, отображаемая в браузере
#'
#' + `leaflet`
#'
#' + `mapview`
#'
#' + `tmap`
#'
#' ### По форматам
#'
#' #### Растры
#'
#' + Для хранения многослойные растров используется BSQ/BIL/BIP чередование слоев/строк/пикелей. Самый неэффективный - это BIP. При пространственно-временном анализе можно выбрать BIL, для большинства случаев - BSQ.
#' + Целочисленный GeoTIFF быстро пишется и читается при использовании функций из библиотеки `rgdal`
#'
#' #### Векторы
#'
#' + Хорошую скорость чтения и записи демонстрирует формат "SpatiaLite" при использовании библиотеки `sf`.
#'
#' + "GeoJSON" не очень быстрый, но можно использовать библиотеку [`geojsonf`](https://cran.rstudio.com/web/packages/geojsonsf/).
#'
#' + При записи использовать опции, предусмотренные для выбранного формата данных
#'
#' + При записи "ESRI Shapefile" обращать внимания на *.prj, так как у QGIS и ESRI-продуктов разные восприятия файлов проекций.
#'
#' ---
#'
#' #### <code>sf</code> или <code>sp</code>?
#'
#' + В пользу [`sf`]{.large} больше аргументов:
#'
#'    + удобнее, активно развивается, поддерживается
#'
#'    + в `sf` объекты класса S3, в `sp` объекты класса S4 (строже, но медленнее)
#'
#'    + есть `sf::as_Spatial()` для преобразования в объекты `sp`. Обратное преобразование: `sf::st_as_sf()`.
#'
#' + Эффективность с геометрией POINT выше у `sp` из-за представления атрибутивной таблицы и геометрии в одной таблице.
#'
#' + Ряд библиотек завязаны на формат данных `sp`, например
#' [`adehabitatHR`](https://cran.rstudio.com/web/packages/adehabitatHR/),
#' [`dismo`](https://cran.rstudio.com/web/packages/dismo/),
#' [`sdm`](https://cran.rstudio.com/web/packages/sdm/).
#'
#' ## Манипуляции с пространст&shy;вен&shy;ными данными
#'
#' ---
#'
#' ### Импорт {.middle}
#' Загрузить пространственные данные из файла
#'
#' #### Источники для примера
#+ shpfile
(shpname <- system.file("vectors","scot_BNG.shp",package="rgdal"))
file.exists(shpname)
#'
#+ tiffile
(tifname <- system.file("pictures/cea.tif",package="rgdal"))
file.exists(tifname)
#'
#' ---
#'
#+ scotBNG
ursa::session_grid(NULL)
ursa::glance(shpname,coast=FALSE,field="(NAME|AFF)",blank="white"
            ,legend=list("left","right"),dpi=88)
#'
#' ---
#'
#+ cea
ursa::session_grid(NULL)
ursa::glance(tifname,coast=FALSE,pal.from=0,pal=c("black","white"),dpi=96)
#'
#' ---
#'
#' #### Векторные данные
#'
#' ##### <code>rgdal/sp</code>
#' ::: {.oversize .h650}
#+ ogrinfo
rgdal::ogrInfo(shpname)
#' :::
#'
#' ---
#'
#+ readogr
b.sp <- rgdal::readOGR(shpname)
#'
#+ iss4
isS4(b.sp)
#+ slotnames
slotNames(b.sp)
#'
#' ---
#'
#' :::oversize
#+ eval=FALSE, include=FALSE
knitr::current_input()

#+ sppatch, include=FALSE
if (isTRUE(try(ursa:::.isRemark()))) {
   b.sp.wkt <- comment(b.sp@proj4string)
   comment(b.sp@proj4string) <- "| __truncated__"
}
#+ sp
str(head(b.sp,2))
#' :::
#'
#' ##### <code>sf</code> {#importExample}
#'
#+ stread
b.sf <- sf::st_read(shpname)
#'
#' ---
#'
#+ strsf
str(b.sf)
#'
#' #### Растровые данные
#'
#' ##### <code>rgdal/sp</code>
#' :::font92
#' Получение данных напрямую
#'
#+ readgdal
d1 <- rgdal::readGDAL(tifname)
#+ d1patch, include=FALSE
if (isTRUE(try(ursa:::.isRemark())))
   comment(d1@proj4string) <- "| __truncated__"
#+ strd1
str(d1)
#+ summaryd1
summary(d1@data[[1]])
#' :::
#'
#' ---
#'
#' Получение данных более гибким способом
#'
#+ gdalinfo
md <- rgdal::GDALinfo(tifname)
mdname <- names(md)
attributes(md) <- NULL
names(md) <- mdname
md
#+ getrasterdata
dset <- methods::new("GDALReadOnlyDataset",tifname)
d2 <- rgdal::getRasterData(dset,offset=c(0,0)
                          ,region.dim=md[c("rows","columns")])
str(d2)
summary(c(d2))
#'
#' ---
#'
#' ##### `raster`
#+ raster
(d3 <- raster::brick(tifname))
#+ sizev3
v3 <- d3[] ## 'd3[]' то же, что и 'raster::getValues(d3)'
c(d3=object.size(d3),v3=object.size(v3))
#+ strv3
str(v3)
#+ summaryv3
summary(c(v3))
#'
#' ---
#'
#' ##### `terra`
#+ terra
(d4 <- terra::rast(tifname))
#+ sizev4
v4 <- d4[] ## 'd4[]' то же, что и 'terra::values(d3)'
c(d4=object.size(d4),v3=object.size(v4))
#+ strv4
str(v4)
#+ summaryv4
summary(c(v4))
#'
#' ---
#'
#' ### Характеристики {.middle}
#'
#' Характеристики, свойства и компоненты пространственных данных
#'
#' ##### `sp`
#+
class(b.sp$NAME)
class(b.sp[["NAME"]])
class(b.sp["NAME"])
#'
#' ##### `sf`
#+
class(b.sf$NAME)
class(b.sf[["NAME"]])
class(b.sf["NAME"])
#'
#' #### Таблица атрибутов
#'
#' ##### `sp`
#+ spdata
head(slot(b.sp,"data"))
#'
#' ##### `sf`
#+ sfdata
head(sf::st_set_geometry(b.sf,NULL))
#'
#' #### Геометрия
#'
#' ##### `sp`
#' :::oversize
#+ spgeom
g.sp <- sp::geometry(b.sp)
#+ strspgeom
str(head(g.sp,2)) ## много строк; выведем первые две записи
#' :::
#' ##### `sf`
#+ headsfgeom
(head(g.sf <- sf::st_geometry(b.sf),2))
#+ strsfgeom
str(g.sf)
#'
#' #### Проекция {.middle}
#'
#' В современных пакетах R данные проекции представляются в виде WKT;
#' по возможножности, сохраняется связь с EPSG и PROJ.
#'
#' ##### `sp`
#+ projsppatch, include=FALSE
if (isTRUE(try(ursa:::.isRemark())))
   comment(b.sp@proj4string) <- b.sp.wkt
#+ projsp
sp::proj4string(b.sp)
#' ##### `sf`
#' :::oversize
#+ projsf
sf::st_crs(b.sf)
#' :::
#'
#' ---
#'
#+ sfproj4
sf::st_crs(b.sf)$proj4string
#'
#' #### Пространственный охват
#'
#' ##### `sp`
#+ bboxsp
sp::bbox(b.sp)
#' ##### `sf`
#+ bboxsf
sf::st_bbox(b.sf)
#'
#' ### Создание {.middle}
#'
#'  Создание пространственных данных, например, новый слой ГИС
#'
#' ---
#'
#' Выйдем из здания вокзала ст. Валдай и создадим точечный `Spatial`-объект:
#+ railway
pt0 <- data.frame(lon=33.24529,lat=57.97012)
sp::coordinates(pt0) <- ~lon+lat
sp::proj4string(pt0) <- sp::CRS("+init=epsg:4326")
#'
#' ---
#'
#+ Valdai
ursa::glance(pt0,resetProj=TRUE,style="mapnik"
            ,basemap.order="before",basemap.alpha=1,dpi=91)
#'
#' ---
#'
#' Смотрим на структуру данных:
#+ pt0patch, include=FALSE
if (isTRUE(try(ursa:::.isRemark()))) {
   pt0.wkt <- comment(pt0@proj4string)
   comment(pt0@proj4string) <- "| __truncated__"
}
#+ strbegin
str(pt0)
#+ pt0wktbackpatch, include=FALSE
if (isTRUE(try(ursa:::.isRemark())))
   comment(pt0@proj4string) <- pt0.wkt
#' Изменим проекцию для расчета расстояний по координатам:
#+ tometers
pt0 <- sp::spTransform(pt0,"+proj=laea +lat_0=58 +lon_0=35 +datum=WGS84")
#' Извлечем координаты:
#+ walkcoords
xy <- sp::coordinates(pt0)
#'
#' ---
#'
#' Решаем перемещаться минутными сегментами в течение часа:
#+ onehour
n <- 60
#' На основе координат создаем таблицу перемещения. По умолчанию весь период стоим на месте и смотрим на север:
#+ tonorth
loc <- data.frame(step=seq(0,n),look=pi/2,x=xy[,1],y=xy[,2])
#' Скорость перемещений (в м&nbsp;мин<sup>-1</sup>) в течение минуты случайна:
#+ segment
segment <- runif(n,min=5,max=80)
str(segment)
#'
#' ---
#'
#' Задаем, что если следующий сегмент длинный, то отклонение направления от предыдущего сегмента будет меньше:
#+ angle
angle <- sapply(1-segment/100,function(x) runif(1,min=-x*pi,max=x*pi))
str(angle)
#' Заполняем последующие шаги на основе предыдущих:
#+ stepbystep
for (i in seq(n)) {
   loc$look[i+1] <- (loc$look[i]+angle[i]) %% (2*pi)
   loc$x[i+1] <- loc$x[i]+segment[i]*cos(loc$look[i+1])
   loc$y[i+1] <- loc$y[i]+segment[i]*sin(loc$look[i+1])
}
head(loc)
#'
#' ---
#'
#' Создадим линейный `sf`-объект
#+ transect
tr <- vector("list",n)
#' Матрица (с двумя столбцами) координат задается как LINESTRING:
#+ trline
for (i in seq(n))
   tr[[i]] <- sf::st_linestring(matrix(c(loc$x[i],loc$y[i],loc$x[i+1],loc$y[i+1])
                               ,ncol=2,byrow=TRUE))
#'
#' ---
#'
#' :::oversize
str(tr)
#' :::
#'
#' ---
#'
#' Набор сегментов объединяем в геометрию:
#+ trsfc
tr <- sf::st_sfc(tr,crs=sp::proj4string(pt0))
str(tr)
#' С геометрией связываем атрибутивную таблицу.
#+ trsf
tr <- sf::st_sf(step=seq(n),segment=segment,geometry=tr)
str(tr)
#'
#' ### Визуализация
#'
#' #### Статическая
#'
#+ route
ursa::session_grid(NULL)
ursa::glance(tr,style="mapnik",plot.lwd=5
            ,layout=c(1,2),legend=list("left",list("bottom",2)),las=1,dpi=96)
#'
#' ---
#'
#' :::middle
#' Графическое отображение переопределенной под класс объекта функцией `plot()` средствами библиотеки `sp` и `sf` развито слабо...
#' :::
#'
#' ---
#'
#+ trplot-sf
plot(tr,lwd=5) ## 'sf'-object
#'
#' ---
#'
#+ trplot-sp
sp::plot(sf::as_Spatial(tr),lwd=5) ## 'sp'-object ('SpatialPointsDataFrame')
#'
#' ---
#'
#' [Возвращаясь](#importExample) к ранее загруженным данным
#+ scotplot
plot(b.sf["AFF"])
#'
#' ---
#'
#+ scotplotgeom
plot(sf::st_geometry(b.sf),col=sf::sf.colors(12,categorical=TRUE)
    ,border='grey',axes=TRUE)
#'
#' ---
#'
#' :::middle
#' Для оформления карт можно использовать функционал других библиотек.
#' :::
#'
#' ##### `ggplot2`
#+ ggplot
require(ggplot2)
#+ geomsf
ggplot()+
   geom_sf(data=b.sf,aes(fill=AFF))+
   coord_sf(crs=sf::st_crs(3857))
#' ##### `tmap`
#+ tmap-plot
require(tmap)
tmap_mode("plot")
(tm1 <- tm_shape(b.sf) + tm_polygons("COUNT") + tm_scale_bar() +
   tm_compass(position=c("left","bottom")) + tm_graticules())
#' ##### Для публикаций
#+ paper-create, eval=T
fileout4 <- "assets/general/firstmap.png"
if (!dir.exists(dirname(fileout4)))
   dir.create(dirname(fileout4),recursive=TRUE)
png(fileout4, res=300, width=1600, height=1200,
    type="cairo", pointsize=12, family="sans")
print(tm1)
dev.off()
#'
#' ---
#'
#+ paper-view
knitr::include_graphics(fileout4) ## try 'browseURL(fileout4)'
#'
#' #### Интерактивная
#'
#' ##### `mapview`
#+ mapview
m <- mapview::mapview(b.sf) ## Не отобразится в Jupyter R Notebook.
m
#'
#' ##### `leaflet`
#+ leafletload
require(leaflet)
#+ leaflet
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
#' ---
#'
#+ leadletwidget
m ## Не отображается в Jupyter R Notebook.
#' ##### `tmap`
#+ tmap-view, results='asis'
tmap_mode("view")
tm <- tm_shape(b.sf) + tm_polygons("COUNT")
tmap_leaflet(tm)
#'
#' ---
#'
#' [`tmap` `r dQuote("Get Started")` vignette](https://cran.rstudio.com/web/packages/tmap/vignettes/tmap-getstarted.html)
#+ tmap-vignette, echo=FALSE
knitr::include_url("https://cran.rstudio.com/web/packages/tmap/vignettes/tmap-getstarted.html"
                  ,height=610)
#'
#' ##### Примеры
#' [GeoSpatial Data Visualization in R](https://bhaskarvk.github.io/user2017.geodataviz/)
#+ geodataviz, echo=FALSE
knitr::include_url("https://bhaskarvk.github.io/user2017.geodataviz/",height=610)
#'
#' ### Экспорт {.middle}
#'
#' Сохранить пространственные данные в файл
#'
#' ##### `sp/rgdal`
#'
#+ writeogr
pt <- loc
sp::coordinates(pt) <- ~x+y
sp::proj4string(pt) <- sp::proj4string(pt0)
pt <- sp::spTransform(pt,"EPSG:4326")
fileout1 <- "afterTrain.geojson"
rgdal::writeOGR(pt,fileout1,gsub("\\..+","",basename(fileout1)),driver="GeoJSON"
                 ,overwrite_layer=TRUE,morphToESRI=FALSE)
#'
#' Проверим, появился ли файл:
#+ ptexists
dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*")))
#'
#' ---
#'
#+ glancept
try(ursa::glance(fileout1,style="mapnik",las=1,size=480,dpi=192))
#'
#' ##### `sf`
#'
#+ stwrite
b.sf <- b.sf[,c("NAME","COUNT")]
b.sf$'категория' <- b$category
b.sf <- sf::st_transform(b.sf,3857)
fileout2 <- "scotland.sqlite"
sf::st_write(b.sf,dsn=fileout2,layer=gsub("\\..+","",basename(fileout2))
            ,driver="SQLite",layer_options=c("LAUNDER=NO"),quiet=TRUE
            ,delete_layer=file.exists(fileout2),delete_dsn=file.exists(fileout2))
#+ scotexists
dir(pattern=paste0(gsub("\\..+","",basename(fileout2),".*")))
#'
#' ---
#'
#+ glancescot
try(ursa::glance(fileout2,resetGrid=TRUE
                ,style="mapnik",las=1,dpi=192,size=480))
#'
#' ---
#'
#+ track
fileout3 <- "track.shp"
sf::st_write(tr,dsn=fileout3,layer=gsub("\\..+","",basename(fileout2))
            ,driver="ESRI Shapefile",quiet=TRUE
            ,delete_layer=file.exists(fileout3),delete_dsn=file.exists(fileout3))
#+ trackexists
dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*")))
#'
#' ---
#'
#+ glancetrack
try(ursa::glance(fileout3,resetGrid=TRUE
                ,style="mapnik",las=1,dpi=192,size=480))
#'
#' ### Рисование
#'
#' Этот раздел предлагается пройти самостоятельно
#'
#+ mapedit, eval=rmarkdown::default_output_format(knitr::current_input())$name=="html_document"
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
#'
#' ## Дополнительно по R
#'
#' ### Воспроизво&shy;ди&shy;мость
#'
#' Ниже приведены фрагмента кода, которые не были выполнены при составлении программы занятия. Их предлагается выполнить самостоятельно. Также необходимо [установленный Pandoc](#pandoc).
#'
#' Содержимое занятия сгенерировано из файла `lesson05.R`. Загрузим его, переименовав:
#+ download, eval=FALSE
sfile <- "lesson05.R"
rfile <- "lesson05-reproduced.R"
{
   if (file.exists(sfile))
      file.copy(sfile,rfile,overwrite=TRUE,copy.date=TRUE)
   else
      download.file(file.path("https://nplatonov.github.io/sevinGIS",sfile)
                   ,rfile)
}
#' <!-- file.copy("main.R","lesson.R",overwrite=TRUE,copy.date=TRUE) -->
#'
#' ---
#'
#' На основе этого файла создадим markdown-документ:
#+ spin, eval=FALSE
mdfile <- knitr::spin(rfile,knit=FALSE)
mdfile
#' Затем из markdown-документа сформируем html-документ:
#+ render, eval=FALSE
if (rmarkdown::pandoc_available()) {
   htmlfile <- rmarkdown::render(mdfile,output_format="html_document"
                                ,output_options=list(toc=TRUE))
   print(basename(htmlfile))
}
#' Полученный html-документ можно открыть в браузере.
#+ browse, eval=FALSE
if ((rmarkdown::pandoc_available())&&(file.exists(htmlfile))) 
   browseURL(basename(htmlfile))
#' И можно скопировать/переименовать/удалить
#'
#' #### Параметры сессии
#' :::oversize
#+ session
sessionInfo()
#' :::
#'
#' ### Узнать больше об R
#'
#' + [R-Bloggers](https://www.r-bloggers.com/) -- современные тенденции R
#'
#' + R's [Spatial](https://cran.rstudio.com/web/views/Spatial.html) and [SpatioTemporal](https://cran.rstudio.com/web/views/SpatioTemporal.html) Task Views 
#'
#' + [R-Spatial](https://www.r-spatial.org/) -- веб-сайт и блог для интересующихся использованием R для анализа пространственных и пространственно-временных данных
#'
#' + [Geocomputation with R ](https://geocompr.github.io) - book and relative
#'
#' + [Stackoverflow](https://stackoverflow.com/feeds/tag/r) с тегом #R.
#'
#' + [Stackexchange](https://gis.stackexchange.com/questions) о ГИС, в т.ч. с использованием R.
#'
#' + Package's vignettes -- обобщенное знакомство с библиотекой. Обычно содержат воспроизводимый код.
#'
#' ######
#'
#' ::: {.small .bottom}
#' Данные после занятия остались на диске. Если не нужны, выполнить следующее: 
#+ clear, eval=TRUE
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout2),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*"))))
#' :::
#'
#' ```{css, echo=F, eval=T}
#' :root {
#'    --pointsize: 20pt;
#'    --sidebar-pointsize: 78%;
#'    --sidebar: 25%;
#' }
#' ```
