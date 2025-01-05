# Sys.setenv(TZ="UTC")
# require(ursa)
a <- readxl::read_excel("marmam.xlsx",sheet="mammals")
ind <- is.na(a[["Повтор"]])
a <- a[ind,]
d3 <- a[["Дата"]] |> as.Date()
a[["Дата"]] <- tidyr::fill(data.frame(d3=d3),"d3",.direction="down")[[1]]
a$time <- Sys.time()
a$lon <- NA_real_
a$lat <- NA_real_
# str(a)
