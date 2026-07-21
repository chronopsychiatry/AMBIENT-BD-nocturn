common <- list(
  sessions = shiny::reactiveVal(example_sessions),
  session_filters = shiny::reactiveVal(data.frame(no_sleep = rep(TRUE, nrow(example_sessions)))),
  annotations = shiny::reactiveVal(
    data.frame(
      id = example_sessions$id,
      annotation = "",
      stringsAsFactors = FALSE
    )
  )
)

test_that("bedtimes_waketimes module works", {
  shiny::testServer(
    bedtimes_waketimes_server,
    args = list(common = common),
    {
      session$setInputs(download_format = "png")
      session$setInputs(groupby = "weekday")
      session$setInputs(colorby = "default")

      expect_no_error(output$bedtimes_waketimes_plot)
    }
  )
})
