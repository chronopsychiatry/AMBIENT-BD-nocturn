comparison_side_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    comparison_data_ui(ns("comparison_data"))
  )
}

comparison_main_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::HTML("HELLO THERE")
}

comparison_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {

    comparison_data_server("comparison_data", common)
  })
}
