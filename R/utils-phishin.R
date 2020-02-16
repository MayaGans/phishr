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
                     sbd_only = FALSE,
                     page) {

  .pi_validate_params(sort_dir,
                      sort_atr,
                      per_page,
                      page)

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

  # Tracks and Shows can accept a sbd only parameter denoting requests to only
  # return soundboards. append that here.

  if(what %in% c('shows', 'tracks') && sbd_only) {
    addl_params <- paste('tag=sbd', addl_params, sep = "&")
  }

  # additional parameters (e.g. sorting) require a "?" after the .json. There
  # should almost always be some addl_params, unless it's pi_get_random_show()

  if(addl_params != "") {
    q_mark <- TRUE
  } else {
    q_mark <- FALSE
  }

  if(!is.null(what_specifically)) {

    if(what_specifically == 'all') {

      # To get all songs, eras, tours, etc you just leave "/songs.json".
      # when year == 'all', the API has an additional
      # parameter named include_show_counts. Automatically append this
      # as it seems like info most would want to have.

      addl_params <- paste(addl_params, '&include_show_counts=true', sep = "")


    } else {

      # This bit is pretty much exclusively to deal with the song and tour names.
      # song IDs get a / between the id and the song, ibid eras, etc.
      # song titles (e.g. "You Enjoy Myself") get turned into slugs
      # "you-enjoy-myself"

      # to handle Santos/5:15/etc, we need to replace punctuation as well.
      what_specifically <- gsub('\\.', '-', what_specifically)
      what_specifically <- gsub('\\:', '-', what_specifically)
      what_specifically <- gsub("\\'", '-', what_specifically)

      what_specifically <- gsub(" ", "-", tolower(what_specifically))

      # finally, if what_specifically == 'all'

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


# get_songs utils----------

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


# get_years utils--------

#' @noRd
.year_list_to_df <- function(year_list) {

  # Use lapply to create a list column with the complete setlist info for each
  # show
  setlists <- lapply(year_list,
                     function(x) .song_list_to_df(x$tracks))

  # vapply is typed so it's a bit quicker than lapply, and we already know
  # exactly what to expect from each column

  date     <- vapply(year_list,
                     function(x) x$date,
                     character(1L))

  venue    <- vapply(year_list,
                     function(x) x$venue$name,
                     character(1L))

  city     <- vapply(year_list,
                     function(x) strsplit(x$venue$location,
                                          split = ', ')[[1]][1],
                     character(1L))
  state    <- vapply(year_list,
                     function(x) strsplit(x$venue$location,
                                          split = ', ')[[1]][2],
                     character(1L))

  tour_id  <- vapply(year_list,
                     function(x) x$tour_id,
                     integer(1L))

  duration <- vapply(year_list,
                     function(x) x$duration / 60000,
                     numeric(1L))

  lat      <- vapply(year_list,
                     function(x) x$venue$latitude,
                     numeric(1L))
  lon      <- vapply(year_list,
                     function(x) x$venue$longitude,
                     numeric(1L))

  out <- data.frame(
    date     = date,
    city     = city,
    state    = state,
    venue    = venue,
    lat      = lat,
    lon      = lon,
    tour_id  = tour_id,
    duration = duration,
    setlists = I(setlists),
    stringsAsFactors = FALSE
  )

  return(out)

}

#' @noRd
.all_years_to_df <- function(year_list) {

  yrs     <- vapply(year_list,
                    function(x) x$date,
                    character(1L))

  n_shows <- vapply(year_list,
                    function(x) x$show_count,
                    integer(1L))

  out <- data.frame(year    = yrs,
                    n_shows = n_shows,
                    stringsAsFactors = FALSE)

  return(out)
}


# get_tours utils ----------

#'@noRd
.tour_list_to_df <- function(tour_list) {

  terr_nm   <- unique(tour_list$name)
  terr_slug <- unique(tour_list$slug)
  terr_beg  <- unique(tour_list$starts_on)
  terr_end  <- unique(tour_list$ends_on)

  shows     <- lapply(tour_list$shows,
                      .tour_show_list_to_df)

  all_shows <- do.call(rbind, shows)

  out <- cbind(tour_name  = terr_nm,
               api_name   = terr_slug,
               tour_start = terr_beg,
               tour_end   = terr_end,
               all_shows,
               stringsAsFactors = FALSE)

  return(out)

}

#' @noRd
.all_tours_to_df <- function(tour_list) {

  all_terr_list <- lapply(tour_list,
                          .tour_list_to_df)

  do.call(rbind, all_terr_list)


}

#' @noRd
.tour_show_list_to_df <- function(show_list) {

  city  <- strsplit(show_list$location, ', ')[[1]][1]
  state <- strsplit(show_list$location, ', ')[[1]][2]

  data.frame(
    date             = show_list$date,
    city             = city,
    state            = state,
    venue            = show_list$venue_name,
    tour_id          = show_list$tour_id,
    show_id          = show_list$id,
    duration         = show_list$duration / 60000,
    likes            = show_list$likes_count,
    soundboard       = show_list$sbd,
    remasterd        = show_list$remastered,
    complete_show    = !show_list$incomplete,
    stringsAsFactors = FALSE
  )

}


# get_venues utils-------

.venue_list_to_df <- function(venue_list) {

  data.frame(
    name             = venue_list$name,
    api_name         = venue_list$slug,
    other_names      = I(list(venue_list$other_names)),
    venue_id         = venue_list$id,
    lat              = venue_list$latitude,
    lon              = venue_list$longitude,
    city             = venue_list$city,
    state            = venue_list$state,
    country          = venue_list$country,
    n_shows          = venue_list$shows_count,
    dates            = I(list(venue_list$show_dates)),
    show_ids         = I(list(venue_list$show_ids)),
    stringsAsFactors = FALSE
  )

}

# get_shows utils-------

.show_list_to_df <- function(show) {

  venue <- data.frame(
    id = show$venue$id,
    name = show$venue$name,
    api_name = show$venue$slug,
    other_names = I(list(show$venue$other_names)),
    city = strsplit(show$venue$location, ', ')[[1]][1],
    state = strsplit(show$venue$location, ', ')[[1]][2],
    lat = show$venue$latitude,
    lon = show$venue$longitude,
    n_shows = show$venue$shows_count,
    stringsAsFactors = FALSE
  )

  data.frame(
    date = show$date,
    venue,
    duration = show$duration / 60000,
    soundboard = show$sbd,
    complete_show = !show$incomplete,
    tags = I(list(show$tags)),
    tour_id = show$tour_id,
    set_list = I(list(.song_list_to_df(show$tracks))),
    stringsAsFactors = FALSE
  )

}


#' @noRd
# Returns the 7 columns here to match up with pi_get_songs(). However, there
# is more information in the "track" object that might be useful. Modify as needed
# to get what you want.
#
# names(track) = c("id", "show_id", "show_date", "title", "position", "duration",
#                  "jam_starts_at_second", "set", "set_name", "likes_count", "slug",
#                  "tags", "mp3", "song_ids", "updated_at")

.track_list_to_df <- function(track) {

  # If there aren't any tags, insert an NA so that the list-column has the same
  # length as the other vectors in the "out" object. Otherwise, error on df creation.

  if(length(track$tags) == 0) {

    tag_list <- list(NA)

  } else {

    tag_list <- lapply(track$tags, function(x) x)

  }

  out <- data.frame(date     = track$show_date,
                    title    = track$title,
                    position = track$position,
                    set      = track$set,
                    duration = track$duration / 60000,
                    likes_ct = track$likes_count,
                    tags     = I(tag_list),
                    stringsAsFactors = FALSE
  )

  return(out)

}

#' @noRd
.all_tags_to_df <- function(tags) {

  out <- data.frame(name        = vapply(tags,
                                         function(x) x$name,
                                         character(1L)),
                    api_name    = vapply(tags,
                                         function(x) x$slug,
                                         character(1L)),
                    description = vapply(tags,
                                         function(x) x$description,
                                         character(1L)),
                    tracks      = NA_integer_,
                    stringsAsFactors = FALSE)

  return(out)

}

#' @noRd
.tag_list_to_df <- function(tags) {

  # list(unlist(track_ids)) converts this to a list column holding a single
  # vector, as opposed to a list of lists with a single integer in each entry

  out <- data.frame(name        = tags$name,
                    api_name    = tags$slug,
                    description = tags$description,
                    tracks      = I(list(unlist(tags$track_ids))),
                    stringsAsFactors = FALSE)

  return(out)

}

#' @noRd

# A couple tests to make sure nothing nefarious is afoot
.pi_validate_params <- function(sort_dir,
                                sort_atr,
                                per_page,
                                page) {

  if(!is.null(sort_dir)) stopifnot(tolower(sort_dir) %in% c("asc", "desc"))

  if(!is.null(per_page)) stopifnot(is.integer(per_page)|| is.double(per_page))
  if(!is.null(page))     stopifnot(is.integer(page)|| is.double(per_page))
  if(!is.null(sort_atr)) stopifnot(tolower(sort_atr) %in% c('date', 'name'))

}
