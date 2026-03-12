# Phase 5: User Hardening Directives

Present findings and collect user's hardening directives.

## Task A - Summarize state

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Analyst-Oracle-Summary"
  run_in_background: false
  description: "Summarize for user review"
  prompt: |
    Compile a summary of all changes and findings for user review:

    - [ ] Gather from previous phases:
          - Commit count from upstream
          - Impact analysis (HIGH/MEDIUM/LOW file counts)
          - Security scan results (CRITICAL/WARNING/INFO counts)
          - Merge conflict resolution summary (if any)
          - Vendored CLAUDE.md status (updated or unchanged)

    - [ ] Format a concise summary report:

    ## Hardening Sync Summary

    **Upstream commits merged:** <N>
    **Files changed:** <N> (HIGH: <N>, MEDIUM: <N>, LOW: <N>)
    **Security findings:** CRITICAL: <N>, WARNING: <N>, INFO: <N>
    **Merge conflicts:** <N> (all resolved / manual needed)
    **Vendored CLAUDE.md:** updated / unchanged

    ### Built-In Hardening Applied
    - curl-based CLAUDE.md download replaced with vendored copy
    - .vendored/install-claude-md.sh replaces scripts/setup-claude-md.sh
    - CLAUDE.md includes `for: @~/.claude/CLAUDE.OMC.md` import reference
    - Auto-update disabled (performUpdate, silentAutoUpdate, fetchLatestRelease, backgroundUpdateCheck)
    - Only runtime binary: node >=20 (managed by user's global mise)

    ### Acceptable (Left Alone)
    - Provider-specific curl/fetch (bitbucket, gitea, github, gitlab, azure-devops) — opt-in only
    - Notification webhook fetch calls — opt-in only
    - CLAUDE_PLUGIN_ROOT trust — controlled fork

    ### Optional: Additional Hardening Directives
    Provide additional hardening rules if desired. Examples:
    - Pin dependency versions
    - Add integrity checks for hook scripts
    - Restrict file system write paths
    - Or "none" to proceed without additional changes

    - [ ] Present this summary to the user via AskUser
    - [ ] Collect the user's hardening directives (free-form text)
    - [ ] Report the directives back for Phase 5 Task B
)
```

## Task B - Apply user directives

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Engineer-Neo-Directives"
  run_in_background: false
  description: "Apply hardening directives"
  prompt: |
    Apply the user's hardening directives from Task A:

    For each directive:
    - [ ] Determine which files need modification
    - [ ] Prefer creating new files over modifying upstream files (reduces merge conflicts)
    - [ ] If modifying upstream files is necessary, wrap changes in comment blocks:
          <!-- HARDENED: <directive description> -->
          <changes>
          <!-- /HARDENED -->
    - [ ] For shell scripts, use:
          # HARDENED: <directive description>
          <changes>
          # /HARDENED
    - [ ] For TypeScript, use:
          // HARDENED: <directive description>
          <changes>
          // /HARDENED
    - [ ] Stage all changes: git add <modified files>
    - [ ] Report: list of files modified and what each directive changed
)
```

## Audit - Phase 5 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase5"
  run_in_background: false
  description: "Audit directive application"
  prompt: |
    Audit the user directive application:
    - [ ] Verify each user directive was addressed
    - [ ] Verify HARDENED comment blocks wrap all modifications to upstream files
    - [ ] Verify new files were preferred over upstream modifications where possible
    - [ ] Run: git diff --cached --stat (show what will be committed)
    - [ ] Report: "✓ Phase 5 audit passed. User directives applied."
)
```
