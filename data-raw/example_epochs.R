# Reads the example epoch data from a CSV file and saves it as an R data object

example_epochs <- nocturn::load_epochs("data-raw/example_epochs.csv") |>
  dplyr::select(  # Remove variables that are not recorded (all values are zero in the original table)
    -dplyr::starts_with("external"),
    -dplyr::starts_with("heart_rate"),
    -dplyr::starts_with("respiration")
  )

usethis::use_data(example_epochs, overwrite = TRUE)
