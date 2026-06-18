update_colorby_dropdown <- function(df, plot_options, input, session, input_id = "colorby") {
  shiny::observe({

    available_vars <- c("default", "annotation", names(df()))

    # Update the dropdown, but preserve the selected variable if possible
    current_variable <- plot_options$colorby
    if (!is.null(current_variable) && current_variable %in% available_vars) {
      selected_variable <- current_variable
    } else {
      selected_variable <- available_vars[1]
    }
    plot_options$colorby <- selected_variable

    shiny::updateSelectInput(
      session,
      inputId = input_id,
      choices = available_vars,
      selected = selected_variable
    )
  })

  shiny::observe({
    plot_options$colorby <- input[[input_id]]
  })
}

update_variable_dropdown <- function(df, plot_options, input, session, input_id = "variable") {
  shiny::observe({

    available_vars <- names(df())

    # Update the dropdown, but preserve the selected variable if possible
    current_variable <- plot_options[[input_id]]
    if (!is.null(current_variable) && current_variable %in% available_vars) {
      selected_variable <- current_variable
    } else {
      selected_variable <- available_vars[1]
    }
    plot_options[[input_id]] <- selected_variable

    shiny::updateSelectInput(
      session,
      inputId = input_id,
      choices = available_vars,
      selected = selected_variable
    )
  })

  # Update the stored plot options when the user changes them
  shiny::observe({
    plot_options[[input_id]] <- input[[input_id]]
  })
}

update_session_dropdown <- function(df_list, plot_options, input, session, input_id = "variable") {
  shiny::observe({
    available_ids <- names(df_list)
    titles <- sapply(df_list, `[[`, "title")
    choices <- setNames(titles, available_vars)

    current_sessions <- plot_options[[input_id]]
    if (!is.null(current_sessions)) {
      selected_sessions <- current_sessions
    } else {
      selected_sessions <- available_ids[1]
    }

    shiny::updateSelectInput(
      session,
      inputId = input_id,
      choices = choices,
      selected = selected_sessions
    )
  })

  shiny::observe({
    plot_options[[input_id]] <- input[[input_id]]
  })
}

validate_columns <- function(df, cols, message = TRUE, prefix_msg = "column was not specified") {
  shiny::validate(shiny::need(!is.null(df), FALSE))

  checks <- lapply(cols, function(col) {
    shiny::need(
      col %in% names(df),
      if (message) sprintf("'%s' %s.", col, prefix_msg) else FALSE
    )
  })

  do.call(shiny::validate, checks)
}
