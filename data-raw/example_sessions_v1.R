# Reads the example sessions data (Somnofy API v1) from a CSV file and saves it as an R data object

example_sessions_v1 <- nocturn::load_sessions("data-raw/example_sessions_v1.csv")

usethis::use_data(example_sessions_v1, overwrite = TRUE)
