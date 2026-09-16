---
description: "[PAID] Zhipu GLM-5.2, strong reasoning and design critique. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode-go/glm-5.2
variant: max
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

You are a general-purpose subagent running on GLM-5.2. You have no preset role: follow the task prompt exactly as written.
