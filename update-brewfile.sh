#!/usr/bin/env bash

# Reconcile installed packages against Brewfile.common + Brewfile.linux + Brewfile.darwin.
# Uses the Homebrew JSON API to auto-categorize untracked brew formulae by OS requirement.
# Run on each platform after installing new packages.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

COMMON="$SCRIPT_DIR/Brewfile.common"
LINUX_FILE="$SCRIPT_DIR/Brewfile.linux"
DARWIN_FILE="$SCRIPT_DIR/Brewfile.darwin"

# Extract quoted name from Brewfile lines: brew "foo", ... -> foo
names_from_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    grep -E '^(brew|tap|cargo|go) ' "$file" \
        | sed 's/^[^ ]* "\([^"]*\)".*/\1/' \
        | sort -u
}

# Full Brewfile line for a given name from a dump file
line_for_name() {
    local name="$1" file="$2"
    grep -E "^(brew|tap|cargo|go) \"$name\"" "$file" || true
}

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

echo "Dumping installed packages..."
brew bundle dump --force --describe --no-vscode --file="$TMPFILE"

# All tracked names across all three Brewfiles
tracked=$(sort -u \
    <(names_from_file "$COMMON") \
    <(names_from_file "$LINUX_FILE") \
    <(names_from_file "$DARWIN_FILE"))

dumped=$(names_from_file "$TMPFILE")

# Packages in dump but not in any Brewfile
new=$(comm -23 <(echo "$dumped") <(echo "$tracked") 2>/dev/null || true)

# Packages in Brewfiles but no longer in dump
removed=$(comm -13 <(echo "$dumped") <(echo "$tracked") 2>/dev/null || true)

if [ -z "$new" ] && [ -z "$removed" ]; then
    echo "Everything in sync — no untracked or missing packages."
    exit 0
fi

if [ -n "$new" ]; then
    # Separate brew formulae from taps/cargo/go (latter are always common)
    new_brew=()
    new_other=()
    while IFS= read -r name; do
        if grep -qE "^brew \"$name\"" "$TMPFILE"; then
            new_brew+=("$name")
        else
            new_other+=("$name")
        fi
    done <<< "$new"

    suggest_common=()
    suggest_linux=()
    suggest_darwin=()
    suggest_unknown=()

    if [ "${#new_brew[@]}" -gt 0 ]; then
        echo "Querying Homebrew API for OS requirements..."
        # Batch query all untracked brew formulae
        if info_json=$(brew info --json=v2 "${new_brew[@]}" 2>/dev/null); then
            linux_names=$(echo "$info_json" \
                | jq -r '.formulae[] | select(.requirements[] | .name == "linux") | .name' 2>/dev/null || true)
            darwin_names=$(echo "$info_json" \
                | jq -r '.formulae[] | select(.requirements[] | .name == "macos") | .name' 2>/dev/null || true)
            common_names=$(echo "$info_json" \
                | jq -r '.formulae[] | select(.requirements | length == 0) | .name' 2>/dev/null || true)

            for name in "${new_brew[@]}"; do
                if echo "$linux_names" | grep -qx "$name"; then
                    suggest_linux+=("$name")
                elif echo "$darwin_names" | grep -qx "$name"; then
                    suggest_darwin+=("$name")
                elif echo "$common_names" | grep -qx "$name"; then
                    suggest_common+=("$name")
                else
                    suggest_unknown+=("$name")
                fi
            done
        else
            # API call failed entirely — mark all as unknown
            suggest_unknown=("${new_brew[@]}")
        fi
    fi

    # taps, cargo, go are always common
    for name in "${new_other[@]}"; do
        suggest_common+=("$name")
    done

    if [ "${#suggest_common[@]}" -gt 0 ]; then
        echo ""
        echo "==> Add to Brewfile.common (cross-platform):"
        for name in "${suggest_common[@]}"; do
            line_for_name "$name" "$TMPFILE" | sed 's/^/  /'
        done
    fi

    if [ "${#suggest_linux[@]}" -gt 0 ]; then
        echo ""
        echo "==> Add to Brewfile.linux (Linux-only):"
        for name in "${suggest_linux[@]}"; do
            line_for_name "$name" "$TMPFILE" | sed 's/^/  /'
        done
    fi

    if [ "${#suggest_darwin[@]}" -gt 0 ]; then
        echo ""
        echo "==> Add to Brewfile.darwin (macOS-only):"
        for name in "${suggest_darwin[@]}"; do
            line_for_name "$name" "$TMPFILE" | sed 's/^/  /'
        done
    fi

    if [ "${#suggest_unknown[@]}" -gt 0 ]; then
        echo ""
        echo "==> Categorize manually (API lookup failed or ambiguous):"
        for name in "${suggest_unknown[@]}"; do
            line_for_name "$name" "$TMPFILE" | sed 's/^/  /'
        done
    fi
fi

if [ -n "$removed" ]; then
    echo ""
    echo "==> No longer installed (consider removing from Brewfiles):"
    while IFS= read -r line; do echo "  $line"; done <<< "$removed"
fi
