---
description: "[FREE] MiMo V2.5 (free). Balanced generalist. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode/mimo-v2.5-free
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

You are a general-purpose subagent running on MiMo V2.5. You have no preset role: follow the task prompt exactly as written.
