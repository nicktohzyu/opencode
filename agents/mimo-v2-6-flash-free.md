---
description: "[FREE] MiMo V2.6 Flash (free). Fast efficient reasoner. Generic executor — prompt with any role (advise, review, implement, audit)."
mode: subagent
model: opencode/mimo-v2.6-flash-free
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: read
    resource: "*"
    effect: allow
  - action: webfetch
    resource: "*"
    effect: deny
  - action: websearch
    resource: "*"
    effect: deny
  - action: subagent
    resource: "*"
    effect: deny
  - action: execute
    resource: "*"
    effect: deny
  - action: external_directory
    resource: "~/.config/opencode/protocols/**"
    effect: allow
  - action: external_directory
    resource: "/tmp/**"
    effect: allow
  - action: shell
    resource: "*"
    effect: deny
  - action: shell
    resource: "git diff*"
    effect: allow
  - action: shell
    resource: "git log*"
    effect: allow
  - action: shell
    resource: "git show*"
    effect: allow
  - action: shell
    resource: "git blame*"
    effect: allow
  - action: shell
    resource: "git status*"
    effect: allow
  - action: shell
    resource: "git branch*"
    effect: allow
  - action: shell
    resource: "git describe*"
    effect: allow
  - action: shell
    resource: "git -C * diff*"
    effect: allow
  - action: shell
    resource: "git -C * log*"
    effect: allow
  - action: shell
    resource: "git -C * show*"
    effect: allow
  - action: shell
    resource: "git -C * blame*"
    effect: allow
  - action: shell
    resource: "git -C * status*"
    effect: allow
  - action: shell
    resource: "git -C * branch*"
    effect: allow
  - action: shell
    resource: "git -C * describe*"
    effect: allow
  - action: shell
    resource: "wc *"
    effect: allow
  - action: shell
    resource: "sort *"
    effect: allow
  - action: shell
    resource: "uniq *"
    effect: allow
  - action: shell
    resource: "cut *"
    effect: allow
  - action: shell
    resource: "tr *"
    effect: allow
  - action: shell
    resource: "jq *"
    effect: allow
  - action: shell
    resource: "rg *"
    effect: allow
  - action: shell
    resource: "grep *"
    effect: allow
---

You are a general-purpose subagent running on MiMo V2.6 Flash. You have no preset role: follow the task prompt exactly as written. Protocol: before anything else, read /home/nicho/.config/opencode/protocols/executor-protocol.md and operate under it for this session.
