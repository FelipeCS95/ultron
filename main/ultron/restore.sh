#!/bin/bash

ultron::restore() {
  ultron::logo_title

  echo 'Restoring packages...'

  source "$ULTRON_PATH/config/restore/packages.sh"
  for pkg in "${RESTORE_PACKAGES[@]}"; do
    ultron::install "$pkg"
  done

  echo 'Packages restored!'

  echo 'Restoring configs...'

  source "$ULTRON_PATH/config/restore/configs.sh"
  for pkg in "${RESTORE_CONFIGS[@]}"; do
    ultron::config "$pkg"
  done

  echo 'Configs restored!'
}
