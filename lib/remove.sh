#!/bin/bash

ultron::remove() {
  local pkg="$1"
  [[ -z "$pkg" ]] && return 1

  local pkg_name
  pkg_name=$(_pkg_normalize "$pkg")
  local pkg_file="$ULTRON_PATH/packages/${pkg_name}.sh"

  # 1. Arquivo dedicado com lógica própria
  if [[ -f "$pkg_file" ]]; then
    (
      PACKAGE_INFO=("$pkg_name")
      PACKAGE_KIND=pkg
      REQUIRED_PACKAGES=()

      source "$pkg_file"

      ultron::print_title "REMOVE $(ultron::uppercase "$pkg")"

      if ! _pkg_is_installed any; then
        echo "$pkg não instalado"
      elif declare -f remove &>/dev/null; then
        remove
      else
        echo "Nenhuma função remove para $pkg" >&2
      fi
    )
    return
  fi

  # 2. Lista apt
  local apt_name
  if apt_name=$(ultron::_apt_name_for "$pkg_name"); then
    ultron::print_title "REMOVE $(ultron::uppercase "$pkg")"
    ultron::check_installed "$apt_name" \
      || { echo "$pkg não instalado"; return 0; }
    sudo apt-get remove -y "$apt_name"
    return
  fi

  # 3. Lista snap
  local snap_name
  if snap_name=$(ultron::_snap_name_for "$pkg_name"); then
    ultron::print_title "REMOVE $(ultron::uppercase "$pkg")"
    sudo snap remove "$snap_name"
    return
  fi

  echo "Pacote não encontrado: $pkg" >&2
  return 1
}
