#!/bin/sh

ORG="$1"
shift
TEAMS="$@"

for TEAM in $TEAMS; do
  echo "Private / Internal Repositories for $TEAM"

  gh api "/orgs/$ORG/teams/$TEAM/repos" --paginate |
    jq -r '.[] | select(.visibility == "private" or .visibility == "internal") | "  - " + .full_name'

  echo
done
