#!/bin/bash

# JetBrains Mono Nerd Font — necessária para ícones no NeoVIM/LazyVIM e Starship
PACKAGE_INFO=(~/.local/share/fonts/NerdFonts)
PACKAGE_KIND=directory

install() {
  local font="JetBrainsMono"
  local version="v3.2.1"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font}.zip"
  local tmp
  tmp=$(mktemp -d)

  _ultron_spin "Baixando ${font} Nerd Font ${version}..." curl -L "$url" -o "$tmp/${font}.zip"
  _ultron_spin "Extraindo fontes..." unzip -q "$tmp/${font}.zip" -d "$tmp/${font}"

  mkdir -p ~/.local/share/fonts/NerdFonts
  find "$tmp/${font}" -name "*.ttf" -exec cp {} ~/.local/share/fonts/NerdFonts/ \;
  find "$tmp/${font}" -name "*.otf" -exec cp {} ~/.local/share/fonts/NerdFonts/ \;

  fc-cache -fv
  rm -rf "$tmp"

  echo "Fonte instalada. Configure 'JetBrainsMono Nerd Font' no seu terminal."
}
