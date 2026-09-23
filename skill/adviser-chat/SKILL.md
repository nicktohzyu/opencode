---
name: adviser-chat
description: Use when you need a cheap second opinion, plan critique, or methodology check from a different model family via generic executor subagents. Covers model-agnostic adviser selection, single-round parallel workflow, and synthesis.
---

# Adviser Chat

Get a second perspective from a fresh executor subagent with a different model family. Single round by default.

## When to use

- Architecture decision with multiple credible paths, plan critique, methodology or data-analysis check, explicit tradeoff surfacing.
- User asks for dissent or second opinions, or anchoring is a risk.

Do not use for pure implementation work, single-file edits, or when the primary context already has enough evidence.

## Selection (model-agnostic)

- Pick a small, diverse set of executor subagents whose model family differs from the primary (free tier first; escalate to lite/paid only if high-stakes or the first pass surfaces real issues). Any `*-free`/`*-lite`/`*-paid` executor works since its role is dynamically specified by your prompt.
- Prefer diverse families over similar ones. Never spawn every available chat agent.
- Subagents are terminal executors and cannot delegate further.

## Workflow

1. **Architect position first:** write down your initial position, 3 strongest reasons, and the main risk in your preferred path — before reading advisers.
2. **Gather compact context only:** decision question, constraints, success criteria, and minimal snippets/metrics. Never feed the full conversation transcript.
3. **Launch in parallel:** one Task call per `subagent_type` in a single message. Require a structured response:
   - Position — 1-2 sentences
   - Reasoning — 3 concise bullets
   - Risk — biggest risk in your recommendation
   - Surprise — one thing others may miss

   Keep it under 300 words. Be direct, no hedging.
4. **Synthesize with guardrails:** do not dismiss a view without explaining why; if a voice changed your recommendation say so; always include the strongest dissent even if rejected; if two voices align against your initial position treat it as a real signal. Keep raw positions visible before the verdict.

## Iterate only when

- Result was empty/truncated (thinking-budget abort): resume via `task_id` (fresh budget), then one fresh retry max, else proceed without it and note the gap.
- A key fact was missing, or you changed code based on the verdict and need a re-check.
- If the adviser returned `BLOCKED:`, supply the requested fact and resume via
  `task_id`. This is the "key fact missing" case, not a second round.

Default is one round. No open debate loops.
