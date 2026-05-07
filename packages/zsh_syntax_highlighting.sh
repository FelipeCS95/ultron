#!/bin/bash

# Destaca comandos válidos em verde e inválidos em vermelho enquanto digita
PACKAGE_INFO=(~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting)
PACKAGE_KIND=directory
REQUIRED_PACKAGES=(oh_my_zsh)

install() {
  _ultron_spin "Clonando zsh-syntax-highlighting..." \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
}

config() {
  if ! ultron::check_file_content ~/.zshrc 'zsh-syntax-highlighting'; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
    echo "  zsh-syntax-highlighting adicionado aos plugins"
  fi
}
