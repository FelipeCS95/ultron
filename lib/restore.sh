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
}
