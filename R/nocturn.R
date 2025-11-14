#' nocturn app
#'
#' This function launches the nocturn app, a Shiny application for visualizing and analyzing sleep data.
#' @import shiny
#' @export
nocturn <- function() {
  app_path <- system.file("shiny", package = "nocturn")
  shiny::runApp(app_path)
}
