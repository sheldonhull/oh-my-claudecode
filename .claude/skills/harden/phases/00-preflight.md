# Phase 0: Pre-flight Checks

Validate environment and state before proceeding.

## Task A - Verify git state

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Engineer-Scotty-Preflight"
  run_in_background: false
  description: "Verify git state"
  prompt: |
    Verify the repository is ready for hardening:
    - [ ] Run: git status --porcelain
    - [ ] If output is non-empty, STOP and report:
          "⚠️  Working tree is dirty. Commit or stash changes before running /harden."
    - [ ] Run: git remote get-url upstream
    - [ ] Verify it contains "Yeachan-Heo/oh-my-claudecode"
    - [ ] If upstream remote missing, STOP and report:
          "⚠️  No upstream remote. Add it:
           git remote add upstream git@github.com:Yeachan-Heo/oh-my-claudecode.git"
    - [ ] Run: git branch --show-current
    - [ ] If not on 'hardened', run: git checkout hardened
    - [ ] If 'hardened' branch doesn't exist, STOP and report:
          "⚠️  Branch 'hardened' not found. Create it:
           git checkout -b hardened main"
    - [ ] Report: "✓ Pre-flight passed. On branch: hardened. Upstream configured."
)
```

## Task B - Verify no npm dependency needed

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Auditor-Data-NoDeps"
  run_in_background: false
  description: "Verify no npm needed"
  prompt: |
    Confirm the harden workflow has no npm dependencies:
    - [ ] Verify .vendored/install-claude-md.sh exists and is executable
    - [ ] Verify .vendored/CLAUDE.OMC.md exists and is non-empty
    - [ ] Verify .claude/skills/harden/SKILL.md exists
    - [ ] Verify node is available: node --version (must be >=20)
    - [ ] Confirm: no package.json scripts are required for the harden workflow
    - [ ] Report: "✓ Harden workflow is self-contained. No npm install required."
)
```

## Audit - Phase 0 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase0"
  run_in_background: false
  description: "Audit phase 0 results"
  prompt: |
    Audit the pre-flight phase results:
    - [ ] Confirm Task A reported success (on hardened branch, upstream configured)
    - [ ] Confirm Task B reported success (no npm dependency)
    - [ ] If either failed, report the failure and STOP — do not proceed to Phase 1
    - [ ] Report: "✓ Phase 0 audit passed. Proceed to Phase 1."
)
```
