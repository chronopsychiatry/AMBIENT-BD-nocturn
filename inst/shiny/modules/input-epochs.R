input_epochs_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h4("Epochs"),
    bslib::card(
      shinyWidgets::radioGroupButtons(
        inputId = ns("epoch_input_type"),
        label = NULL,
        choices = c("Single file upload", "Batch upload"),
        direction = "vertical",
        status = "outline-secondary",
        width = "100%"
      ),
      shiny::conditionalPanel(
        condition = paste0("input['", ns("epoch_input_type"), "'] == 'Single file upload'"),
        shiny::fileInput(
          inputId = ns("epochs_file"),
          label = NULL,
          accept = c(".csv", ".xls", ".xlsx", ".edf", ".rec")
        )
      ),
      shiny::conditionalPanel(
        condition = paste0("input['", ns("epoch_input_type"), "'] == 'Batch upload'"),
        shiny::textInput(
          inputId = ns("batch_file_pattern"),
          label = "Filename pattern:",
          value = ""
        ),
        shinyFiles::shinyDirButton(ns("folder_select"), "Choose folder", "Please select the folder containing the epoch files"),
        shiny::actionButton(ns("load_epochs_batch"), "Load Batch Epoch Data")
      ),
      shiny::fluidRow(
        shiny::column(
          width = 8,
          shiny::actionButton(ns("open_epoch_col_names"), "Set Column Names", width = "100%", icon = shiny::icon("columns"))
        ),
        shiny::column(
          width = 4,
          shiny::actionButton(ns("clear_epochs"), "Clear", width = "100%", icon = shiny::icon("trash"), class = "delete-btn")
        )
      ),
      class = "sidebar_card"
    )
  )
}

input_epochs_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Clear epochs ----
    shiny::observeEvent(input$clear_epochs, {
      clear_epochs(common)
      common$logger |> write_log("Cleared epoch data", type = "complete")
    })

    # Single file upload ----
    shiny::observeEvent(input$epochs_file, {
      shiny::req(input$epochs_file)
      common$logger |> write_log(paste0("Loading epoch file: ", input$epochs_file$name), type = "starting")
      data <- load_epochs(input$epochs_file$datapath)
      if (is.null(data)) {
        common$logger |> write_log(paste0("No epoch data found in file: ", input$epochs_file$name), type = "error")
        return()
      }
      init_epochs(data, common)
    })

    # Batch file upload ----
    volumes <- shinyFiles::getVolumes()()
    shinyFiles::shinyDirChoose(input, "folder_select", roots = volumes, session = session)

    shiny::observeEvent(input$load_epochs_batch, {
      folder_path <- shinyFiles::parseDirPath(roots = volumes, input$folder_select)
      if (length(folder_path) == 0) return()
      common$logger |> write_log(paste0("Batch-loading epoch files from: ", folder_path), type = "starting")
      data <- load_batch(folder_path, input$batch_file_pattern, type = "epochs")
      init_epochs(data, common)
    })

    # Column names modal ----
    shiny::observeEvent(input$open_epoch_col_names, {
      shiny::req(common$epochs())
      show_colnames_modal(
        ns = ns,
        colnames_list = colnames(common$epochs()),
        current_map = get_colnames(common$epochs()),
        title = "Set Epoch Column Names",
        save_id = "save_epoch_col_names",
        reset_id = "reset_epoch_col_names"
      )
    })

    shiny::observeEvent(input$reset_epoch_col_names, {
      epochs <- set_colnames(common$epochs(), NULL)
      col <- get_colnames(epochs)
      common$epochs(set_colnames(epochs, col))
      shiny::removeModal()
    })

    shiny::observeEvent(input$save_epoch_col_names, {
      keys <- names(get_colnames(common$epochs()))
      vals <- lapply(keys, function(key) {
        val <- input[[paste0("col_", key)]]
        if (identical(val, "")) NULL else val
      })
      common$epochs(set_colnames(common$epochs(), stats::setNames(vals, keys)))
      common$epochs(clean_epochs(common$epochs()))
      shiny::removeModal()
    })

  })
}

init_epochs <- function(epochs, common) {
  epochs$annotation <- ""
  common$epochs(epochs)
  common$epoch_filters(data.frame(from_sessions = rep(TRUE, nrow(epochs))))
}

clear_epochs <- function(common) {
  common$epochs(NULL)
  common$epoch_filters(NULL)
}
