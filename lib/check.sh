#!/bin/bash

ultron::check_installed() {
  local pkg=$1
  dpkg --get-selections 2>/dev/null | grep -q "^${pkg}[[:space:]]*install$" \
    || command -v "$pkg" &>/dev/null
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

# Verifica se um pacote está instalado com base em PACKAGE_KIND e PACKAGE_INFO,
# que devem estar setados no subshell chamador (via source do package file).
# $1: modo de verificação — "all" (padrão, install) ou "any" (remove)
_pkg_is_installed() {
  local check_mode="${1:-all}"
  case "$PACKAGE_KIND" in
    file)      ultron::check_file "${PACKAGE_INFO[*]}" ;;
    directory) ultron::check_directory "${PACKAGE_INFO[*]}" ;;
    *)
      if [[ "$check_mode" == "any" ]]; then
        ultron::check_any_installed "${PACKAGE_INFO[@]}"
      else
        ultron::check_all_installed "${PACKAGE_INFO[@]}"
      fi
      ;;
  esac
}
