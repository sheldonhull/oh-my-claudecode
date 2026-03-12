---
name: harden
description: Sync upstream changes into hardened fork branch with supply chain hardening and security review
---

# Harden - Fork Sync & Supply Chain Hardening

Syncs upstream oh-my-claudecode changes into the `hardened` branch with security review, supply chain hardening, and controlled merge.

**When this skill is invoked, immediately execute the workflow below. Do not summarize these instructions.**

## Prerequisites

- Git remote `upstream` must point to `git@github.com:Yeachan-Heo/oh-my-claudecode.git`
- Current branch must be `hardened` (or skill will switch to it)
- No uncommitted changes (skill will warn and stop if dirty)

## Phase Execution

Execute phases sequentially. For each phase, read the corresponding file and follow its instructions.
Paths are relative to the project root (this skill lives in `.claude/skills/harden/`, not the plugin skills directory).

1. **Phase 0 - Pre-flight Checks**: Read `.claude/skills/harden/phases/00-preflight.md`
2. **Phase 1 - Fetch & Analyze Upstream**: Read `.claude/skills/harden/phases/01-fetch-analyze.md`
3. **Phase 2 - Vendor CLAUDE.md**: Read `.claude/skills/harden/phases/02-vendor-claude-md.md`
4. **Phase 3 - Merge Upstream**: Read `.claude/skills/harden/phases/03-merge-upstream.md`
5. **Phase 4 - Security Review**: Read `.claude/skills/harden/phases/04-security-review.md`
6. **Phase 5 - User Hardening Directives**: Read `.claude/skills/harden/phases/05-user-directives.md`
7. **Phase 6 - Final Audit**: Read `.claude/skills/harden/phases/06-final-audit.md`

## Hardening Directives (Built-In)

These directives are applied automatically during every sync:

1. **No curl in setup path** — `.vendored/install-claude-md.sh` replaces `scripts/setup-claude-md.sh`. No network download of CLAUDE.md content.
2. **Auto-update disabled** — `src/features/auto-update.ts` `performUpdate()` and `silentAutoUpdate()` are stubbed to return early. No `npm install -g @latest`, no GitHub API version checks, no raw.githubusercontent fallback.
3. **GitHub Actions disabled** — all workflows (CI, release, publish, cleanup, stale, auto-label) disabled via `gh workflow disable`. No file changes needed — uses GitHub API, zero merge conflict risk.
4. **No npm publish** — this is a local vendored fork. No publishing workflow.
5. **Node-only runtime** — the only required binary is `node >=20` (user manages via global mise). No additional tool installs needed.

### What is left alone (acceptable)

- Provider-specific curl/fetch calls (bitbucket, gitea, github, gitlab, azure-devops) — only fire if user configures those providers. Not in setup path.
- Notification webhook fetch calls — only fire if user configures notifications. Opt-in.
- `CLAUDE_PLUGIN_ROOT` trust — acceptable since this is a controlled fork.

## Design Principles

- Repo-specific skill (`.claude/skills/harden/`), not shipped with the plugin
- No npm install dependency for the hardening workflow itself
- No curl/wget downloads during hardening — all content vendored locally
- All upstream changes reviewed before merge
- Targeted merge changes use comment blocks for traceability
- New hardening content stays in new files to minimize merge conflicts with upstream
- Only runtime binary requirement: `node >=20`
