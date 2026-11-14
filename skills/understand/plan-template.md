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
status: todo | in-progress | done | flagged
base: git SHA at the moment build started this slice (set by build)
fix_rounds: 0–2 (set by build; the cap is 2)
Acceptance criteria are numbered AC<slice>.<n>, are observable, and each becomes at least one test.
-->

### slice-1: <short name>
- **status:** todo
- **base:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC1.1 <Given … when … then …>
  - AC1.2 <…>
- **Notes:** <constraints, files likely touched, edge cases settled during grilling>

### slice-2: <short name>
- **status:** todo
- **base:**
- **fix_rounds:** 0
- **Acceptance criteria:**
  - AC2.1 <…>
- **Notes:**

## Log
<!-- One line per event, appended by the skills: approvals, slice starts/finishes, flags, final review. -->
