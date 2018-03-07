write_card_price_history <- function(card_name, set, directory) {
  dat <- get_card_price_history(card_name = card_name, set = set)
  #full_directory <- paste0(directory,str_replace_all(set," ","_"),"/")
  full_directory <- paste0(directory,str_replace_all(sanitize_name(set),"\\+","_"),"/")
  full_file_path <- paste0(full_directory,
                           #str_replace_all(card_name," ","_"),
                           sanitize_name(card_name),
                           ".tsv")
  if (!file.exists(full_directory)) dir.create(full_directory)
  write_tsv(dat, full_file_path)
}
