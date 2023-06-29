## check_packages.R

#Run this script to check for packages that the other R scripts will use. If missing, try to install.
#code borrowed from here:
#http://www.vikram-baliga.com/blog/2015/7/19/a-hassle-free-way-to-verify-that-r-packages-are-installed-and-loaded

#add new packages to the chain here
packages = c(
  "here", # absolute requirement always
  "knitr", # for processing quarto
  "readr","haven", "googledrive", # I/O
  "tidyverse","lubridate","broom", "janitor", #tidyverse and friends
  "ggdendro", "grid", #extra graphics
  "texreg","gt", "kableExtra", # for table output
  "PNWColors",
  "remotes","survival","reshape2"
)

package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

#install fakeunion library from GitHub
if(!require(fakeunion)) {
  install_github("AaronGullickson/fakeunion")
  library(fakeunion)
}
