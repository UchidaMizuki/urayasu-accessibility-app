source("setup.R")

# バス路線_2022 ---------------------------------------------------------------

# バスルート_2022
dir_busroute_2022 <- "data-raw/バスルート_2022"
dir_create(dir_busroute_2022)

destfile <- file_temp()
curl::curl_download(str_c(url_nlftp, "ksj/gml/data/N07/N07-22/N07-22_12_SHP.zip",
                          sep = "/"),
                    destfile = destfile)

zip::unzip(destfile,
           exdir = dir_busroute_2022)

# バス停留所_2022
dir_busstop_2022 <- "data-raw/バス停留所_2022"
dir_create(dir_busstop_2022)

destfile <- file_temp()
curl::curl_download(str_c(url_nlftp, "ksj/gml/data/P11/P11-22/P11-22_12_SHP.zip",
                          sep = "/"),
                    destfile = destfile)

zip::unzip(destfile,
           exdir = dir_busstop_2022)
