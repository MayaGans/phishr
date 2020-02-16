#' @rdname phish_dot_in
#' @export

pi_get_random_show <- function(apikey   = getOption('phishin_key'),
                               play_show = FALSE) {

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()


  res <- .pi_call(what              = 'random-show',
                  what_specifically = NULL,
                  apikey            = apikey,
                  sort_dir          = NULL,
                  sort_atr          = NULL,
                  per_page          = NULL,
                  page              = NULL)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)

  data <- httr::content(res)$data

  # No if{}else{}, this result is always a 1X16 dataframe
  out <- .show_list_to_df(data)

  if(play_show) {
    show_url <- paste('https://phish.in/', out$date, sep = "")
    utils::browseURL(show_url)
  }

  return(out)

}
