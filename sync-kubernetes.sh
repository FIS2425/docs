#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <api_token>"
  exit 1
fi

API_TOKEN="$1"

# configuration
SPECS_DIR="kubernetes"
BASE_URL="https://api.github.com/repos/FIS2425"

mkdir -p "$SPECS_DIR"

# Just list services one per line
services=(
    alert-svc
    appointment-svc
    authorization-svc
    history-svc
    patient-svc
    payment-svc
    staff-svc
    workshift-svc
    logger-svc
    api-gateway
)

for svc in "${services[@]}"; do
    echo "fetching $svc"

    API_URL="$BASE_URL/$svc/contents/kubernetes"

    # Fetch the YAML files from the repository

    curl -H "Authorization: Bearer ${API_TOKEN}" -s "${API_URL}" \
        | jq -r '.[] | select(.type == "file") | .name,.download_url' \
        | while read -r file && read -r download_url; do
            # Download each YAML file into the SPECS_DIR
            curl \
                -s -o "$SPECS_DIR/${svc}_$file" \
                -L "$download_url" \
                -f -s && echo "✓ $svc" || echo "✗ failed: $svc"
        done
done

date > "$SPECS_DIR/.last_updated"
