get_card_price_history <- function(card_name, set) {
  Sys.sleep(.5)
  print(card_name)
  print(set)
  print(goldfish_url(card_name, set))
#  dat <- parse_goldfish_page(goldfish_url(card_name, set))
#  return(dat)
  dat <- read_html(goldfish_url(card_name, set)) %>%
    xml_find_all("//script") %>%
    xml_text %>%
    keep( ~ contains_price_data(.x,card_name) ) %>%
    str_match_all("e.target.hash == \\\"#tab-(online|paper)\\\"|20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*") %>%
    as.data.frame(stringsAsFactors=FALSE) %>%
    fill(X2) %>%
    filter(!(X1 %in% c("e.target.hash == \"#tab-paper\"", "e.target.hash == \"#tab-online\""))) %>%
    separate(X1,c("date","price"),sep=", ") %>%
    mutate(date=as.Date(date),price=as.numeric(price)) %>%
    select(date,price,category=X2)
  return(dat)
}

parse_goldfish_page <- function(url) {
  dat <- read_html(url) %>%
    xml_find_all("//script") %>%
    xml_text %>%
    keep( ~ contains_price_data(.x,card_name) ) %>%
    str_match_all("e.target.hash == \\\"#tab-(online|paper)\\\"|20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*") %>%
    as.data.frame(stringsAsFactors=FALSE) %>%
    fill(X2) %>%
    filter(!(X1 %in% c("e.target.hash == \"#tab-paper\"", "e.target.hash == \"#tab-online\""))) %>%
    separate(X1,c("date","price"),sep=", ") %>%
    mutate(date=as.Date(date),price=as.numeric(price)) %>%
    select(date,price,category=X2)
  return(dat)
}
