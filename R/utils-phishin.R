# phish.in utilities
# Helper to make sure phish.in API calls are consistent
#' @importFrom httr GET
#' @noRd

.pi_call <- function(what = NULL,
                     what_specifically,
                     apikey,
                     sort_dir,
                     sort_atr,
                     per_page,
                     page) {

  heads <- httr::add_headers(
    Accept        = 'application/json',
    Authorization = paste("Bearer ",
                          apikey,
                          sep = "")
  )

  addl_params <- .collapse_params(sort_dir = sort_dir,
                                  sort_atr = sort_atr,
                                  per_page = per_page,
                                  page     = page)

  # additional parameters (e.g. sorting require a "?" after the .json)

  if(addl_params != "") q_mark <- TRUE

  if(!is.null(what_specifically)) {

    if(what_specifically == 'all') {

      # To get all songs, you just leave "/songs.json". For all others,
      # we need to add the either the song ID or the slug (a modified form
      # of the song's name). when song == 'all', the API has an additional
      # parameter named include_song_counts. We'll automatically append this
      # as it seems like info most would want to have.
      addl_params <- paste(addl_params, '&include_show_counts=true', sep = "")

    } else {

      # song IDs get a / between the id and the song, ibid eras, etc.
      # song slugs (e.g. "You Enjoy Myself") get turned into "you-enjoy-myself"

      # to handle Santos/5:15/etc, we need to replace punctuation as well.
      what_specifically <- gsub('\\.', '-', what_specifically)
      what_specifically <- gsub('\\:', '-', what_specifically)
      what_specifically <- gsub("\\'", '-', what_specifically)

      what_specifically <- gsub(" ", "-", tolower(what_specifically))

      what <- paste(what, what_specifically, sep = "/")

    }

   }

  res <- httr::GET(
    paste0(
      pi_base_url,
      what,
      '.json',
      ifelse(q_mark, "?", ""),
      addl_params,
      sep = ""),
    config = heads
  )

  return(res)
}

#' @importFrom purrr map2_chr
#' @noRd

.collapse_params <- function(...) {

  params <- list(...)

  paste(
    purrr::map2_chr(
      names(params),
      unlist(params),
      ~paste(.x, .y, sep = "=")
    ),
    collapse = "&"
  )

}


# Extracts information from song lists and converts to data frame for return.
# Modify this to include or remove information returned for SPECIFIC songs. Edit
# .all_songs_to_df to include or return information for ALL songs.

#' @noRd
.song_list_to_df <- function(songs) {

  out <- data.frame(date     = vapply(songs,
                                      function(song_entry) song_entry$show_date,
                                      character(1L)),
                    title    = vapply(songs,
                                      function(song_entry) song_entry$title,
                                      character(1L)),
                    position = vapply(songs,
                                      function(song_entry) song_entry$position,
                                      integer(1L)),
                    set      = vapply(songs,
                                      function(song_entry) song_entry$set,
                                      character(1L)),
                    duration = vapply(songs,
                                      # no idea why duration is factored this way, but it is
                                      function(song_entry) song_entry$duration / 60000,
                                      numeric(1L)),
                    likes_ct = vapply(songs,
                                      function(song_entry) song_entry$likes_count,
                                      integer(1L)),
                    tags     = I(lapply(songs, function(x) x$tags)),
                    stringsAsFactors = FALSE
  )

  return(out)

}


.all_songs_to_df <- function(songs) {

  out <- data.frame(title    = vapply(songs,
                                      function(song_entry) song_entry$title,
                                      character(1L)),

                    n_played = vapply(songs,
                                      function(song_entry) song_entry$tracks_count,
                                      integer(1L)),
                    stringsAsFactors = FALSE)

  return(out)

}
