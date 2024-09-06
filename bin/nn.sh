#!/bin/bash

# convenience script for creating new Obsidian note
# based on https://github.com/agalea91/dotfiles/blob/main/bin/on

if [ -z "$1" ]; then
  echo "Error: A file name must be specified."
  exit 1
fi

# replace SP with -
file_name=$(echo "$*" | tr ' ' '-')
formatted_file_name=$(date "+%Y-%m-%d")_${file_name}.md
cd "$HOME/Documents/Obsidian/Ray" || exit
nvim "Inbox/${formatted_file_name}"
