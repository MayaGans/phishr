#' @param track The integer ID for a track. Refers to a specific version of a song.
#'
#' @rdname phish_dot_in
#' @export

pi_get_tracks <- function(apikey   = getOption('phishin_key'),
                          track     = NULL,
                          sort_dir = 'descending',
                          sort_atr = 'name',
                          per_page = 20,
                          page     = 1,
                          sbd_only  = FALSE
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

  res <- .pi_call(what              = 'tracks',
                  what_specifically = as.character(track),
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  sbd_only          = sbd_only,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  # Modify .track_list_to_df in phishin_utils.R to get more/less output as needed.
  # The current iteration is written for consistency w/ pi_get_songs() (same col
  # names, dims, etc.)

  out <- .track_list_to_df(data)

  return(out)

}
