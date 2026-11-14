# overpowered

A plugin for **Claude Code** and **GitHub Copilot CLI** that builds features the careful way: **plan first, then build in small tested slices, each checked by a reviewer.**

## Install for Claude Code

```
claude plugin marketplace add adamsaul314/overpowered
claude plugin install overpowered@overpowered
```
Then start a new `claude` session in your project. (Inside Claude Code, the same commands work with a slash: `/plugin marketplace add …`, `/plugin install …`.)

Update later: `claude plugin marketplace update overpowered`, then `claude plugin update overpowered@overpowered`

## Install for GitHub Copilot CLI

```
copilot plugin marketplace add adamsaul314/overpowered
copilot plugin install overpowered@overpowered
```
Then start a new `copilot` session in your project. Check that it loaded with `/skills list` and `/agent`.

> Copilot support is new and less tested than Claude Code. The built-in code and security reviews in the last step are Claude Code only.

---

## What it does

1. **Understand.** The AI asks you questions until the feature is clear, then writes a plan split into small slices. It writes no code until you approve.
2. **Build.** For one slice at a time, the AI:
   - writes failing tests from the plan
   - writes code until they pass
   - runs your tests, linter, type checker and formatter
   - cleans up the code against `standards.md`
   - has a read-only reviewer check it, then fixes what it finds (2 rounds max, then it stops and asks you)
3. **Final review.** Once every slice is done, the whole feature gets checked for problems between slices.

You approve the plan and commit after each slice. Nothing is committed or scheduled for you.

**Needs:** a git repo with a `.gitignore`.

## How to use it

Commands differ slightly per tool:

| Step | Claude Code | Copilot CLI |
|---|---|---|
| Plan | `/overpowered:understand <idea>` | `/understand <idea>` |
| Build a slice | `/overpowered:build <slug> slice-1` | `/build <slug> slice-1` |
| Final check | `/overpowered:final-review <slug>` | `/final-review <slug>` |

**1. Plan the feature.** For example, `/overpowered:understand add CSV export to reports`.
Answer the questions. Review `docs/features/<slug>/plan.md`, reply **approved**, then commit.
The first run also adds a `standards.md` to your project. Edit it to match your style.

**2. Build each slice.** Run `/clear` first so each slice starts fresh, then build `slice-1`.
When it says done, **commit**. Repeat for `slice-2`, `slice-3`, and so on.

**3. Final check.** Run `/clear`, then the final review.

## If something stops

| Message | What to do |
|---|---|
| *Plan not approved* | Reply **approved** in the understand session |
| *Uncommitted changes* | Commit the previous slice, then run build again |
| *Slice flagged* | Read `review-<slice>.md`. Fix it by hand or edit the plan, then set the slice's status back to `todo` and its fix rounds to 0. Before running build again, commit or stash any leftover changes |

## What gets added to your project

- `standards.md`: your clean-code rules. It's created on first use, so edit it.
- `docs/features/<slug>/`: the plan, a review per slice, and the final review.

## What's in this repo

| Path | What |
|---|---|
| `skills/understand`, `build`, `review`, `final-review` | The workflow |
| `skills/understand/standards.md`, `plan-template.md` | Default standards and plan template |
| `skills/grilling`, `grill-me`, `test-driven-development` | Bundled helper skills (see `THIRD_PARTY_NOTICES.md`) |
| `agents/reviewer.agent.md` | Read-only reviewer subagent |
| `.claude-plugin/` | Plugin and marketplace manifests (read by both tools) |

## Developing

Clone the repo, then load it without installing: `claude --plugin-dir <path-to-clone>`
Validate: `claude plugin validate <path-to-clone>`
