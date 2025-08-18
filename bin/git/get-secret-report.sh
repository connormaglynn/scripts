#!/bin/sh

set -e

ORG="$1"
REPO_FILTER_FILE="repos.txt"
TMP_FILE="/tmp/${ORG}_secret_alerts_raw.json"
SLIMMED_FILE="/tmp/${ORG}_secret_alerts_slimmed.json"
FINAL_OUTPUT="/tmp/${ORG}_secret_alerts_filtered.json"

if [ -z "$ORG" ]; then
  echo "Usage: $0 <github-org-name>"
  exit 1
fi

if [ ! -f "$REPO_FILTER_FILE" ]; then
  echo "Error: $REPO_FILTER_FILE not found. Please provide a list of allowed repositories (one per line)."
  exit 1
fi

echo "Fetching only OPEN secret scanning alerts for org: $ORG..."

# Fetch open alerts and clean control characters
gh api --paginate "/orgs/${ORG}/secret-scanning/alerts?state=open" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" |
  tr -d '\000-\037\177' >"$TMP_FILE"

echo "Enriching alerts with repository metadata..."

# Enrich repositories with visibility/isArchived/description
jq -r '.[].repository.full_name' "$TMP_FILE" | sort | uniq | while read -r REPO; do
  REPO_INFO=$(gh repo view "$REPO" --json visibility,isArchived,description --jq '{visibility, isArchived, description}')
  jq --arg repo "$REPO" --argjson info "$REPO_INFO" '
    map(if .repository.full_name == $repo then .repository += $info else . end)
  ' "$TMP_FILE" >"${TMP_FILE}.tmp" && mv "${TMP_FILE}.tmp" "$TMP_FILE"
done

echo "Filtering down to allowed repositories only..."

# Create a jq array from repos.txt
ALLOWED_REPOS=$(jq -Rn '[inputs]' <"$REPO_FILTER_FILE")

# Filter alerts to only those in repos.txt
jq --argjson allowed_repos "$ALLOWED_REPOS" '
  map(select(.repository.full_name as $name | $allowed_repos | index($name)))
' "$TMP_FILE" >"$SLIMMED_FILE"

echo "Selecting relevant fields and grouping by secret_type..."

# Slim the alerts
jq '[.[] | {
  created_at,
  updated_at,
  state,
  secret_type,
  secret_type_display_name,
  validity,
  multi_repo,
  is_base64_encoded,
  secret,
  publicly_leaked,
  "repository.full_name": .repository.full_name,
  "repository.description": .repository.description,
  "repository.isArchived": .repository.isArchived,
  "repository.visibility": .repository.visibility
}]' "$SLIMMED_FILE" >"${SLIMMED_FILE}.tmp" && mv "${SLIMMED_FILE}.tmp" "$SLIMMED_FILE"

# Group by secret_type
jq 'group_by(.secret_type) | 
    map({ (.[0].secret_type): . }) | 
    add' "$SLIMMED_FILE" >"$FINAL_OUTPUT"

echo "Done. Filtered and grouped secret alerts written to: $FINAL_OUTPUT"
