#' ---
#' output:
#'    revealjs::revealjs_presentation: default
#'    html_document: default
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
#' date: "`r paste('Обновлено:',format(Sys.time(),'%Y-%m-%d %H:%M'),'<br>','[pdf-версия](?print-pdf){.scale80 .pdflink .noprint}')`"
#' abstract: Для желающих сделать первые шаги в освоении R демонстрация основ работы с интерфейсом командной строки в R, позволяющей создавать скрипты и получать воспроизводимые результаты. Узнаете, как пространственные векторные и растровые данные могут попасть в R и как они выглядят в R. Попробуете сделать обработку, анализ и визуализацию пространственных данных.
#' ---

#+ hprint, include=FALSE
knitr::opts_chunk$set(comment="##",collapse=FALSE)
options(width=80)
if (!exists("h1"))
   h1 <- function(hdr,...) paste("#",hdr)
if (!exists("h2"))
   h2 <- function(hdr,...) paste("##",hdr)
if (!exists("h3"))
   h3 <- function(hdr,...) paste("###",hdr)
baseURL <- ifelse(F,".","https://nplatonov.github.io/SCGIS2019")
#'
#' `r h1("Планирование (до&nbsp;27&nbsp;сентября)",ref="intro",opt=".middle")`
#'
#' `r h2("Предлагаемый подход к формированию темы мастер-класса",ref="approach")`
#'
#' Планируется, что основные материалы для проведения мастер-класса появятся здесь к 27 сентября.
#' Предполагается, что некоторые дополнения могут быть внесены и в более поздний срок, но с учетом того, чтобы эти изменения не потребовали существенного заимствования времени от занятия.
#' Основной режим проведения мастер-класса - это копирование/вставка фрагмента кода, поэтому этот материал может быть использован дистанционными участниками.
#'
#' Факультативно задумывается и осваивается вариант занятия с использованием Jupyter R Notebook. Установку необходимых программных компонентов нужно выполнить самостоятельно.
#'
#' Пожелания по затрагиванию какой-либо темы могут быть приняты [&#x2709;](mailto:platonov@sevin.ru) не позднее 27 сентября.
#'
#' `r h1("Подготовка (до&nbsp;05&nbsp;октября)",opt=".middle",ref="before")`
#'
#' `r h2("Операционные системы пользователя",ref="os")`
#'
#' Не для всех операционных систем есть скомпилированные модули (ядро R, библиотеки). В таком случае модули компилируются, и на это уходит какое-то время. Поэтому если ОС не OS Windows, то этот этап нужно пройти заранее.
#'
#' `r h2("Установка базового R",ref="base")`
#'
#' Установить или обновить R, например, [отсюда](https://cran.rstudio.com/). Актуальная версия 3.6.1. Не ниже версии 3.0.
#'
#' `r h2("Установка необходимых библиотек",entry="first",ref="contribute1")`
#'
#+ require, class.source="height450"
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
#'
#' `r h2("Установка необходимых библиотек",entry="next",ref="contribute2")`
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
#' `r h2("Установка дополнительного программного обеспечения",ref="extended1",entry="first")`
#'
#' `r h3("Pandoc",ref="pandoc")`
#'
#' :::scale85
#' Pandoc необходим для создания воспроизводимого результата. Этот шаг опциональный, и может быть пропущен, но в этом случае на занятии будет пропущен раздел по [публикации результатов](#report1).
#'
#' [Ссылка](https://pandoc.org/installing.html) на страницу для скачивания. Для пользователей Windows достаточно перейти к [скачиванию актуального релиза](https://github.com/jgm/pandoc/releases/latest), и выбрать либо установщик (`*.msi`), либо архив (`*.zip`). Запомнить путь, куда произведена установка и где находится файл `pandoc.exe` и добавить этот путь в переменную окружения `%PATH%`, например: WindowsKey+Q, ввести "Переменные среды/Environment Variables", попасть в окошко "Свойства Системы/System Properties", нажать на кнопку "Переменные среды/Environment Variables" и отредактировать пользовательскую или системную переменную PATH, добавив путь к `pandoc.exe`.
#'
#' Чтобы проверить правильно ли установлен Pandoc, в новой R-сессии:
#' :::
#+ pandoc
rmarkdown::pandoc_available()
#'
#' `r h2("Установка дополнительного программного обеспечения",ref="extended2",entry="next")`
#'
#' `r h3("Jupyter R Notebook",ref="conda")`
#'
#' :::scale73
#' Jupyter Notebook для работы с кодом в браузере.
#'
#' 1. [Загрузить](https://docs.conda.io/en/latest/miniconda.html) и установить менеджер Miniconda (проверено на Windows 64bit Python 3.7).
#'
#' 2. Запустить `conda` (На Windows попробовать WinKey+Q и начать вводить "Anaconda")
#'
#' 3. Последовательно выполнить команды (в среде Conda, не в среде R):
#'
#' :::
#' Команда | Описание
#' ---|---
#' `conda install jupyter` | установка Jupyter Notebook
#' `conda install -c r r-recommended r-irkernel` | Установка R, базовых библиотек и библиотеки для использования R в Jupyter Notebook
#' `conda install -c conda-forge jupytext` | Установка преобразователя кода R в формат Jupyter Notebook
#'
#' :::scale73
#' Предварительно скачайте [`main.R`](`r baseURL`/main.R) или только код [`codeOnly.R`](`r baseURL`/codeOnly.R), если будете использовать на занятии Jupyter Notebook. Если проблема с кодировкой остается, попробуйте взять 
#' [`codeOnly1251.R`](`r baseURL`/codeOnly1251.R)
#' Предупреждение: описательный текст (markdown) местами не отформатирован, в частности, не будут отображаться таблицы; также не будут отображаться html-виджеты.
#'
#' :::
#'
#' `r h2("Как использовать материал",ref="howto")`
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
#' `r h2("Начало работы",ref="openR1",entry="first")`
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
#' `r h2("Начало работы",ref="openR2",entry="last")`
#'
#' Команда для проверки кириллицы:
#+ russian, echo=TRUE
print(c('Здесь кириллица?'="Да!"),quote=FALSE)
#'
#' Если вывод не читаемый, то возможные пути решения:
#'
#' ::: scale80
#' 1. Задать кириллицу для символьной локали:
#' :::
#'
#+ locale, results="hide"
if (.Platform$OS.type=="windows")
   Sys.setlocale("LC_CTYPE","Russian")
#'
#' ::: scale80
#' 2. Если скрипты подключаются через `source()`, то можно настроить запуск R через конфигурационные файлы. Например, скачать [.Rprofile](`r baseURL`/.Rprofile), разместить в рабочей директории, перегрузить R. Файл имеет следующую структуру:
#' :::
#'
#'     local({
#'        options(encoding="UTF-8")
#'        Sys.setlocale("LC_CTYPE","Russian")
#'      })
#'
#' ::: scale80
#' 3. Если скрипт `bar.R` с кириллицей в кодировке UTF-8 запускается из командной строки, то использовать следующие параметры запуска.
#' :::
#'      R --encoding UTF-8 -f bar.R
#'
#' `r h1("Занятие (05&nbsp;октября)",opt=".middle",ref="openday")`
#'
#' `r h2("R как ГИС?",ref="gis")`
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
#' `r h2("Структуры данных",ref="typeof2",entry="first")`
#'
#' `r h3("Числа и имена значений")`
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
#' `r h2("Структуры данных",ref="typeof3",entry="next")`
#'
#' `r h3("Целые числа, числа с плавающей точкой")`
#+ stra2int
str(a2+0L)
#+ stra2num
str(a2+0)
#+ typeofa2int
typeof(a2+0L)
#+ typeofa2num
typeof(a2+0)
#'
#' `r h2("Структуры данных",ref="typeof4",entry="next")`
#'
#' `r h3("Логические значения, строки")`
#+ a3
(a3 <- sample(c(TRUE,FALSE),length(a2),replace=TRUE))
#+ classa3
class(a3)
#+ stra3
str(a3)
#+ a4
(a4 <- names(a2))
#+ classa4
class(a4)
#+ stra4
str(a4)
#'
#' `r h2("Структуры данных",ref="typeof5",entry="next")`
#'
#' `r h3("Списки одинаковой длины")`
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
#' `r h2("Структуры данных",ref="typeof6",entry="next")`
#'
#' `r h3("Таблицы")`
#+ a6
(a6 <- data.frame(num=a1[c(1,3:7)],char=a4[-2]))
#+ stra6
str(a6)
#+ classa6
class(a6)
#+ dima6
dim(a6)
#'
#' `r h2("Структуры данных",ref="typeof7",entry="next")`
#'
#' `r h3("Списки различной длины")`
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
#' `r h2("Структуры данных",ref="typeof1",entry="next")`
#'
#' `r h3("Матрицы")`
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
#' `r h2("Структуры данных",ref="typeof8",entry="next")`
#'
#' `r h3("Массивы")`
#+ a8
(a8 <- array(sample(24),dim=c(3,4,2)))
#+ stra8
str(a8)
#+ classa8
class(a8)
#'
#' `r h2("Структуры данных",ref="typeof9",entry="last")`
#'
#' `r h3("Факторы")`
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
#'
#' `r h2("Визуализация данных",ref="visual1",entry="first")`
#'
#' :::scale93
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
#' :::
#'
#' `r h3("Пример путешествия мимо/через Спб",ref="spb1",entry="first",opt=".scale93")`
#'
n <- 60
seqx <- seq(20,40,by=5)
seqy <- seq(55,65,by=2)
x <- sort(runif(n,min=min(seqx),max=max(seqx)))
y <- sort(runif(n,min=min(seqy),max=max(seqy)))
#'
#' `r h2("Визуализация данных",ref="visual2",entry="next")`
#'
#' `r h3("Пример путешествия мимо/через Спб",ref="spb2",entry="next")`
#'
#+ spb1, fig.width=6, fig.height=4, out.height="450px",out.width="600px"
plot(x,y,type="n",asp=NA,axes=FALSE,xlab="",ylab="")
lines(x,y,lwd=4,col="black")
lines(x,y,lwd=3,col="orange")
box()
axis(1,at=seqx,lab=paste0(seqx,"°E"),lwd=0,lwd.ticks=1,las=1)
axis(2,at=seqy,lab=paste0(seqy,"°N"),lwd=0,lwd.ticks=1,las=1)
#'
#' `r h2("Визуализация данных",ref="visual3",entry="next")`
#'
#' `r h3("Пример путешествия мимо/через Спб",ref="spb3",entry="next")`
#'
#+ spb2
e <- sf::st_sfc(sf::st_linestring(cbind(x,y)),crs=4326)
ursa::session_grid(NULL)
ursa::glance(e,blank="white",coast.fill="#00000010",height=320,dpi=66
            ,col="black",plot.lwd=5)
#'

#' `r h2("Визуализация данных",ref="visual4",entry="next")`
#'
#' `r h3("<code>data(volcano)</code>",ref="volcano1",entry="first")`
#'
#+ imgvolcano
image(volcano)
#'
#' `r h2("Визуализация данных",ref="visual5",entry="last")`
#'
#' `r h3("<code>data(volcano)</code>",ref="volcano2",entry="next")`
#'
#' Это вулкан Maunga Whau (Mt Eden).
#'
#+ glancevolcano
try(ursa::glance("Mount Eden",place="park",dpi=83))


#' `r h2("Манипуляции с файлами пространственных данных",ref="connection",entry="default")`
#'
#' Векторные данные
#'
#' :::scale120
#' Библиотека | Формат | Импорт | Экспорт 
#' -----|------|-----|---
#' `sp` | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | **`rgdal`**`::readOGR()` | **`rgdal`**`::writeOGR()`
#' [`sf`](https://r-spatial.github.io/sf/) | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | `st_read()` | `st_write()`
#' <!--[`gdalUtuls`](https://cran.rstudio.com/web/packages/gdalUtils/)^*факультативно*^ | [GDAL vector drivers](https://gdal.org/drivers/vector/index.html) | | оболочка системного GDAL -->
#' :::
#'
#'
#' Растровые данные
#'
#' :::scale120
#' Библиотека | Формат | Импорт | Экспорт
#' ---|----|--------|----
#' `sp` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | **`rgdal`**`::readGDAL()` | **`rgdal`**`::writeGDAL()`
#' `raster` | [GDAL raster drivers](https://gdal.org/drivers/raster/index.html) | `raster()`, `brick()`, `stack()` | `writeRaster()`
#' [`ncdf4`](https://cran.rstudio.com/web/packages/ncdf4/) | [NetCDF](https://gdal.org/drivers/raster/netcdf.html) | `nc_open()` | `nc_create()`
#' `ursa`| [ENVI](https://gdal.org/drivers/raster/envi.html) | `read_envi()` | `write_envi()`
#' :::
#'
#' `r h2("Особенности форматов данных",ref="formats1",entry="first")`
#'
#' `r h3("Растровые данные")`
#'
#' + Для хранения многослойные растров используется BSQ/BIL/BIP чередование слоев/строк/пикелей. Самый неэффективный - это BIP. При пространственно-временном анализе можно выбрать BIL, для большинства случаев - BSQ.
#' + Целочисленный GeoTIFF быстро пишется и читается при использовании функций из библиотеки `rgdal`
#'
#' `r h3("Векторные данные")`
#'
#' + Хорошую скорость чтения и записи демонстрирует формат "SQLite" при использовании библиотеки `sf`.
#'
#' + "GeoJSON" не очень быстрый.
#'
#' + При записи использовать опции, предусмотренные для выбранного формата данных
#'
#' + При записи "ESRI Shapefile" обращать внимания на *.prj, так как у QGIS и ESRI-продуктов разные восприятия файлов проекций.
#'
#' `r h2("Особенности форматов данных",ref="formats2",entry="last")`
#'
#' `r h3("<code>sf</code> или <code>sp</code>?")`
#'
#' + В пользу [`sf`]{.scale110} больше аргументов:
#'
#'    + удобнее, активно развивается, поддерживается
#+
#'    + в `sf` объекты класса S3, в `sp` объекты класса S4 (строже, но медленнее)
#'
#'    + Эффективность с геометрией POINT выше у `sp` из-за представления атрибутивной таблицы и геометрии в одной таблице.
#'
#'    + Ряд библиотек завязаны на формат данных `sp`, например [`adehabitatHR`](https://cran.rstudio.com/web/packages/adehabitatHR/).
#'
#'    + есть `sf::as_Spatial()` для преобразования в объекты `sp`.
#'
#' `r h2("Импорт пространственных данных",ref="import1",entry="first")`
#'
#' `r h3("Используемые данные для примера",ref="systemfiles")`
#+ shpfile
(shpname <- system.file("vectors","scot_BNG.shp",package="rgdal"))
file.exists(shpname)
#'
#+ tiffile
(tifname <- system.file("pictures/cea.tif",package="rgdal"))
file.exists(tifname)
#'
#' `r h2("Импорт пространственных данных",ref="import2",entry="next")`
#'
#+ scotBNG
ursa::session_grid(NULL)
ursa::glance(shpname,coast=FALSE,field="(NAME|AFF)",blank="white"
            ,legend=list("left","right"),dpi=88)
#'
#' `r h2("Импорт пространственных данных",ref="import3",entry="next")`
#'
#+ cea
ursa::session_grid(NULL)
ursa::glance(tifname,coast=FALSE,pal.from=0,pal=c("black","white"),dpi=96)
#'
#' `r h2("Импорт пространственных данных",ref="import4",entry="next")`
#'
#' `r h3("Векторные данные -- <code>rgdal/sp</code>",entry="first")`
#'
#+ ogrinfo
rgdal::ogrInfo(shpname)
#+ readogr
b.sp <- rgdal::readOGR(shpname)
#'
#' `r h2("Импорт пространственных данных",ref="import5",entry="next")`
#'
#' `r h3("Векторные данные -- <code>rgdal/sp</code>",entry="next")`
#'
#+ sp, class.output="height380"
str(head(b.sp,2))
#+ iss4
isS4(b.sp)
#+ slotnames
slotNames(b.sp)
#'
#' `r h2("Импорт пространственных данных",ref="import6",entry="next")`
#'
#' `r h3("Векторные данные -- <code>sf</code>",entry="first",ref="importExample")`
#'
#+ stread
b.sf <- sf::st_read(shpname)
#'
#' `r h2("Импорт пространственных данных",ref="import7",entry="next")`
#'
#' `r h3("Векторные данные -- <code>sf</code>",entry="last")`
#'
#+ strsf, class.output="height550"
str(b.sf)
#'
#' `r h2("Импорт пространственных данных",ref="import8",entry="next")`
#'
#' `r h3("Растровые данные -- <code>rgdal/sp</code>",ref="rgdal1",entry="first")`
#'
#' Получение данных напрямую
#'
#' :::scale90
#+ readgdal
d1 <- rgdal::readGDAL(tifname)
#+ strd1
str(d1)
#+ summaryd1
summary(d1@data[[1]])
#' :::
#'
#'
#' `r h2("Импорт пространственных данных",ref="import9",entry="next")`
#'
#' `r h3("Растровые данные -- <code>rgdal/sp</code>",ref="rgdal2",entry="last")`
#'
#' Получение данных более гибким способом
#'
#' ::: scale89
#+ gdalinfo
md <- rgdal::GDALinfo(tifname)
mdname <- names(md)
attributes(md) <- NULL
names(md) <- mdname
md
#+ getrasterdata
dset <- methods::new("GDALReadOnlyDataset",tifname)
d2 <- rgdal::getRasterData(dset,offset=c(0,0),region.dim=md[c("rows","columns")])
str(d2)
summary(c(d2))
#' :::
#'
#' `r h2("Импорт пространственных данных",ref="import10",entry="next")`
#'
#' `r h3("Растровые данные -- <code>raster</code>",ref="raster1",entry="first")`
#'
#' :::scale88
#+ raster
(d3 <- raster::brick(tifname))
#+ sized3

#+ sizev3
v3 <- d3[] ## 'd3[]' то же, что и 'raster::getValues(d3)'
c(d3=object.size(d3),v3=object.size(v3))
#+ strv3
str(v3)
#+ summaryv3
summary(c(v3))
#' :::
#'
#' `r h2("Характеристики пространственных данных",ref="extract1",entry="first")`
#'
#' `r h3("Атрибутивная таблица",entry="first")`
#'
#' `sp`:
#+ spdata
head(slot(b.sp,"data"))
#'
#' `r h2("Характеристики пространственных данных",ref="extract2",entry="next")`
#'
#' `r h3("Атрибутивная таблица",entry="next")`
#'
#' `sf`:
#+ sfdata
head(sf::st_set_geometry(b.sf,NULL))
#'
#' `r h2("Характеристики пространственных данных",ref="extract3",entry="next")`
#'
#' `r h3("Геометрия",entry="first")`
#'
#' `sp`:
#+ spgeom
g.sp <- sp::geometry(b.sp)
#+ noprintspgeom, eval=FALSE
g.sp ## Не показано: много строк
#'
#+ strspgeom, class.output="height360"
str(head(g.sp,2))
#'
#' `r h2("Характеристики пространственных данных",ref="extract4",entry="next")`
#'
#' `r h3("Геометрия",entry="last")`
#'
#' `sf`:
#+ headsfgeom
(head(g.sf <- sf::st_geometry(b.sf),2))
#+ strsfgeom
str(g.sf)
#'
#' `r h2("Характеристики пространственных данных",ref="extract5",entry="next")`
#'
#' `r h3("Проекция")`
#'
#' В R данные проекции представляются в виде PROJ.4, поэтому при импорте/экспорте данных осуществляется двойное WKT&nbsp;->&nbsp;PROJ4&nbsp;->&nbsp;WKT преобразование
#'
#' `sp`:
#+ projsp
sp::proj4string(b.sp)
#' `sf`:
#+ projsf
sf::st_crs(b.sf)
#'
#' `r h2("Характеристики пространственных данных",ref="extract6",entry="next")`
#'
#' `r h3("Пространственный охват")`
#'
#' `sp`:
#+ bboxsp
sp::bbox(b.sp)
#' `sf`:
#+ bboxsf
sf::st_bbox(b.sf)
#'
#' `r h2("Создание пространственных данных",ref="create1",entry="first")`
#'
#' Выйдем из здания вокзала ст. Валдай и создадим точечный `Spatial`-объект:
#+ railway
pt0 <- data.frame(lon=33.24529,lat=57.97012)
sp::coordinates(pt0) <- ~lon+lat
sp::proj4string(pt0) <- sp::CRS("+init=epsg:4326")
#+ Valdai
ursa::glance(pt0,style="mapnik",basemap.order="before",basemap.alpha=1,dpi=91)
#'
#' `r h2("Создание пространственных данных",ref="create2",entry="next")`
#'
#' Смотрим на структуру данных:
#+ strbegin
str(pt0)
#' Изменим проекцию для расчета расстояний по координатам:
#+ tometers
pt0 <- sp::spTransform(pt0,"+proj=laea +lat_0=58 +lon_0=35 +datum=WGS84")
#' Извлечем координаты:
#+ walkcoords
xy <- sp::coordinates(pt0)
#'
#' `r h2("Создание пространственных данных",ref="create3",entry="next")`
#'
#' Решаем перемещаться минутными сегментами в течение часа:
#+ onehour
n <- 60
#' На основе координат создаем таблицу перемещения. По умолчанию весь период стоим на месте и смотрим на север:
#+ tonorth
loc <- data.frame(step=seq(0,n),look=pi/2,x=xy[,1],y=xy[,2])
#' Скорость перемещений (в м&nbsp;мин^-1^) в течение минуты случайна:
#+ segment
segment <- runif(n,min=5,max=80)
str(segment)
#' Задаем, что если следующий сегмент длинный, то отклонение направления от предыдущего сегмента будет меньше:
#+ angle
angle <- sapply(1-segment/100,function(x) runif(1,min=-x*pi,max=x*pi))
str(angle)
#'
#' `r h2("Создание пространственных данных",ref="create4",entry="next")`
#'
#' Заполняем последующие шаги на основе предыдущих:
#+ stepbystep
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
#+ transect
tr <- vector("list",n)
#' Матрица (с двумя столбцами) координат задается как LINESTRING:
#+ trline, class.output="height340"
for (i in seq(n))
   tr[[i]] <- sf::st_linestring(matrix(c(loc$x[i],loc$y[i],loc$x[i+1],loc$y[i+1])
                               ,ncol=2,byrow=TRUE))
str(tr)
#'
#' `r h2("Создание пространственных данных",ref="create6",entry="last")`
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
#' `r h2("Статическая визуализация",ref="plot1",entry="first")`
#'
#+ route
ursa::session_grid(NULL)
ursa::glance(tr,style="mapnik"
            ,layout=c(1,2),legend=list("left",list("bottom",2)),las=1,dpi=96)
#'
#' `r h2("Статическая визуализация",ref="plot2",entry="next")`
#'
#' Графическое отображение переопределенной под класс объекта функцией `plot()` средствами библиотеки `sp`^(факультативно)^ и `sf` развито слабо...
#+ trplot, out.width="80%"
plot(tr)
#'
#' `r h2("Статическая визуализация",ref="plot3",entry="next")`
#'
#' [Возвращаясь](#importExample) к ранее загруженным данным:
#+ scotplot
plot(b.sf["AFF"])
#'
#' `r h2("Статическая визуализация",ref="plot4",entry="next")`
#+ scotplotgeom
plot(sf::st_geometry(b.sf),col=sf::sf.colors(12,categorical=TRUE)
    ,border='grey',axes=TRUE)
#'
#' `r h2("Статическая визуализация",ref="plot5",entry="next")`
#'
#' ... Поэтому используются возможности других библиотек.
#+ ggplot
require(ggplot2)
#+ geomsf, out.width="85%"
ggplot()+geom_sf(data=b.sf,aes(fill=AFF))+coord_sf(crs=sf::st_crs(3857))
#'
#'
#' `r h2("Интерактивная визуализация",ref="mapview",entry="first")`
#+ mapview
mapview::mapview(b.sf) ## Не отобразится в Jupyter R Notebook.
#'
#' `r h2("Интерактивная визуализация",ref="leaflet1",entry="next")`
#+ leaflet
require(leaflet)
#+ class.source="height650"
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
#+ leadletwidget
m ## Не отобразится в Jupyter R Notebook.
#'
#' `r ## h2("Обработка векторных данных")`
#'
#'
#'
#' `r h2("Экспорт пространственных данных",ref="export1",entry="first")`
#'
#+ writeogr
pt <- loc
sp::coordinates(pt) <- ~x+y
sp::proj4string(pt) <- sp::proj4string(pt0)
pt <- sp::spTransform(pt,"+init=epsg:4326")
fileout1 <- "afterTrain.geojson"
rgdal::writeOGR(pt,fileout1,gsub("\\..+","",basename(fileout1)),driver="GeoJSON"
                 ,overwrite_layer=TRUE,morphToESRI=FALSE)
#'
#' Проверим, появился ли файл:
#+ ptexists
dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*")))
#+ glancept
try(ursa::glance(fileout1,style="mapnik",las=1,size=200,dpi=99))
#'
#' `r h2("Экспорт пространственных данных",ref="export2",entry="next")`
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
#+ glancescot
try(ursa::glance(fileout2,style="mapnik",las=1,dpi=90,size=200))
#+
#' `r h2("Экспорт пространственных данных",ref="export3",entry="last")`
#'
#+ track
fileout3 <- "track.shp"
sf::st_write(tr,dsn=fileout3,layer=gsub("\\..+","",basename(fileout2))
            ,driver="ESRI Shapefile",quiet=TRUE
            ,delete_layer=file.exists(fileout3),delete_dsn=file.exists(fileout3))
#+ trackexists
dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*")))
#'
#+ glancetrack
try(ursa::glance(fileout3,style="mapnik",las=1,dpi=90,size=200))
#'
#' `r h2("Рисование",ref="mapedit")`
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
#' `r h2("Воспроизводимые вычисления и публикация результата",ref="report1",entry="first")`
#'
#' Ниже приведены фрагмента кода, которые не были выполнены при составлении программы занятия. Их предлагается выполнить самостоятельно. Также необходимо [установленный Pandoc](#pandoc).
#'
#' Содержимое занятия сгенерировано из файла `main.R`. Загрузим его, переименовав:
#+ download, eval=FALSE
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
#' И можно скопировать на флешку на память:))
#'
#' `r h1("Успехов!",ref="thankyou",opt=".middle")`
#'
#' `r h2("Дополнительная информация",ref="extra",opt=".scale65")`
#'
#' :::left60
#'
#' `r h3("Как узнать об R поглубже",ref="deeplearn")`
#'
#' + [R-Bloggers](https://www.r-bloggers.com/) -- современные тенденции R
#'
#' + R's [Spatial](https://cran.rstudio.com/web/views/Spatial.html) and [SpatioTemporal](https://cran.rstudio.com/web/views/SpatioTemporal.html) Task Views 
#'
#' + [R-Spatial](https://www.r-spatial.org/) -- веб-сайт и блог для интересующихся использованием R для анализа пространственных и пространственно-временных данных
#'
#' + [Stackoverflow](https://stackoverflow.com/feeds/tag/r) с тегом #R.
#'
#' + [Stackexchange](https://gis.stackexchange.com/questions) о ГИС, в т.ч. с использованием R.
#'
#' + Package's vignettes -- обобщенное знакомство с библиотекой. Обычно содержат воспроизводимый код.
#'
#' :::
#' :::right40
#'
#' `r h3("Ведущий",ref="affiliation",opt=".slide")`
#'
#' - Платонов Никита Геннадьевич [&#x2709;](mailto:platonov@sevin.ru) <a href='https://orcid.org/0000-0001-7196-7882'><img src='https://orcid.org/sites/default/files/images/orcid_32x32.png' style='box-shadow: none; max-height:20px;' alt='ORCID' class='inline'></a>
#'
#' - [ИПЭЭ РАН](http://www.sev-in.ru) [-- 85 лет в 2019 г. &#127874;]{.scale80}
#'
#' - [Постоянно действующая экспедиция РАН по изучению животных Красной книги Российской Федерации и других особо важных
#' животных фауны России](http://www.sevin-expedition.ru)
#'
#' - [Программа изучения белого медведя в Российской Арктике](http://bear.sevin-expedition.ru)
#' 
#' :::{class="scale65" style="margin-top: 10em !important;"}
#' Данные после занятия остались на диске. Если не нужны, выполнить следующее: 
#+ clear, eval=F
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout1),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout2),".*"))))
file.remove(dir(pattern=paste0(gsub("\\..+","",basename(fileout3),".*"))))
#' :::
#' :::
