scatter_base_theme_ = function(base_size=15) {
  theme_bw(base_size = base_size) +
    theme(panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.line = element_line(colour = "#170a45", size = .5),
          axis.ticks = element_line(colour = "#170a45", size = .2),
          axis.text = element_text(color = '#170a45'))
}

gg_qqplot <- function(ps, ci = 0.95, max_yval = 30) {
  # Many thanks to github user slowkow for this function
  # https://gist.github.com/slowkow/9041570
  ps <- ps[!is.na(ps)]
  n  <- length(ps)
  bf <- (1 - ci) / n
  df <- data.frame(
    observed = -log10(sort(ps)),
    expected = -log10(ppoints(n)),
    clower   = -log10(qbeta(p = (1 - ci) / 2, shape1 = 1:n, shape2 = n:1)),
    cupper   = -log10(qbeta(p = (1 + ci) / 2, shape1 = 1:n, shape2 = n:1))
  )
  df$observed[df$observed > max_yval] <- max_yval
  log10Pe <- expression(paste("Expected -log"[10], plain(P)))
  log10Po <- expression(paste("Observed -log"[10], plain(P)))
  ggplot(df) +
    geom_point(aes(expected, observed), size = 3) +
    geom_abline(intercept = 0, slope = 1, alpha = 0.5) +
    geom_line(aes(expected, cupper), linetype = 2) +
    geom_line(aes(expected, clower), linetype = 2) +
    xlab(log10Pe) +
    ylab(log10Po) +
    geom_hline(yintercept = -log10(bf)) +
    scatter_base_theme_()
}