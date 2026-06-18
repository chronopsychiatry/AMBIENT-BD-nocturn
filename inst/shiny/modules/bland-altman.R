bland_altman_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::selectInput(
      InputId = ns("sessions1"),
      label = "Sessions 1",
      choices = NULL
    ),
    shiny::selectInput(
      InputId = ns("sessions2"),
      label = "Sessions 2",
      choices = NULL
    ),
    shiny::selectInput(
      InputId = ns("variable1"),
      label = "Variable 1",
      choices = NULL
    ),
    shiny::selectInput(
      InputId = ns("variable2"),
      label = "Variable 2",
      choices = NULL
    ),
    shiny::plotOutput(ns("bland_altman_plot")),
    shiny::downloadButton(
      outputId = ns("download_plot"),
      label = NULL,
      class = "small-btn"
    ),
    shiny::radioButtons(
      inputId = ns("download_format"),
      label = NULL,
      choices = c("PNG" = "png", "PDF" = "pdf", "SVG" = "svg"),
      inline = TRUE
    )
  )
}

bland_altman_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {

    plot_options = shiny::reactiveValues(sessions1 = NULL, sessions2 = NULL, variable1 = NULL, variable2 = NULL)
    update_session_dropdown(common$secondary_sessions(), plot_options, input, session, input_id = "sessions1")
    update_session_dropdown(common$secondary_sessions(), plot_options, input, session, input_id = "sessions2")

    sessions1 <- shiny::reactiveVal({
      shiny::req(input$sessions1)
      # Here just retrieve the data from the ID select in input$sessions1
    })

    sessions2 <- shiny::reactiveVal({
      shiny::req(input$sessions2)
      
    })

    shiny::observe({
      shiny::req(sessions1(), sessions2())
      update_variable_dropdown(sessions1(), plot_options, input, session, input_id = "variable1")
      update_variable_dropdown(sessions2(), plot_options, input, session, input_id = "variable2")
    })

    bland_altman_plot <- shiny::reactive({
      # Plot definition here
    })

    output$bland_altman_plot <- shiny::renderPlot({
      shiny::req(bland_altman_plot)
      bland_altman_plot()
    })

    output$download_plot <- get_plot_download_handler(
      session = session,
      common = common,
      output_plot = bland_altman_plot,
      format = shiny::reactive(input$download_format),
      width = 12,
      height = 6
    )
  })
}
