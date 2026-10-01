# Shared logic for scuola/run.sh and turismo/run.sh (include with `source`).
# The calling script must define DB and PORT before sourcing this file.
#   DB    database name (= user = password = container name suffix, pg-$DB)
#   PORT  host port: postgresql://$DB:$DB@localhost:$PORT/$DB
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[1]}")"

NAME="pg-$DB"
IMAGE=postgres:16-alpine

DOCKER=docker
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

start() {
  if [ -z "$($DOCKER ps -aq -f name=^${NAME}$)" ]; then
    echo ">> Creo il container $NAME..." >&2
    $DOCKER run -d --name "$NAME" \
      -e POSTGRES_USER="$DB" -e POSTGRES_PASSWORD="$DB" -e POSTGRES_DB="$DB" \
      -p "$PORT:5432" \
      -v "$PWD/init:/docker-entrypoint-initdb.d:ro" \
      "$IMAGE" >/dev/null
  elif [ -z "$($DOCKER ps -q -f name=^${NAME}$)" ]; then
    $DOCKER start "$NAME" >/dev/null
  fi
  # wait until the db is ready (and the init scripts have finished)
  until $DOCKER exec "$NAME" psql -U "$DB" -d "$DB" -h 127.0.0.1 -c 'SELECT 1' >/dev/null 2>&1; do sleep 0.5; done
}

case "${1:-query.sql}" in
  stop)  $DOCKER rm -f "$NAME" >/dev/null && echo "Container rimosso." ;;
  reset) $DOCKER rm -f "$NAME" >/dev/null 2>&1 || true; start; echo "Database ricreato." ;;
  psql)  start; $DOCKER exec -it "$NAME" psql -U "$DB" -d "$DB" ;;
  *)     start; $DOCKER exec -i "$NAME" psql -U "$DB" -d "$DB" -v ON_ERROR_STOP=1 -P pager=off < "${1:-query.sql}" ;;
esac
