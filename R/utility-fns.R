goldfish_url <- function(card_name, set) {
  paste0("https://www.mtggoldfish.com/price/",
         str_replace_all(set," ","+"),
         "/",
         str_replace_all(card_name," ","+"))
}
contains_price_data <- function(script,card_name) {
  all(str_detect(script, paste0("Date,",card_name)),
      str_detect(script, "20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*"))
}
