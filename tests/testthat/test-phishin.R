context('phish.in API tests')

test_that('pi_get_song is working', {

  skip_on_cran()
  skip_on_travis()

  apikey <- readRDS('phishin_key.rds')

  you_enjoy_mytest <- pi_get_songs(song = 'you enjoy myself',
                                  apikey = apikey)

  expect_true(inherits(you_enjoy_mytest, 'data.frame'))

  check_punct <- list(colon = pi_get_songs(song = "5:15",
                                          apikey = apikey),
                      apost = pi_get_songs(song = "mike's song",
                                          apikey = apikey),
                      perio = pi_get_songs(song = 'say it to me s.a.n.t.o.s',
                                          apikey = apikey))

  test_class_vec <- vapply(check_punct,
                           function(x) inherits(x, 'data.frame'),
                           logical(1L))
  test_dim_vec   <- vapply(check_punct,
                           function(x) dim(x)[1] > 0,
                           logical(1L))


  expect_true(all(test_class_vec,
                  test_dim_vec))


  # Make sure song = "all" isn't broken

  all_the_glory <- pi_get_songs(song = 'all',
                                apikey = apikey)

  # dim should be 20 provided the phish.in API default doesn't change

  expect_true(dim(all_the_glory)[1] == c(20))
  expect_true(dim(all_the_glory)[2] == c(2))


})

test_that('pi_get_years is working', {

  skip_on_cran()
  skip_on_travis()

  apikey <- readRDS('phishin_key.rds')

  yrs <- pi_get_years(year = 'all',
                      apikey = apikey)

  expect_equal(dim(yrs)[2], 2)
  expect_true(typeof(yrs$year) == 'character')
  expect_true(typeof(yrs$n_shows) == 'integer')

  # Next, test out the individual year. 02 was the smallest n_shows
  # and for our sake, I hope that remains the case for the foreseeable future!

  oh_two <- pi_get_years(year = '2002',
                         apikey = apikey)

  ed_sul_setlist <- oh_two$setlists[[2]]

  # Three shows in 02, that shouldn't change

  expect_true(dim(oh_two)[1] == 3)

  expect_equal(oh_two$venue[3], 'Madison Square Garden')

  expect_equal(ed_sul_setlist$title, "All of These Dreams")

  # Make sure duration computations are good to at least the decimal second
  # We do not store them as actual seconds, because I'm too lazy to conver those
  # right now ;)
  expect_equal(ed_sul_setlist$duration, 3.78, tol = 10e-2)

  # Finally, test that integers work as well as characters

  ints <- pi_get_years(year = 2002,
                       apikey = apikey)

  expect_true(identical(oh_two, ints))


})

test_that('pi_get_eras is working', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  eras <- pi_get_eras(apikey = apikey) # all eras

  cls <- vapply(eras, class, character(1L))

  expect_equal(as.character(cls), rep("character", 2))
  expect_true('3.0' %in% eras$era)
  expect_true('2.0' %in% eras$era)
  expect_true('1.0' %in% eras$era)
  expect_true('1983-1987' %in% eras$years)

  # test that integers work as well as characters

  ints <- pi_get_eras(era = 2,
                      apikey = apikey)

  # Three years, two columns, one band to rule them all

  expect_true(dim(ints)[2] == 2)
  expect_true(dim(ints)[1] == 3)

})

test_that('pi_get_venues is working', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')


  alpine <- pi_get_venues(apikey = apikey,
                          venue = 'Alpine Valley Music Theatre')


  expect_true(inherits(alpine$dates, 'AsIs'))
  expect_equal(alpine$lat, 42.79, tol = 10e-2)

  all_venues <- pi_get_venues(apikey = apikey)

  expect_true(dim(all_venues)[2] == 12)

})

test_that('pi_get_tours is working', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  all_tours <- pi_get_tours(apikey = apikey)

  expect_true(dim(all_tours)[2] == 15)
  expect_true(all_tours$venue[1] == "Harris-Millis Cafeteria, University of Vermont")

  use_terr <- all_tours$api_name[7] # 1985 tour

  single_tour <- pi_get_tours(apikey = apikey,
                              tour = use_terr)

  expect_true(dim(single_tour)[1] == 6)
  expect_true(all(single_tour$soundboard))


})

test_that('pi_get_shows is working', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  test_show <- pi_get_shows(apikey = apikey,
                            show = '2009-06-07')

  # My first song!
  expect_true(test_show$set_list[[1]]$title[1] == 'Chalk Dust Torture')
  expect_true(dim(test_show)[2] == 16)

  sbd_only <- pi_get_shows(apikey = apikey,
                           show = 'all',
                           sbd_only = TRUE)

  # The first sbd show returned *should* always be the same
  expect_equal(sbd_only$date[1], '1985-10-30')

})

test_that('pi_get_dates is working', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  nye <- pi_get_dates(apikey = apikey,
                      date = '12-31')

  expect_true(dim(nye)[2] == 16)

  # dates w/ only one show (so far)

  singleton <- pi_get_dates(apikey = apikey,
                            date = '01-04')

  expect_true(dim(singleton)[1] == 1)

})


test_that('pi_random_show works', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  rand_show <- pi_get_random_show(apikey = apikey)

  expect_equal(dim(rand_show), c(1, 16))

})

test_that('pi_get_tracks works', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  rand_track <- pi_get_tracks(apikey = apikey,
                              track = 42)

  expect_equal(dim(rand_track), c(1, 7))

  # Test no tags case

  rand_track <- pi_get_tracks(apikey = apikey,
                              track  = 1230)

  expect_true(is.na(rand_track$tags[[1]]))
  expect_equal(dim(rand_track), c(1, 7))

})

test_that('pi_get_tags works', {

  skip_on_cran()
  skip_on_travis()
  apikey <- readRDS('phishin_key.rds')

  some_tags <- pi_get_tags(apikey = apikey)

  expect_true(all(is.na(some_tags$tracks)))
  expect_true(all(is.character(some_tags$api_name)))

  alt_rigs <- pi_get_tags(tag    = "Alt Rig",
                          apikey = apikey)

  expect_equal(dim(alt_rigs), c(1, 4))


})
