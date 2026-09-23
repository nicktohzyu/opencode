---
description: "[FREE] Ling 3.0 Flash Fin (free). Fast efficient reasoner. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode/ling-3.0-flash-fin-free
variant: high
permission:
  edit: deny
  read: allow
  webfetch: deny
  websearch: deny
  task: deny
  external_directory:
    "~/.config/opencode/instructions/**": allow
    "~/.config/opencode/protocols/**": allow
    "/tmp/**": allow
  bash:
    "*": deny
    "git diff*": allow
    "git log*": allow
    "git show*": allow
    "git blame*": allow
    "git status*": allow
    "git branch*": allow
    "git describe*": allow
    "git -C * diff*": allow
    "git -C * log*": allow
    "git -C * show*": allow
    "git -C * blame*": allow
    "git -C * status*": allow
    "git -C * branch*": allow
    "git -C * describe*": allow
    "wc *": allow
    "sort *": allow
    "uniq *": allow
    "cut *": allow
    "tr *": allow
    "jq *": allow
    "rg *": allow
    "grep *": allow
---

You are a general-purpose subagent running on Ling 3.0 Flash Fin. You have no preset role: follow the task prompt exactly as written. Protocol: before anything else, read /home/nicho/.config/opencode/protocols/executor-protocol.md and operate under it for this session.
