#' Search for Setlist
#' @param apikey apikey
#' @param showdate the show setlist in YYYY-MM-DD format
#'
#' @importFrom attempt stop_if_all
#' @importFrom purrr compact
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @export
#' @import jsonlite
#' @importFrom textreadr read_html
#' @import httr
#' @importFrom dplyr filter
#' @importFrom stringr str_split_fixed
#' @importFrom zoo na.locf
#' @rdname get_show_rating
#'
#' @return the selected show's rating
#' @examples
#' \dontrun{
#' BigCypressNYE <- get_show_rating(apikey = "<apikey>", showdate = "1999-12-31")
#' }

get_show_rating <- function(apikey,
                           showdate = NULL){

  args <- list(apikey = apikey,
               showdate = showdate)

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  # Create the API call based on supplied arguments

  res <- GET(
    paste0(
      base_url,
      "setlists/get?apikey=",
      apikey,
      "&showdate=",
      showdate,
      sep=""))

  # Check the result
  check_status(res)
  cont <- content(res)

  notes <- list()

  if (length(cont$response$data) > 0) {

    cleanFun <- function(htmlString) {
      return(gsub("<.*?>", "", htmlString))
    }

    notes <- as.numeric(cont$response$data[[1]]$rating)

  } else {
    notes <- NA
  }
  return(notes)
}

#' @export
#' @rdname get_show_rating
