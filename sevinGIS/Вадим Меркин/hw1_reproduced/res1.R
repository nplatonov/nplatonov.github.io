'step1' <- function() {
   require(rvest)
   url <- "https://ru.wikipedia.org/wiki/Наукограды_России"
   webpage <- read_html(url)
   table <- webpage %>% html_nodes("table.wikitable") %>% html_table()
   ta <- table[[1]]
   str(ta)
   writeLines(jsonlite::toJSON(ta),"naukograd.json")
}
'step2' <- function() {
   da <- jsonlite::fromJSON("naukograd.json")
  # print(da)
   da[[2]] <- gsub(".*/\\s+(.+)$","\\1",da[[2]])
   aname <- unique(paste(da[[1]],da[[2]]))
  # aname <- gsub("\\[\\d+\\]","",aname)
  # aname <- gsub("\\W","",aname)
   res <- lapply(aname,ursa:::.geocode,area="point")
   names(res) <- aname
   res <- lapply(res,sf::st_point)
   res <- sf::st_sfc(res,crs=4326)
   res <- sf::st_sf(name=unique(da[[1]]),geometry=res)
   ursa::spatial_write(res,"naukograd.geojson")
  # ursa::glance(res)
   invisible(0L)
}
step2()
