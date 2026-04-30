#!/bin/bash

ultron::config() {
  local pkg="$1"
  [[ -z "$pkg" ]] && return 1

  local pkg_name
  pkg_name=$(ultron::lowercase "$pkg" | sed 's/-/_/g')
  local pkg_file="$ULTRON_PATH/packages/${pkg_name}.sh"

  if [[ ! -f "$pkg_file" ]]; then
    echo "Package not found: $pkg" >&2
    return 1
  fi

  (
    source "$pkg_file"

    ultron::print_title "CONFIG $(ultron::uppercase "$pkg")"

    if declare -f config &>/dev/null; then
      config
    else
      echo "No config function for $pkg" >&2
    fi
  )
}
