context('phish.in API tests')

test_that('pi_get_all_songs is working', {

  skip_on_cran()
  skip_on_travis()

  all_songs <- pi_get_all_songs()

  expect_equal(
    nrow(all_songs),
    950
  )

  expect_equal(
    colnames(all_songs),
    c('slug', 'title', 'artist', 'tracks_count')
  )

})

test_that('pi_get_all_venues is working', {

  skip_on_cran()
  skip_on_travis()

  all_venues <- pi_get_all_venues()

  expect_equal(
    nrow(all_venues),
    674
  )

  expect_equal(
    colnames(all_venues),
    c('name', 'latitude', 'longitude', 'city', 'state', 'country', 'location')
  )

})

test_that('pi_get_show_by_date is working', {

  skip_on_cran()
  skip_on_travis()

  expect_equal(
    length(pi_get_show_by_date("1999-12-31")),
    19
  )

  expect_equal(
    names(pi_get_show_by_date("1999-12-31")),
    c(
      "id",
      "date",
      "cover_art_urls",
      "album_cover_url",
      "album_zip_url",
      "duration",
      "incomplete",
      "admin_notes",
      "tour_name",
      "venue_name",
      "venue",
      "taper_notes",
      "likes_count",
      "updated_at",
      "tags",
      "tracks",
      "liked_by_user",
      "previous_show_date",
      "next_show_date"
    ))

})

test_that('pi_get_all_times_played works', {

  skip_on_cran()
  skip_on_travis()

  possum <- pi_get_all_times_played('possum')

  expect_equal(nrow(possum), 518)
  expect_equal(
    names(possum),
    c("id",
      "title",
      "show_date",
      "duration_sec",
      "duration_min",
      "venue",
      "location",
      "mp3_url",
      "tags",
      "taper_notes"
    )
  )

})
