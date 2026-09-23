---
name: review-orchestration
description: Use when orchestrating a parallel code review across executor subagents. Covers tiered free/lite/paid selection, custom briefs, verification/selection pass, and iteration.
---

# Code Review Orchestration

Spawn executor subagents via the task tool (one call per `subagent_type`) in a single message for parallel execution. Each runs a different model; its description states its cost tier and strengths. They are terminal executors and cannot delegate further. Agents carry no preset role — your per-review brief is the role.

## Tiers (cost, not capability — use full `subagent_type` strings, short names do not resolve)

- `[FREE]`: atria-dawn-preview-free, big-pickle-free, ling-3-0-flash-fin-free, mimo-v2-5-free, muse-spark-1-3-contributor-free, nemotron-3-ultra-free, nemotron-3-5-lightning-free
- `[LITE]` (budget paid): deepseek-v4-pro-lite
- `[PAID]` (flagship): glm-5-2-paid, kimi-k2-7-code-paid, qwen3-7-max-paid

## Example Focus Areas (pick per review, instruct subagent)

| Focus | When to use | Typical number of subagents |
|-------|-------------|-------------------|
| Security | Auth, crypto, input handling, secrets | 2–3 |
| Performance | Hot paths, DB queries, allocations | 1–2 |
| Simplicity/Readability | New features, refactors, complex logic | 2–3 |
| Correctness | Core logic, edge cases, concurrency | 2–3 |
| Architecture | New modules, boundaries, contracts | 1–2 (higher-tier) |
| Generalist | First pass, small diffs, unknown risk | 2–3 |

**Guideline:** Match focus to change type. Default to generalist for unknown/small changes. Use specialists for known risk areas. Never spawn all — pick 2–3 max per review.

**Diversity rule:** Prefer diverse model families from different providers/lineages. Independent models reduce correlated blind spots.

## Workflow

- Pick a small, diverse set of reviewers (2–5). Never spawn every available reviewer.
- Executors are read-only by design (edit denied, git-scoped bash, no network).
  Never delegate destructive actions, pushes, or releases; the primary executes.
- Start with `[FREE]`; escalate to `[LITE]` or a matched `[PAID]` specialist only when the free pass surfaces real issues or the change is high-stakes.
- Optional pre-pass: run a cheap local check (`git diff --stat`, linter) and include its output in the brief so reviewers skip mechanically-detectable issues.
- Write a custom brief per review with the diff context and the exact output format you want back. Do not rely on a shared spec (`instructions/review-spec.md` is a template to copy from, not an auto-applied contract).
- Treat outputs as candidates, not truth. Confirmed by two model families is strong; a lone flag is suspect. Dedupe, rank by severity, surface criticals prominently. Flag disagreements for user attention.

## On failure

Thinking-budget exhaustion (not context truncation) causes empty/truncated results: no completed deliverable, cut off mid-reasoning, no tool/API error.

1. Resume via `task_id` (fresh thinking budget).
2. If the resume fails, one fresh retry (no `task_id`).
3. If that fails, proceed without that reviewer and note the gap.

## Iterate (optional)

After fixes, repeat to confirm — especially substantial or high-stakes changes. Skip when the review was clean or changes trivial.
