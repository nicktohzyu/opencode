# Context-Offload Cue: Gap, Review, and Fix

> Decision record for commits `5ccf7d0`, `b4bd417`, and `6d079b9` in
> `~/.config/opencode`. Not an instruction file — loose `.md` files in the
> config root are scanned by nothing, so this is safe to keep as an audit trail.

Date: 2026-10-15
Primary: `deepseek-v4.1-flash-free` · Review partner: `muse-spark-1-3-contributor-free` (one adversarial session, static reasoning)

---

## 1. Research basis (why the rule exists)

Raw tool output is the biggest consumer of an agent's context, and context is
re-sent every turn and degrades as it grows. Sources as surfaced by search
during the session — attributed, not independently re-verified:

- **Anthropic, *Effective context engineering for AI agents*** — sub-agents
  "explore extensively, using tens of thousands of tokens or more, but return
  only a condensed, distilled summary"; the goal is "the smallest set of
  high-signal tokens".
- **Anthropic, *How we built our multi-agent research system*** — "the essence
  of search is compression"; subagents operate in their own context windows and
  return condensed summaries; multi-agent fan-out costs roughly **15× the
  tokens** of a chat. (Figure is Anthropic's own; not independently measured
  here — do not cite it as local data.)
- **Chroma, *context rot*** (18 models, July 2025) — measured degradation as
  input length grows with task difficulty held constant; the effective window
  sits well below the advertised one.
- **LangChain, *Context engineering for agents*** — four levers: write,
  select, compress, **isolate**; multi-agent is the canonical isolation lever.
- **Cognition, *Don't Build Multi-Agents*** and its follow-up — parallel agents
  make conflicting implicit decisions (the Flappy Bird example); writes should
  stay single-threaded and extra agents "contribute intelligence rather than
  actions". This is the boundary the rule encodes: **offload facts, not
  judgment.**

## 2. The gap

The rule (commit `5ccf7d0`) was added inside the `orchestrator-playbook`
skill, which loads only when its description matches the task — i.e. only once
the agent is *already* in delegation-framing. If the primary runs a full test
suite or a wide grep directly, delegation is never considered, the skill never
loads, and the rule is never seen.

1. The rule sat downstream of the decision it was meant to inform.
2. The skill's triggers were delegation words only — no noisy-output cue, so
   auto-load could not fire on the situation the rule exists for.
3. The global `AGENTS.md` section a reader scans for "how should I handle tool
   output" (`## Parallelism`) framed batching purely as cost/latency and said
   nothing about context quality.

## 3. Proposal reviewed (as drafted, before revision)

- **A.** Append to `## Parallelism`: *"Tool output is a context cost as well as
  a latency cost: when a call will produce large, low-density output (full test
  suites, log sweeps, wide greps), offload it to a subagent — or filter it
  first — so the raw text never enters the transcript (see the
  `orchestrator-playbook` context-offload rule)."*
- **B.** Playbook description triggers: append `large/noisy tool output,
  context offload`.
- **C.** *(optional)* a clause in `## Delegation`.

Round-0 order: the draft was written before the review was requested, so the
reviewer attacked a fixed target rather than co-authoring it.

## 4. Review findings (muse, verbatim objections)

- **[SEVERE] `## Parallelism` single-call leak** — the section's gate sentence
  is *"When performing multiple independent tool calls…"*, so a reader about to
  run one big `npm test` never pattern-matches the section. A is buried under a
  multi-call frame; the most common noise is a single call.
- **[SEVERE] Trigger words unmatchable** — *"large/noisy tool output, context
  offload"* is meta-jargon no task literally contains. Tasks contain "run the
  test suite", "check the logs", "grep the codebase". Proposed a literal list.
- **[HIGH] Emergent-noise leak** — when noise arises mid-task from the agent's
  own plan ("fix bug X"), no description matcher on the initial task text can
  fire; only the global cue can catch it, and A carried no threshold test.
- **[HIGH] Contradiction / pre-decision** — A ordered "offload it to a subagent
  — or filter it first" while `## Delegation` orders *"Whether delegation pays
  is the skill's decision, not this file's. Do not pre-decide yet."* A
  pre-decides the call the cited skill owns.
- **[HIGH] Missing do-not-offload guard** — A reproduced the spawn instruction
  but dropped the load-bearing guard *"Never offload what you must reason over
  raw"* — a reader following only A would offload the failing trace they need
  to reason over to write the fix.
- **[MED] Spawn-first ordering on a flaky roster** — listing the expensive,
  unreliable path first invites spawns for noise that `head`/`grep -c` would
  have solved in-transcript.
- **[MED] Placement** — one line in one section is not enough; the cue is
  needed at two moments: tool-output time and skill-load time. C must be
  mandatory.
- **[MED] Missing executor-side cap** — the cap lived only in the
  orchestrator-side skill the child never loads, so a brief that forgot it got
  a full log dump back. Not scope creep.
- **[LOW] Absolute promise** — "so the raw text never enters the transcript" is
  false (the distilled summary does) and invites gaming the rule.

## 5. Dispositions (primary)

| Finding | Disposition |
|---|---|
| SEVERE single-call leak | **Accepted** — cue became its own paragraph with a pre-call test |
| SEVERE unmatchable triggers | **Accepted, trimmed** — literal task words kept, list shortened |
| HIGH emergent-noise leak | **Accepted** — threshold test ("more than you can read in full") |
| HIGH contradiction / pre-decision | **Accepted** — filter-first, then load the skill |
| HIGH missing guard | **Accepted** — guard sentence restored verbatim in spirit |
| MED spawn-first ordering | **Accepted** — reversed by the same rework |
| MED placement | **Accepted** — Parallelism cue + `## Delegation` role-list clause |
| MED executor-side cap | **Accepted** — `protocols/executor-protocol.md` rule 5 |
| LOW absolute promise | **Accepted** — scoped to "rather than running it straight into the transcript" |
| Slash-command / review-brief rewrites | **Declined** — the reviewer itself classed them scope creep |

## 6. What shipped

- **`5ccf7d0`** — `orchestrator-playbook`: the "Context offload" rule itself
  (rationale + four disciplines: cap the return, raw lives in the child, filter
  before spawning, never offload what you must reason over raw).
- **`b4bd417`** — *"instruction: cue context offload where the decision is
  made"* — `AGENTS.md ## Parallelism` gains the standalone pre-call paragraph;
  `## Delegation` gains "noisy-output offload" to the role list; the playbook
  description gains literal triggers (`test suite, test output, build output,
  logs, log sweep, wide grep, codebase-wide search, large tool output, context
  offload`).
- **`6d079b9`** — *"protocol: executors cap their return"* —
  `executor-protocol.md` rule 5: distilled findings with `file:line`, never raw
  output; name withheld detail and offer the slice.

Live reload was observed: the harness re-delivered the updated `AGENTS.md` diff
and the new skill description into the editing session itself.

## 7. Open item (falsifiable)

Trigger auto-load is **behaviorally unverified**. If a noisy task appears and
the playbook does *not* surface, the description-matching cue has failed and the
primary-side cue must move to text the model always reads (`AGENTS.md` already
is that; the skill description is not).
