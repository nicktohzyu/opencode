---
name: adviser-chat
description: Use when you need a cheap second opinion at the approach/design level, plan critique, or methodology check from a different model family via generic executor subagents. Covers model-agnostic adviser selection, alternatives-with-tradeoffs briefing, single-round parallel workflow, and synthesis.
---

# Adviser Chat

Get a second perspective from a fresh executor subagent with a different model family. Single round by default.

Advisors explore the approach/design space; they are not reviewers. The target
is not fixed — rebuild-from-scratch may be the right answer. (For
implementation review of a fixed target, use `review-orchestration`.)

## When to use

- Architecture decision with multiple credible paths, plan critique, methodology or data-analysis check, explicit tradeoff surfacing.
- User asks for dissent or second opinions, or anchoring is a risk.

Do not use for pure implementation work, single-file edits, or when the primary context already has enough evidence.

## Selection (model-agnostic)

- Pick a small, diverse set of executor subagents whose model family differs from the primary (free tier first; escalate to lite/paid only if high-stakes or the first pass surfaces real issues). Any `*-free`/`*-lite`/`*-paid` executor works since its role is dynamically specified by your prompt.
- Prefer diverse families over similar ones. Never spawn every available executor.
- Subagents are terminal executors and cannot delegate further.

## Brief

Beyond the playbook's prompt skeleton, every advisor brief declares:

1. **Anti-anchoring frame** — "Do not anchor on the proposed approach merely
   because it was proposed. Present the best alternative shapes with honest
   tradeoffs, then rank them against the proposal."
2. **Redesign scope** — one of: `rebuild in scope` (greenfield allowed; the
   approach may be condemned) or `tweaks only` (implementation exists and
   ships; advise on adjustments within it). An advisor guessing wrong about
   this wastes the round.
3. **Severity-gated output** — findings carry severity tags (the advisor's own
   judgment): report all SEVERE/HIGH without limit, cap MED/LOW trivia.
   Verdict = everything you'd block on, one sentence each. Terse, no hedging.
4. **Scope bounds** — declare what's out of scope (files, areas, questions)
   alongside the redesign scope. Don't review whatever catches your eye.

## Workflow

1. **Architect position first:** write down your initial position, 3 strongest reasons, and the main risk in your preferred path — before reading advisers.
2. **Gather compact context only:** decision question, constraints, success criteria, and minimal snippets/metrics. Never feed the full conversation transcript.
3. **Launch in parallel:** one Task call per `subagent_type` in a single message. Require a structured response:
   - Alternatives — up to 3 shapes including the proposal, honest tradeoffs each
   - Ranking — ordered, one-line reason per position
   - Blockers — anything you'd stop the design over, one sentence each
4. **Synthesize with guardrails:** do not dismiss a view without explaining why; if a voice changed your recommendation say so; always include the strongest dissent even if rejected; if two voices align against your initial position treat it as a real signal. Keep raw positions visible before the verdict.

## Iterate only when

- Result was empty/truncated (thinking-budget abort): resume via `task_id` (fresh budget), then one fresh retry max, else proceed without it and note the gap.
- A key fact was missing, or you changed code based on the verdict and need a re-check.
- If the adviser returned `BLOCKED:`, supply the requested fact and resume via
  `task_id`. This is the "key fact missing" case, not a second round.

Default is one round. No open debate loops.
