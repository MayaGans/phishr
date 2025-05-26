#' @title Query the Phish.in API
#'
#' @description The \code{phish.in} API contains a vast amount of information.
#' The functions here are specific to each type of query that can be sent to the
#' API - all are prefixed with \code{pi_*}

#' @param song Either the name of a song or \code{"all"}. It appears that the
#' API does not support requests for more than one song at a time, so looping
#' over names is required. When \code{song = "all"}, a data frame of song names
#' and the number of times played is returned. When \code{song = "some song name"},
#' a data frame of dates played, show song positions, set positions, durations,
#' number of likes, and a list column of any tags associated with the perforamnce
#' is returned.
#'
#' Note that for all Phish.in API calls that include year information,
#' 1983 - 1987 are lumped together as a single entity. Specific dates are still
#' available for shows and songs played in this time period.
#'
#' @export

pi_get_songs <- function(song) {

  endpoint <- sprintf("https://phish.in/api/v2/songs/%s", tolower(song))
  response <- GET(endpoint)

  if (status_code(response) == 200) {
    data <- content(response, as = "parsed", type = "application/json")
    return(data)
  } else {
    stop("Request failed with status code: ", status_code(response))
  }

}
