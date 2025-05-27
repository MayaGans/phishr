#' Get show using the date from the phish.in API
#'
#' @param date The date you wish to get show info for. Format as \code{'YYYY-MM-DD'}
#' @importFrom progress progress_bar
#'
#' @export

pi_get_show_by_date <- function(date = NULL) {

  endpoint <- sprintf("https://phish.in/api/v2/shows/%s", tolower(date))
  response <- GET(endpoint)

  if (status_code(response) == 200) {
    data <- content(response, as = "parsed", type = "application/json")
    return(data)
  } else {
    stop("Request failed with status code: ", status_code(response))
  }

}

pi_get_all_dates <- function() {
  all_dates <- list()

  first_url <- "https://phish.in/api/v2/shows?page=1&per_page=10&sort=date%3Adesc&start_date=1970-01-01&end_date=2070-01-01&liked_by_user=false"
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
    url <- sprintf(
      "https://phish.in/api/v2/shows?page=%s&per_page=10&sort=date%%3Adesc&start_date=1970-01-01&end_date=2070-01-01&liked_by_user=false",
      page
    )

    response <- GET(url)

    if (status_code(response) != 200) {
      warning(sprintf("Failed on page %d", page))
      next
    }

    dates <- content(response, as = "parsed", type = "application/json")$shows

    dates_df <- unname(dates) %>%
      keep(is.list) %>%
      map_dfr(~tibble(
        date = .x$date %||% NA,
        tour_name = .x$tour_name %||% NA,
        venue_name = .x$venue_name %||% NA
      ))

    all_dates[[page]] <- dates_df
    pb$tick()
  }

  return(bind_rows(all_dates))
}
