---
name: review-orchestration
description: Use when orchestrating a parallel code review across executor subagents. Covers free-tier roster selection, custom briefs, verification/selection pass, and iteration.
---

# Code Review Orchestration

Spawn executor subagents via the subagent tool (one call per agent ID) in a single message for parallel execution. Each runs a different model; its description states its cost tier and strengths. They are terminal executors and cannot delegate further. Agents carry no preset role — your per-review brief is the role.

## Tiers (cost, not capability — use full agent IDs, short names do not resolve)

- `[FREE]`: ling-3-1-flash-free, mimo-v2-6-flash-free, muse-spark-1-3-contributor-free, nemotron-3-ultra-free, step-5-preview-free, space-bunny-free

## Effort per spawn

The tier list names agents; the `subagent` tool's `model` parameter also
accepts `provider/model#variant` per call (e.g.
`opencode/muse-spark-1.3-contributor-free#xhigh`). The agent file's model is
only the default — the parent can scale reasoning effort per task: deep for
high-stakes or narrow re-check passes, cheap for mechanical sweeps. Variants
are catalog-defined per model and change over time; an unavailable variant
fails the spawn with `Variant unavailable for <model>: <variant>`.

## Example Focus Areas (pick per review, instruct subagent)

| Focus | When to use | Typical number of subagents |
|-------|-------------|-------------------|
| Security | Auth, crypto, input handling, secrets | 2–3 |
| Performance | Hot paths, DB queries, allocations | 1–2 |
| Simplicity/Readability | New features, refactors, complex logic | 2–3 |
| Correctness | Core logic, edge cases, concurrency | 2–3 |
| Architecture | New modules, boundaries, contracts | 1–2 |
| Generalist | First pass, small diffs, unknown risk | 2–3 |

**Guideline:** Match focus to change type. Default to generalist for unknown/small changes. Use specialists for known risk areas. Never spawn all — pick 2–3 max per review.

**Diversity rule:** Prefer diverse model families from different providers/lineages. Independent models reduce correlated blind spots.

## Brief

Reviewers check a fixed target; they do not redesign it. (For approach-level
advice where rebuild may be the answer, use `adviser-chat`.) Every brief
declares:

1. **Adversarial frame** — "Review to reject: assume the diff contains at
   least one defect. Findings over approval."
2. **Static reasoning only** — executors cannot execute. Forbid causal claims
   about runtime behavior; anything needing a run goes in assistance requests.
3. **Severity-tagged findings** — `[SEVERE/HIGH/MED/LOW] file:line — issue —
   suggested fix`. Report all SEVERE/HIGH without limit, cap MED/LOW trivia.
4. **Assistance requests** — things the reviewer wanted to execute but
   couldn't: one runnable command per line (with workdir) plus the exact
   expected-output shape, for the orchestrator or verifier tier to run blind.
5. **Docs consistency and revert verdict** — cross-check the implementation
   against its docs; contradictions are findings. Close with the one change
   you would revert, if any.
6. **Scope discipline** — stay inside the briefed files/diff; name anything
   you deliberately excluded.

## Workflow

- Pick a small, diverse set of reviewers (2–5). Never spawn every available reviewer.
- Executors are read-only by design (edit denied, git-scoped bash, no network).
  Never delegate destructive actions, pushes, or releases; the primary executes.
- The roster is free-only: spend the budget on diverse model families rather than tier escalation. Re-run a narrow pass on changed regions instead of escalating.
- Optional pre-pass: run a cheap local check (`git diff --stat`, linter) and include its output in the brief so reviewers skip mechanically-detectable issues.
- Write a custom brief per review with the diff context and the exact output format you want back. Do not rely on a shared spec (`templates/review-spec.md` is a template to copy from, not an auto-applied contract).
- Treat outputs as candidates, not truth. Confirmed by two model families is strong; a lone flag is suspect. Dedupe, rank by severity, surface criticals prominently. Flag disagreements for user attention.

## On failure

Thinking-budget exhaustion (not context truncation) causes empty/truncated results: no completed deliverable, cut off mid-reasoning, no tool/API error.

1. Resume via the session ID (fresh thinking budget).
2. If the resume fails, one fresh retry (no session ID).
3. If that fails, proceed without that reviewer and note the gap.

## Iterate (optional)

After fixes, repeat to confirm — especially substantial or high-stakes changes. Skip when the review was clean or changes trivial.
