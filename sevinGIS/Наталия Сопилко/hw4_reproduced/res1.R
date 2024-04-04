require(tmap)
data(World, land)
m <- tm_shape(land,raster.warp = FALSE) +
	tm_raster("elevation", breaks=c(-Inf, 250, 500, 1000, 1500, 2000, 2500, 3000, 4000, Inf),  
		palette = terrain.colors(9), title="Elevation", midpoint = NA) +
tm_shape(World, is.master=TRUE, projection = "+proj=eck4") +
	tm_borders("grey20") +
	tm_graticules(labels.size = .5) +
	tm_text("name", size="AREA") +
tm_compass(position = c(.65, .15), color.light = "grey90") +
tm_credits("Eckert IV projection", position = c("right", "BOTTOM")) +
tm_style("classic") +
tm_layout(bg.color="lightblue",
	inner.margins=c(.04,.03, .02, .01), 
	earth.boundary = TRUE, 
	space.color="grey90") +
tm_legend(position = c("left", "bottom"), 
	frame = TRUE,
	bg.color="lightblue")
m
