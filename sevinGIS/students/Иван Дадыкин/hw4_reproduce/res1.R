require(ggplot2)
png("foo.png",width=800,height=500)
n <- 11
da <- data.frame(x=seq(n),y=runif(n))
p <- ggplot(da,aes(x,y))+geom_point()+stat_smooth(method="lm")
print(p)
dev.off()
browseURL("foo.png")