library(servr)

dirs <- c("_drafts", "_posts")
servr::jekyll(dir = ".", input = dirs, output = dirs, script = "Makefile",
  serve = TRUE, command = "jekyll build --drafts")
