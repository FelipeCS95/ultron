#!/bin/bash

PACKAGE_INFO=(tmux)

install() {
  _ultron_spin "Instalando tmux..." sudo apt install -y tmux
}

config() {
  local wong="$PROJECTS_PATH/wong"
  if ultron::check_file "$wong/dotfiles/.tmux.conf"; then
    cp "$wong/dotfiles/.tmux.conf" ~/
    echo "  .tmux.conf restaurado do Wong"
  fi
}
