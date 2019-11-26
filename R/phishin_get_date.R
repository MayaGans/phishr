#' @param date The date you wish to get show info for. Format either as \code{'MM-DD'}
#' or code{'month-DD'} (e.g. \code{'10-31'} or \code{'october-31'})
#'
#' @rdname phish_dot_in
#' @export

pi_get_dates <- function(apikey   = getOption('phishin_key'),
                         date     = NULL,
                         sort_dir = 'descending',
                         sort_atr = 'name',
                         per_page = 20,
                         page     = 1
) {

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  # Modify sort_dir to abbreviations listed in the api docs
  sort_dir <- switch(sort_dir,
                     'ascending'  = 'asc',
                     'descending' = 'desc')

  res <- .pi_call(what              = 'shows-on-day-of-year',
                  what_specifically = date,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)

  data <- httr::content(res)$data

  if(length(data) > 1) {

    temp <- lapply(data, .show_list_to_df)
    out <- do.call(rbind, temp)

    out <- out[order(out$date), ]

  } else {

    out <- .show_list_to_df(data[[1]])

  }

  return(out)

}
