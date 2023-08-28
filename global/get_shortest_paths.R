
# get_shortest_paths ------------------------------------------------------

get_shortest_paths <- function(network, orig, dest) {
  stopifnot(
    setequal(names(orig), c("place", "geom")),
    setequal(names(dest), c("place", "geom"))
  )

  # 最近傍の地点を取得
  cost <- st_network_cost(network,
                          from = orig,
                          to = dest)
  dimnames(cost) <- list(orig_place = orig$place,
                         dest_place = dest$place)

  cost_min <- cost |>
    as.table() |>
    as_tibble(n = "cost") |>
    slice_min(cost,
              n = 1,
              by = orig_place,
              with_ties = FALSE)

  # 最短経路を取得
  orig |>
    rename(orig_place = place,
           orig_geom = geom) |>
    left_join(cost_min,
              by = join_by(orig_place)) |>
    nest(.by = dest_place,
         .key = "orig") |>
    left_join(dest |>
                rename(dest_place = place,
                       dest_geom = geom),
              by = join_by(dest_place)) |>
    vec_chop() |>
    map(\(data) {
      data |>
        mutate(path = orig |>
                 map(\(orig) {
                   orig |>
                     mutate(st_network_paths(network,
                                             from = dest_geom,
                                             to = orig_geom,
                                             mode = "in")) |>
                     st_drop_geometry()
                 }),
               .keep = "unused")
    }) |>
    list_rbind() |>
    unnest(path) |>
    select(!node_paths) |>
    mutate(geom = edge_paths |>
             map_vec(\(edge_paths) {
               network |>
                 activate(edges) |>
                 as_tibble() |>
                 rowid_to_column("edge_id") |>
                 filter(edge_id %in% edge_paths) |>
                 st_combine()
             }),
           .keep = "unused") |>
    st_as_sf() |>
    relocate(orig_place, dest_place) |>
    mutate(cost = cost |>
             units::set_units(km))
}
