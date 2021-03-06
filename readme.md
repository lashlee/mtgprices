R Notebook
================

This is my work in progress for parsing MTG Goldfish pages to extract card prices.

``` r
suppressMessages(library(tidyverse))
library(xml2)
library(reticulate)
library(devtools)
library(roxygen2)
library(here)
```

    ## here() starts at /home/john/project/mtgprices

``` r
options(tibble.print_max = Inf)
use_python("/usr/bin/python3") #mtgsdk requires python3
basic_lands <- c("Plains", "Island", "Swamp", "Mountain", "Forest")
error_log_file_path <- paste0(here(),"/get_price_error_",format(Sys.Date(),"%Y_%m_%d"),".log")
if(!file.exists(error_log_file_path)) file.create(error_log_file_path)
```

Load the package.

``` r
load_all()
```

    ## Loading mtgprices

``` r
data_dir <- "/home/john/data/mtg/"
```

Snapcaster Mage from Innistrad will be our sample card.

``` r
card_name <- "Snapcaster Mage"
set <- "Innistrad"
```

Get and then print Snapcaster Mage's price history. Note that the assignment is just illustrative. `plot_card_price_history` will get the history on its own.

``` r
snapcaster_mage_price_history <- get_card_price_history(card_name, set)
```

    ## [1] "Snapcaster Mage"
    ## [1] "Innistrad"
    ## [1] "https://www.mtggoldfish.com/price/Innistrad/Snapcaster+Mage"

``` r
plot_card_price_history(card_name, set) %>% plot
```

    ## [1] "Snapcaster Mage"
    ## [1] "Innistrad"
    ## [1] "https://www.mtggoldfish.com/price/Innistrad/Snapcaster+Mage"

![](readme_files/figure-markdown_github/unnamed-chunk-4-1.png)

Now write down the history to disk.

``` r
write_card_price_history(card_name = card_name, 
                         set = set,
                         directory = data_dir)
```

    ## [1] "Snapcaster Mage"
    ## [1] "Innistrad"
    ## [1] "https://www.mtggoldfish.com/price/Innistrad/Snapcaster+Mage"

The `extract_card_info` function will get card information from the mtgsdk object.

``` r
extract_card_info <- function(card) {
  if (!identical(class(card),c("mtgsdk.card.Card", "python.builtin.object")))
    stop("Input is not of the correct class, c(\"mtgsdk.card.Card\", \"python.builtin.object\").")
  list(name          = card$name,
       set_code      = card$set,
       set_name      = card$set_name,
       layout        = card$layout,
       number        = card$number,
       has_alt_names = !is.null(card$names) & length(card$names) > 1)
}
```

``` r
mtgsdk <- import("mtgsdk")
card_dat <- mtgsdk$Card$all()
```

``` r
#Already saved, no need to rerun.
card_dat_parsed <- card_dat %>% 
  map_df(~list(name = .x$name, 
               type = .x$type,
               set_name = .x$set_name, 
               number = ifelse(is.null(.x$number), NA_character_, .x$number),
               layout = .x$layout,
               has_alt_names = !is.null(.x$names) & length(.x$names) > 1 ,
               has_variations = !is.null(.x$variations) & length(.x$variations) > 0)) %>% 
  mutate(split_num = str_extract_all(number,"[0-9]+",simplify=TRUE)) %>% 
  group_by(set_name, split_num) %>% 
  #mutate(split_names = case_when(all(layout == "split", (set_name %in% expansion_sets) | (set_name %in% core_sets)) ~ paste0(name, collapse = " "), TRUE ~ ""))
  mutate(split_name = case_when(layout == "split" ~ paste0(name, collapse = " "), TRUE ~ NA_character_)) %>% 
  mutate(lookup_name = coalesce(split_name, name)) %>% 
  ungroup

saveRDS(card_dat_parsed, file = "card_dat.RDS")
```

There are some data on particular sets to watch out for included. I will eventually convert these to RDS to properly package them up.

``` r
no_go_sets <- read_tsv(file = "no_go_sets.tsv", col_names = "set", col_types = list(col_character())) %>% unlist
core_sets <- read_tsv(file = "core_sets.tsv", col_names = "set", col_types = list(col_character())) %>% unlist
expansion_sets <- read_tsv(file = "expansion_sets.tsv", col_names = "set", col_types = list(col_character())) %>% unlist
```

For now bring in the data I've already retrieved and saved.

``` r
card_dat_parsed <- readRDS("card_dat.RDS")
```

Here's an example command to pull all the sets.

``` r
all_sets <- card_dat_parsed %>% distinct(set_name) %>% arrange(set_name) %>% unlist(use.names = FALSE)
head(all_sets, 10)
```

    ##  [1] "15th Anniversary" "Aether Revolt"    "Alara Reborn"    
    ##  [4] "Alliances"        "Amonkhet"         "Anthologies"     
    ##  [7] "Antiquities"      "Apocalypse"       "Arabian Nights"  
    ## [10] "Archenemy"

And some simple checks:

``` r
all(no_go_sets %in% all_sets)
```

    ## [1] TRUE

``` r
all(core_sets %in% all_sets)
```

    ## [1] TRUE

``` r
all(expansion_sets %in% all_sets)
```

    ## [1] TRUE

Sample some trial data that you can then attempt to save later.

``` r
trial_dat <- card_dat_parsed %>% 
  #filter(!(set_name %in% no_go_sets)) %>% 
  #filter(!(set_name %in% c("Unglued", "Unhinged", "Unstable"))) %>% #Exclude to start with for simplicity.
  filter((set_name %in% expansion_sets) | (set_name %in% core_sets)) %>% 
  filter(!has_alt_names | str_detect(number, "^[0-9]+$|^[0-9]+a$")) %>% 
  filter(!(name %in% basic_lands) | (set_name %in% c("Unglued", "Unhinged", "Unstable"))) %>% 
  filter((type != "Conspiracy") | (set_name != "Magic: The Gathering—Conspiracy")) %>% #Goldfish doesn't include conspiracies from CNS either.
  filter(!has_variations) %>% #Figure this out later. This is for cards like Fallen Empires Hymn to Tourach or Alliances Arcane Denial.
  filter(name != "Kongming, \"Sleeping Dragon\"") %>% #For some reason many of their Kongming links are broken.
  filter((name != "Phage the Untouchable Avatar") | (set_name != "Vanguard")) %>% #No price history available.
  filter(!(type %in% c("Scheme", "Ongoing Scheme"))) %>% #No prices.
  sample_n(100)
```

``` r
safely_write_card_price_history <- safely(write_card_price_history)
error_behavior <- function(message) {write(toString(message), error_log_file_path, append=TRUE)}

tryCatch({
  trial_dat %>%
    select(name, set_name) %>% 
    pwalk(~ write_card_price_history(card_name = ..1, set = ..2, directory = data_dir))
  }, error = error_behavior
)
```

Some cards with multiple names have exceptions to note:

-   Who What When Where Why
