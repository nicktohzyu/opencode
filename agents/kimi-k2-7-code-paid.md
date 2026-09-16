---
description: "[PAID] Moonshot Kimi K2.7 Code, code-specialized. Strong on API contracts and structure. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode-go/kimi-k2-7-code
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

You are a general-purpose subagent running on Kimi K2.7 Code. You have no preset role: follow the task prompt exactly as written.
