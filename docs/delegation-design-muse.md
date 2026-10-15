# Opencode Delegation Design — Conclusions & Proposal

## 1. Conclusion

Delegate selectively, not liberally.

Default: main agent does the work. Subagents only for isolation, parallelism, or verification.

Liberal delegation increases tokens 3-15x, adds latency, and causes coordination loss. It only pays off for breadth-first, independent, read-heavy work.

Sources: Anthropic multi-agent research 2025 (90.2% internal research-eval gain for multi-agent over single-agent; ~15x tokens vs chat), Anthropic When to use multi-agent 2026 (decompose by context), Claude Code subagent docs, Opencode agents docs (https://opencode.ai/docs/agents/). [The "51.9%" figure in an earlier draft is not present in the cited source; dropped. Verify any number before it becomes doctrine.]

## 2. Justification

Pros:
- Context isolation: child burns its own window, parent keeps 1-2k summary. Delays compaction.
- Parallel speedup: N independent explores in one message cost max() not sum().
- Safety: read-only / cheap-model / specialized prompts limit blast radius.
- Independent signal: 2-3 diverse models catch blind spots.

Cons:
- Token blowup: each child re-pays context + brief + summary.
- Handoff loss: child starts fresh, no parent history. Vague brief = wrong work. Most common failure.
- Coordination failure: parallel writers conflict, duplicate work, merge conflicts.
- Error propagation: verbatim-applied hallucinations ship bugs.
- Config overhead: permission.task, task_budget, level_limit, mode. Opencode hard-fails on bad config.

Rule from research: decompose by context boundary, not by work type. Keep feature+tests together. Split only when contexts truly isolate.

## 3. Proposed Design

### 3.1 Policy for AGENTS.md

```
Main agent implements. Subagents advise/review/explore. Never apply output verbatim.

DELEGATE only when:
- 3+ independent tasks with no shared files, OR
- verbose output >1000 tokens you won't reuse, OR
- need read-only / cheap-model isolation, OR
- explicit verification checkpoint.

DO DIRECTLY when: 1-3 files, sequential edits, context loaded, tight user loop, writes.

Task prompt must have: adversarial role, compressed excerpts+constraints, lettered checklist, triageable format ([SEVERE/HIGH/MED/LOW] file:line — issue — fix).

Reviewers always fresh. Advisors resume via task_id, one round. Resolve by execution, never vote.
```

### 3.2 Opencode config

- `build`: mode primary, full tools, orchestrator.
- `plan`: mode primary, edit deny, bash ask.
- `explore`: mode subagent, read-only, cheap model. Default for search.
- `general`: mode subagent, full tools except todo. Exception only, scoped.
- `reviewer`: mode subagent, read-only, temp 0.0-0.2.

`opencode.json` guardrail:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "mode": "primary",
      "permission": {
        "task": { "*": "deny", "explore": "allow", "reviewer": "allow", "general": "ask" }
      }
    }
  }
}
```

V2 note: action is `subagent`, use `steps` not `maxSteps`. Validate against https://opencode.ai/config.json. Restart opencode after change.

### 3.3 Workflow

1. Debate design (advisor, 1 round) before code.
2. Review plan before implementation (cheapest catch point).
3. Implement in primary.
4. Parallel independent review (2-3 diverse, fresh).
5. Validate triage, emphasis on dismissals.
6. Verify by execution. Narrow re-check of diff only.

Parallel only with no file overlap. Sequential when B needs A. Background for non-blocking research.
