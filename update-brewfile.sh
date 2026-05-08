#!/usr/bin/env bash

# Reconcile installed packages against Brewfile.common + Brewfile.<os>.
# Automatically adds new packages to the appropriate Brewfile and removes
# uninstalled ones. The other OS's Brewfile is never touched.
# Uses the Homebrew JSON API to categorize new brew formulae by OS requirement.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

COMMON="$SCRIPT_DIR/Brewfile.common"
OS_FILE="$SCRIPT_DIR/Brewfile.$OS"

# Extract quoted name from Brewfile lines: brew "foo", ... -> foo
names_from_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    grep -E '^(brew|tap|cargo|go) ' "$file" \
        | sed 's/^[^ ]* "\([^"]*\)".*/\1/' \
        | sort -u
}

# Extract the full entry for a name from a dump file (description comment + package line)
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

# Remove a package entry (and its preceding description comment) from a Brewfile
remove_from_file() {
    local name="$1" file="$2"
    [ -f "$file" ] || return 0
    local tmpf
    tmpf=$(mktemp)
    awk -v name="$name" '
        /^(brew|tap|cargo|go) / && index($0, "\"" name "\"") {
            pending = ""
            next
        }
        /^#/ {
            if (pending != "") print pending
            pending = $0
            next
        }
        {
            if (pending != "") print pending
            pending = ""
            print
        }
        END { if (pending != "") print pending }
    ' "$file" > "$tmpf"
    mv "$tmpf" "$file"
}

# Find which of the two active Brewfiles tracks a given package name
find_tracking_file() {
    local name="$1"
    local f
    for f in "$COMMON" "$OS_FILE"; do
        if grep -qE "^(brew|tap|cargo|go) \"$name\"" "$f" 2>/dev/null; then
            echo "$f"
            return
        fi
    done
}

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "Dumping installed packages..."
brew bundle dump --force --describe --no-vscode --file="$TMPFILE"

# Only compare against the two files relevant to the current OS
tracked=$(sort -u \
    <(names_from_file "$COMMON") \
    <(names_from_file "$OS_FILE"))

dumped=$(names_from_file "$TMPFILE")

new=$(comm -23 <(echo "$dumped") <(echo "$tracked") 2>/dev/null || true)
removed=$(comm -13 <(echo "$dumped") <(echo "$tracked") 2>/dev/null || true)

if [ -z "$new" ] && [ -z "$removed" ]; then
    echo "Everything in sync — no changes needed."
    exit 0
fi

if [ -n "$new" ]; then
    new_brew=()
    new_other=()
    while IFS= read -r name; do
        if grep -qE "^brew \"$name\"" "$TMPFILE"; then
            new_brew+=("$name")
        else
            new_other+=("$name")
        fi
    done <<< "$new"

    add_to_common=()
    add_to_os=()
    add_to_unknown=()

    if [ "${#new_brew[@]}" -gt 0 ]; then
        echo "Querying Homebrew API for OS requirements..."
        if info_json=$(brew info --json=v2 "${new_brew[@]}" 2>/dev/null); then
            # Any OS requirement means it's platform-specific; no requirement means common
            os_specific=$(echo "$info_json" \
                | jq -r '.formulae[] | select(.requirements | length > 0) | .name' \
                2>/dev/null || true)
            cross_platform=$(echo "$info_json" \
                | jq -r '.formulae[] | select(.requirements | length == 0) | .name' \
                2>/dev/null || true)

            for name in "${new_brew[@]}"; do
                if echo "$os_specific" | grep -qx "$name"; then
                    add_to_os+=("$name")
                elif echo "$cross_platform" | grep -qx "$name"; then
                    add_to_common+=("$name")
                else
                    add_to_unknown+=("$name")
                fi
            done
        else
            add_to_unknown=("${new_brew[@]}")
        fi
    fi

    # taps, cargo, go are always common
    for name in "${new_other[@]}"; do
        add_to_common+=("$name")
    done

    for name in "${add_to_common[@]+"${add_to_common[@]}"}"; do
        echo "  → Brewfile.common: $name"
        full_entry_for_name "$name" "$TMPFILE" >> "$COMMON"
    done

    for name in "${add_to_os[@]+"${add_to_os[@]}"}"; do
        echo "  → Brewfile.$OS: $name"
        full_entry_for_name "$name" "$TMPFILE" >> "$OS_FILE"
    done

    if [ "${#add_to_unknown[@]}" -gt 0 ]; then
        echo ""
        echo "Could not categorize — add manually to the appropriate Brewfile:"
        for name in "${add_to_unknown[@]}"; do
            while IFS= read -r line; do echo "  $line"; done \
                <<< "$(full_entry_for_name "$name" "$TMPFILE")"
        done
    fi
fi

if [ -n "$removed" ]; then
    echo ""
    while IFS= read -r name; do
        tracking_file=$(find_tracking_file "$name")
        if [ -n "$tracking_file" ]; then
            echo "  ✗ Removing from $(basename "$tracking_file"): $name"
            remove_from_file "$name" "$tracking_file"
        fi
    done <<< "$removed"
fi

echo ""
echo "Done."
