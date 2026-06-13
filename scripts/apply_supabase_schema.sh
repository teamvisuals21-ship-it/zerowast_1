#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/supabase/migrations"
SEED_FILE="$ROOT_DIR/supabase/seed.sql"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required to apply the Supabase SQL files." >&2
  echo "Install PostgreSQL client tools, then re-run this script." >&2
  exit 1
fi

DB_URL="${SUPABASE_DB_URL:-}"

if [[ -z "$DB_URL" ]] && command -v supabase >/dev/null 2>&1; then
  if ! supabase status >/dev/null 2>&1; then
    echo "Starting local Supabase..."
    supabase start
  fi

  DB_URL="$(supabase status -o env | awk -F= '/^POSTGRES_URL=/{print $2}')"
fi

if [[ -z "$DB_URL" ]]; then
  echo "Set SUPABASE_DB_URL to your Postgres connection string." >&2
  echo "Example: SUPABASE_DB_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres $0" >&2
  exit 1
fi

for migration in "$MIGRATIONS_DIR"/*.sql; do
  echo "Applying migration: $(basename "$migration")"
  psql "$DB_URL" -v ON_ERROR_STOP=1 -f "$migration"
done

echo "Loading seed data: $(basename "$SEED_FILE")"
psql "$DB_URL" -v ON_ERROR_STOP=1 -f "$SEED_FILE"

echo "Supabase schema and seed data are ready."
