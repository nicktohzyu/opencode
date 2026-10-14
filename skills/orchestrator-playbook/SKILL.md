---
name: orchestrator-playbook
description: Orchestrator-side playbook for delegating work to subagents via the subagent tool — picking advisors vs reviewers, writing prompts that produce triageable output, running parallel independent reviews, validating dismissals, verifying with execution. Triggers on subagent, subagent tool, delegate, orchestrate, parallel review, second opinion, triage findings.
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
   for judgment. The roster is free-only — spend depth on diverse families
   the cheap pass.
3. **Dismissals get more scrutiny than fixes.** A wrongly-applied fix wastes
   minutes; a wrongly-dismissed finding ships a bug. Task an advisor explicitly
   to attack your dismissals before you act on a triage.
4. **Ground truth is executable, not consensual.** Reviewer disagreements are
   resolved by running code/tests, never by majority vote.
5. **Continuity for advisors, independence for reviewers.** Resume one advisor
   session (by session ID) so context accumulates; always launch reviewers fresh so
   prior conclusions can't anchor them.
6. **Executors observe and report; only the primary acts.** Keep executor
   permissions read-only (edit denied, git-scoped bash, no network tools) and
   implementation with the primary. If implementation is ever delegated, design
   an explicit full-trust implementer profile then — never live in the middle
   (write access without execution access can corrupt but cannot self-verify).

## When to delegate: verify-cost < redo-cost

Default: do the work yourself. Delegate only when the output reduces to
evidence you can spot-check in seconds — if verifying equals redoing, you
have delegated nothing. Executors can find but cannot verify (read-only, no
execution, no network), so every delegated claim ships a verification debt
you must pay by re-running the read/grep yourself.

Delegate:
- Mechanically-verifiable retrieval: call sites, grep patterns, file locations
- Disagreement generation (`adviser-chat`) — approach-level advisory where
  rebuild may be the answer; divergence is the product
- Parallel review (`review-orchestration`) — implementation-level review of
  a fixed target; adversarial
- Mapping 3+ independent unknowns with zero shared context
- Verbose offload: dozens of tool results in, one summary out
  (>1000 tokens you won't reuse)
- Read-only or cheap-model isolation, or an explicit verification checkpoint
- Test, lint, typecheck, or harness execution (verifier tier) — output is
  self-verifying by construction
- External research (researcher tier) — every claim needs a source URL plus
  a verbatim quote

Do not delegate:
- Design and architecture judgment ("is this sound?")
- Investigation that will birth a deeper question mid-stream
- Anything where verifying equals redoing
- Implementation, commits, pushes, releases — primary-only

Hard invariants:
1. Uncited claims are rejections, not findings — require `file:line` plus a
   verbatim quote for repo claims, source URL plus a verbatim quote for
   external claims.
2. Never chain subagent output into another subagent — it compounds
   ungrounded inference.
3. Never delegate past the point where verifying equals redoing.

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

Spend effort deliberately: the spawn's `model` parameter accepts
`provider/model#variant`, so reasoning effort scales per task — cheap breadth
stays cheap, high-stakes passes go deep (variants per review-orchestration's
Effort per spawn).

### Blocked and denied: subagents inherit their tier protocol

Each tier operates under its own protocol file (`protocols/executor-`,
`verifier-`, `researcher-protocol.md`, pointed to from the agent files): on
missing input they return `BLOCKED:` plus exactly what is needed; on tool
denial they reformulate at most once. Do not re-explain this in prompts —
brief the triageable output format, and resume via the session ID with answers
when BLOCKED arrives.

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
