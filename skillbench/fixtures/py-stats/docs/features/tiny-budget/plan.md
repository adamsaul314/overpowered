# Plan: Median and mode

- **slug:** tiny-budget
- **approval:** approved
- **feature_base:**
- **branch:** master

## Goals
- Callers can get the median and the mode of a list of numbers from `stats.core`.

## Non-goals
- No changes to `mean`, no package-level export.

## Checks
- **test:** python -m unittest discover -s tests -q
- **lint:** none
- **typecheck:** none
- **format:** none   **format-check:** none

## Slices

### slice-1: median and mode
- **status:** todo
- **base:**
- **files:** stats/core.py, tests/test_core.py
- **budget:** code: 5 lines, 1 files; tests: 150 lines
- **budget_reason:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC1.1 Given `[3, 1, 2]`, `median` returns `2`.
  - AC1.2 Given `[4, 1, 3, 2]`, `median` returns `2.5`.
  - AC1.3 Given `[1, 2, 2, 3]`, `mode` returns `2`.
  - AC1.4 Given `[1, 1, 2, 2]`, `mode` returns the smallest of the tied values, `1`.
  - AC1.5 Given `[]`, both `median` and `mode` raise `ValueError` whose message names the function and says the input was empty.
- **Notes:** Add `median(values)` and `mode(values)` to `stats/core.py`, each with a docstring. Put the tests in `tests/test_core.py`.

## Log
- 2026-11-15 plan written, awaiting approval
- 2026-11-15 approved (fixture)
