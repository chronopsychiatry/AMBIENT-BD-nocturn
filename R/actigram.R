#' Plot an Actigram
#'
#' Generate an actigram from the Somnofy epoch data.
#' @param epochs The epochs data frame
#' @details This function uses columns:
#' - `sleep_period`
#' - `signal_quality_mean`
#' - `sleep_stage`
#' @return A ggplot object representing the actigram
#' @importFrom rlang .data
#' @export
plot_actigram <- function(epochs) {
  col <- get_epoch_colnames(epochs)

  epochs <- epochs |>
    dplyr::mutate(
      timestamp = parse_time(.data[[col$timestamp]]),
      date = lubridate::as_date(.data$timestamp),
      time = time_diff("00:00", .data$timestamp),
      sleep_value = ifelse(.data[[col$sleep_stage]] %in% c(2, 3, 4), .data[[col$signal_quality_mean]], 0)
    )

  epochs_duplicated <- dplyr::bind_rows(
    epochs |>
      dplyr::mutate(
        day_label = paste0(date, " - ", date + 1), # Current day and next day
        time_48h = .data$time # Keep original time (0–24)
      ),
    epochs |>
      dplyr::mutate(
        day_label = paste0(date - 1, " - ", date), # Previous day and current day
        time_48h = .data$time + 24 # Shift time by +24 (24–48)
      )
  )

  ggplot2::ggplot(epochs_duplicated, ggplot2::aes(x = .data$time_48h, y = .data$sleep_value)) +
    ggplot2::geom_col(fill = "black") +
    ggplot2::geom_hline(yintercept = 0, color = "gray", linetype = "solid") +
    ggplot2::facet_wrap(~day_label, ncol = 1, strip.position = "left") +
    ggplot2::scale_x_continuous(
      breaks = seq(0, 48, by = 6),
      labels = c(0, 6, 12, 18, 0, 6, 12, 18, 0)
    ) +
    ggplot2::scale_y_continuous(expand = c(0, 0), limits = c(0, 10)) +
    ggplot2::labs(
      x = "Time (hours)",
      y = NULL,
      title = NULL
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_line(color = "gray", linetype = "dashed"), # Keep vertical grid lines
      panel.grid.major.y = ggplot2::element_blank(), # Remove all horizontal grid lines
      panel.grid.minor = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_line(color = "gray"),
      strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1, size = 5), # Day labels on the left
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_text(size = 8),
      panel.spacing = ggplot2::unit(0.1, "lines"), # Reduce spacing between facets
      strip.placement = "outside", # Place facet labels outside the plot
      strip.background = ggplot2::element_blank(), # Remove background from facet labels
      plot.margin = ggplot2::margin(0, 0, 0, 0) # Remove plot margins
    )
}
