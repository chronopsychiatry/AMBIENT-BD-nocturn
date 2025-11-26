#' Check that required columns are set and present in the data
#'
#' This function checks that the required column names have been set (e.g. using set_colnames)
#' and that these columns are present in the provided data frame.
#' @param data A data frame to check for required columns.
#' @param required_cols A character vector of required column identifiers.
#' @return No return value, called for its side effects.
#' @keywords internal
#' @export
check_columns <- function(data, required_cols, call = rlang::caller_env()) {
  col <- get_colnames(data)
  unset_cols <- required_cols[sapply(col[required_cols], is.null)]
  if (length(unset_cols) > 0) {
    cli::cli_abort(c(
      "x" = "Some required column names have not been set",
      "i" = "Unset column names: {paste(unset_cols, collapse = ', ')}",
      "i" = "Use {.fn set_colnames} to set column names."
    ), call = call)
  }
  missing_cols <- setdiff(col[required_cols], names(data))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "x" = "Some column names were set but are not present in the data",
      "i" = "Missing columns in data: {paste(missing_cols, collapse = ', ')}",
      "i" = "Check the data or use {.fn set_colnames} to set correct column names."
    ), call = call)
  }
}
