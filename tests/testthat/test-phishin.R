context('phish.in songs')

test_that('pi_get_song is working', {

  skip_on_cran()
  skip_on_travis()

  apikey <- readRDS('phishin_key.rds')

  you_enjoy_mytest <- pi_get_song(song = 'you enjoy myself',
                                  apikey = apikey)

  expect_true(inherits(you_enjoy_mytest, 'data.frame'))

  check_punct <- list(colon = pi_get_song(song = "5:15",
                                          apikey = apikey),
                      apost = pi_get_song(song = "mike's song",
                                          apikey = apikey),
                      perio = pi_get_song(song = 'say it to me s.a.n.t.o.s',
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

  all_the_glory <- pi_get_song(song = 'all',
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


