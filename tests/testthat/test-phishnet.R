test_that('pn_get_all_songs is working', {
  expect_equal(
    nrow(pn_get_all_songs(key)),
    970
  )
})

test_that('pn_get_all_venues is working', {
  expect_equal(
    nrow(pn_get_all_venues(key)),
    1643
  )
})

test_that('pn_get_setlist is working', {
  expect_equal(
    nrow(pn_get_all_songs(key)),
    970
  )
})
