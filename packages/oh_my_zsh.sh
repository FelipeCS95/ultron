#!/bin/bash

PACKAGE_INFO=(~/.oh-my-zsh)
PACKAGE_KIND=directory
REQUIRED_PACKAGES=(zsh)

install() {
  # RUNZSH=no: não inicia zsh ao terminar, deixa o setup continuar
  # CHSH=no: não muda o shell padrão (já feito pelo zsh.sh)
  RUNZSH=no CHSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
