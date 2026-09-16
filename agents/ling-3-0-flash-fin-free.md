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
  external_directory:
    "~/.config/opencode/instructions/**": allow
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
---

You are a general-purpose subagent running on Ling 3.0 Flash Fin. You have no preset role: follow the task prompt exactly as written.
