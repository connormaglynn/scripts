#!/bin/bash
set -eu

# this script depends on the following being installed:
# - safety (pip install safety)

SERVICES=${1:?"missing arg 1 for SERVICES"}

FILE=~/git/scripts/services/python/$SERVICES.txt

while read -r line; do

  source git-checkout-clean-main.sh "$line"

  echo "$line"
   pip-audit -r requirements.txt || true

  echo "---------------------------------------------------------------"
done < "$FILE"
