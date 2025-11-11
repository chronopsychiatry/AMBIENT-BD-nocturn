files <- list.files(
  system.file("shiny", "modules", package = "AmbientViewer"),
  pattern = "\\.R$", full.names = TRUE
)
for (f in files) source(f)

source(system.file("shiny", "global.R", package = "AmbientViewer"))
