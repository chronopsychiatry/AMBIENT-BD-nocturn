#' Clean session data
#'
#' @param sessions A dataframe containing the session data
#' @returns The cleaned-up sessions dataframe
#' @importFrom rlang .data
#' @export
#' @examples
#' clean_sessions(example_sessions)
clean_sessions <- function(sessions) {

  sessions |>
    sessions_to_canonical() |>
    apply_adapters(adapters) |>
    standardise_types(.sessions_parsers()) |>
    apply_rules(rules)
}

#' Clean epoch data
#'
#' @param epochs A dataframe containing the epoch data
#' @returns The cleaned-up epochs dataframe
#' @importFrom rlang .data
#' @export
#' @examples
#' clean_epochs(example_epochs)
clean_epochs <- function(epochs) {
  col <- get_epoch_colnames(epochs)

  # Somnofy_v1: if session IDs are missing, create them from filenames
  if (is.null(col$session_id)) {
    epochs$session_id <- stringr::str_extract(epochs$filename[1], "^[^.]+")
    col$session_id <- "session_id"
  }
  # GGIR: parse timenum to POSIXct
  if (!is.null(col$timestamp) && identical(col$timestamp, "timenum")) {
    epochs[[col$timestamp]] <- as.POSIXct(epochs[[col$timestamp]], origin = "1970-01-01", tz = "Europe/London")
  }
  # Set is_asleep column
  if (!is.null(col$sleep_stage) && identical(col$sleep_stage, "class_id")) {  # GGIR format
    epochs$is_asleep <- ifelse(epochs[[col$sleep_stage]] == 0, 1, 0) # is_asleep: 0 = awake, 1 = asleep
    col$is_asleep <- "is_asleep"
  } else if (!is.null(col$sleep_stage) && col$sleep_stage == "sleep_stage") {  # Somnofy format
    epochs$is_asleep <- ifelse(epochs[[col$sleep_stage]] %in% c(4, 5), 0, 1)
    col$is_asleep <- "is_asleep"
  }
  #Convert night to date if it exists
  if (!is.null(col$night)) {
    epochs[[col$night]] <- parse_date(epochs[[col$night]])
  }
  # Create night column if it doesn't exist
  if (is.null(col$night) && !is.null(col$timestamp)) {
    epochs <- group_epochs_by_night(epochs)
    col$night <- "night"
  }
  set_colnames(epochs, col)
}

#' Standardise column types using a list of parser functions
#'
#' @param df The dataframe to standardise
#' @param parsers A list of parsing functions
#' @keywords internal
standardise_types <- function(df, parsers) {
  for (nm in intersect(names(parsers), names(df))) {
    df[[nm]] <- parsers[[nm]](df[[nm]])
  }
  df
}

#' Apply adapter functions
#'
#' @details Adapter functions perform specific actions for some data types, e.g. parse session start and end time in GGIR data
#' @param df The dataframe to process
#' @param adapters A list of lists, containing keys 'detects' (function) and 'apply' (function)
#' @keywords internal
apply_adapters <- function(df, adapters) {
  for (a in adapters) if (isTRUE(a$detects(df))) df <- a$apply(df)
  df
}

#' Apply rules
#'
#' @details Rules create missing columns based on those that are present in the data.
#' The function iterates over all rules to make changes until all possible changes have been made.
#' @param df The dataframe to process
#' @param rules a list of lists containing keys 'requires' (str, column name), 'produces' (str, output column name), and 'apply' (function)
#' @keywords internal
apply_rules <- function(df, rules, max_iter = 10) {
  col <- get_colnames(df)

  for (iter in seq_len(max_iter)) {
    changed <- FALSE

    for (r in rules) {
      has_requires <- all(r$requires %in% names(df)) || is.null(r$requires)
      missing_outputs <- any(!r$produces %in% names(df))
      col_missing <- is.null(col[[r$produces]])

      if (has_requires && missing_outputs && col_missing) {
        df2 <- r$apply(df)
        col[[r$produces]] <- r$produces

        # Detect new columns
        new_cols <- setdiff(names(df2), names(df))
        if (length(new_cols) > 0) {
          changed <- TRUE
        }
        df <- df2
      }
    }

    if (!changed) break
  }
  df <- set_colnames(df, col)
  df
}
