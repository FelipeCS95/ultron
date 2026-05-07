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

_ultron_spin() {
  local title="$1"; shift
  if command -v gum &>/dev/null; then
    # Pre-autentica sudo antes do spinner suprimir o prompt de senha
    [[ "$1" == "sudo" ]] && sudo true
    gum spin --spinner dot --title "$title" -- "$@"
  else
    "$@"
  fi
}

_ultron_list_packages() {
  ls "$ULTRON_PATH/packages/"*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh//'

  local entry
  source "$ULTRON_PATH/config/apt.sh"
  for entry in "${APT_PACKAGES[@]}"; do echo "${entry%%:*}"; done

  source "$ULTRON_PATH/config/snap.sh"
  for entry in "${SNAP_PACKAGES[@]}"; do echo "${entry%%:*}"; done
}

ultron::install() {
  local pkg="$1"

  if [[ -z "$pkg" ]]; then
    command -v gum &>/dev/null || return 1
    pkg=$(_ultron_list_packages | sort -u \
      | gum filter --placeholder "buscar pacote..." --height 20) || return 0
  fi

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

      for dep in "${REQUIRED_PACKAGES[@]}"; do
        ultron::install "$dep"
      done

      ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
      _pkg_is_installed && echo "$pkg já instalado" || install  # alternativa ao if/then/else; ok pois echo raramente falha
    )
    return
  fi

  # 2. Lista apt
  local apt_name
  if apt_name=$(ultron::_apt_name_for "$pkg_name"); then
    ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
    if ultron::check_installed "$apt_name"; then
      echo "$pkg já instalado"
    else
      _ultron_spin "Instalando $pkg..." sudo apt-get install -y "$apt_name"
    fi
    return
  fi

  # 3. Lista snap
  local snap_name
  if snap_name=$(ultron::_snap_name_for "$pkg_name"); then
    ultron::print_title "INSTALL $(ultron::uppercase "$pkg")"
    _ultron_spin "Instalando $pkg..." sudo snap install "$snap_name"
    return
  fi

  echo "Pacote não encontrado: $pkg" >&2
  return 1
}
