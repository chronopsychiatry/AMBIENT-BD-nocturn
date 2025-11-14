# Reads the example sessions data from a CSV file and saves it as an R data object

example_sessions <- nocturn::load_sessions("data-raw/example_sessions.csv")

usethis::use_data(example_sessions, overwrite = TRUE)
