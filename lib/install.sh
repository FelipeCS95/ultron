#!/bin/bash

ultron::_apt_name_for() {
  local key="$1"
  local entry
  source "$ULTRON_PATH/config/apt.sh"
  for entry in "${APT_PACKAGES[@]}"; do
    local entry_key="${entry%%:*}"
    if [[ "$entry_key" == "$key" ]]; then
      [[ "$entry" == *":"* ]] && echo "${entry#*:}" || echo "${key//_/-}"
      return 0
    fi
  done
  return 1
}

ultron::_snap_name_for() {
  local key="$1"
  local entry
  source "$ULTRON_PATH/config/snap.sh"
  for entry in "${SNAP_PACKAGES[@]}"; do
    local entry_key="${entry%%:*}"
    if [[ "$entry_key" == "$key" ]]; then
      [[ "$entry" == *":"* ]] && echo "${entry#*:}" || echo "$key"
      return 0
    fi
  done
  return 1
}

ultron::install() {
  local pkg="$1"
  [[ -z "$pkg" ]] && return 1

  local pkg_name
  pkg_name=$(ultron::lowercase "$pkg" | sed 's/-/_/g')
  local pkg_file="$ULTRON_PATH/packages/${pkg_name}.sh"

  # 1. Arquivo dedicado com lógica própria
  if [[ -f "$pkg_file" ]]; then
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
        file)      ultron::check_file "${PACKAGE_INFO[*]}"          && is_installed=true ;;
        directory) ultron::check_directory "${PACKAGE_INFO[*]}"     && is_installed=true ;;
        *)         ultron::check_all_installed "${PACKAGE_INFO[@]}"  && is_installed=true ;;
      esac

      ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
      $is_installed && echo "$pkg already installed" || install
    )
    return
  fi

  # 2. Lista apt
  local apt_name
  if apt_name=$(ultron::_apt_name_for "$pkg_name"); then
    ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
    ultron::check_installed "$apt_name" \
      && echo "$pkg already installed" \
      || sudo apt-get install -y "$apt_name"
    return
  fi

  # 3. Lista snap
  local snap_name
  if snap_name=$(ultron::_snap_name_for "$pkg_name"); then
    ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
    sudo snap install "$snap_name"
    return
  fi

  echo "Pacote não encontrado: $pkg" >&2
  return 1
}
