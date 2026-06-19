# Cohabitation typology — Claude Code instructions

## Handoff: reproducibility package (2026-06-19)

The next task is preparing this repo as a **replication package for
publication**, to be carried out by a CC instance equipped with a
reproducibility plugin. Read this section first.

### Outputs reproduce the published article (renumbered + post-edited)

As of the 2026-06-19 packaging work, the scripts reproduce the **final
published exhibits** (which had been manually post-edited beyond the earlier
"frozen" script output). Exhibits were renumbered — see the 2026-06-19
`CHANGELOG.md` entry and the README §5 map. Do not revisit analytical or
display choices; the following are deliberate (do not "fix" them):

- Independent largest-remainder rounding per panel for the disaggregated vs
  aggregated cohabitation-type figures (rolled-up totals may differ by ±1pp).
- `round_to_100()` tie-breaking by input order.
- Table A3 (`table5`) econ row sums to 100 across valid responses (NAs
  dropped first).
- Table A2 (`table3`) "unknown" education share is shown to **one decimal**
  when it rounds to 0% (e.g. 0.4% in 2021); low/mid/high stay integer and sum
  to 100. (This **reverses** the earlier 2026-05-04 integer-only decision,
  which described the pre-edit script and did not match the published table.)

### Canonical article pipeline (one shared R session, in order)

`analysis.qmd` → `figures.qmd` → `tables.qmd`

- **`figures.qmd` is the article's figure source** — Arial
  only, no proprietary fonts, no `extrafont`/`loadfonts`; writes to
  `plots/`.
- **`visualisation.qmd` (the Jost-font variant) was REMOVED** (2026-06-19,
  user decision) for a single font-portable path. The combined Figure 4 + 4a
  panel was also dropped (not in the article).

### Data

The user **has the GGP/GGS data locally**, so the new instance can and
should do a real end-to-end run and confirm it reproduces the article
outputs. Data is gated behind ggp-i.org and gitignored (`data/`); never
commit it. `analysis.qmd` loads `data/ggp/{round1,round2,pilot}.dta`.
Note `data/ggp/pilot_followup.dta` exists locally but is **not** loaded by
the pipeline — confirm it is intentionally unused before relying on it.

### Reproducibility fragility to address

`round_to_100()` breaks ties by input row order, which depends on the
`arrange()` calls *and* the row order delivered by `haven::read_dta()`. A
`dplyr`/`haven`/R version change that reorders rows could shift a displayed
percentage by 1pp and silently break the match to the article. This is the
strongest argument for pinning package versions (e.g. `renv.lock`) and
recording the R/`haven`/`dplyr` versions used.

### Likely scope (confirm target repo/journal requirements with user)

README with run order + expected data filenames; dependency pinning;
font/OS portability note; and a verified clean end-to-end run reproducing
the frozen outputs. No analytical edits.
