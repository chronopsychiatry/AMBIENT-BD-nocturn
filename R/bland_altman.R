#' Create a Bland-Altman plot
#'
#' @param sessions1 The first sessions dataframe to be compared
#' @param sessions2 The second sessions dataframe to be compared
#' @param variable The name of the variable to compare. Can be a single value for both dataframes, or an array of two values, one for each dataframe
#' @details This function uses columns:
#' - `night`
#' - `sleep_period`
#' @returns a ggplot object showing the Bland-Altman plot
#' @importFrom rlang .data
#' @export
#' @family comparison plot
#' @examples
#' plot_bland_altman(example_sessions, example_sessions, time_at_sleep_onset)
plot_bland_altman <- function(sessions1, sessions2, variable) {
  check_session_colnames(sessions1, c("night", "sleep_period"))
  check_session_colnames(sessions2, c("night", "sleep_period"))

  var <- rlang::ensym(variable)

  standardise <- function(x, source_label) {
    cols <- get_session_colnames(x)

    keep_longest(x) |>
      dplyr::mutate(
        night  = .data[[cols$night]],
        source = source_label,
        value  = !!var
      ) |>
      dplyr::select(.data$night, .data$source, .data$value)
  }

  s1 <- standardise(sessions1, "sessions1")
  s2 <- standardise(sessions2, "sessions2")

  df <- dplyr::bind_rows(s1, s2) |>
    dplyr::filter(.data$night %in% dplyr::intersect(s1$night, s2$night)) |>
    dplyr::arrange(.data$night, .data$source) |>
    dplyr::group_by(.data$night) |>
    dplyr::summarise(
      average = mean(.data$value, na.rm = TRUE),
      diff = {
        v <- .data$value
        if (length(v) != 2) {
          cli::cli_abort(c(
            "x" = "Dataframes have no night in common",
            "i" = "Make sure the two session dataframes have at least one night in common"
          ))
        }
        v[2] - v[1]
      },
      .groups = "drop"
    )

  print(df)

  ## p <- ggplot2::ggplot(df) +
  ##   ggplot2::geom_point(size = 5)
  
}
