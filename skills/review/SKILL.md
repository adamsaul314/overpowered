---
name: review
description: Review one slice of an overpowered-workflow plan by sending a read-only reviewer subagent the slice's plan section, the standards file, and the slice diff. Writes docs/features/<slug>/review-<slice>.md. Called by the build skill; never edits code.
argument-hint: <feature-slug> <slice-id> [round=N]
---

# review: fresh-eyes check of one slice

Workflow home: `${CLAUDE_PLUGIN_ROOT}` (WF below; the plugin root).
Input: `<slug> <slice-id> [round=N]` (round defaults to 0).
Output: `docs/features/<slug>/review-<slice-id>.md` with this round appended. The first line of the file always shows the latest verdict.

**This skill never edits code, tests, or the plan.** The only file it writes is the review file.

## Steps
1. **Gather small inputs.**
   - From `docs/features/<slug>/plan.md`, extract **only** this slice's section (heading through Notes) and the `base` SHA. Don't pass goals, other slices or the log.
   - Standards: `./standards.md` if the project has one, otherwise `WF/standards.md`. Pass its path.
   - Diff: run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/diff-since.sh" <base> <tmpfile>` with `<tmpfile>` = `$(mktemp --suffix=.diff)`. This includes uncommitted and untracked files. If the diff is empty, write a review saying so with verdict CHANGES REQUESTED, then stop.
2. **Spawn the reviewer.** Use the Agent tool with `subagent_type: "overpowered:reviewer"` (read-only: Read, Grep, Glob). Prompt:
   ```
   Mode: slice
   Standards file: <absolute path>
   Diff file: <absolute tmpfile path>
   Plan (this slice only):
   <slice section text>
   Review per your instructions and return the report in your output format.
   ```
   If the `overpowered:reviewer` agent type isn't available, stop and tell the user to check that the overpowered plugin is enabled (it provides `agents/reviewer.md`). **Don't** fall back to an agent that has write tools.
3. **Write the review file.** Write or update `docs/features/<slug>/review-<slice-id>.md`:
   ```
   # Review: <slug> / <slice-id>
   **Latest verdict: <PASS|CHANGES REQUESTED> (round <N>)**

   ## Round <N> (<date>, base <short sha>)
   <reviewer report verbatim>

   ## Round <N-1> …   (earlier rounds kept below, newest first)
   ```
   Add the report exactly as returned, without softening it or dropping findings.
4. **Return** the verdict and the blocking findings to the caller (build) in 1–5 lines.
