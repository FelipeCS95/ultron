#!/bin/bash

_ultron_dev_kitty_session() {
  local project="$1" dir="$2" console_cmd="$3"
  local file="/tmp/ultron-dev-${project}.session"
  printf 'new_tab %s: editor\ncd %s\nlaunch nvim\n\n'                        "$project" "$dir"              > "$file"
  printf 'new_tab %s: console\ncd %s\nlaunch zsh -i -c "%s; exec zsh"\n\n'   "$project" "$dir" "$console_cmd" >> "$file"
  printf 'new_tab %s: claude\ncd %s\nlaunch zsh -i -c "claude; exec zsh"\n'  "$project" "$dir"              >> "$file"
  echo "$file"
}

ultron::dev() {
  local project="${1:-.}"
  local profile="${2:-}"

  local dir
  if [[ "$project" == "." || -z "$project" ]]; then
    dir="$PWD"
    project=$(basename "$PWD")
  else
    dir="$PROJECTS_PATH/$project"
  fi

  [[ -d "$dir" ]] || { echo "Projeto não encontrado: $dir" >&2; return 1; }

  local console_cmd="u console"
  [[ -n "$profile" ]] && console_cmd="u console $profile"

  # Dentro do Kitty com remote control: abre abas na janela atual e roda nvim aqui
  # ${project} com chaves evita que zsh interprete ":editor"/":console" como modificadores
  if [[ -n "${KITTY_WINDOW_ID:-}" ]] && kitty @ ls &>/dev/null; then
    kitty @ set-tab-title "${project}: editor"
    kitty @ launch --type=tab --tab-title="${project}: console" --cwd="$dir" \
      zsh -i -c "$console_cmd; exec zsh"
    kitty @ launch --type=tab --tab-title="${project}: claude" --cwd="$dir" \
      zsh -i -c "claude; exec zsh"
    kitty @ focus-tab --match "title:${project}: editor" 2>/dev/null || true
    cd "$dir" && nvim
    return
  fi

  # Fallback: nova janela Kitty via session file (Kitty sem remote control)
  if command -v kitty &>/dev/null; then
    kitty --session "$(_ultron_dev_kitty_session "$project" "$dir" "$console_cmd")" --detach
    return
  fi

  # Fallback: tmux (SSH ou ambiente sem Kitty)
  local session="$project"
  if tmux has-session -t "$session" 2>/dev/null; then
    [[ -n "${TMUX:-}" ]] && tmux switch-client -t "$session" || tmux attach -t "$session"
    return
  fi
  tmux new-session -d -s "$session" -n "editor"  -c "$dir"
  tmux send-keys -t "$session:editor"  "nvim" Enter
  tmux new-window -t "$session" -n "console" -c "$dir"
  tmux send-keys -t "$session:console" "$console_cmd" Enter
  tmux new-window -t "$session" -n "claude"  -c "$dir"
  tmux send-keys -t "$session:claude"  "claude" Enter
  tmux select-window -t "$session:editor"
  [[ -n "${TMUX:-}" ]] && tmux switch-client -t "$session" || tmux attach -t "$session"
}

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
