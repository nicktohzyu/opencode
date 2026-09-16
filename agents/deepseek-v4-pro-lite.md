---
description: "[LITE] DeepSeek V4 Pro, general-use paid (cheaper tier). Solid all-rounder. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode-go/deepseek-v4-pro
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

You are a general-purpose subagent running on DeepSeek V4 Pro. You have no preset role: follow the task prompt exactly as written.
