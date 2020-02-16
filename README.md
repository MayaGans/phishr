[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

## phishr
 
This is a package to extract data from the Phish.net and phish.in APIs! You can use this package to search for Phish data for:
 * Setlists (both)
 * Show ratings (.net only)
 * Jamchart entries [.net only]
 * Eras (.in only)
 * Years (.in only)
 * Songs (.in only)
 * Tours (.in only)
 * Venues (.in only)
 * Tags (.in only, used to highlight specific content, see [here](https://phish.in/tags) for more details)
 
 
 # Example:
What's the deal with Big Cypress?
 
```
# Request API key from https://api.phish.net/keys/
# Store key as string
phishnet_apikey <- "XXX"
 
# Get a dataframe of songs, segues, and set songs were played in
phishr::pn_get_setlist(phishnet_key, "1999-12-31")

# Get the show notes 
phishr::pn_get_show_notes(phishnet_key, "1999-12-31")

# Get the show rating
phishr::pn_get_show_rating(phishnet_key, "1999-12-31")
 ```

Please (so that we have no regrets), note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
