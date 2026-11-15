---
name: final-review
description: Review a finished overpowered feature as a whole, plus the built-in code and security reviews. Writes docs/features/<slug>/final-review.md and never edits code.
disable-model-invocation: true
argument-hint: <feature-slug>
---

# final-review: the whole feature, combined

Input: `<slug>`. Output: `docs/features/<slug>/final-review.md`. **No code edits.** Fixes go back through build or are done by the user.

## Steps
1. **Preflight.** Read `docs/features/<slug>/plan.md`. Every slice must be `done`. If any slice isn't, stop and list them. `feature_base` must be set. Recommend a clean tree (everything committed), but don't require one.
2. **Diff.** Write it to a temp file **outside the repo**, named `overpowered-<slug>-final.diff`:
   - On Windows, use a Windows path under `$env:TEMP`. From Git Bash, use `"$(cygpath -w "$TEMP")\overpowered-<slug>-final.diff"`. A POSIX path like the Git Bash temp folder can't be read by the Read tool.
   - On macOS or Linux, use `mktemp`, which honours `$TMPDIR`.
   ```
   git diff <feature_base> --no-color --output=<tmpfile> -- . ":(exclude)docs/features" ":(exclude)standards.md"
   git ls-files --others --exclude-standard -- . ":(exclude)docs/features" ":(exclude)standards.md"
   ```
3. **Size.** Measure the way build's gate does:
   - Run `git diff --numstat <feature_base>` with the same exclusions, and count each untracked file with `git diff --no-index --numstat /dev/null <file>`.
   - Lines = added + deleted. A path is a test file if it matches `test_*`, `*_test.*`, `*.test.*`, `*.spec.*`, `tests/` or `__tests__/`.
   - Sum each slice's code and test line budgets.
4. **Integration review.** Use the Agent tool with `subagent_type: "overpowered:reviewer"`:
   ```
   Mode: final
   Standards file: <absolute path to the project's standards.md>
   Diff file: <absolute tmpfile path>
   New files: <absolute paths, or "none">
   Plan (whole feature: goals, non-goals, all slices' acceptance criteria; omit the Log):
   <text>
   Review per your instructions for mode final and return the report.
   ```
5. **Built-in checks.** Use these rather than rebuilding them:
   - Invoke the `code-review` skill at level `medium` for correctness bugs. On a feature branch, pass the branch name. Otherwise, pass the changed paths.
   - If the diff touches input parsing, auth, the file system, shell, network or secrets, also invoke `security-review`.
   - **Never pass `--fix`.** Copy their findings into the report.
6. **Write `docs/features/<slug>/final-review.md`:**
   ```
   # Final review: <slug>
   **Verdict: PASS | CHANGES REQUESTED**
   feature_base <sha> → HEAD <sha> (+ uncommitted: yes/no)
   Size: code <n> / <sum of code budgets> lines, tests <n> / <sum of test budgets> lines

   ## Integration review (reviewer, mode final)
   <report verbatim>

   ## Built-in code review
   <findings, or "none">

   ## Built-in security review
   <findings, "none", or "not run: no sensitive surface">
   ```
   Delete the temp diff file.
7. Append the log line `<date> final review: <verdict>` to plan.md. This is the only edit to the plan. Tell the user the verdict and the top blocking items, with a suggested fix for each: a new slice in the plan (built with build), or a manual fix. Don't start any fix yourself.
