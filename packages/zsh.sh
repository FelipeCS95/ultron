#!/bin/bash

PACKAGE_INFO=(zsh)

install() {
  _ultron_spin "Instalando zsh..." sudo apt-get install -y zsh
  sudo chsh -s "$(which zsh)" "$USER"
}
