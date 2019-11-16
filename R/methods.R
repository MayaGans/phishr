#' @title Methods for selected Phish.in classes
#'
#' @importFrom ggplot2 ggplot aes geom_col theme element_text
#' @importFrom rlang quo !!


plot.phishin_all_years <- function(x, y, ...) {

  year_quo <- rlang::quo(year)
  show_quo <- rlang::quo(n_shows)

  ggplot2::ggplot(x,
                  ggplot2::aes(x = !! year_quo)) +
    ggplot2::geom_col(ggplot2::aes(y = !! show_quo)) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90,
                                                       size  = 14))


}


plot.phishin_year <- function(x, y, ...) {

}
