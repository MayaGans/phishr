pn_get_jamchart <- function(apikey, song_name) {

  res <- httr:::GET(
    sprintf(
      "https://api.phish.net/v5/jamcharts/slug/%s.html?apikey=%s",
      songname_to_slug(song_name),
      apikey
    )
  )

  cont <- httr::content(res)

  tds <- make_list_from_html(cont)

  purrr::map_chr(tds, ~.x[2]) |>
    na.omit() |>
    lubridate::ymd()

}

songname_to_slug <- function(song_name) {
  stringr::str_replace_all(tolower(song_name), " ", "-")
}
