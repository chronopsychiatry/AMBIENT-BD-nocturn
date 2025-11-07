#' Load session data
#'
#' @param sessions_file The path to the sessions file
#' @returns A dataframe containing the session data
#' @details The function loads the session data from a file
#' Supported formats: CSV, Excel, EDF.
#' @export
#' @family data loading
load_sessions <- function(sessions_file) {
  if (!file.exists(sessions_file)) {
    cli::cli_abort(c(
      "!" = "Sessions file not found: {.file {sessions_file}}",
      "i" = "Please check the file path."
    ))
  }

  # Read file ----
  file_ext <- tolower(tools::file_ext(sessions_file))
  if (file_ext == "csv") {
    sessions <- utils::read.csv(sessions_file)
  } else if (file_ext %in% c("xls", "xlsx")) {
    sessions <- readxl::read_excel(sessions_file) |>
      as.data.frame()
  } else if (file_ext %in% c("edf", "rec")) {
    sessions <- read_edf_sessions(sessions_file)
  } else {
    cli::cli_abort(c(
      "!" = "Unsupported file type: {.val {file_ext}}",
      "i" = "Please provide a CSV or Excel file."
    ))
  }

  sessions <- sessions |>
    set_data_type("sessions") |>
    dplyr::mutate(dplyr::across(dplyr::where(is.character), ~dplyr::na_if(., ""))) |>
    clean_sessions()

  if (nrow(sessions) == 0) {
    cli::cli_warn(c(
      "!" = "Sessions table is empty",
      "i" = "Returning NULL"
    ))
    return(NULL)
  }

  sessions
}

#' Load epoch data
#'
#' @param epochs_file The path to the epochs file
#' @returns A dataframe containing the epoch data
#' @details The function loads the epoch data from a file and groups the epochs by night.
#' Supported formats: CSV, Excel, EDF.
#' @export
#' @family data loading
#' @importFrom rlang .data
load_epochs <- function(epochs_file) {
  if (!file.exists(epochs_file)) {
    cli::cli_abort(c(
      "!" = "Epochs file not found: {.file {epochs_file}}",
      "i" = "Please check the file path."
    ))
  }

  file_ext <- tolower(tools::file_ext(epochs_file))
  if (file_ext == "csv") {
    epochs <- utils::read.csv(epochs_file)
  } else if (file_ext %in% c("xls", "xlsx")) {
    epochs <- readxl::read_excel(epochs_file) |>
      as.data.frame()
  } else if (file_ext %in% c("edf", "rec")) {
    epochs <- read_edf_epochs(epochs_file)
  } else {
    cli::cli_abort(c(
      "!" = "Unsupported file type: {.val {file_ext}}",
      "i" = "Please provide a CSV, Excel or EDF file."
    ))
  }

  if (is.null(epochs)) {
    return(NULL)
  }

  epochs <- epochs |>
    set_data_type("epochs") |>
    dplyr::mutate(dplyr::across(dplyr::where(is.character), ~dplyr::na_if(., "")),
                  filename = basename(epochs_file)) |>
    clean_epochs()

  if (nrow(epochs) == 0) {
    cli::cli_warn(c(
      "!" = "Epochs table is empty",
      "i" = "Returning NULL"
    ))
    return(NULL)
  }

  epochs
}

#' Load session or epoch data in batch mode
#'
#' @param folder_path The path to the folder containing session files
#' @param pattern An optional pattern to filter files in the folder
#' @param type The type of data to load: "sessions" or "epochs"
#' @returns A dataframe containing the combined session data from all matching files in the folder
#' @family data loading
#' @export
load_batch <- function(folder_path, pattern = NULL, type = "sessions") {
  if (!dir.exists(folder_path)) {
    cli::cli_abort(c(
      "!" = "Folder not found: {.file {folder_path}}",
      "i" = "Please check the folder path."
    ))
  }

  all_files <- list.files(folder_path, pattern = pattern, full.names = TRUE)

  if (length(all_files) == 0) {
    cli::cli_warn(c(
      "!" = "No files found in folder: {.file {folder_path}} with pattern: {.val {pattern}}",
      "i" = "Returning NULL"
    ))
    return(NULL)
  }

  all_data <- data.frame()
  for (f in all_files) {
    if (type == "sessions")
      data <- load_sessions(f)
    else if (type == "epochs") {
      data <- load_epochs(f)
    } else {
      cli::cli_abort(c(
        "!" = "Unsupported data type: {.val {type}}",
        "i" = "Please use 'sessions' or 'epochs'."
      ))
    }
    if (!is.null(data)) {
      all_data <- dplyr::bind_rows(all_data, data)
    }
  }
  all_data <- all_data |>
    set_data_type(type)

  if (type == "sessions") {
    clean_sessions(all_data)
  } else if (type == "epochs") {
    clean_epochs(all_data)
  }
}

#' @export
set_data_type <- function(data, type) {
  attr(data, "type") <- type
  data
}
