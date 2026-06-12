adapters <- list(
  list(
    name = "ggir_start_end_window",
    detects = function(df) "start_end_window" %in% names(df) && "calendar_date" %in% names(df),
    apply = function(df) {
      df |>
        dplyr::mutate(
          session_start = sub("-.*$", "", start_end_window) |> parse_time() |> update_date(calendar_date),
          session_end   = sub("^[^-]*-", "", start_end_window) |> parse_time() |> update_date(calendar_date) + lubridate::days(1)
        )
      df <- set_colnames(df, list(session_start = "session_start", session_end = "session_end"))
    }
  ),

  list(
    name = "ggir_workday",
    detects = function(df) identical(get_colnames(df)$is_workday, "daytype"),
    apply = function(df) df$is_workday <- ifelse(df$daytype == "WD", TRUE, FALSE)
  ),

  list(
    name = "ggir_part5_sleep_period_min_to_sec",
    detects = function(df) identical(get_colnames(df)$sleep_period, "dur_spt_sleep_min"),
    apply = function(df) df$sleep_period <- df$dur_spt_sleep_min * 60
  ),

  list(
    name = "ggir_part4_sleep_period_hour_to_sec",
    detects = function(df) identical(get_colnames(df)$sleep_period, "SleepDurationInSpt"),
    apply = function(df) df$sleep_duration <- df$SleepDurationInSpt * 60 * 60
  ),

  list(
    name = "sleep_diary_sleep_onset_min_to_sec",
    detects = function(df) identical(get_colnames(df)$sleep_onset_latency, "onset_latency_min"),
    apply = function(df) df$sleep_onset_latency <- df$onset_latency_min * 60
  )
)

rules <- list(
  list(
    requires = NULL,
    produces = "id",
    apply = function(df) dplyr::mutate(df, id = dplyr::row_number())
  ),

  list(
    requires = "session_start",
    produces = "night",
    apply = function(df) group_sessions_by_night(df)
  ),

  list(
    requires = c("session_start", "sleep_onset_latency"),
    produces = "time_at_sleep_onset",
    apply = function(df) dplyr::mutate(df, time_at_sleep_onset = session_start + sleep_onset_latency)
  ),

  list(
    requires = c("session_start", "session_end"),
    produces = "time_in_bed",
    apply = function(df) dplyr::mutate(df, time_in_bed = time_diff(session_start, session_end, unit = "second"))
  ),

  list(
    requires = c("time_at_sleep_onset", "time_at_wakeup"),
    produces = "sleep_period",
    apply = function(df) dplyr::mutate(df, sleep_period = time_diff(time_at_sleep_onset, time_at_wakeup, unit = "second"))
  ),

  list(
    requires = c("time_at_sleep_onset", "sleep_period"),
    produces = "time_at_midsleep",
    apply = function(df) dplyr::mutate(df, time_at_midsleep = time_at_sleep_onset + (sleep_period / 2))
  ),

  list(
    requires = "night",
    produces = "is_workday",
    apply = function(df) dplyr::mutate(df, is_workday = !(weekdays(night) %in% c("Saturday", "Sunday")))
  )
)
