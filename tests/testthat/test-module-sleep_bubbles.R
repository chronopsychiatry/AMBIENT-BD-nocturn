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

test_that("sleep_bubbles module works", {
  shiny::testServer(
    sleep_bubbles_server,
    args = list(common = common),
    {
      session$setInputs(download_format = "png")

      expect_no_error(output$sleep_bubbles_plot)
    }
  )
})
