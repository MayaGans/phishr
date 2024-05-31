make_list_from_html <- function(str) {
  html_string <- as.character(str)

  extract_td <- function(tr) {
    regmatches(tr, gregexpr("(?<=<td>).*?(?=</td>)", tr, perl = TRUE))[[1]]
  }

  tr_matches <- regmatches(html_string, gregexpr("<tr>.*?</tr>", html_string))[[1]]
  lapply(tr_matches, extract_td)
}
