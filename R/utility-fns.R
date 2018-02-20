contains_price_data <- function(script,card_name) {
  all(str_detect(script, paste0("Date,",card_name)),
      str_detect(script, "20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*"))
}

sanitize_name <- function(x) {
  str_replace_all(x, " ", "+") %>%
    str_replace_all("'","") %>%
    str_replace_all(",","") %>%
    str_replace_all(":","") %>%
    str_replace_all("\\.","")
}

goldfish_url <- function(card_name, set) {
  paste0("https://www.mtggoldfish.com/price/",
         sanitize_name(set),
         "/",
         sanitize_name(card_name))
}
