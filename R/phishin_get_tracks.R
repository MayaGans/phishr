#' @title Query the Phish.in API for all performances of a song
#' @description Returns metadata about every time a given song was performed.
#' @param song_name Name of the song, e.g. "Possum"
#' @param per_page Results per page (max 100 recommended)
#' @return A data frame with performance details
#' @export

pi_get_tracks <- function(song_name = "Possum", per_page = 100) {

  song_slug <- gsub(" ", "-", tolower(song_name))
  all_tracks <- list()

  # Initial request to get total_pages
  first_url <- sprintf(
    "https://phish.in/api/v2/tracks?page=1&per_page=%d&sort=date:asc&song_slug=%s",
    per_page, song_slug
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
      "https://phish.in/api/v2/tracks?page=%d&per_page=%d&sort=date:asc&song_slug=%s",
      page, per_page, song_slug
    )

    response <- GET(url)

    if (status_code(response) != 200) {
      warning(sprintf("Failed on page %d", page))
      next
    }

    tracks <- content(response, as = "parsed", type = "application/json")$tracks

    tracks_df <- map_dfr(tracks, function(track) {
      tibble(
        id = track$id,
        title = track$title,
        show_date = track$show_date,
        duration_sec = track$duration,
        duration_min = round(track$duration / 60000, 2),
        venue = track$venue_name,
        location = track$venue_location,
        mp3_url = track$mp3_url,
        tags = if (!is.null(track$tags)) paste(map_chr(track$tags, "name"), collapse = ", ") else NA,
        taper_notes = track$show$taper_notes %||% NA
      )
    })

    all_tracks[[page]] <- tracks_df
  }

  # Combine all pages into a single dataframe
  return(bind_rows(all_tracks))
}
