# Phase 2: Vendor CLAUDE.md

Update the vendored CLAUDE.md from upstream's docs/CLAUDE.md without using curl.

## Task A - Update vendored copy

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Engineer-Bishop-Vendor"
  run_in_background: false
  description: "Update vendored CLAUDE.md"
  prompt: |
    Update the vendored CLAUDE.OMC.md from upstream's docs/CLAUDE.md:
    - [ ] Extract upstream's docs/CLAUDE.md:
          git show upstream/main:docs/CLAUDE.md > /tmp/upstream-claude.md
    - [ ] Compute checksums:
          shasum -a 256 .vendored/CLAUDE.OMC.md (current)
          shasum -a 256 /tmp/upstream-claude.md (upstream)
    - [ ] If checksums match, report: "✓ Vendored CLAUDE.OMC.md is current. No update needed."
    - [ ] If checksums differ:
          - Show diff: diff -u .vendored/CLAUDE.OMC.md /tmp/upstream-claude.md | head -100
          - Copy upstream version: cp /tmp/upstream-claude.md .vendored/CLAUDE.OMC.md
          - Report: "Updated .vendored/CLAUDE.OMC.md from upstream. Diff shown above."
    - [ ] Clean up: rm -f /tmp/upstream-claude.md
)
```

## Task B - Verify vendored installer script

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Auditor-Ash-Installer"
  run_in_background: false
  description: "Verify install script"
  prompt: |
    Verify .vendored/install-claude-md.sh is correct:
    - [ ] Confirm the script exists and is executable (ls -la .vendored/install-claude-md.sh)
    - [ ] Confirm it does NOT contain curl, wget, or any network download commands:
          grep -n 'curl\|wget\|http\|https\|githubusercontent' .vendored/install-claude-md.sh
          (should return NO matches for download URLs — the raw.githubusercontent reference
          in comments is acceptable but active download calls are not)
    - [ ] Confirm it references .vendored/CLAUDE.OMC.md as source
    - [ ] Confirm it injects content directly via OMC markers (no @file references)
    - [ ] Run a dry-check: bash -n .vendored/install-claude-md.sh (syntax check only)
    - [ ] Report: "✓ Vendored installer verified. No network calls. Syntax valid."
)
```

## Audit - Phase 2 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase2"
  run_in_background: false
  description: "Audit phase 2 vendor"
  prompt: |
    Audit the vendoring phase:
    - [ ] Confirm .vendored/CLAUDE.OMC.md is updated or confirmed current
    - [ ] Confirm .vendored/install-claude-md.sh has no network calls
    - [ ] Confirm the installer adds the @import reference
    - [ ] Report: "✓ Phase 2 audit passed. CLAUDE.md vendored and installer verified."
)
```
