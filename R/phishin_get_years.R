#' @param year The desired year. use \code{year = 'all'} to get a show counts
#' for every year they toured. Enter a specific year to get a data frame with
#' dates, venue and location data, and complete setlists information for
#' each show in a year (set list data is the same format as \code{pi_get_song}).
#'
#' @rdname phish_dot_in
#' @export

pi_get_years <- function(apikey   = getOption('phishin_key'),
                         year,
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

  res <- .pi_call(what              = 'years',
                  what_specifically = year,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(year == 'all') {

    out <- .all_years_to_df(data)

  } else {

    out <- .year_list_to_df(data)

  }

  return(out)

}
