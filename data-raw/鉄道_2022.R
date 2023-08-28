source("setup.R")

# 鉄道_2022 -----------------------------------------------------------------

dir_railway_2022 <- "data-raw/鉄道_2022"
dir_create(dir_railway_2022)

destfile <- file_temp()
curl::curl_download(str_c(url_nlftp, "ksj/gml/data/N02/N02-22/N02-22_GML.zip",
                          sep = "/"),
                    destfile = destfile)

zip::unzip(destfile,
           exdir = dir_railway_2022)

# 駅_2022
adminbdry_2023 <- read_sf("data/行政区域_2023.gpkg")

station_2022 <- read_sf("data-raw/鉄道_2022/utf8/N02-22_Station.geojson") |>
  rename(line_name = N02_003,
         station_name = N02_005) |>
  select(line_name, station_name) |>
  st_transform(st_crs(adminbdry_2023)) |>
  st_filter(adminbdry_2023) |>
  st_centroid()

write_sf(station_2022, "data/駅_2022.gpkg")

coord_station_2022 <- station_2022 |>
  mutate(geometry |>
           st_coordinates() |>
           as_tibble()) |>
  st_drop_geometry()

write_excel_csv(coord_station_2022, "data/駅_2022.csv")
