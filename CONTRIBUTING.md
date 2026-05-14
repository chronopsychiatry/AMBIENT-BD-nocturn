# How to contribute to nocturn

## Reporting bugs

If you find a bug in nocturn, please [open an issue](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/issues). Try to provide as many details as possible to help us diagnose and fix the issue. Useful information could be:

- A clear description of the bug, and if possible, steps to reproduce it
- Any error messages associated
- nocturn version (if using the shiny app, version is displayed at the bottom of the main panel)
- The type of data you are using (Somnofy, GGIR, sleep diary...)
  - If you are able to share one, an example data file or snippet (first few lines of a table) is very helpful
- If the bug is in the shiny app or a figure, a screenshot can really help us understand the issue

## Making suggestions

If you have ideas for new features for nocturn, feel free to submit them in the [discussion section](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/discussions).

nocturn is an open-source project, so if you are able to do so, consider making the changes yourself! See below for code contribution guidelines.

## Contributing code

Code contributions to both the shiny app and package are welcome via pull requests (PR).

A few general things to consider when making changes to the package:

- If you make changes to the shiny app, please ensure there is a relatively straightforward way to perform the same actions using package functions
  - Conversely, if you add new functions to the package, consider if their functionalities could also be provided in the shiny app
- Make sure to update or add unit tests as needed to reflect your changes
- Make sure all tests pass before submitting a PR

### Repository structure

- Core functions are found under `/R`
- Code for the shiny app is found under `/inst/shiny`, and is organised into modules
  `server.R` and `ui.R` are the main server and UI definitions, which call the different modules defined under `/inst/shiny/modules`
- Pre-set column names for different data formats can be added by editing the `.sessions_col_presets` and `.epochs_col_presets` variables in `R/colnames_key.R` (add your column names to the corresponding arrays)
- Tests are found under `/tests`, for both the core functions and the shiny app modules (although module tests are quite minimal at the moment)

### Coding conventions

- We try to adhere to the [tidyverse style guide](https://style.tidyverse.org/) as much as possible
- When creating functions, make sure to add roxygen2 tags describing inputs and outputs
  - When updating functions, remember to also update the tags

### AI usage policy

We will reject pull requests made by AI bots, or which haven't been reviewed by a human.

Please be considerate of the maintainer's time - if you submit a pull requests that is largely AI-based, make sure it only makes the necessary changes, to avoid having to review a large volume of unnecessary code changes.
