# Delegation Policy: Conclusions, Justifications, Proposed Design

> Research summary for the primary agent's subagent-delegation policy.
> Not an instruction file (not listed in `opencode.jsonc > instructions`, so it
> is never injected into system context). Loose `.md` files in the config root
> are scanned by nothing — safe to keep here as a decision record.

---

## 1. The question

How liberally should the primary agent delegate to subagents, given a roster of
generic read-only executors? What are the pros and cons, and what is the
best-practice policy?

## 2. Method

Position written down *before* consulting anyone, then attacked by four
**fresh, independent** adviser sessions across different model families
(Big Pickle, Nemotron-3-Ultra, Muse-Spark-1.3, Ling-3.0-Flash), each given the
same adversarial brief and explicitly told to disagree. Factual claims made by
advisers were then checked against the opencode docs and the local config
files rather than trusted. Docs consulted: `/docs/agents/`, `/docs/skills/`.

**Starting position (rejected):** *delegate liberally for read-only breadth —
research, exploration, review, second opinions — and conservatively for
writes; the primary owns the diff and the final decision.*

All four advisers converged on the same objection, from different angles.
That convergence was treated as a real signal, not as verification
(correlation is not confirmation — playbook rule 4).

## 3. Conclusion

**Selective, not liberal. The read/write axis is the wrong axis;
verification cost is the right axis.**

> Delegate iff the output reduces to evidence the primary can spot-check in
> seconds — i.e. **verify-cost < redo-cost**. — Big Pickle

The read-only executor design *inverts* the classic safety case for liberal
delegation. Normally you delegate freely because an executor can test its own
output. Here the **producer cannot verify and the verifier (the primary)
cannot delegate**, so finding and ground-truth check are split across two
agents (Nemotron). "Research and exploration" — the category the rejected
position liberalized most — is precisely where the roster is weakest.

## 4. Justifications

### 4.1 The roster cannot ground its own claims

Every executor is `edit: deny`, with `bash` allowlisted to read-only text
tools and git read-only subcommands, and `webfetch`/`websearch` denied.
Consequences the advisers surfaced:

- **No execution** → causal claims (dead code, unused dependency, "this
  library is maintained") are ungrounded inference, not evidence.
- **No network** → library/API details are recalled from training cutoff.
  Muse-Spark's cost inversion: *free models hallucinate most exactly where
  they are used most; the free tier costs the most in verification.*
- **Citation formatting is not verification** — read-only executors
  extrapolate stale callers, phantom APIs, and wrong line numbers, "wrapped
  in citation formatting that looks verified" (Muse-Spark).

### 4.2 This contradicts the playbook's own rule 4

`subagent-playbook` prescribes both:

- rule 4 — *"Ground truth is executable, not consensual"*, and
- rule 6 — *"Keep executor permissions read-only"*, with the warning that
  *"write access without execution access can corrupt but cannot
  self-verify."*

The current roster sits in exactly that unverifiable middle: **read without
execution**. It cannot corrupt, but it also cannot self-verify. Every
delegated research task therefore ships an unpayable verification debt to the
primary.

### 4.3 The real cost is primary attention, not API spend

Tiers are cost, not capability, and the `-free` tier costs nothing in dollars.
But every delegated task returns as tokens the primary must absorb, triage,
and re-verify. **The merge, not the launch, is the cost** (Big Pickle).
Liberal breadth subsidizes confident fiction at the expense of the scarcest
resource in the system: the primary's attention and context.

### 4.4 Continuity collapse is silent

Offloading exploration severs the primary's causal understanding. The primary
becomes a router stitching opaque summaries, losing the micro-decisions that
inform the final design (Nemotron). *"The mental model lives in the reading,
not the report"* (Muse-Spark) — owning a diff means nothing if the primary
cannot reconstruct *why* the diff exists (Ling).

### 4.5 Breadth/depth is usually a false choice

Research almost always births a deeper question mid-stream. A delegated
explorer hits the wall and stops; serial depth pushes through; the handoff
cost of re-prompting and re-grounding exceeds the savings (Ling). Parallel
breadth wins only for **disjoint, shallow** tasks.

### 4.6 Dissent retained against the advisers (selective ≠ minimal)

The round under-weighted one real win: **primary context is finite, and
compaction is lossy.** Offloading forty tool results for one spot-checkable
summary is a genuine gain even when the summary needs verification. The
verdict is *selective*, not *minimal*.

## 5. Pros and cons of liberal delegation, given this roster

| Pros | Cons |
|---|---|
| Context offload — one summary instead of forty tool results in main context | Verification tax — every finding re-derived or executed by the primary |
| Genuine wall-clock parallelism on disjoint unknowns | Context fragmentation — primary owns a diff it never understood |
| Cross-family diversity surfaces correlated blind spots | Cheap-model noise consumes primary attention on dismissal scrutiny |
| Keeps risky/irreversible work away from the acting agent | Read-only output *looks* verified but isn't — false confidence blocks the correct path |

## 6. Proposed design

### 6.1 The dial

Gate every delegation on **verify-cost < redo-cost**. Concretely:

| Delegate | Do not delegate |
|---|---|
| Mechanically-verifiable retrieval: find call sites, grep patterns, file locations | Design and architecture judgment ("is this sound?") |
| Disagreement generation (`adviser-chat`) — divergence is the product | Investigation that will birth a deeper question mid-stream |
| Parallel review (`review-orchestration`) on a diff | Anything where verifying equals redoing |
| Mapping 3+ independent unknowns with zero shared context | Implementation, commits, pushes, releases — already primary-only |

Sub-mode selection: **parallel breadth for divergence and mapping; serial
depth for convergence** (Nemotron).

### 6.2 Hard invariants (inflexible)

1. **Uncited claims are rejections, not findings.** Require `file:line` plus a
   verbatim quote.
2. **Never chain subagent output into another subagent** — it compounds
   ungrounded inference.
3. **Never delegate past the point where verifying equals redoing.**
4. **Treat every claim as hostile until re-executed** (Muse-Spark); re-run the
   read/grep before acting on it.
5. **Only the primary acts.** Executors observe and report; the primary owns
   the diff *and* the why.

### 6.3 Close the verifier gap (the one design change)

The roster has **no agent that can verify**, which is the root cause of 4.1
and 4.2. Add a `verifier` tier alongside the existing executors:

- `edit: deny` — cannot corrupt.
- `bash` allowlisted to execution-only commands: `*test*`, `*lint*`,
  `*typecheck*`, `ruff *`, `tsc *`, `go test*`, etc.
- No write access, no network.

This restores playbook rule 4 (ground truth is executable) *without*
introducing the write-corruption risk rule 6 warns about: **can't corrupt,
can self-execute ground truth.** The `bash` permission glob already supports
this shape — patterns are evaluated in order, last match wins, so a narrow
execution allowlist slots into the existing permission model without touching
other agents.

### 6.4 Primary stays the integrator

The primary's comparative advantage is **integration judgment**, not just diff
ownership (Nemotron). Delegation buys evidence and divergence; synthesis,
triage, and the final decision stay centralized.

## 7. Unresolved

**Hard policy vs soft defaults.** Muse-Spark argues soft defaults collapse to
liberal under time pressure and wants a hard policy with a checklist gate;
Big Pickle argues delegation is cheap and reversible, so policy overhead is
unearned, and prefers soft defaults plus the two invariants. Resolution
adopted here: **soft defaults everywhere except invariants 6.2.1–6.2.3**, which
are hard. Worth revisiting after the verifier tier exists.

## 8. Provenance

Adviser positions (raw, before synthesis) — all four rejected the starting
position:

- **Big Pickle** — verification cost is the real axis; the merge, not the
  launch, is the cost. Risk of its own recommendation: tighter evidence
  requirements re-bottleneck the primary.
- **Nemotron-3-Ultra** — selective not liberal; primary's edge is integration
  judgment. Parallel for divergence, serial for convergence. Safest
  delegation targets are disagreement and review orchestration, *not*
  exploration.
- **Muse-Spark-1.3** — default to primary-only; 3+ disjoint unknowns
  threshold; hard policy, because soft defaults collapse under pressure.
  Surprise: read-only is anti-safety; free tier costs most in verification.
- **Ling-3.0-Flash** — breadth/depth threshold is a fiction for research;
  handoff cost exceeds savings. Most dangerous when the executor is
  *right-but-unverified*: false confidence blocks the correct path.
