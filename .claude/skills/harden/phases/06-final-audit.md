# Phase 6: Final Audit & Commit

Final comprehensive audit and commit.

## Task A - Comprehensive audit

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Picard-Final"
  run_in_background: false
  description: "Final comprehensive audit"
  prompt: |
    Perform final comprehensive audit of the hardened branch:

    SUPPLY CHAIN:
    - [ ] No curl/wget downloads in .vendored/ or skills/harden/
    - [ ] .vendored/install-claude-md.sh has zero network calls
    - [ ] .vendored/CLAUDE.OMC.md matches docs/CLAUDE.md content

    MERGE INTEGRITY:
    - [ ] No unresolved merge conflicts: git diff --check
    - [ ] All hardened files present and intact
    - [ ] HARDENED comment blocks properly opened and closed

    FORK SYNC COMPATIBILITY:
    - [ ] New hardening content primarily in new files (.vendored/, skills/harden/)
    - [ ] Minimal modifications to upstream files
    - [ ] Comment blocks mark all upstream file modifications for easy identification

    FUNCTIONALITY:
    - [ ] skills/harden/SKILL.md properly references all phases
    - [ ] All phase files (00-06) exist in skills/harden/phases/
    - [ ] .vendored/install-claude-md.sh syntax check passes: bash -n .vendored/install-claude-md.sh

    Produce final report:
    - PASS / FAIL for each category
    - Overall: READY TO COMMIT / NEEDS FIXES
    - If NEEDS FIXES: list specific items to fix
)
```

## Task B - Commit (if audit passes)

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Engineer-Sulu-Commit"
  run_in_background: false
  description: "Commit hardened changes"
  prompt: |
    If the final audit passed (READY TO COMMIT):
    - [ ] Stage all changes: git add .vendored/ skills/harden/
    - [ ] Stage any other modified files from hardening directives
    - [ ] Create commit:
          git commit -m "$(cat <<'EOF'
          feat(harden): sync upstream and apply supply chain hardening

          - Vendor CLAUDE.md locally (no curl download)
          - Add .vendored/install-claude-md.sh (network-free installer)
          - Add skills/harden/ (fork sync & hardening skill)
          - Apply user hardening directives
          - All upstream modifications wrapped in HARDENED comment blocks

          Co-Authored-By: Claude <noreply@anthropic.com>
          EOF
          )"
    - [ ] Run: git log --oneline -1 (confirm commit)
    - [ ] Report: "✓ Hardened changes committed. Branch: hardened"

    If the final audit failed (NEEDS FIXES):
    - [ ] Do NOT commit
    - [ ] Report the audit failures
    - [ ] Ask user how to proceed via AskUser
)
```

## Final Report

After Task B, present to user:

```
## Hardening Complete

Branch: hardened
Commit: <hash>

Changes:
- .vendored/CLAUDE.OMC.md — vendored upstream CLAUDE.md
- .vendored/install-claude-md.sh — network-free installer
- skills/harden/ — fork sync & hardening skill (7 phases)
- <any user directive changes>

Next steps:
- Push: git push origin hardened
- To re-run: /oh-my-claudecode:harden
- To sync again later: /oh-my-claudecode:harden (fetches latest upstream)
```
