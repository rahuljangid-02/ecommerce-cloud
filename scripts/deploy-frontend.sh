#!/usr/bin/env bash
# Upload the static frontend to Azure Storage and purge the CDN cache.
# Run from anywhere after `terraform apply`. Needs Azure CLI login and access.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF="terraform -chdir=$ROOT/infra"

STORAGE_ACCOUNT="$($TF output -raw storage_account_name)"
CDN_ENDPOINT="$($TF output -raw frontend_url)"

# Azure Storage static website endpoint is not the same as the CDN hostname.
SITE_URL="https://${STORAGE_ACCOUNT}.z13.web.core.windows.net"

az storage blob upload-batch \
  --source "$ROOT/frontend/" \
  --destination "\$web" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --overwrite true

echo "Done: $CDN_ENDPOINT"

echo "Static site URL: $SITE_URL"
