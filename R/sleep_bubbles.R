#' Plot Sleep Bubbles
#'
#' @description This function creates a bubble plot of sleep sessions, where the size and colour of the bubbles represents the sleep duration.
#' @param sessions The sessions dataframe.
#' @details This function uses columns:
#' - `sleep_period`
#' - `night`
#' @param color_by The variable to color the bubbles by. Can be "default" or any other column name in the sessions dataframe.
#' @returns A ggplot object containing the sleep bubbles graph.
#' @importFrom rlang .data
#' @export
#' @family plot sessions
plot_sleep_bubbles <- function(sessions, color_by = "default") {
  col <- get_session_colnames(sessions)

  sessions <- sessions |>
    dplyr::filter(!is.na(.data[[col$time_at_sleep_onset]]) & !is.na(.data[[col$time_at_wakeup]])) |>
    dplyr::mutate(sleep_duration = .data[[col$sleep_period]] / 3600)

  if (color_by != "default" && color_by %in% names(sessions)) {
    sessions$color_group <- as.factor(sessions[[color_by]])
    color_levels <- levels(sessions$color_group)
    color_map <- stats::setNames(scales::hue_pal()(length(color_levels)), color_levels)
    color_aes <- ggplot2::aes(x = .data[[col$night]], y = .data$sleep_duration, color = .data$color_group)
    color_scale <- ggplot2::scale_color_manual(values = color_map, name = color_by)
  } else {
    sessions$color <- suppressWarnings(dplyr::case_when(
      sessions$sleep_duration >= 6 & sessions$sleep_duration <= 9 ~ scales::col_numeric(
        palette = c("darkblue", "lightgreen"),
        domain = c(6, 9)
      )(sessions$sleep_duration),
      TRUE ~ "grey"
    ))
    color_aes <- ggplot2::aes(x = .data[[col$night]], y = .data$sleep_duration, color = .data$color)
    color_scale <- ggplot2::scale_color_identity()
  }

  ggplot2::ggplot(sessions, color_aes) +
    ggplot2::annotate(
      "rect",
      xmin = min(sessions[[col$night]]) - 1, xmax = max(sessions[[col$night]]) + 1,
      ymin = 6, ymax = 9,
      fill = "lightgrey", alpha = 0.5
    ) +
    ggplot2::geom_point(size = 20, alpha = 0.5) +
    color_scale +
    ggplot2::labs(
      x = NULL,
      y = "Sleep Duration (hours)",
      title = NULL,
      color = if (color_by != "default" && color_by %in% names(sessions)) color_by else NULL
    ) +
    ggplot2::theme_minimal(base_size = 16) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.text = ggplot2::element_text(size = 14),
      axis.title = ggplot2::element_text(size = 16)
    )
}
