#' @export
get_session_colnames <- function(sessions) {
  col_names <- attr(sessions, "col")
  if (is.null(col_names)) {
    col_names <- .sessions_col_none
  }

  for (col in names(col_names)) {
    if (is.null(col_names[[col]])) {
      for (name in .sessions_col_presets[[col]]) {
        if (name %in% colnames(sessions)) {
          col_names[[col]] <- name
          break
        }
      }
    }
  }
  col_names
}

#' @export
get_epoch_colnames <- function(epochs) {
  col_names <- attr(epochs, "col")
  if (is.null(col_names)) {
    col_names <- .epochs_col_none
  }

  for (col in names(col_names)) {
    if (is.null(col_names[[col]])) {
      for (name in .epochs_col_presets[[col]]) {
        if (name %in% colnames(epochs)) {
          col_names[[col]] <- name
          break
        }
      }
    }
  }
  col_names
}

#' @export
get_colnames <- function(df) {
  type <- attr(df, "type")
  if (is.null(type)) {
    NULL
  } else if (type == "sessions") {
    get_session_colnames(df)
  } else if (type == "epochs") {
    get_epoch_colnames(df)
  } else {
    cli::cli_abort(c("x" = "Unknown data type: {.val {type}}.",
                     "i" = "Data type must be \"sessions\" or \"epochs\"."))
  }
}

#' @export
set_colnames <- function(df, col) {
  attr(df, "col") <- col
  df
}
