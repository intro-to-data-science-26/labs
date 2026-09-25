#!/usr/bin/env bash

set -euo pipefail

# Run from the project root even if this script was called elsewhere.
# Just focus on why this is a good idea for now - no need to grok it right now.
project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

input="data/bird_notes.txt"
output_dir="results"
mkdir -p "$output_dir"

echo "Creating a bird-word count and an R summary from $input"
grep -i -o -E 'sparrow|robin|blackbird' "$input" |
  tr '[:upper:]' '[:lower:]' |
  sort |
  uniq -c |
  sort -nr > "$output_dir/bird-counts.txt"

Rscript scripts/make_summary.R "$input" "$output_dir/bird-summary.csv"

echo "Done. Results are in $output_dir/."
