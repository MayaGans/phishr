#' Get all Venue names Phish has played
#'
#' @export

pi_get_all_venues <- function(per_page = 100) {

  # Initial request to get total_pages
  first_url <- sprintf(
    "https://phish.in/api/v2/venues?page=1&per_page=%s&sort=name%%3Aasc",
    per_page
  )

  first_response <- GET(first_url)

  if (status_code(first_response) != 200) {
    stop("Initial request failed.")
  }

  first_content <- content(first_response, as = "parsed", type = "application/json")
  total_pages <- first_content$total_pages

  all_venues <- list()

  # Loop over all pages
  for (page in 1:total_pages) {

    url <- sprintf(
      "https://phish.in/api/v2/venues?page=%s&per_page=%s&sort=name%%3Aasc",
      page, per_page
    )

    response <- GET(url)

    if (status_code(response) != 200) {
      warning(sprintf("Failed on page %d", page))
      next
    }

    venues <- content(response, as = "parsed", type = "application/json")$venues

    venues_df <- map_dfr(venues, function(venue) {
      tibble(
        name = venue$name,
        latitude = venue$latitude,
        longitude = venue$longitude,
        city = venue$city,
        state = venue$state,
        country = venue$country,
        location = venue$location,
        shows_count = venues$shows_count
      )
    })

    all_venues[[page]] <- venues_df
  }

  # Combine all pages into a single dataframe
  return(bind_rows(all_venues))


}
