pn_get_all_showdates <- function(key) {

  res <- httr:::GET(
    sprintf(
      "https://api.phish.net/v5/shows/artist/phish.json?order_by=showdate&apikey=%s",
      key
    )
  )

  cont <- httr::content(res)

  purrr::map_dfr(cont$data, ~as.data.frame(t(.)))

}

pn_get_all_songs <- function(key) {

  res <- httr:::GET(
    sprintf(
      "https://api.phish.net/v5/songs.json?apikey=%s",
      key
    )
  )

  cont <- httr::content(res)

  purrr::map_dfr(cont$data, ~as.data.frame(t(.)))

}


pn_get_all_setlists <- function(key) {

  shows <- pn_get_all_showdates(key)

  purrr::map(shows$showdate, ~pn_get_setlist(key, .x)) |>
    purrr::reduce(dplyr::bind_rows)

}

pn_get_all_venues <- function(key) {

  res <- httr:::GET(
    sprintf(
      "https://api.phish.net/v5/venues.html?apikey=%s",
      key
    )
  )

  cont <- httr::content(res)

  td_content <- make_list_from_html(cont)

  purrr::map(td_content, ~data.frame(
    name = .x[2],
    city = .x[3],
    state = .x[4],
    country = .x[5]
  )) |>
    purrr::reduce(dplyr::bind_rows)

}
