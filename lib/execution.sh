#!/bin/bash

ultron::current_folder() {
  basename "$PWD"
}

ultron::import_functions() {
  local directory="$ULTRON_PATH/projects/$1"
  ultron::check_directory "$directory" || return

  ultron::check_file "$directory.sh" && . "$directory.sh"

  for i in "$directory"/*.sh; do
    [[ -f "$i" ]] && . "$i"
  done
}

ultron::execute_function() {
  local folder_name
  folder_name=$(ultron::current_folder)
  local project_name
  project_name=$(ultron::normalize_project_name "$folder_name")
  local cmd="$1"; shift

  # Funções do próprio ultron já estão carregadas — reimportar causaria recursão
  if [[ "$project_name" != "ultron" ]]; then
    ultron::import_functions "$project_name"
  fi

  local function_name="${project_name}::${cmd}"
  local ultron_function="ultron::${cmd}"

  if ultron::check_function "$function_name"; then
    "$function_name" "$@"
  elif ultron::check_function "$ultron_function"; then
    "$ultron_function" "$@"
  else
    echo "Comando não encontrado: $cmd" >&2
    return 127
  fi
}
