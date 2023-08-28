source("setup.R")

library(shiny)
library(shinydashboard)
library(shinyWidgets)

# global ------------------------------------------------------------------

source("global/get_shortest_paths.R")

JGD2011 <- 6668

osm_2023 <- read_rds("data/OpenStreetMap_2023.rds")

edges_osm_2023 <- osm_2023 |>
  activate(edges) |>
  as_tibble()

smallarea_2020 <- read_sf("data/町丁・字等_2020.gpkg") |>
  rename(place = S_NAME) |>
  select(place)

centroid_smallarea_2020 <- st_centroid(smallarea_2020)
