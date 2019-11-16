#' @importFrom attempt stop_if_not
#' @importFrom curl has_internet
check_internet <- function(){
  attempt::stop_if_not(.x = curl::has_internet(),
                       msg = "Please check your internet connexion")
}

#' @importFrom httr status_code
#' @noRd
check_status <- function(res){
  attempt::stop_if_not(.x = status_code(res),
                       .p = ~ .x == 200,
                       msg = "The API returned an error")
}

pn_base_url <- "https://api.phish.net/v3/"
pi_base_url <- "https://phish.in/api/v1/"

