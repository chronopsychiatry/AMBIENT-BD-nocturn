common <- list(
  secondary_sessions = shiny::reactiveVal(
    list(
      abcdef = list(
        title = "somnofy",
        filters = data.frame(no_sleep = rep(TRUE, nrow(example_sessions))),
        data = example_sessions
      ),
      ghijkl = list(
        title = "axivity",
        filters = data.frame(no_sleep = rep(TRUE, nrow(example_sessions))),
        data = example_sessions
      )
    )
  )
)

test_that("timeseries_comparison module works", {
  shiny::testServer(
    timeseries_comparison_server,
    args = list(common = common),
    {
      plot <- session$getReturned()
      session$setInputs(download_format = "png",
                        variable = "time_at_sleep_onset")

      expect_s3_class(plot, "shiny.render.function")
    }
  )
})
