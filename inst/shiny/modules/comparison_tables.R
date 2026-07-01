comparison_tables_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    bslib::navset_card_tab(
      id = "comparison_tabs_tables",
      bslib::nav_panel(
        "Summary",
        shiny::div(
          style = "width: 800px;",
          shiny::tableOutput(ns("sessions_summary_table"))
        )
      ),
      bslib::nav_panel(
        "Sleep timing",
        shiny::div(
          style = "width: 800px;",
          shiny::tableOutput(ns("sessions_sleep_table"))
        )
      ),
      bslib::nav_panel(
        "Differences",
        shiny::tableOutput(ns("onset_diffs"))
      )
    )
  )
}

comparison_tables_server <- function(id, common) {
  shiny::moduleServer(id, function(input, output, session) {

    ss <- common$secondary_sessions

    sessions_summary_table <- shiny::reactive({
      shiny::req(ss())
      get_comparison_summary_table(ss())
    })

    output$sessions_summary_table <- shiny::renderTable({
      shiny::req(sessions_summary_table())
      sessions_summary_table()
    })

    sessions_sleep_table <- shiny::reactive({
      shiny::req(ss())
      get_comparison_sleep_table(ss())
    })

    output$sessions_sleep_table <- shiny::renderTable({
      shiny::req(sessions_sleep_table())
      sessions_sleep_table()
    })

    onset_diffs <- shiny::reactive({
      sessions_list <- list()
      for (i in names(ss())) {
        title <- ss()[[i]]$title
        sessions_list[[title]] <- ss()[[i]]$data
      }
      bland_altman_pairwise_matrix(sessions_list, variable = "time_at_sleep_onset")
    })

    output$onset_diffs <- shiny::renderTable({
      onset_diffs()
    },
    rownames = TRUE)

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
      total_sessions = dplyr::n_distinct(.data$id, na.rm = TRUE),
      earliest_night = min(.data$night) |> format("%Y-%m-%d"),
      latest_night = max(.data$night) |> format("%Y-%m-%d"),
      n_removed = as.integer(mean(.data$n_removed)),
      n_non_complying = as.integer(mean(.data$n_non_complying))
    )
}

get_comparison_sleep_table <- function(secondary_sessions) {
  ss <- secondary_sessions
  sessions_list <- list()

  for (id in names(ss)) {
    df <- ss[[id]]$data
    filters <- ss[[id]]$filters
    title <- ss[[id]]$title

    sessions_list[[title]] <- df |>
      apply_filters(filters) |>
      dplyr::select(dplyr::any_of(c("id", "night", "time_at_sleep_onset", "time_at_wakeup", "time_in_bed", "sleep_period")))
  }

  sessions_list |>
    dplyr::bind_rows(.id = "session") |>
    dplyr::group_by(.data$session) |>
    get_sessions_summary()
}

bland_altman_pairwise_matrix <- function(sessions_list, variable, digits = 3) {

  nm <- names(sessions_list)

  pair_stats <- function(sessions1, sessions2, variable) {

    variable <- rlang::sym(variable)

    if (is_iso8601_datetime(sessions1[[variable]]) && is_iso8601_datetime(sessions2[[variable]])) {
      var_type <- "time"
    } else if (is.numeric(sessions1[[variable]][1]) && is.numeric(sessions2[[variable]][1])) {
      var_type <- "numeric"
    }

    standardise <- function(x, source_label, variable_sym) {
      x <- keep_longest(x) |>
        dplyr::mutate(
          source = source_label,
          value  = !!variable_sym
        ) |>
        dplyr::select("night", "source", "value") |>
        dplyr::filter(!is.na(.data$value))

      if (var_type == "time") {
        x$value <- update_date(x$value, "0000-01-01")
      }
      x
    }

    s1 <- standardise(sessions1, "sessions1", variable)
    s2 <- standardise(sessions2, "sessions2", variable)

    df <- dplyr::bind_rows(s1, s2) |>
      dplyr::filter(.data$night %in% dplyr::intersect(s1$night, s2$night)) |>
      dplyr::arrange(.data$night, .data$source) |>
      dplyr::group_by(.data$night) |>
      dplyr::summarise(
        average = {
          if (var_type == "numeric") {
            mean(.data$value, na.rm = TRUE)
          } else {
            mean_time(.data$value) |>
              shift_times_by_12h()
          }
        },
        diff = {
          v <- .data$value
          if (var_type == "time") {
            circ_time_diff(v[2], v[1], unit = "hour")
          } else {
            as.numeric(v[2] - v[1])
          }
        },
        .groups = "drop"
      )

    md  <- mean(df$diff, na.rm = TRUE)
    sdd <- stats::sd(df$diff, na.rm = TRUE)

    c(
      md = md,
      sdd = sdd,
      loa_lower = md - 1.96 * sdd,
      loa_upper = md + 1.96 * sdd
    )
  }

  make_mat <- function() {
    matrix(NA_real_, length(sessions_list), length(sessions_list),
           dimnames = list(nm, nm))
  }

  out <- list(
    md        = make_mat(),
    sdd       = make_mat(),
    loa_lower = make_mat(),
    loa_upper = make_mat()
  )

  for (i in seq_along(sessions_list)) {
    for (j in seq_along(sessions_list)) {
      if (i == j) next
      st <- pair_stats(sessions_list[[i]], sessions_list[[j]], variable)
      out$md[i, j]        <- st[["md"]]
      out$sdd[i, j]       <- st[["sdd"]]
      out$loa_lower[i, j] <- st[["loa_lower"]]
      out$loa_upper[i, j] <- st[["loa_upper"]]
    }
  }

  out$md        <- round(out$md, digits)
  out$sdd       <- round(out$sdd, digits)
  out$loa_lower <- round(out$loa_lower, digits)
  out$loa_upper <- round(out$loa_upper, digits)

  out
}
