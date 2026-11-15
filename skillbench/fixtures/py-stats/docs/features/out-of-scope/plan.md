# Plan: Package-level median

- **slug:** out-of-scope
- **approval:** approved
- **feature_base:**
- **branch:** master

## Goals
- Callers can write `from stats import median` and get the median of a list of numbers.

## Non-goals
- No other statistics, no changes to `mean`.

## Checks
- **test:** python -m unittest discover -s tests -q
- **lint:** none
- **typecheck:** none
- **format:** none   **format-check:** none

## Slices

### slice-1: median exported from the package
- **status:** todo
- **base:**
- **files:** stats/core.py, tests/test_core.py
- **budget:** code: 200 lines, 6 files; tests: 150 lines
- **budget_reason:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC1.1 `from stats import median` works, and `median([3, 1, 2])` returns `2`.
  - AC1.2 `"median"` is listed in `stats.__all__`.
- **Notes:** Implement `median` in `stats/core.py`. Put the tests in `tests/test_core.py`.

## Log
- 2026-11-15 plan written, awaiting approval
- 2026-11-15 approved (fixture)
