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
}

ultron::console() {
  ultron::up "${1:-}"
  docker compose exec web sh
}

ultron::clear() {
  read -rp "Isso vai remover todos os containers, imagens e volumes Docker. Confirmar? [y/N] " confirm
  [[ "${confirm,,}" != "y" ]] && return 0

  ultron::down
  docker system prune -a -f
  docker volume ls -q | xargs -r docker volume rm 2>/dev/null
}

ultron::coverage() {
  local coverage_path="$PWD/coverage/index.html"
  if [[ -f "$coverage_path" ]]; then
    echo "file://$PROJECT_SYSTEM_PATH$coverage_path"
  else
    echo "Relatório de cobertura não encontrado em: $coverage_path"
    return 1
  fi
}

ultron::bisect() {
  local action="$1"
  shift

  if [[ -z "$action" ]]; then
    echo "Usage: u bisect <prepare|search|show|run>"
    return 1
  fi

  local function_name="ultron::bisect_${action}"
  if declare -f "$function_name" > /dev/null; then
    "$function_name" "$@"
  else
    echo "Ação inválida: $action"
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
  docker compose exec web bin/rspec "${BISECT_FILES[@]}" --bisect --seed "$BISECT_SEED" \
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
  docker compose exec web bin/$cmd
}
