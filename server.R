
# server ------------------------------------------------------------------

server <- function(input, output, session) {
  output$select_file_data_dest <- renderUI({
    if (!input$use_sample) {
      fileInput("file_data_dest",
                label = "目的地データ（CSV）を選択",
                accept = ".csv")
    }
  }) |>
    bindEvent(input$use_sample)

  reactive_data_dest_raw <- reactive({
    read_csv(input$file_data_dest$datapath,
             col_types = cols(.default = "c"))
  }) |>
    bindEvent(input$file_data_dest)

  output$select_col_X_data_dest <- renderUI({
    if (!input$use_sample) {
      data_dest_raw <- reactive_data_dest_raw()
      names_data_dest_raw <- names(data_dest_raw)

      col_X <- c("経度", "X", "lon", "long", "longitude")
      selectInput("col_X_data_dest",
                  label = "経度（X方向）",
                  choices = c(intersect(names_data_dest_raw, col_X),
                              setdiff(names_data_dest_raw, col_X)))
    }
  }) |>
    bindEvent(input$use_sample, input$file_data_dest)

  output$select_col_Y_data_dest <- renderUI({
    if (!input$use_sample) {
      data_dest_raw <- reactive_data_dest_raw()
      names_data_dest_raw <- names(data_dest_raw)

      col_Y <- c("緯度", "Y", "lat", "latitude")
      selectInput("col_Y_data_dest",
                  label = "緯度（Y方向）",
                  choices = c(intersect(names_data_dest_raw, col_Y),
                              setdiff(names_data_dest_raw, col_Y)))
    }
  }) |>
    bindEvent(input$use_sample, input$file_data_dest)

  output$select_col_place_data_dest <- renderUI({
    if (!input$use_sample) {
      data_dest_raw <- reactive_data_dest_raw()
      names_data_dest_raw <- names(data_dest_raw)

      col <- c("経度", "X", "lon", "long", "longitude",
               "緯度", "Y", "lat", "latitude")
      selectInput("col_place_data_dest",
                  label = "地名",
                  choices = c(setdiff(names_data_dest_raw, col),
                              intersect(names_data_dest_raw, col)))
    }
  }) |>
    bindEvent(input$use_sample, input$file_data_dest)

  reactive_data_dest <- reactive({
    if (input$use_sample) {
      data_dest <- read_sf("data/駅_2022.gpkg") |>
        rename(place = station_name) |>
        select(place)
    } else {
      data_dest_raw <- reactive_data_dest_raw()
      col_X <- input$col_X_data_dest
      col_Y <- input$col_Y_data_dest
      col_place <- input$col_place_data_dest

      data_dest <- data_dest_raw |>
        rename(X = !!col_X,
               Y = !!col_Y,
               place = !!col_place) |>
        select(X, Y, place)

      if (vec_duplicate_any(data_dest$place)) rlang::abort("地点名は重複してはいけません")

      data_dest |>
        mutate(across(c(X, Y),
                      parse_number)) |>
        st_as_sf(coords = c("X", "Y"),
                 crs = JGD2011) |>
        rename(geom = geometry)
    }
  }) |>
    bindEvent(input$action_shortest_paths)

  output$plot_shortest_paths <- renderTmap({
    if (input$action_shortest_paths == 0) {
      tm_shape(smallarea_2020) +
        tm_polygons(alpha = 0.5)
    } else {
      data_dest <- reactive_data_dest()

      shortest_paths <- get_shortest_paths(network = osm_2023,
                                           orig = centroid_smallarea_2020,
                                           dest = data_dest)

      smallarea <- smallarea_2020 |>
        left_join(shortest_paths |>
                    st_drop_geometry(),
                  by = join_by(place == orig_place))
      data_dest <- data_dest |>
        inner_join(shortest_paths |>
                     st_drop_geometry() |>
                     distinct(dest_place),
                   by = join_by(place == dest_place))
      tm_shape(smallarea) +
        tm_polygons("cost",
                    title = "最短経路［km］",
                    palette = "-viridis",
                    alpha = 0.5) +

        tm_shape(shortest_paths) +
        tm_lines("white", 8) +

        tm_shape(shortest_paths) +
        tm_lines("dest_place", 2,
                 legend.col.show = FALSE,
                 palette = "Dark2") +

        tm_shape(data_dest) +
        tm_dots("white", 0.12,
                border.col = NULL) +

        tm_shape(data_dest) +
        tm_dots("place", 0.05,
                legend.show = FALSE,
                palette = "Dark2",
                border.col = NULL)
    }
  }) |>
    bindEvent(input$action_shortest_paths,
              ignoreNULL = FALSE)
}
