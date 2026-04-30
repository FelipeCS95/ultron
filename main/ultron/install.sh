#!/bin/bash

ultron::install() {
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
    PACKAGE_INFO=("$pkg_name")
    PACKAGE_KIND=pkg
    REQUIRED_PACKAGES=()

    source "$pkg_file"

    for dep in "${REQUIRED_PACKAGES[@]}"; do
      ultron::install "$dep"
    done

    local is_installed=false
    case "$PACKAGE_KIND" in
      file)      ultron::check_file "${PACKAGE_INFO[*]}" && is_installed=true ;;
      directory) ultron::check_directory "${PACKAGE_INFO[*]}" && is_installed=true ;;
      *)         ultron::check_all_installed "${PACKAGE_INFO[@]}" && is_installed=true ;;
    esac

    ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"

    if $is_installed; then
      echo "$pkg already installed"
    else
      install
    fi
  )
}
