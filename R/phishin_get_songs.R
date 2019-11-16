#' @title Query the Phish.in API
#'
#' @description The \code{phish.in} API contains a vast amount of information.
#' The functions here are specific to each type of query that can be sent to the
#' API - all are prefixed with \code{pi_*}

#' @param apikey Your key for the Phish.net API. This can also be stored
#' as an option using \code{options('phishin_key') <- 'your_api_key'}. See details
#' for more information on how to obtain one.'
#' @param song Either the name of a song or \code{"all"}. It appears that the
#' API does not support requests for more than one song at a time, so looping
#' over names is required. When \code{song = "all"}, a data frame of song names
#' and the number of times played is returned. When \code{song = "some song name"},
#' a data frame of dates played, show song positions, set positions, durations,
#' number of likes, and a list column of any tags associated with the perforamnce
#' is returned.
#' @param sort_dir direction to sort result in. The direction is used to sort
#' on \code{sort_atr}.
#' @param sort_atr the attribute to sort on. "date", "name", etc
#' @param per_page The number of results per page. The API's default is 20, but
#' this can be set to larger or smaller numbers.
#' @param page The page of results to return.
#'
#' @details Note that for all Phish.in API calls that include year information,
#' 1983 - 1987 are lumped together as a single entity. Specific dates are still
#' available for shows and songs played in this time period.
#'
#' @rdname phish_dot_in
#' @export

pi_get_song <- function(apikey   = getOption('phishin_key'),
                        song     = NULL,
                        sort_dir = 'descending',
                        sort_atr = 'name',
                        per_page = 20,
                        page     = 1
) {

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  # Create the API headers based on supplied arguments.
  # Accept header hardcoded because apparently phish.in requires this:
  # https://phish.in/api-docs

  sort_dir <- switch(sort_dir,
                     'ascending'  = 'asc',
                     'descending' = 'desc')

  res <- .pi_call(what              = 'songs',
                  what_specifically = song,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(song == 'all') {

    out <- .all_songs_to_df(data)

    class(out) <- c('phishin_all_songs', 'data.frame')

  } else {

    out <- .song_list_to_df(data$tracks)
    class(out) <- c('phishin_song', 'data.frame')

  }

  return(out)

}
