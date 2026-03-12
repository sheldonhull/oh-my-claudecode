# Phase 4: Security Review

Run security analysis on the merged state.

## Task A - Supply chain scan

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Engineer-Worf-SupplyChain"
  run_in_background: false
  description: "Supply chain security scan"
  prompt: |
    Scan for supply chain risks in the merged codebase:

    NETWORK CALLS:
    - [ ] Search all scripts for curl/wget/fetch:
          grep -rn 'curl\|wget' scripts/ .vendored/ .claude/skills/harden/
    - [ ] Search TypeScript/JavaScript for fetch/http calls:
          grep -rn 'fetch(\|http\.get\|https\.get\|axios\|request(' src/ bridge/
    - [ ] Flag any NEW network calls not present in the previous hardened commit

    DYNAMIC EXECUTION:
    - [ ] Search for eval/exec/Function() in scripts and source:
          grep -rn '\beval\b\|\bexec\b\|new Function' src/ scripts/ bridge/
    - [ ] Flag any that process user input or remote data

    DEPENDENCY CHANGES:
    - [ ] Check: git diff hardened~1..hardened -- package.json (if merge committed)
          or: git diff HEAD -- package.json (if uncommitted)
    - [ ] Flag new dependencies
    - [ ] For each new dependency, note: name, version, purpose, weekly downloads

    FILE SYSTEM ACCESS:
    - [ ] Search for writes outside project directory:
          grep -rn 'writeFile\|appendFile\|fs\.write\|> /' src/ scripts/
    - [ ] Flag any that write to $HOME, /etc, /usr, or other system paths

    HOOK INTEGRITY:
    - [ ] Compare hooks/hooks.json with upstream version
    - [ ] Flag any new hooks or changed hook commands
    - [ ] Verify all hook commands reference ${CLAUDE_PLUGIN_ROOT} (no hardcoded paths)

    Produce a security report with:
    - CRITICAL: Must fix before merge commit
    - WARNING: Should fix, can proceed with acknowledgment
    - INFO: Noted for awareness
)
```

## Task B - Disable auto-update

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Engineer-Ripley-KillUpdate"
  run_in_background: false
  description: "Disable auto-update system"
  prompt: |
    Disable the auto-update system in src/features/auto-update.ts.
    This is a hardened fork — updates come through the /harden skill (git merge), not npm.

    Apply these changes with HARDENED comment blocks:

    1. In performUpdate() (around line 520), add early return at top of function:
       // HARDENED: auto-update disabled in hardened fork — updates via /harden skill
       return {
         success: false,
         previousVersion: null,
         newVersion: 'disabled',
         message: 'Auto-update disabled in hardened fork. Use /harden skill to sync upstream.',
       };
       // /HARDENED

    2. In silentAutoUpdate() (around line 837), add early return at top of function body:
       // HARDENED: silent auto-update disabled in hardened fork
       return null;
       // /HARDENED

    3. In fetchLatestRelease() (around line 358), add early return at top:
       // HARDENED: no remote version checks in hardened fork
       throw new Error('Remote version checks disabled in hardened fork. Use /harden skill.');
       // /HARDENED

    4. In backgroundUpdateCheck() (around line 693), add early return at top:
       // HARDENED: background update checks disabled in hardened fork
       return;
       // /HARDENED

    - [ ] Apply all four changes
    - [ ] Verify the file still compiles: npx tsc --noEmit src/features/auto-update.ts
          (If tsc is not available, run: node -e "require('./src/features/auto-update.ts')" to syntax check,
          or just verify the HARDENED blocks are syntactically correct by inspection)
    - [ ] Report which functions were disabled and line numbers
)
```

## Task C - Hardened file integrity

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Validator-Tuvok-Integrity"
  run_in_background: false
  description: "Check hardened files"
  prompt: |
    Verify hardened-specific files are intact:
    - [ ] .vendored/CLAUDE.OMC.md — exists, matches docs/CLAUDE.md content
    - [ ] .vendored/install-claude-md.sh — exists, executable, no network calls
    - [ ] .claude/skills/harden/SKILL.md — exists, references all phases
    - [ ] .claude/skills/harden/phases/ — all phase files present (00 through 06)
    - [ ] Compute SHA-256 of each hardened file and report
    - [ ] Report: "✓ Hardened file integrity verified."
)
```

## Audit - Phase 4 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase4"
  run_in_background: false
  description: "Audit security review"
  prompt: |
    Audit the security review results:
    - [ ] Review Task A security report
    - [ ] If any CRITICAL findings: present to user via AskUser and STOP
    - [ ] If WARNING findings: present to user via AskUser, ask to proceed or fix
    - [ ] Confirm Task B disabled auto-update (4 functions stubbed)
    - [ ] Confirm Task C verified all hardened files
    - [ ] Report: "✓ Phase 4 audit passed. Security review complete."
)
```
