#' Get Setlist
#'
#' Get the setlist for one specific phish show using phish.net
#'
#' @param apikey key
#' @param showdate date in YYYY-MM-DD format
#'
#' @importFrom stringr regex str_detect
#' @importFrom purrr map2
#' @export
pn_get_setlist <- function(apikey = getOption('phishnet_key'),
                           showdate = NULL) {

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  # Create the API call based on supplied arguments

  res <- httr::GET(
    paste0(
      "https://api.phish.net/v5/",
      "setlists/showdate/",
      showdate,
      ".json?apikey=",
      apikey,
      sep = "")
  )

  # Check the result
  check_status(res)
  cont <- httr::content(res)

  if (length(cont$data) == 0) stop(paste0("\n No show data for ", showdate))

  purrr::map_dfr(cont$data, ~as.data.frame(t(.)))

}
