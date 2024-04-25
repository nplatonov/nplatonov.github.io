require(ursa)
a <- ursa:::spatialize("полынья.shp")
session_grid(res=500)
session_grid()
b <- ursa:::.fasterize(a["id"])
d <- as.table(b)
str(d)
d*(ursa(b,"cellsize")^2)*1e-6
