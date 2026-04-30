#!/bin/bash

_ultron_commands() {
  grep -rhoE 'ultron::[a-zA-Z0-9_]+[[:space:]]*\(\)' "$ULTRON_PATH"/lib/*.sh \
    | sed 's/.*ultron:://; s/[[:space:]]*()//' \
    | grep -Ev '^(_|check_|print_|logo_title|uppercase|lowercase|normalize_|current_folder|import_functions|execute_function|restore_personal|change_files_owner|get_theme|bisect_)' \
    | sort -u
}

_ultron_projects() {
  find "$PROJECTS_PATH" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort | uniq
}

_ultron_completion() {
  local prev_arg="${COMP_WORDS[COMP_CWORD-1]}"
  local cur_word="${COMP_WORDS[COMP_CWORD]}"

  . "$ULTRON_PATH"/config/completions.sh

  COMPREPLY=()
  if [[ "$COMP_CWORD" == 1 ]]; then
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
complete -F _ultron_completion u
