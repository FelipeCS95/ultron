#!/bin/bash

ultron::setup() {
  ultron::logo_title

  echo 'Iniciando setup...'
  sudo apt update

  source "$ULTRON_PATH/config/setup.sh"

  for pkg in "${SETUP_DEPENDENCIES[@]}"; do
    ultron::install "$pkg"
  done

  for pkg in "${SETUP_PACKAGES[@]}"; do
    ultron::install "$pkg"
  done

  for pkg in "${SETUP_CONFIGS[@]}"; do
    ultron::config "$pkg"
  done

  echo 'Setup concluído!'
  echo 'Faça logout ou execute: gnome-session-quit'
}
