input_sessions_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h4("Sessions"),
    bslib::card(
      shinyWidgets::radioGroupButtons(
        inputId = ns("session_input_type"),
        label = NULL,
        choices = c("Single file upload", "Batch upload"),
        direction = "vertical",
        status = "outline-secondary",
        width = "100%"
      ),
      shiny::conditionalPanel(
        condition = paste0("input['", ns("session_input_type"), "'] == 'Single file upload'"),
        shiny::fileInput(
          inputId = ns("sessions_file"),
          label = NULL,
          accept = c(".csv", ".xls", ".xlsx", ".edf", ".rec")
        ),
      ),
      shiny::conditionalPanel(
        condition = paste0("input['", ns("session_input_type"), "'] == 'Batch upload'"),
        shiny::fluidRow(
          shiny::column(
            width = 3,
            shinyFiles::shinyDirButton(ns("folder_select"), "Browse...", "Please select the folder containing the session files")
          ),
          shiny::column(
            width = 9,
            bslib::card_body(
              shiny::textOutput(ns("selected_folder")),
              class = "selected-folder"
            )
          )
        ),
        shiny::textInput(
          inputId = ns("batch_file_pattern"),
          label = NULL,
          placeholder = "Filename pattern (e.g., 'sessions_')",
          value = ""
        ),
        shiny::actionButton(ns("load_sessions_batch"), "Load Session Data", icon = shiny::icon("upload")),
        shiny::hr()
      ),
      shiny::fluidRow(
        shiny::column(
          width = 8,
          shiny::actionButton(ns("open_session_col_names"), "Set Column Names", width = "100%", icon = shiny::icon("columns"))
        ),
        shiny::column(
          width = 4,
          shiny::actionButton(ns("clear_sessions"), "Clear", width = "100%", icon = shiny::icon("trash"), class = "delete-btn")
        )
      ),
      class = "sidebar_card"
    )
  )
}

input_sessions_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Clear sessions ----
    shiny::observeEvent(input$clear_sessions, {
      clear_sessions(common)
      common$logger |> write_log("Cleared session data", type = "complete")
    })

    # Single file upload ----
    shiny::observeEvent(input$sessions_file, {
      shiny::req(input$sessions_file)
      common$logger |> write_log(paste0("Loaded session file: ", input$sessions_file$name), type = "complete")
      data <- load_sessions(input$sessions_file$datapath)
      init_sessions(data, common)
    })

    # Batch file upload ----
    volumes <- shinyFiles::getVolumes()()
    shinyFiles::shinyDirChoose(input, "folder_select", roots = volumes, session = session)

    output$selected_folder <- shiny::renderText({
      shinyFiles::parseDirPath(roots = volumes, input$folder_select)
    })

    shiny::observeEvent(input$load_sessions_batch, {
      folder_path <- shinyFiles::parseDirPath(roots = volumes, input$folder_select)
      if (length(folder_path) == 0) return()
      common$logger |> write_log(paste0("Batch-loaded session files from: ", folder_path), type = "complete")
      data <- load_batch(folder_path, input$batch_file_pattern, type = "sessions")
      if (is.null(data)) {
        common$logger |> write_log(paste0(
          "No session data found in folder: ", folder_path,
          " with pattern ", input$batch_file_pattern
        ), type = "error")
        return()
      }
      init_sessions(data, common)
    })

    # Column names modal ----
    shiny::observeEvent(input$open_session_col_names, {
      shiny::req(common$sessions())
      show_colnames_modal(
        ns = ns,
        colnames_list = colnames(common$sessions()),
        current_map = get_colnames(common$sessions()),
        title = "Set Session Column Names",
        save_id = "save_session_col_names",
        reset_id = "reset_session_col_names"
      )
    })

    shiny::observeEvent(input$reset_session_col_names, {
      sessions <- set_colnames(common$sessions(), NULL)
      col <- get_colnames(sessions)
      common$sessions(set_colnames(sessions, col))
      common$sessions(clean_sessions(common$sessions()))
      common$logger |> write_log("Reset session column names to default", type = "complete")
      shiny::removeModal()
    })

    shiny::observeEvent(input$save_session_col_names, {
      keys <- names(get_colnames(common$sessions()))
      vals <- lapply(keys, function(key) {
        val <- input[[paste0("col_", key)]]
        if (identical(val, "")) NULL else val
      })
      common$sessions(set_colnames(common$sessions(), stats::setNames(vals, keys)))
      common$sessions(clean_sessions(common$sessions()))
      common$logger |> write_log("Session column names saved", type = "complete")
      shiny::removeModal()
    })

  })
}

init_sessions <- function(sessions, common) {
  col <- get_colnames(sessions)
  sessions$annotation <- ""
  common$sessions(sessions)
  common$session_filters(data.frame(no_sleep = rep(TRUE, nrow(sessions))))
  common$annotations(data.frame(
    id = sessions[[col$id]],
    annotation = "",
    stringsAsFactors = FALSE
  ))
}

clear_sessions <- function(common) {
  common$sessions(NULL)
  common$session_filters(NULL)
  common$annotations(NULL)
}
