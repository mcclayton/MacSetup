---
name: my-address-comments
description: Triage and resolve GitHub pull-request code-review comments. Use when the user invokes $my-address-comments or asks to assess review/CR comments for validity, meaningfulness, PR scope, and duplication; then reply to and resolve out-of-scope or non-actionable threads, or fix, commit, push, reply to, and resolve actionable comments.
---

# My Address Comments

Review every unresolved code-review thread on the target pull request. Do not change code, reply, or resolve a thread until it has been evaluated against all four criteria.

## Triage

For each comment, decide whether it is:

1. **Valid** — the concern is technically correct after checking the relevant code, behavior, and tests.
2. **Meaningful** — fixing it materially improves correctness, safety, maintainability, performance, accessibility, or the intended user experience.
3. **In scope** — the issue was introduced by this PR. Use the base diff, blame/history, and surrounding unchanged code as needed; do not make this PR fix a pre-existing issue unless the user explicitly expands scope.
4. **Not a duplicate** — no other review thread already requests the same underlying fix or decision.

Treat ambiguity as a reason to investigate, not as automatic acceptance. Check the exact code location, full thread context, existing fixes, and relevant tests. Consider an issue introduced if the PR changes behavior, exposes a pre-existing latent defect through its new behavior, or removes a safeguard that previously prevented it.

## Resolution rules

- If any criterion is false, reply concisely with the factual reason and resolve the thread. Be respectful and specific; identify whether the concern is invalid, not meaningful, pre-existing/out of scope, or duplicative, and link or name the canonical thread when applicable.
- If all four criteria are true, implement the smallest complete fix. Preserve the PR's intended scope; do not bundle unrelated cleanup.
- Validate each accepted fix proportionally: run the relevant targeted tests, lint/typecheck/build, and `git diff --check` when applicable.
- Before committing, review the final diff and ensure each changed file is attributable to an accepted thread.
- Commit accepted fixes with the repository's commit convention, push the current branch, then reply with what changed and resolve every addressed thread.

## GitHub workflow

Use the GitHub review-comment tooling available in the environment. If the `github:gh-address-comments` skill is available, apply it for retrieving, replying to, and resolving review threads; otherwise use the connected GitHub tools or `gh`.

Explicitly inspect inline diff threads, not only top-level review summaries. Treat reduced summaries such as "0 current threads" as advisory, not authoritative: before concluding that no unresolved feedback remains, enumerate the pull request's canonical review-thread connection, follow every pagination cursor, and inspect every thread whose `isResolved` value is false. Include outdated threads and threads created by reviewer apps, even when the preferred wrapper omits them. If a supplied discussion URL or the canonical thread list exposes a thread missing from the wrapper's output, use the canonical thread data for that run and report the coverage gap.

Do not resolve a comment before its reply is successfully posted. Do not resolve threads that cannot be conclusively triaged; report the blocker and leave them open. Do not force-push, amend an existing commit, or resolve a thread without an explanatory response unless the user explicitly asks.

## Final report

Summarize:

- Each thread and its four-part triage outcome.
- Which threads were declined/resolved and the reason.
- Which threads were fixed/resolved and the commit SHA.
- Validation performed and any unresolved blockers.
