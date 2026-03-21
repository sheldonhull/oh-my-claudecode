# Phase 1: Install CLAUDE.md

## Upfront Configuration Gathering

Gather ALL setup choices in a single prompt before doing any work. This avoids piecemeal interruptions.

Use AskUserQuestion with a multiselect-style prompt:

**Question:** "Which setup components would you like to configure? (defaults shown)"

**Options:**
1. **Inject OMC directions into CLAUDE.md (recommended)** — Injects OMC instructions between `<!-- OMC:START -->` / `<!-- OMC:END -->` markers. Your other content is preserved. [DEFAULT: YES]
2. **Configure HUD statusline** — Sets up the status bar display. Requires restart after. [DEFAULT: NO]
3. **Configure MCP servers** — Adds external tool integrations (web search, GitHub, etc.). Run `/mcp-setup` separately anytime. [DEFAULT: NO]
4. **Enable agent teams** — Experimental feature for coordinated multi-agent execution. [DEFAULT: NO]
5. **Cancel** — Exit without changes

If user selects Cancel, **STOP HERE**. Do not continue to any other phase.

Store the user's choices for later phases:
- `SETUP_INJECT_CLAUDE_MD` = true/false (option 1)
- `SETUP_HUD` = true/false (option 2)
- `SETUP_MCP` = true/false (option 3)
- `SETUP_TEAMS` = true/false (option 4)

**Note:** Since AskUserQuestion only supports single-select, present each non-default option individually only if the user didn't choose the defaults-only option. Ask a follow-up: "Would you like to also enable any of these optional features?" with options for HUD, MCP, Teams, or "No, just inject directions".

## Determine Configuration Target

If `--local` flag was passed, set `CONFIG_TARGET=local`.
If `--global` flag was passed, set `CONFIG_TARGET=global`.

Otherwise, use AskUserQuestion to prompt:

**Question:** "Where should I configure oh-my-claudecode?"

**Options:**
1. **Local (this project)** - Creates `.claude/CLAUDE.md` in current project directory. Best for project-specific configurations.
2. **Global (all projects)** - Creates `~/.claude/CLAUDE.md` for all Claude Code sessions. Best for consistent behavior everywhere.

Set `CONFIG_TARGET` to `local` or `global` based on user's choice.

## Skip if not selected

If `SETUP_INJECT_CLAUDE_MD` is false, skip the install step and proceed to Phase 2.

## Install CLAUDE.md (Vendored)

Uses vendored local copy — no network, no curl. Do NOT use the Write tool.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/.vendored/install-claude-md.sh" <CONFIG_TARGET>
```

Replace `<CONFIG_TARGET>` with `local` or `global`.

The script must install the canonical `docs/CLAUDE.md` content and preserve the required
`<!-- OMC:START -->` / `<!-- OMC:END -->` markers. Do **not** hand-write, summarize, or
partially reconstruct CLAUDE.md.

After running the script, verify the target file contains both markers. If marker validation
fails, stop and report the failure instead of writing CLAUDE.md manually.

For `local` installs inside a git repository, the script also seeds `.git/info/exclude` with an OMC block that ignores local `.omc/*` artifacts by default while preserving `.omc/skills/` for version-controlled project skills.

**FALLBACK** if the vendored copy is missing or empty:
Tell user to run the `/harden` skill to refresh the vendored copy from `docs/CLAUDE.md`.

**Note**: The installed CLAUDE.md includes Context Persistence instructions with `<remember>` tags for surviving conversation compaction.

**Note**: If an existing CLAUDE.md is found, it will be backed up before installing the new version.

## Report Success

If `CONFIG_TARGET` is `local`:
```
OMC Project Configuration Complete
- CLAUDE.md: Updated with vendored OMC instructions at ./.claude/CLAUDE.md
- Git excludes: Added local `.omc/*` ignore rules to `.git/info/exclude` (keeps `.omc/skills/` trackable)
- Backup: Previous CLAUDE.md backed up (if existed)
- Scope: PROJECT - applies only to this project
- Hooks: Provided by plugin (no manual installation needed)
- Agents: 28+ available (base + tiered variants)
- Model routing: Haiku/Sonnet/Opus based on task complexity

Note: This configuration is project-specific and won't affect other projects or global settings.
```

If `CONFIG_TARGET` is `global`:
```
OMC Global Configuration Complete
- CLAUDE.md: Updated with vendored OMC instructions at ~/.claude/CLAUDE.md
- Backup: Previous CLAUDE.md backed up (if existed)
- Scope: GLOBAL - applies to all Claude Code sessions
- Hooks: Provided by plugin (no manual installation needed)
- Agents: 28+ available (base + tiered variants)
- Model routing: Haiku/Sonnet/Opus based on task complexity

Note: Hooks are now managed by the plugin system automatically. No manual hook installation required.
```

## Save Progress

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-progress.sh" save 2 <CONFIG_TARGET>
```

## Early Exit for Flag Mode

If `--local` or `--global` flag was used, clear state and **STOP HERE**:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-progress.sh" clear
```
Do not continue to Phase 2 or other phases.
