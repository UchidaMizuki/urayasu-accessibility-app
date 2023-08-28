
# ui ----------------------------------------------------------------------

header <- dashboardHeader(
  title = "最寄りの〇〇までどれくらい？",
  titleWidth = 400
)

sidebar <- dashboardSidebar(
  width = 400,
  sidebarMenu(
    switchInput(inputId = "use_sample",
                label = "サンプル（市内の駅）を使用",
                value = TRUE,
                labelWidth = "100%",
                width = "100%"),
    uiOutput("select_file_data_dest"),
    uiOutput("select_col_X_data_dest"),
    uiOutput("select_col_Y_data_dest"),
    uiOutput("select_col_place_data_dest"),
    actionButton("action_shortest_paths",
                 label = "決定"),
    menuItem(
      "最短経路",
      tabName = "tab_shortest_paths",
      icon = icon("route")
    )
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(
      "tab_shortest_paths",
      fluidRow(
        box(
          title = "最短経路",
          width = 12,
          tmapOutput("plot_shortest_paths",
                     height = 1000)
        )
      )
    )
  )
)

ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body)
