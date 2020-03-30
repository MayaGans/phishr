#' @rdname phish_dot_net
#'
#' @importFrom xml2 read_html xml_find_all as_list
#' @importFrom stringr regex str_detect
#' @importFrom purrr map2
#' @importFrom magrittr %>%
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

    xml_show <- xml2::read_html(cont$response$data[[1]]$setlistdata)

    out <- .clean_pn_setlist(xml_show)

  } else {
    # in the case that the show had no data set that list element to NA
    out <- NA
  }
  return(out)
}


#' @noRd
# This uses xml nodes to find the set list text.
# It then removes all of the [0-9] stuff that indicate notes,
# creates a vector for each set, then merges the text that separates each
# song into a single line with the song (e.g. Chalkdust -> Ass Handed, becomes
# something like tribble(~song, ~ seg,
#                        'Chalkdust', '->',
#                        'Ass Handed', ','))

.clean_pn_setlist <- function(xml_show) {

  ugly_mess <- xml2::xml_find_all(xml_show, xpath = '//text()') %>%
    xml2::as_list()

  # These are mostly show notes, can be added later when as needed (famous last words)
  toss_out  <- stringr::regex('[\\[0-9]\\]|\\:')

  # create list index for shit we don't want, keep the stuff we do

  toss_ind <- vapply(ugly_mess,
                     function(x, pat) stringr::str_detect(x, pat),
                     logical(1L),
                     pat = toss_out)

  less_mess <- ugly_mess[!toss_ind]

  # Now, find the set splits, and create a list with a vector for each one.

  set_pat   <- stringr::regex('Set [0-9]|Encore')

  set_ind <- vapply(less_mess,
                    function(x, pat) stringr::str_detect(x, pat),
                    logical(1L),
                    pat = set_pat) %>%
    which()

  sets <- list()

  for(i in seq_along(set_ind)) {

    start <- set_ind[i] + 1

    end <- ifelse(i == length(set_ind),
                  length(less_mess),
                  set_ind[(i + 1)] - 1)

    sets[[i]] <- unlist(less_mess[start:end])
    names(sets)[i] <- gsub(' ', '_', less_mess[set_ind[i]])

  }

  # As far as a I can tell, the pattern is always song segue song segue.
  # so odd indices correspond to songs, and the index after is always the segue.
  # the exception is the final song of the set - that never has a segue

  temp <- purrr::map2(.x = sets,
                      .y = names(sets),
                      function(.x, .y) {
                        song_ind <- seq(1, length(.x), by = 2)
                        seg_ind  <- song_ind[-length(song_ind)] + 1

                        out <- data.frame(Set = .y,
                                          Song = .x[song_ind],
                                          Segue = c(.x[seg_ind], NA_character_),
                                          stringsAsFactors = FALSE)
                        return(out)

                      })

  # Now some housekeeping to create the returnable dataframe

  temp$make.row.names <- FALSE
  out <- do.call('rbind', temp)
  out$Set <- gsub('_', ' ', out$Set)

  # out$Segue[grepl(',', out$Segue)] <- NA

  return(out)

}
