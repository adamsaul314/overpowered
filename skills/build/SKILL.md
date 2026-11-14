---
name: build
description: Build one slice of an approved overpowered-workflow plan. Failing tests from the slice's acceptance criteria, code to green, checks (test/lint/typecheck/format), refactor against standards, then review with a capped fix loop (2 rounds max).
disable-model-invocation: true
argument-hint: <feature-slug> <slice-id, e.g. slice-1>
---

# build: one slice, test-first, reviewed

Input: `<slug> <slice-id>`. Reads only `docs/features/<slug>/plan.md` (this slice, plus Checks) and the project's `standards.md`.
Output: code and tests for the slice, plus `review-<slice-id>.md`, with the slice status set to `done` or `flagged`.

Skill names: in Claude Code, this plugin's skills are prefixed `overpowered:` (e.g. `overpowered:review`). Elsewhere, use the bare name (`review`).

**Fresh context.** Each slice should start in a fresh context (`/clear` or a new session). Build only from plan.md and standards.md. Don't rely on earlier chat about other slices. If this conversation already contains work on another slice, tell the user to start a fresh context and re-run, then stop.

**Never commit.** The user commits. You tell them when.

## 0. Preflight (stop on any failure and tell the user why)
1. Read `docs/features/<slug>/plan.md`. Require `approval: approved`. If it's anything else, stop: "Plan not approved. Run the understand skill or approve the plan first."
2. Find the slice. Require status `todo` or `in-progress`. If it's `done`, stop. If it's `flagged`, stop and say the user must decide how to proceed (edit the plan or criteria, then reset status to `todo` and `fix_rounds` to 0).
3. Every earlier slice must be `done`. If any isn't, stop.
4. **Clean tree.** `git status --porcelain` must be empty. If it isn't, stop: "Uncommitted changes. Commit the previous slice (or stash) before starting <slice-id>." This is what keeps each slice's diff to that slice only.
5. `standards.md` must exist in the project root. If it doesn't, stop and tell the user to run the understand skill, which creates it.
6. Set the slice's `status: in-progress`, `base: <git rev-parse HEAD>`, `fix_rounds: 0`. Append a log line.

## 1. Discover checks (only if the plan's Checks section is empty or has placeholders)
Look in this order and use the first real source. Prefer the project's own scripts over raw tools.
- `CLAUDE.md` / `AGENTS.md` / `.github/copilot-instructions.md` / `README` stating the commands
- `package.json` scripts (`test`, `lint`, `typecheck`/`tsc`, `format`/`prettier`). Runner from the lockfile: pnpm/yarn/bun/npm
- `pyproject.toml` / `uv.lock`: `uv run pytest`, `uv run ruff check .`, `uv run mypy .` (or pyright), `uv run ruff format .` / `--check`
- `Makefile` / `justfile` targets
- `Cargo.toml`: `cargo test`, `cargo clippy -- -D warnings`, (types: n/a, covered by build), `cargo fmt` / `cargo fmt --check`
- `go.mod`: `go test ./...`, `go vet ./...` (+ `staticcheck` if configured), (types: `go build ./...`), `gofmt -w .` / `gofmt -l .`
- `*.csproj` / `*.sln`: `dotnet test`, `dotnet format --verify-no-changes` (format and lint), (types: `dotnet build -warnaserror`)

Write what you found into the plan's **Checks**. For any check you can't find, **ask the user** once (they can answer "none"). Don't invent tooling or install new tools without asking.

## 2. Red: failing tests from the acceptance criteria
Follow the `test-driven-development` skill and its `writing-good-tests.md`.
- At least one test per AC. Put the AC ID in the test name or a comment (e.g. `test_ac1_2_rejects_empty_input`).
- Run the test command. **Every new test must fail, and fail for the right reason** (missing behavior, not an import or typo error). Record the failing output summary.

## 3. Green: minimal code
Write the simplest code that passes. Re-run the **full** test suite until it's green. Don't build anything the slice's ACs don't ask for. Later slices have their own ACs.

## 4. Checks
Run in order: **format** (write mode), then **lint**, **typecheck**, and the **full test suite**. Fix anything they report. Everything must be clean before you continue.

## 5. Refactor against standards
Read `standards.md`. Walk the slice's changed code (`git diff <base>` plus new files) rule by rule and fix violations. Tests must stay green. Re-run step 4 afterward. In Claude Code you may also invoke the built-in `simplify` skill for a quick extra pass, but keep its changes inside this slice.

## 6. Review and the fix loop (bounded: at most 2 fix rounds)
```
round = 0
loop:
  invoke the `review` skill with args: "<slug> <slice-id> round=<round>"
  read the verdict at the top of docs/features/<slug>/review-<slice-id>.md
  if PASS                → go to 7
  if round == 2          → FLAG (below) and stop
  round += 1; set fix_rounds: <round> in plan.md
  fix ONLY the blocking findings (nits are optional), adding or adjusting tests first if a finding is an unmet AC
  re-run step 4 (checks must be clean)
```
There is no third fix round, and nothing is scheduled, retried later, or looped in the background.

**FLAG:** set `status: flagged`, append the log line `<date> <slice-id> flagged after 2 fix rounds`, and end your turn with:
> ⚠️ **<slice-id> flagged.** Still failing review after 2 fix rounds. See `docs/features/<slug>/review-<slice-id>.md`. Remaining blocking findings: <list>. Your call: adjust the plan or ACs, fix by hand, or reset the slice to `todo`.

## 7. Done
- Set `status: done` and append the log line `<date> <slice-id> done (fix_rounds=<n>)`.
- Report: tests added (by AC), checks run with results, fix rounds used, and any nits left.
- End with:
  > ✅ **<slice-id> done. Commit it now before the next slice** (e.g. `git add -A` then `git commit -m "<slug>: <slice-id> <name>"`). Then start a fresh context and run the build skill with `<slug> <next-slice>`.

  If this was the last slice:
  > ✅ **All slices done. Commit, start a fresh context, and run the final-review skill with `<slug>`.**
