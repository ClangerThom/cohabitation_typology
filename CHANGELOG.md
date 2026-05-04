# Changelog

## 2026-05-04 — Rounded percentages now sum to 100

Replaced independent `round(. * 100)` calls in figures and tables with a
shared `round_to_100()` helper applied within each grouping that should sum
to 100. Previously, rounding each proportion independently could leave the
displayed labels summing to 99 or 101.

### `round_to_100()` helper (analysis.qmd setup)

Largest-remainder (Hamilton's) method: floor every scaled value, then
distribute the leftover percentage points to the entries with the largest
fractional remainders. Always renormalises input first, so the result sums
to 100 regardless of whether the input proportions sum to 1. Returns
integer percentages.

### Where it's applied

- `figure4_pct` (visualisation.qmd) — `prop` rounded per `survey` (six typ
  values); `prob_big` rounded per `survey` over the distinct big_types
  (three values).
- `figure5_pct` — `prop` rounded per `survey × age4`.
- `figure6_pct` — `prop` rounded per `survey × edu3`.
- `table3proper` — rounded per `variable × sample × survey`. Age stat rows
  (Mean age / Age SD) bypass `round_to_100` and use a simple `round()`.
- `table4` — rounded per `survey` within each `sample` block.
- `table5` — rounded per `survey` within each variable block (int3, econ,
  att).

### Choices made (revisitable)

- **Round at display time, not at creation time.** `analysis.qmd` still
  produces raw proportions; `round_to_100()` is only applied in
  `visualisation.qmd` and `tables.qmd`. Keeps `analysis` auditable for any
  future consumer that wants raw values, and lets tables and figures use
  different denominators without re-deriving anything.
- **typ-level (Fig 4) and big_type-level (Fig 4a) rounded independently.**
  Each chart's labels sum to exactly 100 within a survey-year, but the
  rolled-up totals between the two panels may differ by ±1pp. The
  alternative — deriving big_type totals as sums of rounded typ values —
  was rejected because Fig 4 and Fig 4a are read separately, so internal
  consistency within each chart matters more.
- **Tie-breaking on equal remainders falls back to input order.**
  Deterministic but not principled. If a small category should be
  protected from being starved of points (e.g. by the order it appears in
  the data), change the helper to break ties by raw count.
- **Table 5 econ row now sums to 100 across valid responses.** Previously
  "Have trouble" and "Don't have trouble" summed to ~95% because the NA
  share sat implicitly in the denominator. Now NAs are dropped first and
  the remaining two values are renormalised. **Substantive change:** the
  numbers represent the distribution among cohabitors with a valid econ
  response, not among all cohabitors. int3 and att have no NAs in
  `analysis_sample` by construction, so they're unaffected.
- **Table 3 "unknown" education share dropped its 0.X-decimal fallback
  display.** Previously, tiny "unknown" shares that rounded to 0% were
  shown with one decimal so they didn't visually disappear. Now all four
  edu categories (low/mid/high/unknown) are rounded to integers as a group
  and sum to 100; if "unknown" rounds to 0 it displays as `.` (same as any
  other 0 cell). To restore the 0.X display, the helper would need to be
  applied only to (low, mid, high) and unknown handled separately — at the
  cost of the four edu values no longer summing to 100.

### Inherited bug fixes (unrelated to rounding, but blocking rendering)

Both regressions came from the 2026-04-20 cleanup commit and were caught
when re-running the pipeline end-to-end.

- **`analysis.qmd`** — `respid` cast to character before `add_rows()`.
  Round 1's `arid` is numeric while round 2/pilot's `respid` is character,
  so `bind_rows()` refused to combine them. respid is only ever an
  identifier, so coercion is safe.
- **`visualisation.qmd`** — six instances of `data = . |> ...` (inside
  `geom_segment` / `geom_text`) rewritten to `data = \(d) d |> ...`. The
  `.` placeholder relies on magrittr `%>%` semantics; under native `|>`
  the dot is just a free variable and ggplot raised "object '.' not
  found".

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
