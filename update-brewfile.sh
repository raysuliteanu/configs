#!/usr/bin/env bash

set -euo pipefail

FORCE=""

while getopts "f" opt; do
    case "$opt" in
    f) FORCE="--force" ;;
    *)
        echo "Usage: $0 [-f]" >&2
        exit 1
        ;;
    esac
done

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
brew bundle dump ${FORCE:+"$FORCE"} --describe --no-vscode --file="Brewfile.$OS"
echo "Dumped to Brewfile.$OS — move any newly added cross-platform packages to Brewfile.common manually."
