#' @rdname phish_dot_in
#'
#' @param show Either an integer show ID (obtainable through \code{pi_get_tours},
#' \code{pi_get_songs}, etc) OR a specific date as a character string with
#' "YYYY-MM-DD" format.
#' @param play_show logical indicating whether to navigate to the phish.in
#' url and start playing the show. Default is \code{FALSE}. Must supply a
#' \code{show} for this to be \code{TRUE}
#'
#' @importFrom utils browseURL
#' @export

pi_get_shows <- function(apikey    = getOption('phishin_key'),
                         show      = NULL,
                         sort_dir  = 'descending',
                         sort_atr  = 'name',
                         per_page  = 20,
                         page      = 1,
                         play_show = FALSE
) {

  # phish.in automatically starts the show once you reach the URL, so nothing
  # else needed

  if(play_show & !is.null(show)) {

    show_url <- paste('https://phish.in/', show, sep = "")
    utils::browseURL(show_url)

  } else if(play_show & is.null(show)) {

    stop('Must supply a date to play show')

  }

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

  res <- .pi_call(what              = 'shows',
                  what_specifically = show,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(!is.null(show)) {

    out <- .show_list_to_df(data)

  } else {

    temp <- lapply(data, .show_list_to_df)
    out <- do.call(rbind, temp)

  }

  return(out)

}
