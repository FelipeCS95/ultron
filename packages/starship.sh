#!/bin/bash

PACKAGE_INFO=(starship)

install() {
  mkdir -p ~/.local/bin
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir ~/.local/bin
}

config() {
  local wong="$PROJECTS_PATH/wong"

  if ultron::check_file "$wong/configs/starship/starship.toml"; then
    mkdir -p ~/.config
    cp "$wong/configs/starship/starship.toml" ~/.config/starship.toml
    echo "  starship.toml restaurado do Wong"
  fi

  if ! ultron::check_file_content ~/.zshrc 'starship init zsh'; then
    printf '\neval "$(starship init zsh)"\n' >> ~/.zshrc
    echo "  starship init adicionado ao .zshrc"
  fi
}
