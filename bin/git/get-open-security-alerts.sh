#!/bin/bash

ORG="ministryofjustice"
# ORG="moj-analytical-services"
ACCEPT_HEADER="Accept: application/vnd.github+json"

# Query all open secret scanning alerts for the org
gh api \
  -H "$ACCEPT_HEADER" \
  --paginate \
  "/orgs/${ORG}/secret-scanning/alerts?state=open" |
  jq -r '
    group_by(.repository.full_name) |
    map({
      repo: .[0].repository.name,
      url: .[0].repository.html_url,
      count: length
    }) as $repos |
    # First, print the total count
    "Total Open Alerts: \($repos | map(.count) | add)\n" +
    # Then print the sorted list
    ($repos | sort_by(.count) | reverse | map("\(.url) \(.count)") | join("\n"))
  '
