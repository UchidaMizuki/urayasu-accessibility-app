source("setup.R")

# OpenStreetMap -----------------------------------------------------------

adminbdry_2023 <- read_sf("data/行政区域_2023.gpkg")

osm_2023 <- opq(st_bbox(adminbdry_2023)) |>
  add_osm_feature(key = "highway") |>
  osmdata_sf()

# https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html
osm_2023 <- osm_2023$osm_lines |>
  select(highway) |>
  as_sfnetwork(directed = FALSE) |>
  st_transform(st_crs(adminbdry_2023)) |>
  st_filter(adminbdry_2023) |>
  convert(to_spatial_subdivision,
          .clean = TRUE) |>
  convert(to_components,
          .select = 1,
          .clean = TRUE) |>
  convert(to_spatial_smooth,
          .clean = TRUE)

write_rds(osm_2023, "data/OpenStreetMap_2023.rds")
