#!/usr/bin/env bash

FORCE=""

while getopts "f" opt; do
    case "$opt" in
        f) FORCE="--force" ;;
        *) echo "Usage: $0 [-f]" >&2; exit 1 ;;
    esac
done

brew bundle dump $FORCE --describe
