---
name: final-review
description: Final review of a whole overpowered-workflow feature once every slice is done. Reviews the full feature diff for problems that only appear when slices combine, plus the tool's built-in code and security review when available. Writes docs/features/<slug>/final-review.md. Never edits code.
disable-model-invocation: true
argument-hint: <feature-slug>
---

# final-review: the whole feature, combined

Input: `<slug>`. Output: `docs/features/<slug>/final-review.md`. **No code edits.** Fixes go back through the build skill or are done by the user.

## Steps
1. **Preflight.** Read `docs/features/<slug>/plan.md`. Every slice must be `done`. If any slice is `flagged` or `todo`, stop and list them. `feature_base` must be set. Recommend a clean tree (everything committed) but don't require one.
2. **Diff.** Use a temp file outside the repo:
   ```
   git diff <feature_base> --no-color --output=<tmpfile> -- . ":(exclude)docs/features"
   git ls-files --others --exclude-standard -- . ":(exclude)docs/features"
   ```
3. **Integration review.** Delegate to the read-only `reviewer` agent (Claude Code: Agent tool with `subagent_type: "overpowered:reviewer"`; Copilot: the `reviewer` custom agent):
   ```
   Mode: final
   Standards file: <absolute path to the project's standards.md>
   Diff file: <tmpfile>
   New files: <absolute paths, or "none">
   Plan (whole feature: goals, non-goals, all slices' acceptance criteria; omit the Log):
   <text>
   Review per your instructions for mode final and return the report.
   ```
4. **Built-in checks** (use what the tool has; don't rebuild them):
   - **Claude Code:** invoke the `code-review` skill at level `medium` for correctness bugs. If on a feature branch, pass the branch name. Otherwise pass the changed paths. If the diff touches input parsing, auth, file system or shell access, network or secrets, also invoke `security-review`. Don't pass `--fix`.
   - **Other tools:** skip this step and say so in the report.
   - Copy their findings into the report. Don't apply fixes.
5. **Write `docs/features/<slug>/final-review.md`:**
   ```
   # Final review: <slug>
   **Verdict: PASS | CHANGES REQUESTED**
   feature_base <sha> → HEAD <sha> (+ uncommitted: yes/no)

   ## Integration review (reviewer, mode final)
   <report verbatim>

   ## Built-in code review
   <findings, "none", or "not available in this tool">

   ## Built-in security review
   <findings, "none", "not run: no sensitive surface", or "not available in this tool">
   ```
   Delete the temp diff file.
6. Append the log line `<date> final review: <verdict>` to plan.md (the only edit to the plan). Tell the user the verdict and the top blocking items. Suggest how to fix each one: a new slice in the plan, run through the build skill, or a manual fix. Don't start any fix yourself.
