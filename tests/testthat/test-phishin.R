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
