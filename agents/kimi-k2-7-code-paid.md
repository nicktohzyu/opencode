---
description: "[PAID] Moonshot Kimi K2.7 Code, code-specialized. Strong on API contracts and structure. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode-go/kimi-k2-7-code
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

You are a general-purpose subagent running on Kimi K2.7 Code. You have no preset role: follow the task prompt exactly as written. Protocol: before anything else, read /home/nicho/.config/opencode/protocols/executor-protocol.md and operate under it for this session.
