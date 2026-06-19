# run_all.R — master reproduction script for the cohabitation typology package.
#
# Runs the full pipeline in ONE shared R session, in order:
#
#   analysis.qmd  ->  figures.qmd  ->  tables.qmd
#
# This single-session design is REQUIRED: figures.qmd and
# tables.qmd consume objects created in analysis.qmd (the round_to_100()
# helper and the data frames `analysis`, `analysis_sample`, `figure4`,
# `figure5`, `figure6`). They are never written to / read from disk, so the
# scripts cannot be rendered independently — Quarto runs each .qmd in its own
# fresh R session and the downstream files would error on missing objects.
# This script extracts the R code from each .qmd with knitr::purl() and
# source()s it into the global environment so upstream objects stay visible.
#
# Run from the package root:   Rscript run_all.R
#
# Inputs  (not distributed — see README, gated behind ggp-i.org):
#   data/ggp/round1.dta, data/ggp/round2.dta, data/ggp/pilot.dta
#
# Outputs:
#   plots/Figure_1.png, Figure_2.png, Figure_3.png, Figure_4.png  (Figures 1–4)
#   tables/Table_2.docx, Table_A1.docx, Table_A2.docx, Table_A3.docx
#                                                  (Table 2 + Tables A1–A3)

if (!requireNamespace("knitr", quietly = TRUE)) {
  stop("The 'knitr' package is required to run this pipeline. Install it with install.packages('knitr').")
}

scripts <- c("analysis.qmd", "figures.qmd", "tables.qmd")

# Output directories (the .qmd files also create plots/, but make the master
# script self-sufficient).
dir.create("plots", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

run_qmd <- function(qmd) {
  message("=== Running ", qmd, " ===")
  r_file <- tempfile(fileext = ".R")
  knitr::purl(qmd, output = r_file, quiet = TRUE)
  # local = FALSE evaluates in the global environment, so objects defined in
  # one .qmd persist for the next one in `scripts`.
  source(r_file, local = FALSE, echo = FALSE)
}

invisible(lapply(scripts, run_qmd))

message("=== Pipeline complete: figures in plots/, tables in tables/ ===")
