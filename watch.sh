#!/bin/bash
set -euo pipefail

# Make sure a file was provided
if [ $# -eq 0 ]; then
    echo "No arguments supplied. Please provide the path to the file to watch."
    exit 1
fi

file_to_watch="$1"
watchexec -w "$file_to_watch" -r "crystal \"$file_to_watch\" && dot -Tpng tree.dot -o tree.png"
