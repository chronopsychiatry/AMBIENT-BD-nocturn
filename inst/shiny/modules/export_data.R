export_data_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h4("Raw Data"),
    shiny::downloadButton(
      outputId = ns("download_sessions"),
      label = "Sessions"
    ),
    shiny::downloadButton(
      outputId = ns("download_epochs"),
      label = "Epochs"
    ),
    shiny::br(),
    shiny::br(),
    shiny::h4("Subject Report"),
    shiny::p("(Somnofy data only)"),
    shiny::textInput(
      inputId = ns("title"),
      label = "Report Title",
      value = ""
    ),
    shiny::downloadButton(
      outputId = ns("download_report"),
      label = "Subject Report"
    )
  )
}

export_data_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {

    # Sessions download ----
    shiny::observe({
      shiny::req(common$sessions(), common$session_filters())
      sessions <- apply_filters(common$sessions(), common$session_filters()) |>
        annotate(common$annotations())
      output$download_sessions <- get_table_download_handler(
        session = session,
        common = common,
        output_table = sessions,
        output_name = "sessions"
      )
    })

    # Epochs download ----
    shiny::observe({
      shiny::req(common$epochs(), common$epoch_filters())
      epochs <- apply_filters(common$epochs(), common$epoch_filters())
      output$download_epochs <- get_table_download_handler(
        session = session,
        common = common,
        output_table = epochs,
        output_name = "epochs"
      )
    })

    # Report download ----
    shiny::observe({
      shiny::req(common$sessions(), common$session_filters())
      sessions <- apply_filters(common$sessions(), common$session_filters()) |>
        annotate(common$annotations())
      output$download_report <- get_report_download_handler(
        session = session,
        logger = common$logger,
        sessions = sessions,
        title = shiny::reactive(input$title)
      )
    })

    shiny::observe({
      shiny::req(input$download_report)
      sessions <- apply_filters(common$sessions(), common$session_filters()) |>
        annotate(common$annotations())
      col <- get_colnames(common$sessions())
      shiny::validate(
        shiny::need(!is.null(col$time_at_sleep_onset),
                    common$logger |> write_log("Sleep report: 'time_at_sleep_onset' column was not set", type = "error")),
        shiny::need(!is.null(col$time_at_wakeup),
                    common$logger |> write_log("Sleep report: 'time_at_wakeup' column was not set", type = "error")),
        shiny::need(!is.null(col$time_at_midsleep),
                    common$logger |> write_log("Sleep report: 'time_at_midsleep' column was not set", type = "error")),
        shiny::need(!is.null(col$sleep_onset_latency),
                    common$logger |> write_log("Sleep report: 'sleep_onset_latency' column was not set", type = "error")),
        shiny::need(!is.null(col$sleep_period),
                    common$logger |> write_log("Sleep report: 'sleep_period' column was not set", type = "error")),
        shiny::need(!is.null(col$time_in_bed),
                    common$logger |> write_log("Sleep report: 'time_in_bed' column was not set", type = "error")),
        shiny::need(!is.null(col$night),
                    common$logger |> write_log("Sleep report: 'night' column was not set", type = "error")),
      )
    })

  })
}
