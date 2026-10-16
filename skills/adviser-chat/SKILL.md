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

- Pick a small, diverse set of executor subagents whose model family differs from the primary (the roster is free-only). Any `*-free` executor works since its role is dynamically specified by your prompt.
- Default picks: deepseek, muse, or GLM (fast and reliable); add nemotron-3-ultra-free for a third independent opinion. space-bunny and mimo are capable but slower and flakier — pick them deliberately (see `agents/README`).
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
3. **Launch in parallel:** one subagent call per agent ID in a single message. Require a structured response:
   - Alternatives — up to 3 shapes including the proposal, honest tradeoffs each
   - Ranking — ordered, one-line reason per position
   - Blockers — anything you'd stop the design over, one sentence each
4. **Synthesize with guardrails:** do not dismiss a view without explaining why; if a voice changed your recommendation say so; always include the strongest dissent even if rejected; if two voices align against your initial position treat it as a real signal. Keep raw positions visible before the verdict.

## Iterate only when

- Result was empty/truncated (thinking-budget abort) or a provider-side request error (transient on free tiers — 403/429, upstream/server errors, odd gate messages): resume via the session ID (fresh budget), then one fresh retry max, else proceed without it and note the gap.
- A key fact was missing, or you changed code based on the verdict and need a re-check.
- If the adviser returned `BLOCKED:`, supply the requested fact and resume via
  its session ID. This is the "key fact missing" case, not a second round.

Default is one round. No open debate loops.

## Design partner (the bounded exception)

Design decisions are the one place multi-crossing dialogue earns its cost:
there is no answer key, the primary is the judge, and continuity — one
partner that remembers the phase — is the actual product. Still bounded:

- **One session per design phase.** Pick the partner once, resume it by
  session ID at milestones. Default: `glm-5-3-flash-free` (run crossings on
  `#max` when the decision is high-stakes) — swap to
  `muse-spark-1.3-contributor-free` or `deepseek-v4-1-flash-free` if GLM is
  unavailable, rate-limited, or slow. GLM's speed is unconfirmed: its first
  smoke-test spawn aborted under provider load on 2026-10-16.
- **Round 0 stays independent.** Both sides write positions before seeing
  each other's; diversity is real only before the first exchange.
- **Crossings are capped and structured.** Max 2 by default. Each side gets
  the other's last position verbatim plus new artifacts — diffs, docs, file
  paths (it can read the repo), not re-descriptions — and replies only with
  concessions, holdings backed by NEW evidence, and factual questions for
  verification. No new falsifiable claim = a pass; end there.
- **Hold under pressure.** Brief both sides to keep well-supported positions
  and adopt the other's answer only on new evidence — agreement is not
  verification.
- **Facts exit the dialogue.** Factual disputes go to execution (verifier),
  never to another round. The primary decides.
- **Reassess cheaply.** If the second crossing never changes the synthesis
  across a few decisions, make one crossing the cap.
