#' Create a Bland-Altman plot
#'
#' @param sessions1 The first sessions dataframe to be compared
#' @param sessions2 The second sessions dataframe to be compared
#' @param variable The name of the variable to compare. Can be a single value for both dataframes, or an array of two values, one for each dataframe
#' @details This function uses columns:
#' - `night`
#' @returns a ggplot object showing the Bland-Altman plot
#' @importFrom rlang .data
#' @export
#' @family comparison plot
#' @examples
#' plot_bland_altman(example_sessions, example_sessions, time_at_sleep_onset)
plot_bland_altman <- function(sessions1, sessions2, variable) {
  check_session_colnames(sessions, c("night"))
  col <- get_session_colnames(sessions)

  sessions1 <- keep_longest(sessions1)
  sessions2 <- keep_longest(sessions2)

  df <- dplyr::mutate(averages = mean(sessions1[[variable]], sessions2[[variable]]))

  df <- dplyr::bind_rows(sessions1, sessions2) |>
    dplyr::mutate(
             averages = .data
           )

  p <- ggplot2::ggplot(df) +
    ggplot2::geom_point(size = 5)
  
}
