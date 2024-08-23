#!/bin/bash

# Get the directory to search in, or use the current directory if none is provided
search_dir=${1:-$(pwd)}

# Find all directories containing a .git subdirectory
repo_dirs=$(find "$search_dir" -type d -name '.git' -prune -exec dirname {} \;)

# Iterate over each repository directory found and perform git pull
for repo in $repo_dirs; do
    echo "Pulling updates in repository: $repo"
    (cd "$repo" && git pull)
done

