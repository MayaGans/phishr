#' @title Query the Phish.Net API
#'
#' @description The \code{phish.net} API contains a vast amount of information.
#' The functions here are specific to each type of query that can be sent to the
#' API - all are prefixed with \code{pn_*}
#'
#' @param apikey Your key for the Phish.net API. This can also be stored
#' as an option using \code{options('phishnet_key') <- 'your_api_key'}. See details
#' for more information on how to obtain one.
#' @param showdate the show setlist in YYYY-MM-DD format
#'
#' @details Accessing the Phish.Net API requires an API key. These can be obtained
#' at the following link: \link{http://api.phish.net/keys/}. First, you'll need
#' to create a username and password. After confirming your this information, you
#' can follow the link above to create an API key. Once approved, store the private
#' key somewhere that it is easily retrieved, and use it in the \code{apikey}
#' argument to each \code{pn_*} function.
#'
#' @return the selected show's rating, setlist, or notes.
#'
#' @examples
#' \dontrun{
#' BigCypressNYE <- pn_get_setlist(apikey = "<apikey>", showdate = "1999-12-31")
#' }
#'
#' @importFrom attempt stop_if_all
#' @importFrom purrr compact
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET content
#' @import jsonlite
#' @importFrom textreadr read_html
#' @importFrom dplyr filter
#' @importFrom stringr str_split_fixed
#' @importFrom zoo na.locf
#'
#' @export
#' @rdname phish_dot_net


pn_get_setlist <- function(apikey = getOption('phishnet_key'),
                           showdate = NULL) {

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

  # Get the content and return it as a data.frame
  # using an if statements lets deal with the shows that do have data

  if (length(cont$response$data) > 0) {

    # cont$response$data[[1]]$setlistdata
    # contains the setlist data in html which is a hot mess
    # cont$response$data[[1]]$setlistdata
    # contains the setlist data in html which is a hot mess
    set_html <- textreadr::read_html(cont$response$data[[1]]$setlistdata)

    # combine the colon with the previous line
    # because colons are found with "Set 1:", "Set 2:" etc.
    ind.colon <- which(set_html == ":")
    ind.set <- ind.colon - 1

    # paste the colon and the prior line together
    # to concatenate Set 1 and :
    set_html[ind.set] <- paste(set_html[ind.set], set_html[ind.colon], sep = "")

    # make into data frame
    set_html <- data.frame(set_html)
    # call the song column Song
    set_html$Song <- as.character(set_html$set_html)
    set_html$set_html <- NULL

    # remove cells containing brackets, this is a vestage of show notes
    # remove cells only containing special characters
    set_html <- dplyr::filter(set_html, !grepl("\\[",set_html$Song))
    set_html <- dplyr::filter(set_html, !grepl("^:$",set_html$Song))

    # create a character string for song names
    # the easiest filter is that they should include all alphabetical characters
    # but then we also need to search for the songs that are numbers
    # call others false
    boo <- c("[a-zA-Z]+", "1999", "555", "5:15")

    # now we can set our songs to true and the rest to false
    set_html$Boolian <- grepl(paste(boo, collapse = "|"), set_html$Song)

    # now we can take the cells that were returned as false
    # and put those into a new column for segues
    ind.FALSE <- which(set_html$Boolian == FALSE)
    ind.CAT <- ind.FALSE - 1

    set_html$Song[ind.CAT] <- paste(set_html$Song[ind.CAT], set_html$Song[ind.FALSE], sep = "__")
    set_html <- filter(set_html, set_html$Boolian == TRUE)
    set_html <- stringr::str_split_fixed(set_html$Song, "__", 2)
    colnames(set_html) <- c("Song", "Segue")

    set_html <- data.frame(set_html)

    # now we can remove the rows containing the set
    # and use that data to populate which set each show belongs in
    # we will use a combination of a colon and the colon being
    # the last character in the string (because of RS song 5:15)

    substrRight <- function(x, n){
      substr(x, nchar(x)-n+1, nchar(x))
    }

    set_html$Set <- ifelse(substrRight(as.character(set_html$Song), 1) == ":", paste(set_html$Song), NA)
    set_html$Set <- zoo::na.locf(set_html$Set)
    set_html <- filter(set_html, set_html$Song != set_html$Set)


  } else {
    # in the case that the show had no data set that list element to NA
    set_html <- NA
  }
  return(set_html)
}

