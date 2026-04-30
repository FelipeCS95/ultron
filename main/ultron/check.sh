#!/bin/bash

ultron::check_installed() {
  local pkg=$1
  dpkg --get-selections | grep -q "^${pkg}[[:space:]]*install$"
}

ultron::check_file() {
  [[ -f $1 ]]
}

ultron::check_directory() {
  [[ -d $1 ]]
}

ultron::check_file_content() {
  local file="$1"
  local substring="$2"

  ultron::check_file "$file" && grep -qF "$substring" "$file"
}

ultron::check_all_installed() {
  for pkg in "$@"; do
    ultron::check_installed "$pkg" || return 1
  done
}

ultron::check_any_installed() {
  for pkg in "$@"; do
    ultron::check_installed "$pkg" && return 0
  done
  return 1
}

ultron::check_function() {
  declare -f -F "$1" &> /dev/null
}
