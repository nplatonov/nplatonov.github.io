list1 <- dir(pattern="^r.+\\.html")
if (F) {
   res <- unname(sapply(sample(list1),function(fname) {
     # message(fname)
      a <- readLines(fname)
      ind <- grep("<title>",a)
      gsub("(<|>|/|title|ArcNet PAC|\\s+)","",a[ind])
   }))
   print(sort(as.integer(res)))
}
if (T) {
   res <- unname(sapply(sample(list1),function(fname) {
      message(fname)
      a <- readLines(fname)
      ind <- grep("220px",a)
      if (length(ind)) {
         print(a[ind])
         a[ind] <- gsub("220px","210px",a[ind])
        # print(a[ind])
      }
     # writeLines(a,fname)
     # gsub("(<|>|/|title|ArcNet PAC|\\s+)","",a[ind])
   }))
}
