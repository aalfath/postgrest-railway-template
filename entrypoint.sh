#!/bin/sh
set -eu

: "${DATABASE_URL:?set DATABASE_URL to an owner connection, e.g. \${{Postgres.DATABASE_URL}}}"
: "${PGHOST:?set PGHOST, e.g. \${{Postgres.PGHOST}}}"
: "${PGPORT:=5432}"
: "${PGDATABASE:?set PGDATABASE, e.g. \${{Postgres.PGDATABASE}}}"
: "${PGRST_AUTHENTICATOR_PASSWORD:?set PGRST_AUTHENTICATOR_PASSWORD}"
: "${PGRST_JWT_SECRET:?set PGRST_JWT_SECRET (at least 32 characters)}"

# Listen on IPv4 and IPv6 (Railway's private network is IPv6).
export PGRST_SERVER_HOST="${PGRST_SERVER_HOST:-*6}"
export PGRST_SERVER_PORT="${PGRST_SERVER_PORT:-${PORT:-3000}}"
export PGRST_DB_SCHEMAS="${PGRST_DB_SCHEMAS:-api}"
export PGRST_DB_ANON_ROLE="${PGRST_DB_ANON_ROLE:-web_anon}"
AUTH_ROLE="${PGRST_AUTHENTICATED_ROLE:-authenticated}"
API_SCHEMA="${PGRST_DB_SCHEMAS%%,*}"

if [ "${PGRST_BOOTSTRAP:-true}" = "true" ]; then
  tries=0
  until psql "$DATABASE_URL" -qAtc 'select 1' >/dev/null 2>&1; do
    tries=$((tries + 1))
    [ "$tries" -ge 60 ] && { echo "bootstrap: database not reachable" >&2; exit 1; }
    echo "bootstrap: waiting for database"; sleep 2
  done
  echo "bootstrap: ensuring roles ($PGRST_DB_ANON_ROLE, $AUTH_ROLE, authenticator) and schema $API_SCHEMA"
  psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 \
    -v api_schema="$API_SCHEMA" -v anon_role="$PGRST_DB_ANON_ROLE" -v auth_role="$AUTH_ROLE" \
    -v authenticator_password="$PGRST_AUTHENTICATOR_PASSWORD" \
    -f /opt/postgrest/bootstrap.sql
fi

# PostgREST connects as the low-privilege authenticator role.
export PGRST_DB_URI="host=$PGHOST port=$PGPORT dbname=$PGDATABASE user=authenticator password=$PGRST_AUTHENTICATOR_PASSWORD"
unset DATABASE_URL
exec postgrest
