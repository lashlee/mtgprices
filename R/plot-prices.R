plot_card_price_history <- function(card_name, set) {
  g <- get_card_price_history(card_name = card_name,
                              set = set) %>%
    ggplot(aes(x=date,y=price,group=category,color=category)) +
      geom_line() +
      scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
      ggtitle(paste0(card_name,": ",set," Price History"),
              subtitle = paste0("Data Retrieved from MTG Goldfish on ", format(Sys.time(), "%Y%m%d"))) +
      xlab("") +
      ylab("Price in US Dollars") +
      theme_classic()
  return(g)
}
