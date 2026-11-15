# overpowered

A **Claude Code** plugin that builds features the careful way: **plan first, then build one small tested slice per run, each one checked by a reviewer.**

## Install

```
claude plugin marketplace add adamsaul314/overpowered
claude plugin install overpowered@overpowered
```
Then start a new `claude` session in your project. Inside Claude Code, the same commands work with a slash (`/plugin marketplace add …`, `/plugin install …`).

To update later, run `claude plugin marketplace update overpowered`, then `claude plugin update overpowered@overpowered`.

---

## What it does

1. **Understand.** Claude asks you questions until the feature is clear, then writes a plan split into small slices. Each slice lists the files it may touch and a size budget. No code gets written until you approve.
2. **Build, one slice per run.** Subagents do the work, so every slice starts fresh with no need to clear the chat:
   - A **builder** writes failing tests from the plan, writes code until they pass, and cleans it up against `standards.md`.
   - A **gate** reruns your tests, linter, type checker and formatter itself. It also measures the diff against the slice's budget and file list.
   - A read-only **reviewer** checks every acceptance criterion and every standards rule.
   - A **fixer** works on whatever failed: up to 2 rounds, then it stops and hands the slice back to you.
3. **Final review.** Once every slice is done, the whole feature gets checked for problems between slices, plus Claude Code's built-in code and security reviews.

You approve the plan and commit between slices. Nothing is committed or scheduled for you.

**Needs:** a git repo with a `.gitignore`.

## How to use it

| Step | Command |
|---|---|
| Plan | `/overpowered:understand <idea>` |
| Build a slice | `/overpowered:build <slug> slice-1` |
| Final check | `/overpowered:final-review <slug>` |

1. **Plan the feature**, for example `/overpowered:understand add CSV export to reports`. Answer the questions, review `docs/features/<slug>/plan.md`, and reply **approved**. Then **commit**. The first run also adds a `standards.md` to your project, so edit it to match your style.
2. **Build `slice-1`.** When it says done, **commit**, then build `slice-2`, and so on. Each run handles exactly one slice.
3. **Final check.** After the last slice is committed, run the final review.

## Budgets and file scopes

Each slice in the plan has two limits:

- **`files:`** lists the files the slice is allowed to change, for example `src/report/csv.*, tests/test_csv.*`.
- **`budget:`** caps how big the change can be. The default is 200 lines across 6 code files, plus 150 lines of tests. Tests are counted separately so they're never cut short to fit.

They keep each slice small enough to review properly. If a slice goes over its budget or touches a file outside its list, build doesn't fail it. It **stops and asks you**, and the slice is marked `needs-decision`. Then you choose one of two things:

- **Split the slice** into two smaller ones in the plan, or
- **Raise the budget** (or add the file to `files:`) and write a one-line `budget_reason:` saying why.

Then run build on that slice again. It keeps the work done so far and carries on from the check.

## If something stops

| Message | What to do |
|---|---|
| *Plan not approved* | Reply **approved** in the understand session |
| *Uncommitted changes* | Commit or stash your changes, then run build again |
| *needs a decision* | The slice went over its budget or out of its file list. Split it, or raise the budget with a `budget_reason:`, then run build again |
| *Slice flagged* | It still failed after 2 fix rounds, or the fixer found a cause no code change can fix (such as a broken check command). Read `review-<slice>.md`, fix it by hand or edit the plan, then set the status to `in-progress` with fix rounds at 0 (to keep the work) or to `todo` (after discarding it) |

## What gets added to your project

- `standards.md`: your clean-code rules. It's created on first use, so edit it.
- `docs/features/<slug>/`: the plan, a review for each slice, and the final review.

## What's in this repo

| Path | What |
|---|---|
| `skills/understand`, `build`, `final-review` | The workflow |
| `skills/build/tdd.md` | TDD rules the builder subagent reads |
| `skills/understand/standards.md`, `plan-template.md` | The default standards and plan template |
| `skills/grilling`, `grill-me` | Bundled interview skills (see `THIRD_PARTY_NOTICES.md`) |
| `agents/reviewer.agent.md` | The read-only reviewer subagent |
| `.claude-plugin/` | Plugin and marketplace manifests |
| `skillbench/` | skillbench tests for the workflow (`skillbench check` validates them for free; `skillbench agent` runs them) |

## Developing

Clone the repo, then load it without installing: `claude --plugin-dir <path-to-clone>`
Validate it with `claude plugin validate <path-to-clone>`.
