#' @title Get All Songs
#'
#' @returns a data.frame with the slug, names,
#' original artist, and times played of each song!
#'
#' @description The \code{phish.in} API contains a vast amount of information.
#' The functions here are specific to each type of query that can be sent to the
#' API - all are prefixed with \code{pi_*}
#'
#' @importFrom purrr map_dfr keep
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows
#'
#' @export

pi_get_all_songs <- function(per_page = 100) {
  all_songs <- list()

  # Initial request to get total pages
  first_url <- sprintf("https://phish.in/api/v2/songs?page=1&per_page=%d", per_page)
  first_response <- GET(first_url)

  if (status_code(first_response) != 200) {
    stop("Initial request failed.")
  }

  first_content <- content(first_response, as = "parsed", type = "application/json")
  total_pages <- first_content$total_pages

  # Initialize progress bar
  pb <- progress_bar$new(
    format = "Fetching [:bar] :current/:total pages (:percent) eta: :eta",
    total = total_pages,
    clear = FALSE,
    width = 60
  )

  for (page in 1:total_pages) {
    url <- sprintf("https://phish.in/api/v2/songs?page=%d&per_page=%d", page, per_page)
    response <- GET(url)

    if (status_code(response) != 200) {
      warning(sprintf("Failed on page %d", page))
      next
    }

    songs <- content(response, as = "parsed", type = "application/json")$songs

    songs_df <- map_dfr(songs, function(song) {
      tibble(
        slug = song$slug,
        title = song$title,
        artist = song$artist %||% "Phish",
        tracks_count = song$tracks_count
      )
    })

    all_songs[[page]] <- songs_df
    pb$tick()
  }

  return(bind_rows(all_songs))
}


