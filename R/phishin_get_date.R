#' Get show using the date from the phish.in API
#'
#' @param date The date you wish to get show info for. Format as \code{'YYYY-MM-DD'}
#'
#' @export

pi_get_dates <- function(date = NULL) {

  endpoint <- sprintf("https://phish.in/api/v2/shows/%s", tolower(date))
  response <- GET(endpoint)

  if (status_code(response) == 200) {
    data <- content(response, as = "parsed", type = "application/json")
    return(data)
  } else {
    stop("Request failed with status code: ", status_code(response))
  }

}
