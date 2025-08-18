#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file_with_org_repo_list.txt>"
  exit 1
fi

input_file="$1"

# Read file line by line
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines or lines without a slash
  if [[ -z "$line" || "$line" != */* ]]; then
    continue
  fi

  org_repo="$line"

  # Use gh CLI to get repo info
  repo_info=$(gh api repos/"$org_repo" 2>/dev/null)

  if [[ $? -ne 0 ]]; then
    echo "$org_repo: Error retrieving info"
    continue
  fi

  # Extract visibility
  visibility=$(echo "$repo_info" | jq -r '.visibility')

  if [[ "$visibility" == "private" ]]; then
    echo "$org_repo: $visibility"
  fi
done <"$input_file"
