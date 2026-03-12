# Phase 1: Fetch & Analyze Upstream

Fetch latest upstream changes and produce an impact analysis before merging.

## Task A - Fetch upstream

```text
Task(
  subagent_type: "general-purpose"
  model: "haiku"
  name: "Engineer-Ripley-Fetch"
  run_in_background: false
  description: "Fetch upstream changes"
  prompt: |
    Fetch upstream and analyze divergence:
    - [ ] Run: git fetch upstream main
    - [ ] Run: git log --oneline hardened..upstream/main | head -50
    - [ ] Count commits behind: git rev-list --count hardened..upstream/main
    - [ ] Count commits ahead: git rev-list --count upstream/main..hardened
    - [ ] Report commit counts and latest 20 commit summaries
)
```

## Task B - Impact analysis

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Analyst-Cortana-Impact"
  run_in_background: false
  description: "Analyze upstream changes"
  prompt: |
    Produce a security-focused impact analysis of upstream changes:
    - [ ] Run: git diff --stat hardened..upstream/main
    - [ ] Identify files changed, insertions, deletions
    - [ ] Categorize changes by risk level:

    HIGH RISK (requires manual review):
    - [ ] scripts/*.sh — shell scripts can execute arbitrary commands
    - [ ] hooks/ — hooks run automatically, can intercept/modify behavior
    - [ ] .claude-plugin/ — plugin manifest controls what gets loaded
    - [ ] src/hooks/ — hook implementation changes
    - [ ] src/installer/ — installer can modify user's system
    - [ ] bridge/ — bridges execute as Node.js processes
    - [ ] Any new curl/wget/fetch calls (search with: git diff hardened..upstream/main | grep -E 'curl|wget|fetch\(')
    - [ ] Any new eval/exec calls (search with: git diff hardened..upstream/main | grep -E '\beval\b|\bexec\b')
    - [ ] package.json dependency changes (new deps = new supply chain surface)

    MEDIUM RISK (review recommended):
    - [ ] src/**/*.ts — core logic changes
    - [ ] skills/ — skill definitions affect agent behavior
    - [ ] agents/ — agent definitions affect delegation

    LOW RISK (informational):
    - [ ] docs/ — documentation only
    - [ ] README* — readme changes
    - [ ] tests — test changes

    - [ ] For each HIGH RISK file, show the actual diff excerpt (first 50 lines)
    - [ ] Flag any new network calls, file system writes outside project, or privilege escalations
    - [ ] Produce summary report with:
          - Total files changed
          - HIGH/MEDIUM/LOW counts
          - Top 5 most impactful changes
          - Recommendation: SAFE TO MERGE / REVIEW REQUIRED / BLOCK
)
```

## Audit - Phase 1 completion

```text
Task(
  subagent_type: "general-purpose"
  model: "sonnet"
  name: "Auditor-Spock-Phase1"
  run_in_background: false
  description: "Audit phase 1 analysis"
  prompt: |
    Audit the impact analysis:
    - [ ] Confirm Task A fetched upstream successfully
    - [ ] Confirm Task B produced a categorized risk analysis
    - [ ] Verify HIGH RISK items were identified with diff excerpts
    - [ ] If recommendation is BLOCK, present findings to user via AskUser and STOP
    - [ ] If recommendation is REVIEW REQUIRED, present HIGH RISK items to user via AskUser
          and ask for explicit approval before continuing
    - [ ] If recommendation is SAFE TO MERGE, report and proceed
    - [ ] Report: "✓ Phase 1 audit complete. Impact analysis reviewed."
)
```
