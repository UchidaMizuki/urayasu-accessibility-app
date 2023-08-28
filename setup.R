library(tidyverse)
library(fs)
library(sf)
library(osmdata)
library(tidygraph)
library(sfnetworks)
library(vctrs)
library(tmap)

# setup -------------------------------------------------------------------

dir_create("data-raw")
dir_create("data")

url_nlftp <- "https://nlftp.mlit.go.jp"
