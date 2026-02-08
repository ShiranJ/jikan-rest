#!/bin/bash
set -eo pipefail

echo "=== Generating .env from environment variables ==="

# Generate .env file from environment variables
cat > /app/.env <<EOF
APP_NAME=${APP_NAME:-Jikan}
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-base64:$(openssl rand -base64 32)}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost}

LOG_CHANNEL=${LOG_CHANNEL:-stderr}
LOG_LEVEL=${LOG_LEVEL:-error}

DB_CONNECTION=${DB_CONNECTION:-}
MONGODB_DSN=${MONGODB_DSN:-}

CACHE_DRIVER=${CACHE_DRIVER:-file}
QUEUE_CONNECTION=${QUEUE_CONNECTION:-sync}
SESSION_DRIVER=${SESSION_DRIVER:-file}

REDIS_HOST=${REDIS_HOST:-127.0.0.1}
REDIS_PASSWORD=${REDIS_PASSWORD:-}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_CLIENT=${REDIS_CLIENT:-phpredis}
EOF

echo "=== .env generated ==="
echo "DB_CONNECTION: ${DB_CONNECTION}"
echo "MONGODB_DSN: $(echo ${MONGODB_DSN} | sed 's/:[^:]*@/:***@/')"  # Hide password
echo "CACHE_DRIVER: ${CACHE_DRIVER}"
echo "REDIS_HOST: ${REDIS_HOST}"

# Run original entrypoint logic
status=0
if [[ $# -eq 0 ]] ; then
  php /app/docker-entrypoint.php
  status=$?
else
  php /app/docker-entrypoint.php "$@"
  status=$?
fi

[[ $status -ne 0 ]] && exit $status

echo "=== Starting RoadRunner ==="
exec rr serve -c .rr.yaml
