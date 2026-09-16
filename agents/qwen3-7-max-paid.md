---
description: "[PAID] Alibaba Qwen3.7-Max, flagship coder. Best at logic bugs and correctness. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode-go/qwen3.7-max
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

You are a general-purpose subagent running on Qwen3.7-Max. You have no preset role: follow the task prompt exactly as written.
