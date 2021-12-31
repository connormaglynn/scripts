#!/bin/bash
set -eu

# this script depends on the following being installed:
# - better-npm-audit (npm install -g better-npm-audit)

SERVICES=${1:?"missing arg 1 for SERVICES"}

FILE=~/git/scripts/services/node/$SERVICES.txt



while read -r line; do

  source git-checkout-clean-main.sh "$line"

  echo "$line"
  better-npm-audit audit || true

  echo "---------------------------------------------------------------"
done < "$FILE"
