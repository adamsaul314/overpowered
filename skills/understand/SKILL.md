---
name: understand
description: Start an overpowered feature. Grill the user, then write docs/features/<slug>/plan.md with small slices, file scopes and budgets. Stop for approval. Writes no code.
disable-model-invocation: true
argument-hint: <feature idea>
---

# understand: from idea to an approved plan

Input: the feature idea, from the arguments or the conversation. Output: `docs/features/<slug>/plan.md` (plus `standards.md` on first use), then a **stop**.

This skill's folder holds `plan-template.md` and `standards.md`. Read them from there.

**Hard rule: write no production or test code in this skill.**

## Steps

1. **Preflight.**
   - The current directory is a git repo (`git rev-parse --show-toplevel`). If it isn't, stop and say so. Build needs git for diffs.
   - The tree is clean apart from the workflow's own files:
     ```
     git status --porcelain -- . ":(exclude)docs/features" ":(exclude)standards.md"
     ```
     If that prints anything, stop: "Uncommitted changes outside docs/features and standards.md. Commit or stash them first, so the feature starts from a clean point."
   - If the project root has no `standards.md`, copy this skill's `standards.md` there. Tell the user it's a draft for them to edit, since build and the reviewer use the project's copy.
2. **Grill.** Invoke `overpowered:grilling` (not `grill-me`, which only the user can invoke) and run it to completion. Look up facts in the codebase yourself. Make sure the grilling covers:
   - goals as observable outcomes, and explicit non-goals
   - **slice boundaries**: thin, end-to-end, independently testable slices, ordered so each one builds on the last
   - **the files each slice touches**, as glob patterns (this becomes `files:`)
   - **a budget for each slice** (default: code 200 lines and 6 files, tests 150 lines). A slice that needs more is usually two slices.
   - acceptance criteria for each slice, each one phrased so it becomes a test
   - edge cases and error behavior
   - any project convention that overrides `standards.md`
3. **Write the plan.** Copy `plan-template.md` to `docs/features/<slug>/plan.md`, using a short kebab-case slug, and fill it in:
   - `approval: awaiting-approval`, and leave `feature_base` empty.
   - Number the ACs `AC<slice>.<n>`. Each one is observable (input → output or effect), never "the code is clean".
   - Every slice gets `files:` and `budget:`.
   - Aim for 2–6 slices. More than that probably means two features, so say so.
   - Fill in **Checks** if you know the project's commands. Otherwise build fills them in.
   - Recommend a branch `feature/<slug>`, but don't create it.
   - Append the log line `<date> plan written, awaiting approval`.
4. **STOP.** Show the plan path and a short summary (goals, then slice names with their AC counts and budgets), then end your turn with exactly:

   > **Plan ready for review: `docs/features/<slug>/plan.md`.** Edit it or tell me what to change. Reply **"approved"** when it's right. No code will be written until then.

5. **On approval only.** Do this only when the user explicitly approves ("approved", "OK", "go"):
   - Set `approval: approved` and `feature_base: <git rev-parse HEAD>`.
   - Append the log line `<date> approved at <short sha>`.
   - Tell the user: **"Commit the plan (and `standards.md` if it's new), then run `/overpowered:build <slug> slice-1`."**

   If the user asks for changes instead, edit the plan and repeat step 4.
