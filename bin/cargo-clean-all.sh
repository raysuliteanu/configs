#!/bin/bash

# Check if a directory is provided as an argument, if not, use the current directory
search_dir=${1:-$(pwd)}

# find -execdir won't run if PATH ends in a colon, for security; see man page
export PATH=$(echo "$PATH" | sed 's/:$//')

find "$search_dir" -type f -name "Cargo.toml" -execdir cargo -q clean \;

