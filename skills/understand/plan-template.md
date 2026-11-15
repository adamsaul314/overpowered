# Plan: <Feature name>

- **slug:** <feature-slug>
- **approval:** awaiting-approval   <!-- awaiting-approval | approved. Only the user's explicit OK sets "approved". -->
- **feature_base:** <git SHA of HEAD when the plan was approved>
- **branch:** <branch name, recommended: feature/<feature-slug>>

## Goals
- <What this feature must achieve, as observable outcomes.>

## Non-goals
- <What this feature deliberately does NOT do. Reviewers flag work that strays into these.>

## Checks
<!-- build fills this in from the project on its first run, and asks if something is missing. "none" means the user confirmed there isn't one. -->
- **test:** <command>
- **lint:** <command>
- **typecheck:** <command>
- **format:** <command that rewrites files>   **format-check:** <command that only checks>

## Slices
<!--
Ordered vertical slices. Each one delivers a thin end-to-end piece of behavior that can be tested on its own.
status: todo | in-progress | needs-decision | done | flagged
  needs-decision = build stopped because the slice went over budget or touched a file outside files:. Split the slice, or raise the budget / widen files: and give a budget_reason.
base: git SHA at the moment build started this slice (set by build)
files: glob patterns the slice may touch. Any other file stops the build.
budget: the maximum diff size for this slice. Lines are added + deleted. Test files are counted separately.
fix_rounds: 0–2 (set by build; the cap is 2)
Acceptance criteria are numbered AC<slice>.<n>, are observable, and each becomes at least one test.
-->

### slice-1: <short name>
- **status:** todo
- **base:**
- **files:** <e.g. src/report/csv.*, tests/test_csv.*>
- **budget:** code: 200 lines, 6 files; tests: 150 lines
- **budget_reason:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC1.1 <Given … when … then …>
  - AC1.2 <…>
- **Notes:** <constraints and edge cases settled during grilling>

### slice-2: <short name>
- **status:** todo
- **base:**
- **files:** <…>
- **budget:** code: 200 lines, 6 files; tests: 150 lines
- **budget_reason:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC2.1 <…>
- **Notes:**

## Log
<!-- One line per event, appended by the skills: approvals, slice starts/finishes, decisions, flags, final review. -->
