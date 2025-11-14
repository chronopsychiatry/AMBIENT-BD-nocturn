#' Plot epoch time series data for a given variable
#'
#' @param epochs The epochs dataframe
#' @param variable The variable to plot (e.g., "temperature_ambient_mean")
#' @param exclude_zero Logical, whether to exclude zero values from the plot (default: FALSE)
#' @param color_by The variable to color the points by. Can be "default" or any other column name in the epochs dataframe.
#' @details This function uses columns:
#' - `timestamp`
#' - `night`
#' @returns A ggplot object
#' @importFrom rlang .data
#' @export
#' @family plot epochs
#' @seealso [plot_timeseries_sessions()] to plot session data.
plot_timeseries <- function(epochs, variable, color_by = "default", exclude_zero = FALSE) {
  col <- get_epoch_colnames(epochs)

  color_by <- if (color_by %in% colnames(epochs)) color_by else "night"

  if (exclude_zero) {
    epochs <- epochs |>
      dplyr::filter(.data[[variable]] != 0)
  }

  ggplot2::ggplot(
    epochs,
    ggplot2::aes(
      x = time_to_hours(shift_times_by_12h(.data[[col$timestamp]])),
      y = .data[[variable]],
      color = as.factor(.data[[color_by]]),
      group = .data[[col$night]]
    )
  ) +
    ggplot2::geom_point() +
    ggplot2::labs(
      x = "Time",
      y = variable,
      color = color_by
    ) +
    ggplot2::theme_minimal(base_size = 16) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    ) +
    ggplot2::scale_x_continuous(
      limits = c(0, 24),
      breaks = seq(0, 24, by = 2),
      labels = function(x) sprintf("%02d:00", (x + 12) %% 24) # Format as HH:00
    )
}

#' Plot session time series data for a given variable
#'
#' @param sessions The sessions dataframe
#' @param variable The variable to plot (e.g., "time_at_sleep_onset")
#' @param exclude_zero Logical, whether to exclude zero values from the plot (default: FALSE)
#' @details This function uses columns:
#' - `night`
#' @param color_by The variable to color the points by. Can be "default" or any other column name in the sessions dataframe.
#' @returns A ggplot object
#' @export
#' @family plot sessions
#' @seealso [plot_timeseries()] to plot epoch data.
plot_timeseries_sessions <- function(sessions, variable, color_by = "default", exclude_zero = FALSE) {
  col <- get_session_colnames(sessions)

  sessions <- sessions |>
    dplyr::filter(!is.na(.data[[variable]]) & .data[[variable]] != "")

  if (exclude_zero) {
    sessions <- sessions |>
      dplyr::filter(.data[[variable]] != 0)
  }

  if (is_iso8601_datetime(sessions[[variable]])) {
    sessions <- sessions |>
      dplyr::mutate(variable = time_to_hours(.data[[variable]]))
  } else {
    sessions$variable <- sessions[[variable]]
  }

  if (color_by != "default" && color_by %in% names(sessions)) {
    sessions$color_group <- as.factor(sessions[[color_by]])
    color_aes <- ggplot2::aes(x = .data[[col$night]], y = .data$variable, color = .data$color_group)
    color_scale <- ggplot2::scale_color_manual(
      values = stats::setNames(scales::hue_pal()(length(levels(sessions$color_group))), levels(sessions$color_group)),
      name = color_by
    )
  } else {
    color_aes <- ggplot2::aes(x = .data[[col$night]], y = .data$variable)
    color_scale <- ggplot2::scale_color_manual(values = "black", guide = "none")
  }

  p <- ggplot2::ggplot(sessions, color_aes) +
    ggplot2::geom_point(size = 5) +
    color_scale +
    ggplot2::labs(
      x = NULL,
      y = variable,
      color = if (color_by != "default" && color_by %in% names(sessions)) color_by else NULL
    ) +
    ggplot2::theme_minimal(base_size = 16) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )

  if (is_iso8601_datetime(sessions[[variable]])) {
    p <- p + ggplot2::scale_y_continuous(
      labels = function(x) sprintf("%02d:%02d", floor(x), round((x %% 1) * 60))
    )
  }
  p
}
