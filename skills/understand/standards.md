# Clean-Code Standards

> **DRAFT. Edit freely.** These are the defaults the `build` and `review` skills use.
> `understand` copies this file into a project root the first time it runs there. The project copy is the one that's used, so edit it per project.
> Reviewers cite rules by ID (S1, S2, …), so keep the IDs stable when you edit.

## Naming
- **S1. Names say what, not how.** Variables, functions and types reveal intent. No `data`, `tmp`, `mgr`, `doStuff`, or single letters outside tiny loops.
- **S2. One word per concept.** Don't mix `fetch` / `get` / `load` for the same idea in one codebase.
- **S3. Booleans read as questions.** `isValid`, `hasItems`, `shouldRetry`.

## Functions
- **S4. Small and single-purpose.** A function does one thing at one level of abstraction. If you need "and" to describe it, split it.
- **S5. Few parameters.** Three or fewer. More than that usually means a missing type or object.
- **S6. No hidden side effects.** A function named like a query doesn't mutate state, write files or call the network.
- **S7. Command–query separation.** A function either changes state or returns information, not both (unless it's an idiomatic exception, such as `pop`).

## Structure
- **S8. No duplication.** The same logic in two places is extracted once. Don't extract on the first repeat if the two copies are only coincidentally similar.
- **S9. No dead code.** No commented-out code, unused functions, imports, variables or parameters, and no unreachable branches.
- **S10. Small public interfaces.** Export only what callers need. Everything else is private or module-local.
- **S11. Dependencies point inward.** Core logic doesn't import UI, I/O or framework code. Pass those in.

## Errors
- **S12. Explicit error handling.** No empty catch blocks, and no swallowed errors or ignored return codes. Either handle the error or let it propagate with context.
- **S13. Fail fast at the boundary.** Validate input where it enters the system. Raise or return a clear error. Don't return silent defaults for bad input.
- **S14. Errors say what and why.** Messages name the bad value or operation, not just "error" or "invalid".

## Hygiene
- **S15. No magic values.** Unexplained literals get a named constant, unless the meaning is obvious in place (`0`, `1`, `""`).
- **S16. Comments explain why, not what.** If a comment restates the code, delete the comment or improve the names.
- **S17. Tests are code too.** Tests follow these rules, test behavior rather than implementation, and each one names the break it catches.
