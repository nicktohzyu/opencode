---
name: subagent-playbook
description: Use when delegating work to subagents via the task tool — picking advisors vs reviewers, writing prompts that produce triageable output, running parallel independent reviews, validating dismissals, verifying with execution. Triggers on subagent, task tool, delegate, parallel review, second opinion, triage findings.
---

# Subagent Playbook

Complements the `review-orchestration` skill (tiered reviewer selection) and
the `adviser-chat` skill (single-round second opinions). This skill covers the
workflow around them: how to prompt, how to triage, and how to verify.

## Core rules

1. **Subagents advise; you decide and you write.** Never apply subagent output
   verbatim — not code sketches, not "fixes." Assume every output contains at
   least one confident error until verified.
2. **Cheap breadth, then targeted depth.** Free-tier models in parallel for
   findings (diverse lineages give independent signals); one advisor serially
   for judgment. Escalate to lite, then paid specialists, only for what survives
   the cheap pass.
3. **Dismissals get more scrutiny than fixes.** A wrongly-applied fix wastes
   minutes; a wrongly-dismissed finding ships a bug. Task an advisor explicitly
   to attack your dismissals before you act on a triage.
4. **Ground truth is executable, not consensual.** Reviewer disagreements are
   resolved by running code/tests, never by majority vote.
5. **Continuity for advisors, independence for reviewers.** Resume one advisor
   session (`task_id`) so context accumulates; always launch reviewers fresh so
   prior conclusions can't anchor them.
6. **Executors observe and report; only the primary acts.** Keep executor
   permissions read-only (edit denied, git-scoped bash, no network tools) and
   implementation with the primary. If implementation is ever delegated, design
   an explicit full-trust implementer profile then — never live in the middle
   (write access without execution access can corrupt but cannot self-verify).

## Prompt skeleton

Every subagent prompt needs four parts. Missing any one degrades output sharply:

1. **Role with teeth** — "be adversarial", "don't just agree", "steelman the
   opposing case." Vague roles get vague reviews.
2. **Compressed context** — actual code idioms, constraints already
   established, prior decisions. Grounds findings in the real codebase instead
   of an imagined one. Include short excerpts, not whole files.
3. **Enumerated attack surface** — lettered checklist of areas to cover
   (e.g. recursion direction, error paths, API-sandbox interactions, perf
   bounds). Coverage becomes systematic rather than whatever the model notices.
4. **Triageable output format** — force it:
   - Reviews: `[SEVERE/HIGH/MED/LOW] file:line — issue — suggested fix`
   - Validation: `CONFIRM` or `CHALLENGE` per item, with reasoning
   - Plans: concrete sketch in the repo's own style/idioms, not pseudocode

## Workflow

1. **Debate the design first** (advisor, divergent perspective) → converge in
   writing before code exists.
2. **Review the plan before implementation** — cheapest place to catch
   mistakes (scoping, API shape, failure modes). Ask for a sketch in matching
   style.
3. **Implement yourself.** Keeps ownership of the diff; subagents stay in
   advise/review roles.
4. **Parallel independent review** (same brief to 2–3 diverse models) →
   triage findings into FIX vs DISMISS with reasons.
5. **Validate the triage** (advisor, emphasis on dismissals) → apply fixes.
6. **Verify by execution** (tests, harnesses, repro scripts) → extend coverage
   for each fix, not just the original behavior.
7. **Narrow re-check** of only the changed regions — full re-reviews mostly
   re-report known issues. Review leverage per token is highest on diffs.

## Anti-patterns

- Applying a reviewer's suggested fix without understanding it (known cases:
  backwards recursion claims, "fixes" that break sandbox API detection).
- Re-reviewing whole files after targeted fixes instead of the diff.
- Letting reviewers share a session (anchoring) or letting advisors start
  fresh each round (context loss).
- Treating agreement between models as verification — it is correlation.
  Only execution verifies.
