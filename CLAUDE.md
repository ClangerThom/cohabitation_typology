# Cohabitation typology — Claude Code instructions

## Review at start of next session

Before starting any new work, surface the 2026-05-04 changes for the user
to review and discuss. After the review, this section can be removed.

- **Largest-remainder rounding fix** to figures 4/5/6 and tables 3/4/5
  (see `CHANGELOG.md` 2026-05-04). The choices made — independent rounding
  per panel for Fig 4 vs Fig 4a, tie-breaking by input order, Table 5 econ
  row now sums to 100 across valid responses (NAs dropped first), Table 3
  "unknown" education share lost its 0.X-decimal display — are flagged
  revisitable.
- **Two unrelated bugs patched in the same commit** (inherited from the
  prior `old-main` cleanup, both were blocking end-to-end rendering):
  - `analysis.qmd`: `respid` cast to character before `add_rows()` —
    round 1's `arid` was numeric, round 2/pilot's `respid` was character.
  - `visualisation.qmd`: six instances of `data = . |> ...` rewritten to
    `data = \(d) d |> ...`. The native pipe doesn't bind `.` the way
    magrittr `%>%` did.
