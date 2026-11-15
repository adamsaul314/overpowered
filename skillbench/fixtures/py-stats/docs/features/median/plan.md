# Plan: Median

- **slug:** median
- **approval:** approved
- **feature_base:**
- **branch:** master

## Goals
- Callers can get the median of a list of numbers from `stats.core.median`.

## Non-goals
- No other statistics, no changes to `mean`, no package-level export.

## Checks
- **test:** python -m unittest discover -s tests -q
- **lint:** none
- **typecheck:** none
- **format:** none   **format-check:** none

## Slices

### slice-1: median of a list
- **status:** todo
- **base:**
- **files:** stats/core.py, tests/test_core.py
- **budget:** code: 200 lines, 6 files; tests: 150 lines
- **budget_reason:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC1.1 Given `[3, 1, 2]`, `median` returns `2`.
  - AC1.2 Given `[4, 1, 3, 2]`, `median` returns `2.5`.
  - AC1.3 Given `[]`, `median` raises `ValueError` whose message says the input was empty.
- **Notes:** Add `median(values)` to `stats/core.py`. Put the tests in `tests/test_core.py`. Don't mutate the caller's list.

## Log
- 2026-11-15 plan written, awaiting approval
- 2026-11-15 approved (fixture)
