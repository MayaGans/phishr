#' @param tag The integer ID, tag name, or slug entry for a tag. Defaults to \code{"all"},
#' returning a list of all tags w/ ID numbers, tag names, corresponding slugs,
#' descriptions, and a list of tracks that it's used for. The latter only applies
#' to specific tags, as the API doesn't return that information when \code{tag = "all"}
#'
#' @rdname phish_dot_in
#' @export

pi_get_tags <- function(apikey   = getOption('phishin_key'),
                        tag      = "all",
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

  # The default is actually just GET /tags, which corresponds to "all". Keeping
  # the "all" option for consistency w/ songs, etc.

  if(tag == 'all') {

    tag <- NULL

  } else {

    tag <- as.character(tag)

  }

  # Override higher page requests, as these all seem to return no data and
  # generate confusing errors
  if(page > 1) {
    page <- 1
    message("Over-riding 'page'(-side, rage-side) parameter and resetting to '1'.\n",
            "There is no additional data available for 'page's > 1")
  }
  res <- .pi_call(what              = 'tags',
                  what_specifically = tag,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(is.null(tag)) {

    out <- .all_tags_to_df(data)

  } else {

    out <- .tag_list_to_df(data)

  }

  return(out)

}
