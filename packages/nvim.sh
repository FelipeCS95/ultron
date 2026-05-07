#!/bin/bash

PACKAGE_INFO=(nvim)
REQUIRED_PACKAGES=(lazygit nerd_fonts)

install() {
  sudo add-apt-repository ppa:neovim-ppa/unstable -y
  sudo apt update
  sudo apt install -y neovim

  # LazyVIM starter — só instala se não houver config própria
  if [[ ! -d ~/.config/nvim ]]; then
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    echo "LazyVIM instalado. Abra 'nvim' para baixar os plugins."
  else
    echo "~/.config/nvim já existe — LazyVIM starter não aplicado."
  fi

  # fd é esperado pelo Telescope; fd-find instala como fdfind
  mkdir -p ~/.local/bin
  command -v fdfind &>/dev/null && ln -sf "$(which fdfind)" ~/.local/bin/fd || true
}

config() {
  local wong="$PROJECTS_PATH/wong"
  if [[ -d "$wong/configs/nvim" ]]; then
    mkdir -p ~/.config/nvim
    cp -r "$wong/configs/nvim/." ~/.config/nvim/
    echo "  nvim config restaurada do Wong"
  fi
}
