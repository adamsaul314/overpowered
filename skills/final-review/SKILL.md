---
name: final-review
description: Final review of a whole overpowered-workflow feature once every slice is done. Reviews the full feature diff for problems that only appear when slices combine, then runs the built-in code-review (and security-review when relevant). Writes docs/features/<slug>/final-review.md. Never edits code.
disable-model-invocation: true
argument-hint: <feature-slug>
---

# final-review: the whole feature, combined

Workflow home: `${CLAUDE_PLUGIN_ROOT}` (WF below; the plugin root).
Input: `<slug>`. Output: `docs/features/<slug>/final-review.md`. **No code edits.** Fixes go back through `/overpowered:build` or are done by the user.

## Steps
1. **Preflight.** Read `docs/features/<slug>/plan.md`. Every slice must be `done`. If any slice is `flagged` or `todo`, stop and list them. `feature_base` must be set. Recommend a clean tree (everything committed) but don't require one.
2. **Diff.** Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/diff-since.sh" <feature_base> <tmpfile>` with `<tmpfile>` = `$(mktemp --suffix=.diff)`.
3. **Integration review.** Use the Agent tool with `subagent_type: "overpowered:reviewer"`:
   ```
   Mode: final
   Standards file: <./standards.md if present, else WF/standards.md>
   Diff file: <tmpfile>
   Plan (whole feature: goals, non-goals, all slices' acceptance criteria; omit the Log):
   <text>
   Review per your instructions for mode final and return the report.
   ```
4. **Built-in checks** (don't rebuild them):
   - Invoke the `code-review` skill at level `medium` for correctness bugs. Target the feature's changes: if on a feature branch, pass the branch name; otherwise pass the changed paths from the diff.
   - If the diff touches input parsing, auth, file system or shell access, network or secrets, also invoke `security-review`.
   - Copy their findings into the report. Don't apply fixes, and don't pass `--fix`.
5. **Write `docs/features/<slug>/final-review.md`:**
   ```
   # Final review: <slug>
   **Verdict: PASS | CHANGES REQUESTED**
   feature_base <sha> → HEAD <sha> (+ uncommitted: yes/no)

   ## Integration review (reviewer, mode final)
   <report verbatim>

   ## /code-review (medium)
   <findings, or "none">

   ## /security-review
   <findings, "none", or "not run: no sensitive surface">
   ```
6. Append the log line `<date> final review: <verdict>` to plan.md (the only edit to the plan). Tell the user the verdict and the top blocking items. Suggest how to fix each one: a new slice in the plan, run through `/overpowered:build`, or a manual fix. Don't start any fix yourself.
