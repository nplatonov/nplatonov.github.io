`state_labels <- st_centroid(aus_states)`

> `Warning: st_centroid assumes attributes are constant over geometries`

Принудительно задать `sf::st_agr(aus_states) <- "constant"`
