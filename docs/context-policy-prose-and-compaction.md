# Prose preservation and the compaction checkpoint

**Date:** 2026-10-16 · **Commit:** `2911919` · **Takes effect on:** the next service reload

Two plugin options in `opencode.jsonc`, one policy:

| Option | Was | Now |
|---|---|---|
| `compressText` | `true` (default) | `false` |
| `compactionCheckpoint` | `true` | `false` |

**Policy: tool output is pruned, prose is preserved, thinking is untouched.**

## Why

Bloat ranks tools > thinking > user text. The pruner was already dropping tool
output correctly (135 tool results pruned, ~468k tokens saved against a 95k
target), but prose was *also* a compression target: text parts are units when
`compressText` is on (`index.js:771`), and it defaults to `true`
(`index.js:549`). Setting it false narrows the pruner's contract to "only tool
output is ever dropped". User text was already covered by
`protectUserMessages: true`.

## Thinking cannot be compressed — by design

- Reasoning is detected but only as a hazard. `partHasReasoning()`
  (`index.js:888`) matches `type: "reasoning"` / `"thinking"` and the legacy
  top-level fields; `hasReasoningContent()` (`index.js:923`) is consulted once,
  to refuse injecting a nudge into a reasoning turn (`index.js:3945-3948`).
- Span collapse cannot touch it either: a message collapses only if every part
  is already represented by a digest, pointer, or stub, and any unrecognized
  part type sets `ok = false` — "unknown part type: never dropped blind"
  (`index.js:2143-2165`).
- The reason is provider safety (`index.js:916-919`): strict providers do a
  `reasoning_content` round-trip, and *"thinking is enabled but reasoning_content
  is missing"* makes them reject the next request and kill the session. A safe
  version would have to summarize the reasoning **in place, keeping the part** —
  which the plugin has no option for.

Reasoning is not a rounding error: this session
(`ses_ec05d9c59ffdPNHy0fZEvRLibN`, `deepseek-v4.1-flash-free#high`) shows input
1,704,988 · output 58,189 · **reasoning 261,498**.

## Why native compaction becomes the valve

With prose ineligible for pruning, prose only accumulates; when the conversation
*alone* outgrows the budget, compaction is the last lever. The checkpoint made
compaction's summary a deterministic digest — Goal = the last 3 user messages,
Progress = the last 3 assistant messages (400 chars each), plus files touched
and recent errors. Native compaction writes the summary with the session model,
structured for handoff (objective, decisions, blockers, next moves, files) and
cumulative across compactions. Against the policy above, the second preserves
the arc of the prose; the first reduced older history to three messages per
role. Cost: one session-model call at the moment context is fullest. Compaction
is rare here — 3 in 152 compiled requests.

## Unchanged

- `retryOnOverflow` is a separate hook and still recovers from context-limit
  rejections.
- Window, budget, and targets (200000 / 111808 / 95036) untouched, as requested.
- `protectUserMessages: true` retained.

## Alternatives considered

`opencode-dcp` (MIT) and `@tarquinen/opencode-dcp` (AGPL-3.0) are sibling
implementations of the same idea. Neither compresses thinking: the latter's
`lib/messages/reasoning-strip.ts` drops stale provider *metadata* on assistant
parts after a model switch (`stripStaleMetadata`) and explicitly preserves part
content. Both compress prose into summaries by default, which is the opposite of
this policy, so adopting either would regress it. Their real increments are a
TUI panel/footer with slash commands, and model-chosen (task-boundary)
compression where this plugin uses a deterministic epoch scheduler.

## Residual uncertainty

Whether deepseek re-sends reasoning in the outgoing request is unconfirmed. If
the provider strips it between turns, thinking is not per-turn bloat and this
thread is moot — but the plugin's guard implies the round-trip is real for at
least some providers.

## Verified

`python3` JSONC parse (comment lines stripped) asserting `compressText is False`,
`compactionCheckpoint is False`, `protectUserMessages is True`, run before the
commit.
