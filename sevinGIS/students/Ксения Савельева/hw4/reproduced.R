require(ursa)
pol <- spatial_read("Полыньи.shz")
glance(pol[,grep("(name|area)",spatial_colnames(pol),ignore.case=TRUE)]
      ,resetGrid=TRUE,border=0,coast.col="black",legend=list("left","right"))
