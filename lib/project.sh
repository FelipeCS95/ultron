#!/bin/bash

ultron::up() {
  if [[ -n "$1" ]]; then
    docker compose --profile="$1" up -d
  else
    docker compose up -d
  fi
}

ultron::down() {
  docker compose down --remove-orphans
  docker ps -a -q | xargs -r docker stop 2>/dev/null
  docker ps -a -q | xargs -r docker rm 2>/dev/null
}

ultron::console() {
  ultron::up "${1:-}"
  dce web sh
}

ultron::prepare() {
  echo "Command not implemented: prepare" >&2
  return 127
}

ultron::clear() {
  ultron::down

  docker system prune -a -f
  docker images -a -q | xargs -r docker rmi 2>/dev/null
  docker ps -a -q | xargs -r docker stop 2>/dev/null
  docker ps -a -q | xargs -r docker rm 2>/dev/null
  docker volume ls -q | xargs -r docker volume rm 2>/dev/null
}

ultron::coverage() {
  local coverage_path="$PWD/coverage/index.html"
  if [[ -f "$coverage_path" ]]; then
    echo "file://$PROJECT_SYSTEM_PATH$coverage_path"
  else
    echo "Coverage report not found at: $coverage_path"
    return 1
  fi
}

ultron::vpn() {
  echo "Command not implemented: vpn" >&2
  return 127
}

ultron::bisect() {
  local action="$1"
  shift

  if [[ -z "$action" ]]; then
    echo "Usage: ultron bisect <prepare|search|show|run>"
    return 1
  fi

  local function_name="ultron::bisect_${action}"
  if declare -f "$function_name" > /dev/null; then
    "$function_name" "$@"
  else
    echo "Invalid action: $action"
    return 1
  fi
}

ultron::bisect_prepare() {
  local project
  project=$(ultron::current_folder)
  local log_file="$ULTRON_PATH/tmp/$project/bisect_prepare.log"
  mkdir -p "$(dirname "$log_file")"
  echo "INSERT SEED"
  read -r SEED
  echo "BISECT_SEED=$SEED" > "$log_file"
  echo "BISECT_FILES=(" >> "$log_file"

  echo "INSERT FILES - ENTER to finish"
  local file
  while read -r file; do
    [[ -z "$file" ]] && break
    if [[ "$file" == *"spec/"* ]]; then
      file=$(echo "$file" | sed 's/.*\(spec\/.*\.rb\).*/\1/')
      echo "  $file" >> "$log_file"
    fi
  done
  echo ")" >> "$log_file"
}

ultron::bisect_search() {
  local project
  project=$(ultron::current_folder)
  local log_file="$ULTRON_PATH/tmp/$project/bisect_search.log"
  . "$ULTRON_PATH/tmp/$project/bisect_prepare.log"
  dce web bin/rspec "${BISECT_FILES[@]}" --bisect --seed "$BISECT_SEED" \
    | tee >(grep -A1 "The minimal reproduction command is:" | tail -n 1 | sed 's/.*\(rspec.*\)/\1/' > "$log_file")
}

ultron::bisect_show() {
  local project
  project=$(ultron::current_folder)
  cat "$ULTRON_PATH/tmp/$project/bisect_search.log"
}

ultron::bisect_run() {
  local project
  project=$(ultron::current_folder)
  local cmd
  cmd=$(<"$ULTRON_PATH/tmp/$project/bisect_search.log")
  cmd="${cmd//$'\r'/}"
  dce web bin/$cmd
}
