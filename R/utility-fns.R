contains_price_data <- function(script,card_name) {
  # Apparently Goldfish takes out the comma in card names.
  # Apparently Goldfish replaces apostrophes with &#39; in card names.
  all(str_detect(script, paste0("Date,",
                                card_name %>%
                                  str_replace_all(",","") %>%
                                  str_replace_all("'","&#39;"))),
      str_detect(script, "20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*"))
}

sanitize_name <- function(x) {
  str_replace_all(x, " ", "\\+") %>%
    str_replace_all("'","") %>%
    str_replace_all(",","") %>%
    str_replace_all(":","") %>%
    str_replace_all("\\.","")
}

goldfish_set <- function(set) {
  case_when(set == "Magic: The Gathering—Commander"  ~ "Commander",
            set == "Magic: The Gathering—Conspiracy" ~ "Conspiracy",
            set == "Judge Gift Program"              ~ "Judge Promos",
            set == "Prerelease Events"               ~ "Prerelease Cards",
            set == "Time Spiral \"Timeshifted\""     ~ "Timeshifted",
            set == "Magic Game Day"                  ~ "Game Day Promos",
            TRUE                                     ~ set)
}

goldfish_url <- function(card_name, set) {
  paste0("https://www.mtggoldfish.com/price/",
         sanitize_name(goldfish_set(set)),
         "/",
         sanitize_name(card_name))
}
