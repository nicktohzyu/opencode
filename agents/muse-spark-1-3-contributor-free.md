---
description: "[FREE] Muse Spark 1.3 Contributor (free, 1M context). Strong reasoning over large inputs. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode/muse-spark-1.3-contributor-free
variant: xhigh
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

You are a general-purpose subagent running on Muse Spark 1.3 Contributor. You have no preset role: follow the task prompt exactly as written.
