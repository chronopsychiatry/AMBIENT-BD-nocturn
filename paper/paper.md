---
title: 'nocturn: an online tool and R package for sleep data visualisation'
tags:
  - R
  - circadian research
  - sleep
  - somnofy
authors:
  - name: Daniel Thedie
    orcid: 0000-0002-1352-7245
    affiliation: 1
  - name: Andrew J. Millar
    orcid: 0000-0003-1756-3654
    corresponding: true
    affiliation: 1
  - name: Daniel Smith
    orcid: 0000-0002-2267-1951
    affiliation: 2
affiliations:
 - name: The University of Edinburgh School of Biological Sciences, Edinburgh, Scotland, UK
   index: 1
 - name: The University of Edinburgh Division of Psychiatry, Edinburgh, Scotland, UK
   index: 2
date: 19 September 2025
bibliography: paper.bib
---

# Summary


# Statement of need

Radar technology has recently emerged as a useful tool for longitudinal sleep monitoring for wellbeing and research. It has been used in the Ambient-BD study [@Manrai2025], where Somnofy devices (VitalThings) were used to monitor the sleep of 180 participants over 18 months. Somnofy is a promising tool for research applications, as it allows long-term, non-intrusive sleep monitoring, with minimal maintenance. This can be harnessed to pick up long-term trends in sleep and circadian rhythm, and monitor related health outcomes. However, due to the novelty of this technology, few specialised tools are currently available for the analysis of radar-derived sleep data, as is produced by Somnofy. nocturn was developed as part of the Ambient-BD study to enable researchers to:

- Explore Somnofy sleep data, regardless of their familiarity with programming languages
- Apply thresholds on key variables (such as time spent in bed) to remove spurious sleep sessions, for example caused by pets lying on the bed
- Generate attractive visualisations that can be used in research outputs during and after the project
- Produce accessible sleep summaries to be shared with study participants
- Create automated workflows to quickly produce the outputs listed above for a large number of participants

To achieve these aims, nocturn was developped as an R package and an R shiny app, which can be accessed directly online, or run locally.

# Main functionalities

## Interface

nocturn can be used through a graphical interface (running online or locally), or as an R package.

The nocturn graphical interface is conceived as a dashboard, where the different information and menus are easily reachable. It contains five main areas:

- Data input
- Data filtering
- Data export
- Tables
- Figures

The application is reactive, allowing for direct feedback on the effect of data filters.

Conversely, using nocturn as an R package allows designing custom data processing workflows:

- The session and epoch data are stored as DataFrames, which allows easy integration of `dplyr` or custom functions in the processing
- Plotting functions all return `ggplot2` objects, allowing for further editing of figures
- All functionalities available via the graphical interface can easily be reproduced in code

This makes it straightforward to integrate nocturn functions into existing data analysis pipelines.

## Input data

### Somnofy

During the Ambient-BD project, the raw radar data produced by Somnofy devices was processed internally by VitalThings to extract information such as sleep onset and wakeup time, as well as classifying sleep stages (awake, light sleep, REM, deep sleep). The processed data was then made available to the researchers via an API, in the form of two separate .csv files:

- Sessions file: one row per sleep session, with data including time at sleep onset, time at wakeup, time spent in bed, and aggregate values such as the average temperature during the session
- Epochs file: timestamped sleep data with 30-second resolution, including classification of sleep stages. A session ID is indicated for each timepoint, so epoch data can be linked with session data

### Data from other devices

Although nocturn was primarily designed to work with Somnofy data, it can also accept data from other devices, in .csv format. This requires the data to have a similar structure, i.e. one file containing "sleep sessions" (with measurements such as sleep onset and wakeup times), and (optionally) one file containing timestamped "epoch data" (at any time resolution). Once loaded in nocturn, use the "Set Session Columns" and "Set Epoch Columns" menus (in the Data Input section) to select the right column names for your data files. Column names can be left blank if they are not available in the data, though that might prevent certain visualisations from being displayed. If you plan to work with a certain data format on a regular basis, please open an issue on github so it can be added to nocturn's automatically recognised formats.

nocturn does not accept raw actigraphy data. However, it accepts outputs from the [GGIR package](https://wadpac.github.io/GGIR/index.html) (cite). To do so, the option `save_ms5rawlevels` of the GGIR pipeline must be set to `TRUE`. The output can be found in `meta/ms5.outraw`. After running the pipeline, the following files can be loaded into nocturn:
- The "day summary" results (output from part 5) as Somnofy Sessions
- The "raw output" time-series (ms5.outraw) as Somnofy Epochs

## Data compliance and filtering

A common issue with sleep data collected by Somnofy devices, is the presence of "spurious sleep sessions". These are typically short sessions (a few minutes to hours), and can be due to:

- House pets lying on the bed
- The participant lying still in bed (e.g. reading or watching TV)
- Movement in the room, such as curtains blowing in the wind
- The participant taking a nap during the day, which might not be of interest in the context of a particular study

Given the scale of the data collected (in the case of the Ambient-BD study, 18 months of daily data collection for 180 participants), manual curation of the sleep sessions would be too time-consuming. Hence, nocturn reports days where multiple sleep sessions have been detected, and provides the following filters:

- Removal of sessions where no sleep occurred (enabled by default in the app)
- Removal of sessions where the participant spent less than X hours in bed (in our experience, 2 hours is a good threshold to remove short sessions)
- Removal of sessions where sleep onset occurred outside of a defined range (e.g. 17:00 to 18:00)

## Annotations

In the nocturn app, the annotation tab allows manually adding tags to sleep sessions. Tags can then be used to set the colormap on the different figures. This can be useful to:

- Highlight specific sessions of interest in figures
- Include information from other sources, for example health questionnaires completed by participants

# Examples of use



# Acknowledgements

The authors would like to thank all members of the "Chronopsychiatry group" (division of Psychiatry, University of Edinburgh) for their feedback during the development of nocturn.

# Funding

The development of nocturn was funded by the XXX grant awarded to Prof. Daniel Smith (and others?).

# References
