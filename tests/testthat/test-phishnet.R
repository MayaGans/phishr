test_that('pn_get_all_showdates is working', {

})

test_that('pn_get_all_songs is working', {
  expect_equal(
    nrow(pn_get_all_songs(key)),
    965
  )
})

# this test is really long to run!
# test_that('pn_get_all_setlists is working', {
#   pn_get_all_setlists(key)
# })

test_that('pn_get_all_venues is working', {
  expect_equal(
    nrow(pn_get_all_venues(key)),
    965
  )
})

test_that('pn_get_setlist is working', {
  expect_equal(
    nrow(pn_get_all_songs(key)),
    965
  )

  expect_error(
    nrow(pn_get_all_songs(key)),
    965
  )
})
