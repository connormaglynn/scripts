#!/bin/sh

ORG=${1:?"missing arg 1 for ORG i.e. ministryofjustice"}
TEAM=${2:?"missing arg 2 for TEAM i.e. modernisaiton-platform"}

gh api "/orgs/$ORG/teams/$TEAM/repos" --paginate |
  # jq -r '.[] | select(.permissions.admin == true and .archived == false) | .name'
  jq -r '.[] | select(.archived == false) | .name'
