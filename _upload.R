src <- file.path(getOption("ursaCacheDir"),"knit","site_libs")
dst <- file.path(".",basename(src))
invisible(lapply(dir(src,recursive=TRUE),function(x) {
   dst0 <- file.path(dst,x)
   dpath <- dirname(dst0)
   if (!dir.exists(dpath))
      dir.create(dpath,recursive=TRUE)
   file.copy(file.path(src,x),dst0,overwrite=FALSE,copy.date=TRUE)
  # message(x)
}))
patt <- "file\\:///C:/platt/R/style/"
for (myname in c("C:/platt/article/platt.bib"
                ,"C:/platt/R/style/platt3.csl"
                ,"C:/platt/R/style/platt4.csl"
                ,"C:/platt/R/style/common.css"
                ,"C:/platt/R/style/html_vignette.css"
                ,"C:/platt/R/style/flex_dashboard.css"
                ,"C:/platt/R/style/revealjs_presentation.css"
                ,"C:/platt/R/style/revealjs-header.Rmd"
                ,"C:/platt/R/style/html_resume.css"
                ,"C:/platt/R/style/thesis_paged.css"
                ,"C:/platt/R/style/distill_article.css"
                ,"C:/platt/R/style/tufte_html.css"
                ,"C:/platt/R/style/link.svg"
                ,"C:/platt/R/style/orcid.svg"
                )) {
   cat(myname,"\n")
   a <- readLines(myname,encoding="UTF-8")
   if (length(ind <- grep(patt,a))) {
      message("gsub file:/// pattern")
      print(a[ind])
      a[ind] <- gsub(patt,"https://nplatonov.github.io/",a[ind])
      print(a[ind])
      Fout <- file(basename(myname),encoding="UTF-8")
      writeLines(a,Fout)
      close(Fout)
   }
   else {
      message("just copy file")
      if (grepl("\\.css$",myname))
         file.copy(myname,file.path("site_libs",basename(myname)),overwrite=TRUE,copy.date=TRUE)
      else
         file.copy(myname,basename(myname),overwrite=TRUE,copy.date=TRUE)
   }
}
if (T) {
   ret <- c(add=999,commit=999,push=999)
   ret[1] <- system("git add -A")
   if (!(ret[2] <- system("git commit -m\"ongoing\"")))
      ret[3] <- system("git push")
   ret
}
