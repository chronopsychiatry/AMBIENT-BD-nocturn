comparison_side_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    comparison_data_ui(ns("comparison_data"))
  )
}

comparison_main_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    bslib::navset_card_tab(
      id = "comparison_tabs_tables",
      bslib::nav_panel("Summary", comparison_summary_table("comp_summary"))
    ),
    bslib::navset_card_tab(
      id = "comparison_tabs_plots",
      bslib::nav_panel("Bland-Altman", bland_altman_ui("bland_altman")),
      bslib::nav_panel("Timeseries", timeseries_comparison_ui("timeseries_comparison_ui"))
    )
  )
}

comparison_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {
    comparison_data_server("comparison_data", common)

    comparison_summary_server("comparison_summary", common)

    bland_altman_server("bland_altman", common)
    timeseries_comparison_server("timeseries_comparison_server", common)
  })
}
