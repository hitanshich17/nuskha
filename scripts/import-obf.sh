#!/usr/bin/env bash
# Imports Open Beauty Facts products into the local database.
#
#   docker compose up -d postgres     # the database must be running
#   scripts/import-obf.sh             # downloads the dump once (~100 MB), then imports
#   scripts/import-obf.sh --refresh   # downloads the latest dump first
#
# Data: Open Beauty Facts (https://world.openbeautyfacts.org), Open Database License (ODbL).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="https://static.openbeautyfacts.org/data/openbeautyfacts-products.jsonl.gz"
DUMP="$ROOT/data/openbeautyfacts-products.jsonl.gz"

if [[ ! -f "$DUMP" || "${1:-}" == "--refresh" ]]; then
  mkdir -p "$ROOT/data"
  echo "Downloading $URL"
  curl -fL --progress-bar -o "$DUMP.part" "$URL"
  mv "$DUMP.part" "$DUMP"
fi

# Use the same credentials as docker compose (.env), unless DB_* are already set.
if [[ -f "$ROOT/.env" ]]; then
  set -a; source "$ROOT/.env"; set +a
fi
export DB_URL="${DB_URL:-jdbc:postgresql://localhost:5432/${POSTGRES_DB:-nuskha}}"
export DB_USER="${DB_USER:-${POSTGRES_USER:-nuskha}}"
export DB_PASSWORD="${DB_PASSWORD:-${POSTGRES_PASSWORD:-nuskha_dev_password}}"

cd "$ROOT/services/core-api"
./mvnw -q spring-boot:run \
  -Dspring-boot.run.arguments="--spring.main.web-application-type=none --nuskha.import.obf-file=$DUMP"
