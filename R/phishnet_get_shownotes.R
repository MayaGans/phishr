#' @importFrom attempt stop_if_all
#' @importFrom purrr compact
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET content
#' @importFrom textreadr read_html
#' @importFrom dplyr filter
#' @importFrom stringr str_split_fixed
#' @importFrom zoo na.locf
#'
#' @examples
#' \dontrun{
#' BigCypressNYE <- get_show_notes(apikey = "<apikey>", showdate = "1999-12-31")
#' }
#' @export
#' @rdname phish_dot_net

pn_get_show_notes <- function(apikey = getOption('phishnet_key'),
                        showdate = NULL){

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  # Create the API call based on supplied arguments

  res <- httr::GET(
    paste0(
      pn_base_url,
      "setlists/get?apikey=",
      apikey,
      "&showdate=",
      showdate,
      sep = "")
    )

  # Check the result
  check_status(res)
  cont <- httr::content(res)

  notes <- list()

  if (length(cont$response$data) > 0) {

    cleanFun <- function(htmlString) {
      return(gsub("<.*?>", "", htmlString))
    }

    notes <- cont$response$data[[1]]$setlistnotes

    notes <- gsub("&nbsp;", " ", cleanFun(notes))

    } else {
    notes <- NA
  }
  return(notes)
}


