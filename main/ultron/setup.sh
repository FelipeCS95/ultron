#!/bin/bash

ultron::setup() {
  ultron::logo_title

  echo 'Starting setup...'
  sudo apt update

  source "$ULTRON_PATH/config/setup/dependencies.sh"
  for pkg in "${SETUP_DEPENDENCIES[@]}"; do
    ultron::install "$pkg"
  done

  source "$ULTRON_PATH/config/setup/packages.sh"
  for pkg in "${SETUP_PACKAGES[@]}"; do
    ultron::install "$pkg"
  done

  source "$ULTRON_PATH/config/setup/configs.sh"
  for pkg in "${SETUP_CONFIGS[@]}"; do
    ultron::config "$pkg"
  done

  echo 'Setup complete!'
  echo 'Please logout or run: gnome-session-quit'
}
