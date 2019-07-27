library(devtools)
library(usethis)
library(desc)

# Remove default DESC
unlink("DESCRIPTION")
# Create and clean desc
my_desc <- description$new("!new")

# Set your package name
my_desc$set("Package", "phishr")

#Set your name
my_desc$set("Authors@R", "person('Maya', 'Gans', email = 'jaffe.maya@gmail.com',
            role = c('cre', 'aut'))")

# Remove some author fields
my_desc$del("Maintainer")

# Set the version
my_desc$set_version("0.1")

# The title of your package
my_desc$set(Title = "Phish.net API Wrapper")
# The description of your package
my_desc$set(Description = "An API wrapper for the phish.net website to extract setlist, rating, and jamchart data.")
# The urls
my_desc$set("URL", "http://this")
my_desc$set("BugReports", "http://that")
# Save everyting
my_desc$write(file = "DESCRIPTION")

# If you want to use the MIT licence, code of conduct, and lifecycle badge
use_mit_license(name = "Maya GANS")
use_code_of_conduct()
use_lifecycle_badge("Experimental")
use_news_md()

# Get the dependencies
use_package("httr")
use_package("jsonlite")
use_package("curl")
use_package("attempt")
use_package("purrr")
use_package("textreadr")

# Clean your description
use_tidy_description()
