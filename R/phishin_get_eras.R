#' @param era The era you wish to get years for
#'
#' @rdname phish_dot_in
#' @export

pi_get_eras <- function(apikey   = getOption('phishin_key'),
                        era      = NULL,
                        sort_dir = 'descending',
                        sort_atr = 'name',
                        per_page = 20,
                        page     = 1
) {

  # Check that at least one argument is not null
  # stop_if_all(apikey, is.null, "You need to specify the API key!")
  # Chek for internet
  check_internet()

  if(!is.null(era)) {
    if(!era %in% c('1', '2', '3')) {
      stop("'era' must be either '1', '2', '3', or 'NULL'",
           call. = FALSE)
    }
  }

  # Modify sort_dir to abbreviations listed in the api docs
  sort_dir <- switch(sort_dir,
                     'ascending'  = 'asc',
                     'descending' = 'desc')

  res <- .pi_call(what              = 'eras',
                  what_specifically = era,
                  apikey            = apikey,
                  sort_dir          = sort_dir,
                  sort_atr          = sort_atr,
                  per_page          = per_page,
                  page              = page)

  if(res$status_code != 200) stop("Something went wrong\nStatus code: ",
                                  res$status_code)
  data <- httr::content(res)$data

  if(!is.null(era)) {
    era <- paste(era, '.0', sep = "")

    out <- data.frame(era   = era,
                      years = unlist(data),
                      stringsAsFactors = FALSE)

  } else {
    out <- lapply(1:3,
                  function(x) {
                    nm <- names(data)[x]
                    data.frame(era   = nm,
                               years = unlist(data[[x]]),
                               stringsAsFactors = FALSE)

                  })

    out <- do.call(rbind, out)
  }


  return(out)

}
