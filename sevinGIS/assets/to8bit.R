list1 <- dir(pattern="\\.png$",recursive=TRUE,full.names=TRUE)
ret <- lapply(sample(list1),function(x) {
   src <- normalizePath(x)
   message(src)
   system2("i_view32",c(src,"/bpp=8",paste0("/convert=",dQuote(src))))
})
