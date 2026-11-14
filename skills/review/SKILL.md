---
name: review
description: Review one slice of an overpowered-workflow plan by sending a read-only reviewer subagent the slice's plan section, the standards file, and the slice diff. Writes docs/features/<slug>/review-<slice>.md. Called by the build skill; never edits code.
argument-hint: <feature-slug> <slice-id> [round=N]
---

# review: fresh-eyes check of one slice

Input: `<slug> <slice-id> [round=N]` (round defaults to 0).
Output: `docs/features/<slug>/review-<slice-id>.md` with this round appended. The first line of the file always shows the latest verdict.

**This skill never edits code, tests, or the plan.** The only file it writes is the review file.

## Steps
1. **Gather small inputs.**
   - From `docs/features/<slug>/plan.md`, extract **only** this slice's section (heading through Notes) and the `base` SHA. Don't pass goals, other slices or the log.
   - Standards: the project's `standards.md`. Pass its absolute path.
   - Diff: pick a temp file path **outside the repo** (in the system temp folder), then run these commands. They work the same in bash and PowerShell, and plans and reviews under `docs/features/` aren't code under review, so both exclude it:
     ```
     git diff <base> --no-color --output=<tmpfile> -- . ":(exclude)docs/features"
     git ls-files --others --exclude-standard -- . ":(exclude)docs/features"
     ```
     The second command lists new (untracked) files. Pass them as absolute paths. If the diff file is empty and there are no new files, write a review saying so with verdict CHANGES REQUESTED, then stop.
2. **Spawn the reviewer subagent.** Delegate to the plugin's `reviewer` agent, which has read-only tools. In Claude Code use the Agent tool with `subagent_type: "overpowered:reviewer"`. In Copilot, delegate to the `reviewer` custom agent. Prompt:
   ```
   Mode: slice
   Standards file: <absolute path>
   Diff file: <absolute tmpfile path>
   New files: <absolute paths, or "none">
   Plan (this slice only):
   <slice section text>
   Review per your instructions and return the report in your output format.
   ```
   If the reviewer agent isn't available, stop and tell the user to check that the overpowered plugin is installed and enabled (it provides `agents/reviewer.agent.md`), then restart the tool. **Don't** fall back to an agent that has write tools.
3. **Write the review file.** Write or update `docs/features/<slug>/review-<slice-id>.md`:
   ```
   # Review: <slug> / <slice-id>
   **Latest verdict: <PASS|CHANGES REQUESTED> (round <N>)**

   ## Round <N> (<date>, base <short sha>)
   <reviewer report verbatim>

   ## Round <N-1> …   (earlier rounds kept below, newest first)
   ```
   Add the report exactly as returned, without softening it or dropping findings. Delete the temp diff file.
4. **Return** the verdict and the blocking findings to the caller (build) in 1–5 lines.
