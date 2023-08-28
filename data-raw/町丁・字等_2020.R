source("setup.R")

# 町丁・字等_2020 --------------------------------------------------------------

dir_smallarea_2020 <- "data-raw/町丁・字等_2020"
dir_create(dir_smallarea_2020)

destfile <- file_temp()
curl::curl_download("https://www.e-stat.go.jp/gis/statmap-search/data?dlserveyId=A002005212020&code=12227&coordSys=1&format=shape&downloadType=5&datum=2011",
                    destfile = destfile)

zip::unzip(destfile,
           exdir = dir_smallarea_2020)

smallarea_2020 <- read_sf("data-raw/町丁・字等_2020/r2ka12227.shp") |>
  select(KEY_CODE, S_NAME)

write_sf(smallarea_2020, "data/町丁・字等_2020.gpkg")
