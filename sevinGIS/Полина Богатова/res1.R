#plutil::ursula()
#a <- spatialize("10_Точки_20230928-2109.kml")
#str(a)
"10_Точки_20230928-2109.kml" |>
   sf::st_read() |>
   mapview::mapview(loc) |>
   ursa:::widgetize()
