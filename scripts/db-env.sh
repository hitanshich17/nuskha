# Sourced by the import scripts: database settings matching docker compose (.env),
# unless DB_URL / DB_USER / DB_PASSWORD are already set.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT/.env" ]]; then
  set -a; source "$ROOT/.env"; set +a
fi
export DB_URL="${DB_URL:-jdbc:postgresql://localhost:5432/${POSTGRES_DB:-skinvidhi}}"
export DB_USER="${DB_USER:-${POSTGRES_USER:-skinvidhi}}"
export DB_PASSWORD="${DB_PASSWORD:-${POSTGRES_PASSWORD:-skinvidhi_dev_password}}"
