#!/bin/bash

# Guard: evita re-execução quando sourced dentro do subshell de ultron()
[[ -n "${_ULTRON_INIT:-}" ]] && return

. "$ULTRON_PATH/config/helpers.sh"

ultron() {
  local cmd="$1"

  if [[ -z "$cmd" || "$cmd" == "help" ]]; then
    echo "Comandos disponíveis:"
    echo "  projects          Vai para o diretório de projetos"
    echo "  <nome_projeto>    Vai para o diretório de um projeto"
    echo "  <comando>         Executa um comando ultron::"
    echo ""
    echo "Comandos detectados (ultron::):"
    _ultron_commands | sed 's/^/  /' | column
    return 0
  fi

  if [[ "$cmd" == "projects" ]]; then
    cd "$PROJECTS_PATH" || return 1
    return 0
  fi

  local project_path="$PROJECTS_PATH/$cmd"
  if [[ -d "$project_path" ]]; then
    cd "$project_path" || return 1
    return 0
  fi

  (
    . "$ULTRON_PATH/config/env.sh"

    local file
    for file in "$ULTRON_PATH"/lib/*.sh; do
      . "$file"
    done

    shift
    ultron::execute_function "$cmd" "$@"
  )
}
alias u=ultron

_ULTRON_INIT=1
ultron kill_sessions
