# Changelog

## 2026-04-20 — Script cleanup

Full cleanup of all three scripts and resolution of a remote divergence. The
remote (`old-main`) had moved ahead with new features; these were incorporated
and the whole codebase was tidied at the same time.

### analysis.qmd
- Removed to-do list and "Inconsistencies?" prose sections
- Updated chunk option syntax (`{r message=FALSE}` → `#| message: false`)
- Deduplicated `round2tidy` / `pilot2tidy` into a shared helper function
  `tidy_r2_format(df, edu_codes)` — the only difference between the two is
  education variable codes (1–8 in round 2, 2801–2808 in the pilot)
- Replaced verbose `case_when` recodes for `dem07`, `dem25`, `dem06` with `case_match`
- Added `respid = arid` to `round1tidy` rename block (was inconsistent with round 2/pilot)
- Simplified `survey` `case_when` → `if_else`
- Merged duplicate Conformist rows in `typ` to `att %in% c(1, 3)`
- Fixed `TRUE ~ NA` → `TRUE ~ NA_character_` in `typ` and `big_type`
- **Bug fix:** `arrange(survey, typ, age3)` in figure5 → `age4`
- Improved `analysis_sample` filter to `edu3 %in% c("low", "mid", "high")`

### visualisation.qmd
- Replaced CSV-based import with `figure4proper` / `figure5proper` / `figure6proper`
  transformation pipeline pulling directly from `analysis.qmd` outputs, connecting
  the two scripts
- Updated all plot data references to the `*proper` objects
- **Bug fix:** `figure5$year` in `figure_6` `geom_text_repel` → `figure6proper$year`
- Updated chunk option syntax, replaced `%>%` with `|>`, removed knitr setup chunk
- Removed "Failed ideas" section
- Trimmed noisy comments, renamed "Trying to paste..." heading to "Combined plot"

### tables.qmd (new)
- Brought in from `old-main`; cleaned up with `|>`, modern chunk options,
  `case_match` substitutions, spaces removed from chunk names, `make_header_row`
  helper extracted to reduce repetition

### README.md
- Removed outdated note about the scripts not being connected

### Git
- Previous `main` preserved permanently as `old-main`
- Cleaned local version force-pushed as new `main`
