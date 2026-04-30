#!/bin/bash

_ultron_commands() {
  grep -rhoP 'ultron::\K\w+' "$ULTRON_PATH"/main/ultron/*.sh | sort -u
}

_ultron_projects() {
  find "$PROJECTS_PATH" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | uniq
}

_ultron_completion() {
  local prev_arg="${COMP_WORDS[COMP_CWORD-1]}"
  local cur_word="${COMP_WORDS[COMP_CWORD]}"

  . "$ULTRON_PATH"/config/completions.sh

  COMPREPLY=()
  if [[ "$prev_arg" == "ultron" ]]; then
    while IFS= read -r line; do
      COMPREPLY+=("$line")
    done < <(compgen -W "projects $(_ultron_projects) $(_ultron_commands)" -- "$cur_word")
  elif [[ -n "${ULTRON_COMPLETIONS[$prev_arg]}" ]]; then
    while IFS= read -r line; do
      COMPREPLY+=("$line")
    done < <(compgen -W "${ULTRON_COMPLETIONS[$prev_arg]}" -- "$cur_word")
  else
    COMPREPLY=()
  fi
}
complete -F _ultron_completion ultron
