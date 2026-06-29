comparison_tables_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::div(
      style = "width: 800px;",
      shiny::tableOutput(ns("sessions_summary_table"))
    )
  )
}

comparison_tables_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {

    sessions_summary_table <- shiny::reactive({
      shiny::req(common$secondary_sessions())
      get_comparison_summary_table(common$secondary_sessions())
    })

    output$sessions_summary_table <- shiny::renderTable({
      shiny::req(sessions_summary_table())
      sessions_summary_table()
    })
  })
}

get_comparison_summary_table <- function(secondary_sessions) {
  ss <- secondary_sessions
  sessions_list <- list()

  for (id in names(ss)) {
    df <- ss[[id]]$data
    filters <- ss[[id]]$filters
    title <- ss[[id]]$title

    df <- df[filters$no_sleep == TRUE, , drop = FALSE]
    filters <- filters[filters$no_sleep == TRUE, , drop = FALSE]
    df_filtered <- apply_filters(df, filters)

    sessions_list[[title]] <- df_filtered |>
      dplyr::mutate(
        n_removed = nrow(get_removed_rows(df, filters)),
        n_non_complying = nrow(get_non_complying_sessions(df_filtered))
      ) |>
      dplyr::select("id", "night", "n_removed", "n_non_complying")
  }

  sessions_list |>
    dplyr::bind_rows(.id = "session") |>
    dplyr::group_by(.data$session) |>
    dplyr::summarise(
      total_sessions = dplyr::n_distinct(.data$id),
      earliest_night = min(.data$night) |> format("%Y-%m-%d"),
      latest_night = max(.data$night) |> format("%Y-%m-%d"),
      n_removed = as.integer(mean(.data$n_removed)),
      n_non_complying = as.integer(mean(.data$n_non_complying)),
    )
}
