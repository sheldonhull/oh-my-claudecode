# Phase 3: Merge Upstream

Merge upstream/main into hardened branch with conflict handling.

## Task A - Perform merge

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Engineer-Chekov-Merge"
  run_in_background: false
  description: "Merge upstream changes"
  prompt: |
    Merge upstream/main into hardened branch:
    - [ ] Run: git merge upstream/main --no-edit
    - [ ] If merge succeeds cleanly:
          - Report: "✓ Merge completed cleanly. No conflicts."
    - [ ] If merge has conflicts:
          - Run: git diff --name-only --diff-filter=U (list conflicted files)
          - For each conflicted file, categorize:
            * .vendored/* — resolve by keeping OUR version (hardened overrides)
            * skills/harden/* — resolve by keeping OUR version (our skill)
            * scripts/setup-claude-md.sh — resolve by keeping THEIRS but noting
              we override it with .vendored/install-claude-md.sh
            * All other files — keep THEIRS (upstream) unless in hardening scope
          - Resolve conflicts per above rules
          - Run: git add <resolved files>
          - Do NOT commit yet — Phase 4 reviews first
          - Report: "Merge conflicts resolved. <N> files had conflicts. Review before commit."
    - [ ] If merge fails entirely:
          - Run: git merge --abort
          - Report: "⚠️ Merge failed. Aborted. Manual intervention required."
          - STOP
)
```

## Task B - Verify merge state

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Validator-Borg-MergeState"
  run_in_background: false
  description: "Verify merge state"
  prompt: |
    Verify the merge state is clean:
    - [ ] Run: git status
    - [ ] Confirm no unresolved conflicts (no "both modified" entries)
    - [ ] Confirm .vendored/CLAUDE.OMC.md is present and non-empty
    - [ ] Confirm .vendored/install-claude-md.sh is present and executable
    - [ ] Confirm skills/harden/SKILL.md is present
    - [ ] Report merge state summary
)
```

## Audit - Phase 3 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase3"
  run_in_background: false
  description: "Audit merge results"
  prompt: |
    Audit the merge:
    - [ ] Confirm Task A completed (clean merge or resolved conflicts)
    - [ ] Confirm Task B validated clean state
    - [ ] Confirm hardened-specific files survived the merge:
          .vendored/CLAUDE.OMC.md, .vendored/install-claude-md.sh, skills/harden/
    - [ ] If any hardened files were lost or overwritten, flag as CRITICAL
    - [ ] Report: "✓ Phase 3 audit passed. Merge state verified."
)
```
