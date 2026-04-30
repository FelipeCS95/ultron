#!/bin/bash

. "$ULTRON_PATH/config/helpers.sh"

ultron() {
  local cmd="$1"

  if [[ -z "$cmd" || "$cmd" == "help" ]]; then
    echo "Available commands:"
    echo "  projects          Go to projects directory"
    echo "  <project_name>    Go to a project by name"
    echo "  <command>         Run an ultron:: command"
    echo ""
    echo "Detected commands (ultron::):"
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
    for file in "$ULTRON_PATH"/main/ultron/*.sh; do
      . "$file"
    done

    shift
    ultron::execute_function "$cmd" "$@"
  )
}
alias u=ultron

u kill_sessions
