#!/bin/bash

ultron::remove() {
  local pkg="$1"
  [[ -z "$pkg" ]] && return 1

  local pkg_name
  pkg_name=$(_pkg_normalize "$pkg")
  local pkg_file="$ULTRON_PATH/packages/${pkg_name}.sh"

  if [[ ! -f "$pkg_file" ]]; then
    echo "Package not found: $pkg" >&2
    return 1
  fi

  (
    PACKAGE_INFO=("$pkg_name")
    PACKAGE_KIND=pkg
    REQUIRED_PACKAGES=()

    source "$pkg_file"

    ultron::print_title "REMOVE $(ultron::uppercase "$pkg")"

    if ! _pkg_is_installed any; then
      echo "$pkg not installed"
    elif declare -f remove &>/dev/null; then
      remove
    else
      echo "No remove function for $pkg" >&2
    fi
  )
}
