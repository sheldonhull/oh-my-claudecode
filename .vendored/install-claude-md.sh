#!/usr/bin/env bash
# install-claude-md.sh - Hardened CLAUDE.md installer (no curl, vendored copy)
# Usage: install-claude-md.sh <local|global>
#
# Replaces the upstream curl-based setup-claude-md.sh with a local vendored copy.
# Supply chain hardened: no network downloads, no remote content injection.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:?Usage: install-claude-md.sh <local|global>}"
VENDORED_SOURCE="${SCRIPT_DIR}/CLAUDE.OMC.md"

# Validate vendored source exists and is non-empty
if [ ! -s "$VENDORED_SOURCE" ]; then
  echo "ERROR: Vendored CLAUDE.OMC.md not found or empty at: $VENDORED_SOURCE" >&2
  echo "Run the harden skill to refresh the vendored copy from docs/CLAUDE.md" >&2
  exit 1
fi

# Determine target path
if [ "$MODE" = "local" ]; then
  mkdir -p .claude
  TARGET_PATH=".claude/CLAUDE.md"
elif [ "$MODE" = "global" ]; then
  TARGET_PATH="$HOME/.claude/CLAUDE.md"
else
  echo "ERROR: Invalid mode '$MODE'. Use 'local' or 'global'." >&2
  exit 1
fi

# Extract old version before install
OLD_VERSION=$(grep -m1 'OMC:VERSION:' "$TARGET_PATH" 2>/dev/null | sed -E 's/.*OMC:VERSION:([^ ]+).*/\1/' || true)
[ -z "$OLD_VERSION" ] && OLD_VERSION="none"

# Backup existing
if [ -f "$TARGET_PATH" ]; then
  BACKUP_DATE=$(date +%Y-%m-%d_%H%M%S)
  BACKUP_PATH="${TARGET_PATH}.backup.${BACKUP_DATE}"
  cp "$TARGET_PATH" "$BACKUP_PATH"
  echo "Backed up existing CLAUDE.md to $BACKUP_PATH"
fi

# Compute checksum of vendored source for audit trail
CHECKSUM=$(shasum -a 256 "$VENDORED_SOURCE" | cut -d' ' -f1)
echo "Vendored source checksum (SHA-256): $CHECKSUM"

# Use vendored copy (no curl, no network)
TEMP_OMC=$(mktemp "${TMPDIR:-/tmp}/omc-claude-XXXXXX.md")
trap 'rm -f "$TEMP_OMC"' EXIT
cp "$VENDORED_SOURCE" "$TEMP_OMC"

# Strip existing markers from content (idempotency)
if grep -q '<!-- OMC:START -->' "$TEMP_OMC"; then
  awk '/<!-- OMC:END -->/{p=0} p; /<!-- OMC:START -->/{p=1}' "$TEMP_OMC" > "${TEMP_OMC}.clean"
  mv "${TEMP_OMC}.clean" "$TEMP_OMC"
fi

if [ ! -f "$TARGET_PATH" ]; then
  # Fresh install: wrap in markers
  {
    echo '<!-- OMC:START -->'
    cat "$TEMP_OMC"
    echo '<!-- OMC:END -->'
  } > "$TARGET_PATH"
  echo "Installed CLAUDE.md (fresh, vendored)"
else
  # Merge: preserve user content outside OMC markers
  if grep -q '<!-- OMC:START -->' "$TARGET_PATH"; then
    perl -0pe 's/^<!-- OMC:START -->\R[\s\S]*?^<!-- OMC:END -->(?:\R)?//msg; s/^<!-- User customizations(?: \([^)]+\))? -->\R?//mg; s/\A(?:[ \t]*\R)+//; s/(?:\R[ \t]*)+\z//;' \
      "$TARGET_PATH" > "${TARGET_PATH}.preserved"

    # Strip any legacy @import references
    sed -i.bak '/^for: @.*CLAUDE\.OMC\.md/d' "${TARGET_PATH}.preserved"
    rm -f "${TARGET_PATH}.preserved.bak"

    PRESERVED_CONTENT=$(cat "${TARGET_PATH}.preserved")
    {
      echo '<!-- OMC:START -->'
      cat "$TEMP_OMC"
      echo '<!-- OMC:END -->'
      if printf '%s' "$PRESERVED_CONTENT" | grep -q '[^[:space:]]'; then
        echo ""
        echo "<!-- User customizations -->"
        printf '%s\n' "$PRESERVED_CONTENT"
      fi
    } > "${TARGET_PATH}.tmp"
    mv "${TARGET_PATH}.tmp" "$TARGET_PATH"
    rm -f "${TARGET_PATH}.preserved"
    echo "Updated OMC section (vendored, user customizations preserved)"
  else
    OLD_CONTENT=$(cat "$TARGET_PATH")
    {
      echo '<!-- OMC:START -->'
      cat "$TEMP_OMC"
      echo '<!-- OMC:END -->'
      echo ""
      echo "<!-- User customizations (migrated from previous CLAUDE.md) -->"
      printf '%s\n' "$OLD_CONTENT"
    } > "${TARGET_PATH}.tmp"
    mv "${TARGET_PATH}.tmp" "$TARGET_PATH"
    echo "Migrated existing CLAUDE.md (vendored, added OMC markers)"
  fi
fi

# Extract new version and report
NEW_VERSION=$(grep -m1 'OMC:VERSION:' "$TARGET_PATH" 2>/dev/null | sed -E 's/.*OMC:VERSION:([^ ]+).*/\1/' || true)
[ -z "$NEW_VERSION" ] && NEW_VERSION="unknown"

if [ "$OLD_VERSION" = "none" ]; then
  echo "Installed CLAUDE.md: $NEW_VERSION (vendored, no network)"
elif [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
  echo "CLAUDE.md unchanged: $NEW_VERSION"
else
  echo "Updated CLAUDE.md: $OLD_VERSION -> $NEW_VERSION (vendored, no network)"
fi

# Legacy hooks cleanup (global mode only)
if [ "$MODE" = "global" ]; then
  rm -f ~/.claude/hooks/keyword-detector.sh
  rm -f ~/.claude/hooks/stop-continuation.sh
  rm -f ~/.claude/hooks/persistent-mode.sh
  rm -f ~/.claude/hooks/session-start.sh
  echo "Legacy hooks cleaned"
fi
