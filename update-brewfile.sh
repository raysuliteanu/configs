#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

COMMON="$SCRIPT_DIR/Brewfile.common"
OS_FILE="$SCRIPT_DIR/Brewfile.$OS"

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "Dumping installed packages..."
brew bundle dump --force --describe --no-vscode --file="$TMPFILE"

# Extract full entry for a name (preserves preceding description comment)
full_entry_for_name() {
    local name="$1" file="$2"
    awk -v name="$name" '
        /^(brew|tap|cargo|go) / && index($0, "\"" name "\"") {
            if (pending ~ /^#/) print pending
            print
            pending = ""
            next
        }
        /^#/ { pending = $0; next }
        { pending = "" }
    ' "$file"
}

# Collect all brew formula names
mapfile -t brew_names < <(grep -E '^brew ' "$TMPFILE" | sed 's/^brew "\([^"]*\)".*/\1/' | sort -u)

common_brews=()
os_brews=()

if [ "${#brew_names[@]}" -gt 0 ]; then
    echo "Querying Homebrew API for OS requirements..."
    if info_json=$(brew info --json=v2 "${brew_names[@]}" 2>/dev/null); then
        mapfile -t os_specific < <(echo "$info_json" \
            | jq -r '.formulae[] | select(.requirements | length > 0) | .name' 2>/dev/null || true)
        for name in "${brew_names[@]}"; do
            if printf '%s\n' "${os_specific[@]+"${os_specific[@]}"}" | grep -qx "$name"; then
                os_brews+=("$name")
            else
                common_brews+=("$name")
            fi
        done
    else
        echo "Warning: brew info API failed; placing all formulae in Brewfile.common"
        common_brews=("${brew_names[@]}")
    fi
fi

# Brewfile.common: taps + cross-platform brews + cargo + go
{
    grep -E '^tap ' "$TMPFILE" || true
    for name in "${common_brews[@]+"${common_brews[@]}"}"; do
        full_entry_for_name "$name" "$TMPFILE"
    done
    grep -E '^(cargo|go) ' "$TMPFILE" || true
} > "$COMMON"
echo "Wrote Brewfile.common (${#common_brews[@]} formulae)"

# Brewfile.<os>: OS-specific brews only
{
    for name in "${os_brews[@]+"${os_brews[@]}"}"; do
        full_entry_for_name "$name" "$TMPFILE"
    done
} > "$OS_FILE"
echo "Wrote Brewfile.$OS (${#os_brews[@]} formulae)"

echo "Done."
