if (T) {
   ret <- c(pull=999)
   ret[1] <- system("git pull")
   if (ret[1]) {
      Sys.sleep(3)
   }
  # if (!(ret[2] <- system("git commit -m\"ongoing\"")))
  #    ret[3] <- system("git push")
   ret
}
