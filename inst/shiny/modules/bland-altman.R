bland_altman_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 4,
        shiny::selectInput(
          inputId = ns("sessions1"),
          label = "Sessions 1",
          choices = NULL
        )
      ),
      shiny::column(
        width = 4,
        shiny::selectInput(
          inputId = ns("sessions2"),
          label = "Sessions 2",
          choices = NULL
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 4,
        shiny::selectInput(
          inputId = ns("variable1"),
          label = "Variable 1",
          choices = NULL
        )
      ),
      shiny::column(
        width = 4,
        shiny::selectInput(
          inputId = ns("variable2"),
          label = "Variable 2",
          choices = NULL
        )
      )
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

    ss <- common$secondary_sessions

    plot_options <- shiny::reactiveValues(sessions1 = NULL, sessions2 = NULL, variable1 = NULL, variable2 = NULL)

    s1_data <- shiny::reactive({
      shiny::req(input$sessions1)
      ss()[[input$sessions1]]$data
    })

    s2_data <- shiny::reactive({
      shiny::req(input$sessions2)
      ss()[[input$sessions2]]$data
    })

    update_session_dropdown(ss, plot_options, input, session, input_id = "sessions1")
    update_session_dropdown(ss, plot_options, input, session, input_id = "sessions2")

    update_variable_dropdown(s1_data, plot_options, input, session, input_id = "variable1")
    update_variable_dropdown(s2_data, plot_options, input, session, input_id = "variable2")

    shiny::observe({
      print(input$sessions1)
    })

    bland_altman_plot <- shiny::reactive({
      shiny::req(ss, s1_data(), s2_data(), input$variable1, input$variable2)
      s1 <- apply_filters(s1_data(), ss()[[input$sessions1]]$filters)
      s2 <- apply_filters(s2_data(), ss()[[input$sessions2]]$filters)
      validate_columns(s1, c("night", "sleep_period"))
      validate_columns(s2, c("night", "sleep_period"))

      plot_bland_altman(
        s1,
        s2,
        variable = c(input$variable1, input$variable2)
      )
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
