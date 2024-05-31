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
  html_string <- as.character(cont)

  extract_td <- function(tr) {
    regmatches(tr, gregexpr("(?<=<td>).*?(?=</td>)", tr, perl = TRUE))[[1]]
  }

  tr_matches <- regmatches(html_string, gregexpr("<tr>.*?</tr>", html_string))[[1]]
  td_content <- lapply(tr_matches, extract_td)

  td_content[[1]]

  purrr::map(td_content, ~data.frame(
    name = .x[2],
    city = .x[3],
    state = .x[4],
    country = .x[5]
  )) |>
    purrr::reduce(dplyr::bind_rows)

}
