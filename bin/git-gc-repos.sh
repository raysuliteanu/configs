#!/bin/bash

# Directory to search for git repositories
SEARCH_DIR=$1

if [ -z "$SEARCH_DIR" ]; then
    echo "Please provide a directory to search for git repositories."
    exit 1
fi

# Find all git repositories and run 'git gc'
find "$SEARCH_DIR" -type d -name ".git" | while read -r gitdir; do
    repo_dir=$(dirname "$gitdir")
    echo "Running 'git gc' in $repo_dir"
    cd "$repo_dir" && git gc
done

