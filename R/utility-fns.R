contains_price_data <- function(script,card_name) {
  # Apparently Goldfish takes out the comma in card names.
  # Apparently Goldfish replaces apostrophes with &#39; in card names.
  all(str_detect(script, paste0("Date,",
                                card_name %>%
                                  str_replace_all(",","") %>%
                                  str_replace_all("'","&#39;") %>%
                                  str_replace_all("â","a"))),
      str_detect(script, "20[0-9]{2}-[0-9]{2}-[0-9]{2}, \\d+\\.*\\d*"))
}

sanitize_name <- function(x) {
  str_replace_all(x, " ", "\\+") %>%
    str_replace_all("'","") %>%
    str_replace_all(",","") %>%
    str_replace_all(":","") %>%
    str_replace_all("\\.","") %>%
    str_replace_all("â","a")
}

goldfish_set <- function(set) {
  case_when(set == "Magic: The Gathering-Commander"           ~ "Commander",
            set == "Magic: The Gathering—Conspiracy"          ~ "Conspiracy",
            set == "Judge Gift Program"                       ~ "Judge Promos",
            set == "Prerelease Events"                        ~ "Prerelease Cards",
            set == "Time Spiral \"Timeshifted\""              ~ "Timeshifted",
            set == "Magic Game Day"                           ~ "Game Day Promos",
            set == "Modern Masters 2015 Edition"              ~ "Modern Masters 2015",
            set == "Friday Night Magic"                       ~ "FNM Promos",
            set == "Wizards Play Network"                     ~ "WPN Promos",
            set == "Duel Decks: Elspeth vs. Kiora"            ~ "Duel Decks Elspeth vs%252E Kiora",
            set == "Masterpiece Series: Amonkhet Invocations" ~ "Amonkhet Invocations",
            set == "Release Events"                           ~ "Release Event Cards",
            set == "Champs and States"                        ~ "Champs Promos",
            set == "Super Series"                             ~ "JSS MSS Promos",
            set == "Masterpiece Series: Kaladesh Inventions"  ~ "Kaladesh Inventions",
            TRUE                                              ~ set)
}

goldfish_url <- function(card_name, set) {
  paste0("https://www.mtggoldfish.com/price/",
         sanitize_name(goldfish_set(set)),
         "/",
         sanitize_name(card_name))
}
