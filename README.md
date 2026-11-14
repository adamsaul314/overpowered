# overpowered

A Claude Code plugin that builds features the careful way: **plan first, then build in small tested slices, each checked by a reviewer.**

## What it does

1. **Understand.** Claude asks you questions until the feature is clear, then writes a plan split into small slices. It writes no code until you approve.
2. **Build.** For one slice at a time, Claude:
   - writes failing tests from the plan
   - writes code until they pass
   - runs your tests, linter, type checker and formatter
   - cleans up the code against `standards.md`
   - has a read-only reviewer check it, then fixes what it finds (2 rounds max, then it stops and asks you)
3. **Final review.** Once every slice is done, the whole feature gets checked for problems between slices.

You approve the plan and commit after each slice. Nothing is committed or scheduled for you.

## Setup (once)

From PowerShell or any terminal:
```
claude plugin marketplace add C:\Users\adams\Desktop\overpowered
claude plugin install overpowered@overpowered
```
Or from inside Claude Code, use the same commands with a slash: `/plugin marketplace add …` and `/plugin install …`

Then start a new `claude` session in your project.
Your project must be a **git repo** with a `.gitignore`.

## How to use it

**1. Plan the feature**
```
/overpowered:understand add CSV export to reports
```
Answer the questions. Review `docs/features/<slug>/plan.md`, reply **approved**, then commit.

**2. Build each slice**
```
/clear
/overpowered:build <slug> slice-1
```
When it says done, **commit**. Then repeat for `slice-2`, `slice-3`, and so on.
Always run `/clear` first, so each slice starts fresh.

**3. Final check**
```
/clear
/overpowered:final-review <slug>
```

## If something stops

| Message | What to do |
|---|---|
| *Plan not approved* | Reply **approved** in the understand session |
| *Uncommitted changes* | Commit the previous slice, then run build again |
| *Slice flagged* | Read `review-<slice>.md`. Fix it by hand or edit the plan, then set the slice's status back to `todo` and its fix rounds to 0. Before running build again, commit or stash any leftover changes |

## Where things are

- **In your project:** `docs/features/<slug>/` holds the plan, the reviews and the final review.
- **Here:** `standards.md` (your clean-code rules, **edit it**), `templates/plan.md`, `skills/`, `agents/reviewer.md`
- **Project-specific rules:** put a `standards.md` in a project's root and it's used instead of the default.

## Developing the plugin

Load it from this folder without installing: `claude --plugin-dir C:\Users\adams\Desktop\overpowered`
Check it: `claude plugin validate C:\Users\adams\Desktop\overpowered`
