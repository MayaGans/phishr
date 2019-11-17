#' @param venue The venue you wish to get information for. Either \code{NULL} or the
#' name of a venue.
#'
#' @rdname phish_dot_in
#' @export

pi_get_venues <- function(apikey   = getOption('phishin_key'),
                          venue    = NULL,
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

  res <- .pi_call(what              = 'venues',
                  what_specifically = venue,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(is.null(venue) || venue == "") {

    out <- lapply(data, .venue_list_to_df)
    out <- do.call(rbind, out)

  } else {

    out <- .venue_list_to_df(data)

  }

  return(out)

}
