#!/bin/bash
set -eu

SERVICES=${1:?"missing arg 1 for SERVICES"}

FILE=~/git/scripts/services_files/all/$SERVICES.txt

while read -r line; do
  source git-checkout-clean-main.sh "$line"

  echo "$line"
  git fetch origin
  git reset --hard origin/main

  echo "---------------------------------------------------------------"
done < "$FILE"
