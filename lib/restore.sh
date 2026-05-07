#!/bin/bash

_ultron_restore_packages() {
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    ultron::install "$pkg"
  done
}

_ultron_restore_configs() {
  local cfgs=("$@")
  for cfg in "${cfgs[@]}"; do
    ultron::config "$cfg"
  done
}

ultron::restore() {
  ultron::logo_title
  source "$ULTRON_PATH/config/restore.sh"

  if command -v gum &>/dev/null; then
    local pre_pkgs pre_cfgs all_pkgs all_cfgs selected_pkgs selected_cfgs

    pre_pkgs=$(printf '%s\n' "${RESTORE_PACKAGES[@]}" | paste -sd,)
    all_pkgs=$(_ultron_list_packages | sort -u)

    selected_pkgs=$(echo "$all_pkgs" | gum choose --no-limit \
      --selected="$pre_pkgs" \
      --header "Pacotes a instalar (SPACE seleciona · ENTER confirma)") || return 0

    # Packages que têm config()
    all_cfgs=$(grep -rl "^config()" "$ULTRON_PATH/packages/"*.sh \
      | xargs -n1 basename | sed 's/\.sh//' | sort)
    pre_cfgs=$(printf '%s\n' "${RESTORE_CONFIGS[@]}" | paste -sd,)

    selected_cfgs=$(echo "$all_cfgs" | gum choose --no-limit \
      --selected="$pre_cfgs" \
      --header "Configs a aplicar após instalar") || true

    echo 'Restaurando pacotes...'
    while IFS= read -r pkg; do
      [[ -z "$pkg" ]] && continue
      ultron::install "$pkg"
    done <<< "$selected_pkgs"

    echo 'Restaurando configs...'
    while IFS= read -r cfg; do
      [[ -z "$cfg" ]] && continue
      ultron::config "$cfg"
    done <<< "$selected_cfgs"
  else
    echo 'Restaurando pacotes...'
    _ultron_restore_packages "${RESTORE_PACKAGES[@]}"
    echo 'Restaurando configs...'
    _ultron_restore_configs "${RESTORE_CONFIGS[@]}"
  fi

  ultron::restore_personal
}
