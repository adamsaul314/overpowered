---
name: understand
description: Start a feature in the overpowered workflow. Grill the user to shared understanding, write docs/features/<slug>/plan.md with ordered vertical slices, then stop and wait for approval. Writes no code.
disable-model-invocation: true
argument-hint: <feature idea>
---

# understand: from idea to an approved plan

Workflow home: `${CLAUDE_PLUGIN_ROOT}` (WF below; the plugin root).
Input: the feature idea in the arguments or the conversation. Output: `docs/features/<slug>/plan.md` in the current project, then a **stop**.

**Hard rule: write no production or test code in this skill.** The only file you create is the plan.

## Steps

1. **Preflight.** Confirm the current directory is a git repo (`git rev-parse --show-toplevel`). If it isn't, stop and tell the user. The later steps need git for diffs.
2. **Grill.** Invoke the `overpowered:grilling` skill with the Skill tool (not `overpowered:grill-me`, which only the user can invoke) and run it to completion on the feature idea. Look up facts about the codebase yourself, as grilling says. Make sure the grilling covers:
   - goals stated as observable outcomes, and explicit non-goals
   - how to cut the work into **vertical slices**: each one is thin, end-to-end, independently testable, and ordered so each builds on the last
   - acceptance criteria for each slice, phrased so each one becomes a test
   - edge cases and error behavior
   - anything in the project's own conventions that overrides `WF/standards.md`
3. **Write the plan.** Copy `WF/templates/plan.md` to `docs/features/<slug>/plan.md` (choose a short kebab-case slug) and fill it in. Rules:
   - `approval: awaiting-approval`, and leave `feature_base` empty.
   - Number the acceptance criteria `AC<slice>.<n>`. Each must be observable (input → output or effect), not "code is clean".
   - Prefer 2–6 slices. If you have more, the feature is probably two features. Say so.
   - Fill in **Checks** if you already know the project's commands. Otherwise leave it for build.
   - Recommend (don't create) a branch `feature/<slug>`.
   - Append a log line: `<date> plan written, awaiting approval`.
4. **STOP.** Show the user the plan path and a short summary (goals, slice names, AC counts), then end your turn with exactly:

   > **Plan ready for review: `docs/features/<slug>/plan.md`.** Edit it or tell me what to change. Reply **"approved"** when it's right. No code will be written until then.

5. **On approval only.** When the user explicitly approves ("approved", "OK", "go"), and only then:
   - set `approval: approved`
   - set `feature_base` to the current `git rev-parse HEAD`. Uncommitted changes outside `docs/features/` (`git status --porcelain -- . ':(exclude)docs/features'`) mean feature_base isn't a clean point. In that case tell the user to commit or stash them first. The plan file itself may be uncommitted.
   - append the log line `<date> approved at <sha>`
   - tell the user the next step: **commit the plan, run `/clear`, then `/overpowered:build <slug> slice-1`.**

   If the user asks for changes instead, edit the plan and repeat step 4.
