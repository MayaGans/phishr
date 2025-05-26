#' @title Get All Songs
#'
#' @returns a data.frame with the slug, names,
#' original artist, and times played of each song!
#'
#' @description The \code{phish.in} API contains a vast amount of information.
#' The functions here are specific to each type of query that can be sent to the
#' API - all are prefixed with \code{pi_*}
#'
#' @export

pi_get_all_songs <- function(per_page = 1000) {

  endpoint <- sprintf("https://phish.in/api/v2/songs")
  response <- GET(endpoint)
  all_songs <- list()

  # Initial request to get total_pages
  first_url <- sprintf(
    "https://phish.in/api/v2/tracks?page=1&per_page=%d&sort=date:asc",
    per_page
  )

  first_response <- GET(first_url)

  if (status_code(first_response) != 200) {
    stop("Initial request failed.")
  }

  first_content <- content(first_response, as = "parsed", type = "application/json")
  total_pages <- first_content$total_pages

  # Loop over all pages
  for (page in 1:total_pages) {

    url <- sprintf(
      "https://phish.in/api/v2/tracks?page=%d&per_page=%d&sort=date:asc",
      page, per_page
    )

    response <- GET(url)

    if (status_code(response) != 200) {
      warning(sprintf("Failed on page %d", page))
      next
    }

    songs <- content(response, as = "parsed", type = "application/json")$tracks

    songs_df <- map_dfr(songs, function(track) {

      song <- track$songs[[1]]

      tibble(
        slug = song$slug,
        title = song$title,
        artist = song$artist %||% 'Phish',
        tracks_count = song$tracks_count
      )
    })

    all_songs[[page]] <- songs_df
  }

  # Combine all pages into a single dataframe
  return(bind_rows(all_songs))

}
