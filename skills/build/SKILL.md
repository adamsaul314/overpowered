---
name: build
description: Build one slice of an approved overpowered plan with test-first subagents, a gate for checks, budget and scope, a read-only review, and at most 2 fix rounds.
disable-model-invocation: true
argument-hint: <feature-slug> <slice-id, e.g. slice-1>
---

# build: one slice per run

Input: `<slug> <slice-id>`. You are the orchestrator. Subagents do the heavy work. Keep your own context small: read only `docs/features/<slug>/plan.md` (this slice and the Checks section) and the subagents' reports.

**Never commit.** The user commits between slices. Only you edit plan.md, and only the fields named here.

## 1. Preflight (on any failure, stop and tell the user why)
1. The plan has `approval: approved`. If it doesn't: "Plan not approved. Run /overpowered:understand or approve the plan first."
2. Check the slice status:
   - `todo`: a new slice. Go on to the next checks.
   - `in-progress` or `needs-decision`: resume. Run checks 3–4, set `status: in-progress`, log `<date> <slice-id> resumed`, keep the recorded `base` and any uncommitted work, then do **2. Checks** and skip to **4. Gate**.
   - `done`: stop. The slice is already built.
   - `flagged`: stop. Tell the user to decide. They can reset the slice to `in-progress` with `fix_rounds: 0` to keep the work, or discard the work and reset it to `todo`.
3. Every earlier slice is `done`.
4. `standards.md` exists in the project root. If it doesn't, tell the user to run /overpowered:understand, which creates it.
5. Only for a `todo` slice, the tree must be clean:
   ```
   git status --porcelain -- . ":(exclude)docs/features" ":(exclude)standards.md"
   ```
   If that prints anything, stop with: "Uncommitted changes outside docs/features and standards.md. Commit or stash them, then run build again."
6. Only for a `todo` slice: set `status: in-progress`, `base: <git rev-parse HEAD>` and `fix_rounds: 0`, then append the log line `<date> <slice-id> started at <short sha>`.

## 2. Checks
Use the plan's **Checks** section. If it's empty or holds placeholders, discover the checks and use the first real source. The project's own scripts come first:
- `CLAUDE.md`, `AGENTS.md` or the `README` naming the commands
- `package.json` scripts (`test`, `lint`, `typecheck`, `format`). Pick the runner from the lockfile: pnpm, yarn, bun or npm.
- `pyproject.toml` / `uv.lock`: `uv run pytest`, `uv run ruff check .`, `uv run mypy .`, `uv run ruff format .`
- `Makefile` / `justfile` targets
- `Cargo.toml`: `cargo test`, `cargo clippy -- -D warnings`, `cargo fmt`
- `go.mod`: `go test ./...`, `go vet ./...`, `go build ./...`, `gofmt -w .`
- `*.csproj` / `*.sln`: `dotnet test`, `dotnet format --verify-no-changes`, `dotnet build -warnaserror`

Write what you find into Checks. For anything missing, **ask the user once**. They can answer "none". Don't invent or install tooling.

## 3. Builder subagent
Use the Agent tool with `subagent_type: "general-purpose"` and the session model. Prompt:
```
You are building one slice of a planned feature, test-first.
Read first: <absolute path to this skill's folder>/tdd.md (TDD rules) and <absolute path>/standards.md (clean-code rules).
Slice (from the plan):
<slice section, from its heading through Notes>
Allowed files (globs): <files:>
Checks: test=<cmd> lint=<cmd> typecheck=<cmd> format=<cmd>   ("none" = skip)
Rules:
- One failing test per acceptance criterion, with the AC ID in the test name. Run each one and confirm it fails for the right reason before writing code.
- Write the minimal code that passes. Then do a refactor pass against every rule in standards.md (S1-S17). Keep the tests green.
- Touch only files matching the allowed globs. If you need any other file, don't edit it. Stop and report `SCOPE: <path> <why>`.
- Add what the ACs need. Don't change existing functions, signatures or behavior unless an AC requires it, and respect the plan's Non-goals.
- Don't commit. Don't edit anything under docs/features/.
- Run every check at the end. If a check fails for a reason no code change in the allowed files can fix (for example, the check command itself is broken), say so in the report as `BLOCKED: <check> <cause>`.
Report (20 lines or fewer): for each AC, the test name with its red failure line and green result; the fresh output tail of each check command you ran (a bare "passed" isn't evidence); and the files changed.
```
The path to this skill's folder is `${CLAUDE_SKILL_DIR}`. If that isn't expanded, use the directory this SKILL.md was loaded from.

## 4. Gate (you run this in the main session; don't trust any report)
**a. Measure.**
```
git diff --numstat <base> -- . ":(exclude)docs/features" ":(exclude)standards.md"
git ls-files --others --exclude-standard -- . ":(exclude)docs/features" ":(exclude)standards.md"
```
Count each untracked file with `git diff --no-index --numstat /dev/null <file>` (exit code 1 is normal here). Lines = added + deleted. A file is a **test** file if its path matches `test_*`, `*_test.*`, `*.test.*`, `*.spec.*`, `tests/` or `__tests__/`. Everything else is **code**. Total the code lines, the code files and the test lines.

**b. Scope and budget come first.** Check these:
- the code lines, code files or test lines exceed the slice's `budget:`
- a changed or new file doesn't match `files:`
- the builder or fixer reported `SCOPE:` (it needs to edit a file outside `files:`)

`BLOCKED:` is not a scope problem. It's handled at the end of **c**.

If any of them is true, set `status: needs-decision`, append `<date> <slice-id> needs-decision: <what> (code <n>/<budget> lines, <n>/<budget> files, tests <n>/<budget> lines)`, and stop with:
> ⏸ **<slice-id> needs a decision:** <what was exceeded, or which file is out of scope, and why>. Either split the slice in the plan, or raise `budget:` / widen `files:` and write a `budget_reason:`. Then run `/overpowered:build <slug> <slice-id>` again. It keeps the current work and resumes here.

This is never a fix round.

**c. Checks.** Run them in order: format (write mode), lint, typecheck, then the full test suite. If any fails, go to **6. Fixer** with the failing command and its output tail. The exception: if the builder or the last fixer reported `BLOCKED:` for this check and it still fails the same way, go straight to **7. Flag** with that cause. More fix rounds can't help.

## 5. Reviewer subagent
Write the diff to a temp file **outside the repo**, named `overpowered-<slug>-<slice-id>.diff`:
- On Windows, use a Windows path under `$env:TEMP`. From Git Bash, use `"$(cygpath -w "$TEMP")\overpowered-<slug>-<slice-id>.diff"`. A POSIX path like the Git Bash temp folder can't be read by the Read tool.
- On macOS or Linux, use `mktemp`, which honours `$TMPDIR`.
```
git diff <base> --no-color --output=<tmpfile> -- . ":(exclude)docs/features" ":(exclude)standards.md"
```
Then use the Agent tool with `subagent_type: "overpowered:reviewer"`:
```
Mode: slice
Standards file: <absolute path>
Diff file: <absolute tmpfile path>
New files: <absolute paths of the untracked files, or "none">
Plan (this slice only):
<slice section>
Review per your instructions and return the report in your output format.
```
If that agent isn't available, stop and tell the user to check that the overpowered plugin is enabled. Never fall back to an agent with write tools.

The reviewer is read-only, so **you** write `docs/features/<slug>/review-<slice-id>.md`. Add the newest round first, keep the earlier rounds below it, and copy the report verbatim:
```
# Review: <slug> / <slice-id>
**Latest verdict: <PASS|CHANGES REQUESTED> (round <fix_rounds>)**

## Round <fix_rounds> (<date>, base <short sha>)
<reviewer report verbatim>
```
Delete the temp file. If the verdict is PASS, go to **8. Done**. Otherwise, go to **6. Fixer** with the blocking findings. Nits never trigger a fix.

## 6. Fixer subagent (cap: 2 fix rounds in total)
If `fix_rounds` is already 2, go to **7. Flag**. Otherwise, increment `fix_rounds` in plan.md and use the Agent tool with `subagent_type: "general-purpose"` and `model: "sonnet"` (leave the model out if it isn't accepted):
```
You are fixing one slice of a planned feature. Read <absolute path>/standards.md and <skill folder>/tdd.md first.
Problems to fix (only these):
<the failing check command and its output tail, or the blocking findings verbatim>
Previous round's cause (if any): <cause from the last fixer report, or "none">
Allowed files (globs): <files:>   Checks: <same as builder>
Rules:
- First, state the root cause in 1-2 sentences, from the evidence. Read the failing output and the code. Don't guess.
- If the same check failed last round with the same cause, don't try again. Report `REPEAT: <cause>` and stop.
- If no change inside the allowed files can fix it (for example, the check command itself is broken or contradicts an AC), change nothing. Report `BLOCKED: <check> <cause>` and stop.
- If the fix needs an edit to a file outside the allowed files, report `SCOPE: <path> <why>` and stop.
- If a finding is an unmet acceptance criterion, add or fix the test first, and watch it fail.
- Don't change existing behavior beyond what the fix needs. Don't commit. Don't edit docs/features/.
Report (15 lines or fewer): the cause, what you changed, and the fresh output tail of each check.
```
If the fixer reports `REPEAT:` or `BLOCKED:`, go to **7. Flag** with that cause. If it reports `SCOPE:`, go to **4. Gate**, where step b stops the slice as `needs-decision`. Otherwise, go back to **4. Gate**.

## 7. Flag
Set `status: flagged`, append `<date> <slice-id> flagged after <fix_rounds> fix rounds: <cause, e.g. BLOCKED/REPEAT reason or "cap reached">`, and end with:
> ⚠️ **<slice-id> flagged.** It's still failing after <n> fix rounds. Remaining: <failing checks or blocking findings, with the cause if known>. See `docs/features/<slug>/review-<slice-id>.md`. Your call: fix it by hand or edit the plan, then set the status to `in-progress` with `fix_rounds: 0` (keep the work), or discard the work and set it to `todo`.

## 8. Done
Set `status: done`, append `<date> <slice-id> done (fix_rounds=<n>, code lines=<n>, test lines=<n>)`, report the tests by AC and any leftover nits in 5 lines or fewer, then end with:
> ✅ <slice-id> done. Review: docs/features/<slug>/review-<slice-id>.md. Commit it, then run build <slug> <next-slice>. If that was the last slice, commit and run final-review <slug>.
