source("setup.R")

# 行政区域_2023 ---------------------------------------------------------------

dir_adminbdry_2023 <- "data-raw/行政区域_2023"
dir_create(dir_adminbdry_2023)

destfile <- file_temp()
curl::curl_download("https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2023/N03-20230101_12_GML.zip",
                    destfile = destfile)
zip::unzip(destfile,
           exdir = dir_adminbdry_2023)

adminbdry_2023 <- read_sf("data-raw/行政区域_2023/N03-23_12_230101.shp",
                          options = "ENCODING=shift-jis") |>
  rename(city_name = N03_004) |>
  select(city_name) |>
  filter(city_name == "浦安市") |>
  select(!city_name)

write_sf(adminbdry_2023, "data/行政区域_2023.gpkg")
