#!/bin/bash

ultron::restore() {
  ultron::logo_title

  echo 'Restaurando pacotes...'

  source "$ULTRON_PATH/config/restore.sh"

  for pkg in "${RESTORE_PACKAGES[@]}"; do
    ultron::install "$pkg"
  done

  echo 'Pacotes restaurados!'
  echo 'Restaurando configs...'

  for pkg in "${RESTORE_CONFIGS[@]}"; do
    ultron::config "$pkg"
  done

  echo 'Configs restauradas!'

  local wong_setup="$PROJECTS_PATH/wong/setup.sh"
  if [[ -f "$wong_setup" ]]; then
    echo ''
    echo 'Restaurando configs pessoais (Wong)...'
    bash "$wong_setup"
  fi
}
