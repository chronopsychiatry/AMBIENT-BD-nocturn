# nocturn

<img src="./inst/shiny/www/logo.png" width="200" height="200">

nocturn provides tools to filter and visualise sleep data.

## Getting started

The easiest way to use nocturn is to visit the [online app](ambientviewer.bio.ed.ac.uk). Visit the [wiki](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/wiki) for more detailed instructions!

## Can I use nocturn with my data?

nocturn was initially developped to process data from Somnofy devices. However, other data types are supported, such as outputs from the GGIR package (for actigraphy), or .edf files converted with `edfs_to_csv`.

If your data is not listed here, feel free to [open an issue](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/issues) (preferably with a sample dataset) for it to be supported by nocturn.

## Running nocturn locally

If you wish to run the app locally, or to use the R package, please follow the [installation instructions](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/wiki/Installation) and [how to get started](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/wiki/Getting-started).

Descriptions of functions from the nocturn R package can be found in the [PDF manual](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/tree/main/Package_manuals). Select the package version that corresponds to the one you have installed. If you are unsure, you can check your current version of nocturn by running `packageVersion("nocturn")` in R.

The [changelog](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/blob/main/CHANGELOG.md) contains information about changes made in each version. Generally, it is preferable to run the latest version of the package, as each version will contain bug fixes and improvements. You can update your installed version by running `devtools::install_github("Chronopsychiatry/AMBIENT-BD-nocturn", force = TRUE)` in R.

## Bugs and suggestions

To report a bug or request a new feature, [open a new issue](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/issues).

To make suggestions, request new features or discuss how to use the app or package, [start a new discussion](https://github.com/chronopsychiatry/AMBIENT-BD-nocturn/discussions).

## Contact

Maintainer: [daniel.thedie@ed.ac.uk](mailto:daniel.thedie@ed.ac.uk)

nocturn is developed by the [BioRDM team](https://biology.ed.ac.uk/research/facilities/research-data-management) at the University of Edinburgh, as part of the [Ambient-BD project](https://www.ambientbd.com/).
