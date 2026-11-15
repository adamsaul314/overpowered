# TDD rules for the builder

Adapted and condensed from obra/superpowers `test-driven-development` (MIT, see THIRD_PARTY_NOTICES.md).

Write the test first. Watch it fail. Write minimal code to pass.
If you didn't watch the test fail, you don't know whether it tests the right thing.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

If you write code before its test, delete it and start over from the test. Don't keep it as a reference.

## The cycle

**1. RED: write one failing test.** It covers one behavior, has a clear name, and runs real code (mocks only if unavoidable). Put the AC ID in the name, e.g. `test_ac1_2_rejects_empty_input`.

```python
def test_ac1_1_median_of_odd_list_is_middle_value():
    assert median([3, 1, 2]) == 2
```

**2. Verify RED. This is mandatory.** Run the test and confirm that:
- it fails (an assertion failure, not an error)
- the failure message is the one you expect
- it fails because the feature is missing, not because of an import error or a typo

If it passes, it's testing existing behavior, so fix the test. If it errors, fix the error and re-run until it fails correctly.

**3. GREEN: write minimal code.** Write the simplest code that passes. Add no options, features or "improvements" the test doesn't ask for (YAGNI).

**4. Verify GREEN. This is mandatory.** Run the **project's full test command**, not just your file. A green run of your one test is not a green suite. The test must pass, the other tests must still pass, and the output must be clean (no errors, no warnings). If your test fails, fix the code, not the test. Report any failure by name, including ones you didn't cause.

**5. REFACTOR.** Only once everything is green: remove duplication, improve names, extract helpers, and check against the standards file. Keep the tests green and add no behavior.

Then write the next failing test.

## Good tests

- **Name the break.** Before writing the test body, name the production change that would make it fail. If you can't name one, the test checks nothing. If only intentional decisions would fail it (a constant's value, exact wording), it's a change detector, so test the behavior that depends on the decision instead.
- **Derive expectations independently.** Use literals and hand-checked fixtures. Never compute the expected value with the code under test or its helpers.
- **Assert real behavior, not mocks.** A mock assertion only proves the mock exists. Mock only the slow or external level, and learn the real method's side effects first. Mock responses mirror the complete real structure.
- **Make doubles specific.** If arguments, call counts or ordering are part of the contract, assert them. Give each branch (success, error, malformed) its own fixture.
- **Keep test-only code out of production.** Cleanup or helpers that only tests use go in test utilities, not on production classes.
- **Test your code, not the framework.** Test the contract at your boundary. Trivial getters, constants and forwarding earn no test.
- **Mutation check.** Before finishing, imagine these mutations: a wrong constant or argument, a wrong branch, a missing side effect, an empty return, missing validation for empty or bad input. At least one test should fail for each.

## Verification checklist

Before you report back:

- [ ] Every new function or method has a test
- [ ] You watched each test fail before implementing
- [ ] Each test failed for the expected reason (feature missing, not a typo)
- [ ] You wrote minimal code to pass each test
- [ ] All tests pass (the full suite)
- [ ] The output is clean (no errors, no warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors are covered

If you can't tick every box, you skipped TDD. Start over.

## When stuck

| Problem | Solution |
|---|---|
| You don't know how to test it | Write the API you wish existed. Write the assertion first. |
| The test is too complicated | The design is too complicated. Simplify the interface. |
| You'd have to mock everything | The code is too coupled. Use dependency injection. |
| The test setup is huge | Extract helpers. Still complex? Simplify the design. |
