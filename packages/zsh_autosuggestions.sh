#!/bin/bash

PACKAGE_INFO=(~/.oh-my-zsh/custom/plugins/zsh-autosuggestions)
PACKAGE_KIND=directory
REQUIRED_PACKAGES=(oh_my_zsh)

install() {
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
}

config() {
  if ! ultron::check_file_content ~/.zshrc 'zsh-autosuggestions'; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' ~/.zshrc
    echo "  zsh-autosuggestions adicionado aos plugins"
  fi
}
